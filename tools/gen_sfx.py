# -*- coding: utf-8 -*-
"""Procedural SFX for AEONFALL. Pure numpy synthesis -> mp3 via ffmpeg."""
import os
import subprocess
import wave

import numpy as np

SR = 44100
ROOT = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.abspath(os.path.join(ROOT, "..", "aeonfall", "assets", "audio"))
TMP = os.path.join(ROOT, "sfx_raw")
os.makedirs(OUT, exist_ok=True)
os.makedirs(TMP, exist_ok=True)

rng = np.random.default_rng(7)


def t(dur):
    return np.linspace(0, dur, int(SR * dur), endpoint=False)


def env(n, a=.005, d=.25, curve=3.0):
    at = max(1, int(SR * a))
    e = np.ones(n)
    e[:at] = np.linspace(0, 1, at)
    rest = n - at
    if rest > 0:
        e[at:] = np.linspace(1, 0, rest) ** curve
    return e


def noise(dur):
    return rng.uniform(-1, 1, int(SR * dur))


def sine(f, dur, phase=0.0):
    return np.sin(2 * np.pi * f * t(dur) + phase)


def sweep(f0, f1, dur, kind="exp"):
    x = t(dur)
    if kind == "exp":
        f = f0 * (f1 / f0) ** (x / dur)
    else:
        f = np.linspace(f0, f1, len(x))
    return np.sin(2 * np.pi * np.cumsum(f) / SR)


def lowpass(x, cutoff):
    """One-pole low-pass — cheap and plenty for SFX."""
    a = np.exp(-2 * np.pi * cutoff / SR)
    y = np.zeros_like(x)
    acc = 0.0
    for i in range(len(x)):
        acc = (1 - a) * x[i] + a * acc
        y[i] = acc
    return y


def hipass(x, cutoff):
    return x - lowpass(x, cutoff)


def fit(x, n):
    return x[:n] if len(x) >= n else np.concatenate([x, np.zeros(n - len(x))])


def mix(*parts):
    """Sum signals of differing lengths by zero-padding to the longest."""
    n = max(len(p) for p in parts)
    return sum(fit(p, n) for p in parts)


def place(buf, seg, offset):
    """Add [seg] into [buf] at sample [offset], clipped to the buffer."""
    i = int(offset)
    end = min(len(buf), i + len(seg))
    if end > i:
        buf[i:end] += seg[: end - i]
    return buf


def norm(x, peak=.85):
    m = np.max(np.abs(x)) or 1.0
    return x / m * peak


def save(name, mono, stereo_spread=.0):
    mono = norm(np.nan_to_num(mono))
    if stereo_spread > 0:
        delay = int(SR * stereo_spread)
        left = np.concatenate([mono, np.zeros(delay)])
        right = np.concatenate([np.zeros(delay), mono])
        data = np.stack([left, right], axis=1)
    else:
        data = np.stack([mono, mono], axis=1)
    pcm = (np.clip(data, -1, 1) * 32000).astype(np.int16)
    wav = os.path.join(TMP, f"{name}.wav")
    with wave.open(wav, "wb") as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(pcm.tobytes())
    mp3 = os.path.join(OUT, f"sfx_{name}.mp3")
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", wav,
                    "-c:a", "libmp3lame", "-b:a", "96k", mp3], check=True)
    print(f"{name:16s} {os.path.getsize(mp3)//1024}KB")


