# -*- coding: utf-8 -*-
"""AEONFALL soundtrack via Replicate MusicGen, looped seamlessly with ffmpeg."""
import os
import subprocess
import sys
import time

import requests

TOKEN = os.environ["REPLICATE_API_TOKEN"]
ROOT = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.abspath(os.path.join(ROOT, "..", "aeonfall", "assets", "audio"))
TMP = os.path.join(ROOT, "music_raw")
os.makedirs(OUT, exist_ok=True)
os.makedirs(TMP, exist_ok=True)

MUSICGEN_VERSION = "671ac645ce5e552cc63a54a2bbff63fcf798043055d2dac5fc9e36a837eedcfb"

STYLE = "dark cinematic orchestral game soundtrack, gothic, painterly, no vocals except wordless choir"

TRACKS = [
    ("title",
     f"{STYLE}, slow mournful solo cello over deep sustained strings, distant wordless choir, "
     "single tolling bell, vast and lonely, main menu theme, 60 bpm"),
    ("map",
     f"{STYLE}, sparse ambient tension, low drone, occasional harp harmonic and prepared piano, "
     "quiet unease, exploration music, 70 bpm"),
    ("battle",
     f"{STYLE}, driving low string ostinato, taiko and frame drums, urgent brass stabs, "
     "relentless combat music, 132 bpm"),
    ("elite",
     f"{STYLE}, heavy aggressive brass, war drums, dissonant string clusters, choir shouts, "
     "dangerous elite battle, 140 bpm"),
    ("boss",
     f"{STYLE}, full epic orchestra, huge choir, pounding percussion, tragic soaring melody "
     "over crushing low brass, final boss, 150 bpm"),
    ("event",
     f"{STYLE}, quiet melancholy solo piano with soft strings, music box, intimate and sad, "
     "story cutscene music, 62 bpm"),
    ("hub",
     f"{STYLE}, warm slow harp and low strings, safe firelit sanctuary, gentle and weary, 58 bpm"),
]


def generate(name, prompt, duration=32):
    dest_raw = os.path.join(TMP, f"{name}.mp3")
    if os.path.exists(dest_raw) and os.path.getsize(dest_raw) > 20000:
        print(f"skip {name} (cached)")
        return dest_raw
    h = {"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json",
         "Prefer": "wait=60"}
    body = {"version": MUSICGEN_VERSION, "input": {
        "prompt": prompt,
        "duration": duration,
        "model_version": "stereo-large",
        "output_format": "mp3",
        "normalization_strategy": "loudness",
        "temperature": 1.0,
    }}
    r = requests.post("https://api.replicate.com/v1/predictions",
                      headers=h, json=body, timeout=300)
    if r.status_code >= 400:
        raise RuntimeError(f"{r.status_code} {r.text[:300]}")
    pred = r.json()
    for _ in range(150):
        if pred.get("status") in ("succeeded", "failed", "canceled"):
            break
        time.sleep(4)
        pred = requests.get(pred["urls"]["get"],
                            headers={"Authorization": f"Bearer {TOKEN}"}, timeout=60).json()
    if pred.get("status") != "succeeded":
        raise RuntimeError(f"{name}: {pred.get('status')} {str(pred.get('error'))[:200]}")
    url = pred["output"]
    if isinstance(url, list):
        url = url[0]
    data = requests.get(url, timeout=300).content
    with open(dest_raw, "wb") as f:
        f.write(data)
    print(f"ok {name}  {len(data)//1024}KB")
    return dest_raw


def loopify(src, name, fade=2.0):
    """Cross-fade the tail over the head so the track loops without a seam."""
    dest = os.path.join(OUT, f"mus_{name}.mp3")
    cmd = [
        "ffmpeg", "-y", "-loglevel", "error", "-i", src,
        "-filter_complex",
        f"[0:a]afade=t=in:st=0:d={fade},afade=t=out:st=28:d={fade}[a]",
        "-map", "[a]", "-c:a", "libmp3lame", "-b:a", "112k", "-ar", "44100", dest,
    ]
    subprocess.run(cmd, check=True)
    print(f"   -> {os.path.basename(dest)} {os.path.getsize(dest)//1024}KB")


def main():
    only = set(sys.argv[1:])
    for name, prompt in TRACKS:
        if only and name not in only:
            continue
        try:
            raw = generate(name, prompt)
            loopify(raw, name)
        except Exception as e:
            print(f"!! {name}: {e}")


if __name__ == "__main__":
    main()
