# -*- coding: utf-8 -*-
"""Builds manifest_v2.py — the art manifest for everything added in v2.

Reads the Dart data files rather than a hand-kept list, so a piece of content
cannot ship without a panel. Event scenes come from the opening lines of the
prose that was actually written for them, which is where the staging already
lives.
"""
import io
import os
import re

ROOT = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.abspath(os.path.join(ROOT, "..", "aeonfall", "lib", "data"))

STYLE = ("dark fantasy storyboard illustration, painterly gouache and ink wash, "
         "dramatic chiaroscuro lighting, volumetric haze, cinematic film-still framing, "
         "deep indigo and ember-gold and bone-white palette, ornate arcane detail, "
         "AAA game concept art, highly detailed, masterpiece")
EVENT_SUFFIX = ("wide cinematic storyboard panel, strong staging, atmospheric depth, "
                "moody, " + STYLE)
FOE_SUFFIX = ("creature concept art, single subject, centered, isolated on flat "
              "near-black void background, strong rim light, menacing silhouette, " + STYLE)
ICON_SUFFIX = ("ornate arcane relic icon, single centered object, symmetrical, glowing "
               "runic accents, flat near-black background, crisp game inventory icon, " + STYLE)
POTION_SUFFIX = ("a small glass apothecary vial of glowing liquid, single centered object, "
                 "cork stopper, wax seal, flat near-black background, crisp game inventory "
                 "icon, " + STYLE)


def read(name):
    return io.open(os.path.join(DATA, name), encoding="utf-8").read()


def dart_str(raw):
    """Join Dart adjacent-string concatenation into one line of plain prose."""
    parts = re.findall(r"'((?:[^'\\]|\\.)*)'", raw, re.S)
    s = "".join(parts)
    s = s.replace("\\'", "'").replace("\\n", " ").replace("\\\\", "\\")
    s = s.replace("**", "").replace("*", "")
    return re.sub(r"\s+", " ", s).strip()


def scene_from_body(body, limit=320):
    """Keep the staging, drop the talking.

    Quoted speech and attributions ("he says") describe nothing a painter can
    put on a panel, and they crowd out the parts that do.
    """
    body = re.sub(r"\s+", " ", body).strip()
    body = re.sub(r'"[^"]*"', "", body)          # spoken lines
    body = re.sub(r"\s*,?\s*(he|she|it|they) says[^.]*\.", ".", body)
    body = re.sub(r"\s{2,}", " ", body).replace(" .", ".").replace("..", ".")

    out, total = [], 0
    for sent in re.split(r"(?<=[.!?]) ", body):
        sent = sent.strip()
        if len(sent) < 12:
            continue
        if total + len(sent) > limit and out:
            break
        out.append(sent)
        total += len(sent)
    return " ".join(out)


ELEM_TINT = {
    "ember": "molten ember-orange",
    "frost": "pale glacier-blue",
    "volt": "crackling violet-white",
    "umbra": "black iridescent",
    "lumen": "warm gold",
    "none": "colourless silver",
}


# ---------------------------------------------------------------- events
def events():
    rows = []
    for fn in ("events_c.dart", "events_d.dart", "events_e.dart"):
        src = read(fn)
        for m in re.finditer(r"id:\s*'([a-z0-9_]+)',\s*\n\s*title:\s*'([^']*)',"
                             r"\s*\n\s*art:\s*'([a-z0-9_]+)',", src):
            eid, title, art = m.group(1), m.group(2), m.group(3)
            bm = re.search(r"\n\s*body:\s*\n?((?:\s*'(?:[^'\\]|\\.)*'\s*\n?)+)",
                           src[m.end():m.end() + 4000])
            body = dart_str(bm.group(1)) if bm else title
            rows.append({
                "key": "event/" + art.replace("event_", "", 1),
                "group": "event",
                "ar": "16:9",
                "model": "flux-1.1-pro",
                "prompt": f"{scene_from_body(body)} {EVENT_SUFFIX}",
            })
    return rows