# ------------------------------------------------------------------ library
def build():
    # --- UI ---------------------------------------------------------
    x = mix(sine(880, .09) * env(int(SR * .09), .001, .09) * .5,
            sine(1320, .07) * env(int(SR * .07), .001, .07) * .25)
    save("tap", x)

    x = np.concatenate([
        sine(520, .06) * env(int(SR * .06), .001, .06),
        sine(780, .14) * env(int(SR * .14), .002, .14),
    ])
    save("confirm", x * .7)

    save("back", sweep(700, 300, .13) * env(int(SR * .13), .002, .13) * .6)

    # --- cards ------------------------------------------------------
    n = hipass(noise(.16), 2600) * env(int(SR * .16), .002, .16, 2.0)
    save("draw", n * .55, stereo_spread=.004)

    n = hipass(noise(.10), 1800) * env(int(SR * .10), .001, .10)
    n += sine(400, .10) * env(int(SR * .10), .001, .10) * .4
    save("play", n * .7)

    # --- impacts ----------------------------------------------------
    d = .22
    x = lowpass(noise(d), 2200) * env(int(SR * d), .001, d, 2.4)
    x += sweep(220, 60, d) * env(int(SR * d), .001, d, 2.0) * .8
    save("hit_light", x)

    d = .45
    x = lowpass(noise(d), 1200) * env(int(SR * d), .001, d, 1.8)
    x += sweep(140, 38, d) * env(int(SR * d), .001, d, 1.4) * 1.2
    x += sine(70, d) * env(int(SR * d), .001, d, 1.2) * .8
    save("hit_heavy", x, stereo_spread=.006)

    d = .3
    x = lowpass(noise(d), 900) * env(int(SR * d), .004, d, 2.2) * .7
    x += sine(180, d) * env(int(SR * d), .004, d, 2.0) * .6
    save("block", x)

    d = .8
    x = sine(660, d) * env(int(SR * d), .06, d, 1.6) * .5
    x += sine(990, d) * env(int(SR * d), .10, d, 1.6) * .3
    x += hipass(noise(d), 5000) * env(int(SR * d), .05, d, 2.5) * .15
    save("heal", x, stereo_spread=.008)

    # --- elements ---------------------------------------------------
    d = .7
    x = lowpass(noise(d), 1600) * env(int(SR * d), .02, d, 1.6)
    x *= (1 + .3 * np.sin(2 * np.pi * 7 * t(d)))
    save("ember", x * .8, stereo_spread=.01)

    d = .55
    x = hipass(noise(d), 4500) * env(int(SR * d), .004, d, 2.6)
    x += sweep(2400, 700, d) * env(int(SR * d), .004, d, 2.2) * .5
    save("frost", x * .8, stereo_spread=.008)

    d = .35
    x = hipass(noise(d), 3000) * env(int(SR * d), .0008, d, 3.2)
    crackle = (rng.uniform(0, 1, len(x)) > .988).astype(float)
    x += crackle * rng.uniform(-1, 1, len(x)) * .9
    x = hipass(x, 1500)
    save("volt", x * .85, stereo_spread=.005)

    d = .8
    x = lowpass(noise(d), 500) * env(int(SR * d), .05, d, 1.4)
    x += sweep(190, 45, d) * env(int(SR * d), .05, d, 1.3) * .8
    save("umbra", x * .8, stereo_spread=.012)

    d = .9
    x = sum(sine(f, d) * env(int(SR * d), .02 + i * .01, d, 1.5) * (0.5 ** i)
            for i, f in enumerate([880, 1320, 1760, 2640]))
    save("lumen", x * .6, stereo_spread=.01)

    # --- big moments ------------------------------------------------
    d = 1.5
    x = sweep(80, 1400, .5, "lin")
    x = np.concatenate([x, np.zeros(int(SR * (d - .5)))])
    boom = lowpass(noise(d), 900) * env(int(SR * d), .001, d, 1.6)
    bell = sum(sine(f, d) * env(int(SR * d), .002, d, 1.3) * (0.6 ** i)
               for i, f in enumerate([1320, 1980, 2640]))
    save("reaction", mix(x * env(len(x), .01, .5, 1.2) * .7, boom, bell * .45),
         stereo_spread=.014)

    d = 2.2
    sub = sweep(60, 30, d, "lin") * env(int(SR * d), .002, d, 1.1) * 1.3
    hit = lowpass(noise(d), 700) * env(int(SR * d), .001, d, 1.5)
    choir = sum(sine(f, d) * env(int(SR * d), .25, d, .9) * (0.55 ** i)
                for i, f in enumerate([220, 330, 440, 660]))
    save("cinematic", mix(sub, hit, choir * .5), stereo_spread=.02)

    d = .9
    x = sweep(400, 40, d) * env(int(SR * d), .002, d, 1.5)
    x += lowpass(noise(d), 700) * env(int(SR * d), .002, d, 2.2) * .8
    save("death", x, stereo_spread=.01)

    # --- stings -----------------------------------------------------
    notes = [(523, 0), (659, .13), (784, .26), (1047, .40)]
    total = 1.9
    x = np.zeros(int(SR * total))
    for f, off in notes:
        seg = mix(sine(f, total - off) * env(int(SR * (total - off)), .006, total - off, 1.2),
                  sine(f * 2, total - off) * env(int(SR * (total - off)), .01, total - off, 1.4) * .3)
        place(x, seg * .55, SR * off)
    save("victory", x, stereo_spread=.012)

    notes = [(392, 0), (330, .22), (262, .45), (196, .72)]
    total = 2.6
    x = np.zeros(int(SR * total))
    for f, off in notes:
        seg = sine(f, total - off) * env(int(SR * (total - off)), .02, total - off, 1.1)
        place(x, seg * .6, SR * off)
    x = mix(x, lowpass(noise(total), 300) * env(int(SR * total), .3, total, 1.0) * .25)
    save("defeat", x, stereo_spread=.016)

    # --- misc -------------------------------------------------------
    x = np.concatenate([sine(1568, .05) * env(int(SR * .05), .001, .05),
                        sine(2093, .16) * env(int(SR * .16), .001, .16)])
    save("coin", x * .55)

    d = 1.1
    x = sum(sine(f, d) * env(int(SR * d), .01, d, 1.2) * (0.6 ** i)
            for i, f in enumerate([392, 587, 784, 1175]))
    x += hipass(noise(d), 6000) * env(int(SR * d), .005, d, 3.0) * .2
    save("relic", x * .7, stereo_spread=.01)

    n = hipass(noise(.35), 2200) * env(int(SR * .35), .01, .35, 1.8)
    save("page", n * .5, stereo_spread=.006)

    d = .5
    x = sweep(120, 900, d) * env(int(SR * d), .01, d, 1.3) * .7
    x += hipass(noise(d), 3500) * env(int(SR * d), .01, d, 2.0) * .3
    save("levelup", x, stereo_spread=.01)


if __name__ == "__main__":
    build()
    print("done ->", OUT)
