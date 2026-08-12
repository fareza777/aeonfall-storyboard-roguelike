# -*- coding: utf-8 -*-
"""Parallel, resumable Replicate art generator for AEONFALL.

Usage:  python gen_art.py [group ...]
Writes raw output to raw/<key>.webp and never regenerates an existing file.
"""
import io
import os
import sys
import json
import time
import threading
from concurrent.futures import ThreadPoolExecutor

import requests
from PIL import Image

from manifest import ASSETS

try:
    from manifest_extra import EXTRA
    ASSETS = ASSETS + EXTRA
except ImportError:
    pass

try:
    from manifest_v2 import V2
    ASSETS = ASSETS + V2
except ImportError:
    pass

TOKEN = os.environ.get("REPLICATE_API_TOKEN", "").strip()
if not TOKEN:
    sys.exit("REPLICATE_API_TOKEN not set")

ROOT = os.path.dirname(os.path.abspath(__file__))
RAW = os.path.join(ROOT, "raw")
OUT = os.path.abspath(os.path.join(ROOT, "..", "aeonfall", "assets", "img"))
LOG = os.path.join(ROOT, "gen_log.jsonl")

MODEL_PATH = {
    "flux-1.1-pro": "black-forest-labs/flux-1.1-pro",
    "flux-dev": "black-forest-labs/flux-dev",
    "flux-schnell": "black-forest-labs/flux-schnell",
}

# target long-edge in px per group, keeps the APK small without looking soft
SIZE = {
    "brand": 1280, "biome": 1280, "event": 1280, "boss": 900, "elite": 800,
    "vessel": 900, "enemy": 640, "card": 512, "relic": 256, "crest": 256,
    "potion": 256,
}

_lock = threading.Lock()
_done = 0
_fail = []


def payload(asset):
    m, p, ar = asset["model"], asset["prompt"], asset["ar"]
    if m == "flux-1.1-pro":
        return {"prompt": p, "aspect_ratio": ar, "output_format": "webp",
                "output_quality": 92, "safety_tolerance": 5, "prompt_upsampling": False}
    if m == "flux-dev":
        return {"prompt": p, "aspect_ratio": ar, "output_format": "webp",
                "output_quality": 92, "num_outputs": 1, "go_fast": False,
                "guidance": 3.2, "num_inference_steps": 32,
                "disable_safety_checker": True}
    return {"prompt": p, "aspect_ratio": ar, "output_format": "webp",
            "output_quality": 92, "num_outputs": 1, "go_fast": True,
            "disable_safety_checker": True}


def call(asset, model):
    url = f"https://api.replicate.com/v1/models/{MODEL_PATH[model]}/predictions"
    h = {"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json",
         "Prefer": "wait=60"}
    r = requests.post(url, headers=h,
                      json={"input": payload(dict(asset, model=model))}, timeout=180)
    if r.status_code >= 400:
        raise RuntimeError(f"{r.status_code} {r.text[:220]}")
    pred = r.json()
    # poll if the sync wait timed out
    for _ in range(90):
        if pred.get("status") in ("succeeded", "failed", "canceled"):
            break
        time.sleep(2)
        pred = requests.get(pred["urls"]["get"],
                            headers={"Authorization": f"Bearer {TOKEN}"},
                            timeout=60).json()
    if pred.get("status") != "succeeded":
        raise RuntimeError(f"status={pred.get('status')} err={str(pred.get('error'))[:200]}")
    out = pred["output"]
    return out[0] if isinstance(out, list) else out


def process(asset):
    global _done
    key = asset["key"]
    dest = os.path.join(OUT, key.replace("/", "_") + ".webp")
    if os.path.exists(dest) and os.path.getsize(dest) > 2000:
        with _lock:
            _done += 1
        return

    chain = [asset["model"]]
    if asset["model"] == "flux-1.1-pro":
        chain.append("flux-dev")
    chain.append("flux-schnell")

    last = None
    for model in chain:
        for attempt in range(2):
            try:
                link = call(asset, model)
                img_bytes = requests.get(link, timeout=180).content
                im = Image.open(io.BytesIO(img_bytes)).convert("RGB")
                target = SIZE.get(asset["group"], 768)
                if max(im.size) > target:
                    ratio = target / max(im.size)
                    im = im.resize((max(1, int(im.width * ratio)),
                                    max(1, int(im.height * ratio))), Image.LANCZOS)
                os.makedirs(os.path.dirname(dest), exist_ok=True)
                im.save(dest, "WEBP", quality=86, method=6)
                with _lock:
                    _done += 1
                    with open(LOG, "a", encoding="utf-8") as f:
                        f.write(json.dumps({"key": key, "model": model,
                                            "bytes": os.path.getsize(dest)}) + "\n")
                    print(f"[{_done}] ok {key} <{model}> {os.path.getsize(dest)//1024}KB",
                          flush=True)
                return
            except Exception as e:
                last = e
                cool = float(os.environ.get("AE_COOLDOWN", "0"))
                time.sleep(max(1.5 + attempt * 2, cool))
    with _lock:
        _fail.append((key, str(last)[:200]))
        print(f"!! FAIL {key}: {last}", flush=True)


def main():
    groups = set(sys.argv[1:])
    work = [x for x in ASSETS if not groups or x["group"] in groups]
    os.makedirs(OUT, exist_ok=True)
    print(f"generating {len(work)} assets -> {OUT}", flush=True)
    workers = int(os.environ.get("AE_WORKERS", "8"))
    with ThreadPoolExecutor(max_workers=workers) as ex:
        list(ex.map(process, work))
    print(f"\nDONE ok={_done} fail={len(_fail)}", flush=True)
    for k, e in _fail:
        print("  ", k, e, flush=True)


if __name__ == "__main__":
    main()
