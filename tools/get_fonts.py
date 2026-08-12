# -*- coding: utf-8 -*-
"""Download and validate the two UI fonts. Refuses to write a non-sfnt file."""
import os

import requests

ROOT = os.path.dirname(os.path.abspath(__file__))
DEST = os.path.abspath(os.path.join(ROOT, "..", "aeonfall", "assets", "fonts"))
os.makedirs(DEST, exist_ok=True)

SFNT = (b"\x00\x01\x00\x00", b"OTTO", b"true", b"ttcf")

SOURCES = {
    "Cinzel.ttf": [
        "https://raw.githubusercontent.com/google/fonts/main/ofl/cinzel/Cinzel%5Bwght%5D.ttf",
        "https://cdn.jsdelivr.net/gh/google/fonts@main/ofl/cinzel/Cinzel%5Bwght%5D.ttf",
        "https://raw.githubusercontent.com/google/fonts/main/ofl/cinzel/static/Cinzel-Bold.ttf",
    ],
    "Inter.ttf": [
        "https://raw.githubusercontent.com/google/fonts/main/ofl/inter/Inter%5Bopsz,wght%5D.ttf",
        "https://cdn.jsdelivr.net/gh/google/fonts@main/ofl/inter/Inter%5Bopsz,wght%5D.ttf",
        "https://raw.githubusercontent.com/google/fonts/main/ofl/inter/static/Inter-Regular.ttf",
    ],
}


def main():
    for name, urls in SOURCES.items():
        for url in urls:
            try:
                r = requests.get(url, timeout=120)
                if r.status_code != 200:
                    print(f"  {r.status_code} {url}")
                    continue
                head = r.content[:4]
                if head not in SFNT:
                    print(f"  not a font ({head!r}) {url}")
                    continue
                with open(os.path.join(DEST, name), "wb") as f:
                    f.write(r.content)
                print(f"ok {name:12s} {len(r.content)//1024:4d}KB  {head!r}  <- {url}")
                break
            except Exception as e:
                print(f"  err {url}: {e}")
        else:
            raise SystemExit(f"could not fetch {name}")


if __name__ == "__main__":
    main()