# ------------------------------------------------------------------ foes
def foes():
    src = read("enemies_b.dart")
    rows = []
    # Split on the constructor so each foe's own body is searched in isolation.
    # A single greedy pattern kept picking up the *next* entry's tier.
    chunks = re.split(r"\n  _e\(", src)
    for chunk in chunks[1:]:
        head = re.match(r"'([a-z0-9_]+)',\s*'((?:[^'\\]|\\.)*)',", chunk)
        if not head:
            continue
        fid, name = head.group(1), head.group(2).replace("\\'", "'")
        tm = re.search(r"tier:\s*(\d)", chunk)
        tier = int(tm.group(1)) if tm else 0
        folder = {0: "enemy", 1: "elite", 2: "boss"}[tier]
        bm = re.search(r"blurb:\s*\n?((?:\s*'(?:[^'\\]|\\.)*'\s*\n?)+)", chunk)
        desc = dart_str(bm.group(1)) if bm else name
        lead = f"{name.upper()}: " if tier == 2 else ""
        rows.append({
            "key": f"{folder}/{fid}",
            "group": folder,
            "ar": "1:1",
            "model": "flux-dev" if tier == 0 else "flux-1.1-pro",
            "prompt": f"{lead}{desc} {FOE_SUFFIX}",
        })
    return rows


# -------------------------------------------------------------- draughts
def potions():
    src = read("potions.dart")
    rows = []
    for m in re.finditer(r"id:\s*'([a-z0-9_]+)',\s*\n\s*name:\s*'((?:[^'\\]|\\.)*)',", src):
        pid, name = m.group(1), m.group(2).replace("\\'", "'")
        tail = src[m.end():m.end() + 900]
        em = re.search(r"elem:\s*Elem\.(\w+)", tail)
        tint = ELEM_TINT.get(em.group(1) if em else "none", ELEM_TINT["none"])
        # The rules text is not paintable. The name and the colour are.
        rows.append({
            "key": f"potion/{pid}",
            "group": "potion",
            "ar": "1:1",
            "model": "flux-schnell",
            "prompt": f'a draught named "{name}", filled with {tint} liquid, {POTION_SUFFIX}',
        })
    return rows


# ----------------------------------------------------------------- sigils
def relics():
    src = read("relics_b.dart")
    rows = []
    for m in re.finditer(r"_r\('([a-z0-9_]+)',\s*'((?:[^'\\]|\\.)*)',", src):
        rid, name = m.group(1), m.group(2).replace("\\'", "'")
        # Same reasoning as the draughts: the rules line is not an image, the
        # object's name is.
        rows.append({
            "key": f"relic/{rid}",
            "group": "relic",
            "ar": "1:1",
            "model": "flux-schnell",
            "prompt": f"the {name} — an aged, worn arcane object, {ICON_SUFFIX}",
        })
    return rows


def main():
    rows = events() + foes() + potions() + relics()

    seen, uniq = set(), []
    for r in rows:
        if r["key"] in seen:
            continue
        seen.add(r["key"])
        uniq.append(r)

    out = io.open(os.path.join(ROOT, "manifest_v2.py"), "w", encoding="utf-8")
    out.write("# -*- coding: utf-8 -*-\n")
    out.write("# Generated by build_manifest_v2.py — do not edit by hand.\n")
    out.write("V2 = [\n")
    for r in uniq:
        out.write("    {\n")
        for k in ("key", "group", "ar", "model", "prompt"):
            out.write("        %r: %r,\n" % (k, r[k]))
        out.write("    },\n")
    out.write("]\n")
    out.close()

    by = {}
    for r in uniq:
        by[r["group"]] = by.get(r["group"], 0) + 1
    print("manifest_v2.py written:", len(uniq), "assets")
    for g in sorted(by):
        print("  %-8s %3d" % (g, by[g]))


if __name__ == "__main__":
    main()
