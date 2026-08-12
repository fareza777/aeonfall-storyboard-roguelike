# -*- coding: utf-8 -*-
"""Build Android launcher icons from the generated key crest."""
import os

from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.abspath(os.path.join(ROOT, "..", "aeonfall", "assets", "img", "brand_icon.webp"))
RES = os.path.abspath(os.path.join(ROOT, "..", "aeonfall", "android", "app", "src", "main", "res"))

# legacy square icons + adaptive foreground sizes
SIZES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}
FG = {k: int(v * 108 / 48) for k, v in SIZES.items()}


def rounded(im, radius_ratio=0.22):
    w, h = im.size
    mask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, w - 1, h - 1], radius=int(w * radius_ratio), fill=255)
    out = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    out.paste(im, (0, 0), mask)
    return out


def main():
    base = Image.open(SRC).convert("RGB")
    side = min(base.size)
    base = base.crop(((base.width - side) // 2, (base.height - side) // 2,
                      (base.width + side) // 2, (base.height + side) // 2))

    for folder, size in SIZES.items():
        d = os.path.join(RES, folder)
        os.makedirs(d, exist_ok=True)
        icon = rounded(base.resize((size, size), Image.LANCZOS).convert("RGBA"))
        icon.save(os.path.join(d, "ic_launcher.png"))

        # adaptive foreground: art inset inside a 108dp canvas so the system
        # mask never clips the crest
        fs = FG[folder]
        canvas = Image.new("RGBA", (fs, fs), (0, 0, 0, 0))
        inner = int(fs * 0.62)
        art = base.resize((inner, inner), Image.LANCZOS).convert("RGBA")
        canvas.paste(art, ((fs - inner) // 2, (fs - inner) // 2), art)
        canvas.save(os.path.join(d, "ic_launcher_foreground.png"))
        print(folder, size, "/", fs)

    # adaptive icon descriptor + background colour
    anydpi = os.path.join(RES, "mipmap-anydpi-v26")
    os.makedirs(anydpi, exist_ok=True)
    with open(os.path.join(anydpi, "ic_launcher.xml"), "w", encoding="utf-8") as f:
        f.write(
            '<?xml version="1.0" encoding="utf-8"?>\n'
            '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
            '    <background android:drawable="@color/ic_launcher_background"/>\n'
            '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
            '</adaptive-icon>\n')

    values = os.path.join(RES, "values")
    os.makedirs(values, exist_ok=True)
    with open(os.path.join(values, "ic_launcher_background.xml"), "w", encoding="utf-8") as f:
        f.write(
            '<?xml version="1.0" encoding="utf-8"?>\n'
            '<resources>\n'
            '    <color name="ic_launcher_background">#07070C</color>\n'
            '</resources>\n')

    # 512px Play Store icon
    store = os.path.join(ROOT, "store")
    os.makedirs(store, exist_ok=True)
    base.resize((512, 512), Image.LANCZOS).save(os.path.join(store, "play_icon_512.png"))
    print("play icon ->", os.path.join(store, "play_icon_512.png"))


if __name__ == "__main__":
    main()
