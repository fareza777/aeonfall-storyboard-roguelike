# -*- coding: utf-8 -*-
"""Third and final pass, using phrasing that was tested before it was used.

Passes v3 and v4 both leaned on describing what is absent ("the face is
hidden", "an empty suit of armour"). Flux paints a person anyway; a soft
clause at the end of a prompt loses to a strong subject noun at the front.

Three phrasings were probed on a single image first and all three came back
clean, so the rewrites below use only those:

  A  HEADLESS   - the neck or collar visibly ends in an empty dark opening
  B  REAR VIEW  - stated up front, repeated, back squarely to the viewer
  C  VOID HEAD  - the head is a smooth featureless sphere or column

The rule the probe established: the concealment has to be the opening
sentence, stated physically and emphatically. Anything appended to the end is
ignored.
"""
import io
import os

ROOT = os.path.dirname(os.path.abspath(__file__))

from manifest import ASSETS as A0

try:
    from manifest_extra import EXTRA
except ImportError:
    EXTRA = []
try:
    from manifest_v2 import V2
except ImportError:
    V2 = []
try:
    from manifest_v3 import V3
except ImportError:
    V3 = []
try:
    from manifest_v4 import V4
except ImportError:
    V4 = []

ALL = {}
for a in A0 + EXTRA + V2 + V3 + V4:
    ALL[a["key"]] = a

STYLE_MARK = "dark fantasy storyboard illustration"

BODY = {
    # ---------- A: headless / empty garment
    "comp/brann":
        "A HEADLESS suit of battered mismatched plate armour standing upright "
        "on its own. There is no head and no helmet - the armoured neck simply "
        "ends in an empty dark opening. A greatsword is planted in the ground "
        "beside it, a cold stew-pot at its feet",
    "comp/mordwen":
        "A HEADLESS grey funeral robe standing upright on its own. There is no "
        "head - the collar ends in an empty dark opening. A tall iron staff is "
        "held in one empty sleeve, grave-candles burning at the hem",
    "comp/vessa":
        "A HEADLESS duellist's high-collared coat standing upright on its own. "
        "There is no head - the collar ends in an empty dark opening. A rapier "
        "is held in one empty glove",

    # ---------- B: rear view
    "comp/nim":
        "REAR VIEW from directly behind. We see only the back of a small wiry "
        "figure in a patched scarf and an oversized coat, hood up, walking away "
        "from us. Back view, rear view, seen strictly from behind",
    "comp/orrin":
        "REAR VIEW from directly behind. We see only the back of a scholar in a "
        "heavy travelling coat with a satchel and a wide-brimmed hat, walking "
        "away from us. Back view, rear view, seen strictly from behind",
    "card/volt_overcharge":
        "REAR VIEW from directly behind. We see only the back of a figure in "
        "segmented armour overloaded with arcs of golden lightning, back "
        "squarely to the viewer. Back view, rear view, seen strictly from behind",

    # ---------- C: void head
    "comp/calder":
        "A tall figure in a storm-soaked greatcoat whose head is a perfectly "
        "smooth featureless black sphere, like polished obsidian - no eyes, no "
        "nose, no mouth, no openings of any kind. Lightning arcs off the "
        "shoulders",
    "comp/thessa":
        "A tall figure sheathed in rime whose head is a perfectly smooth "
        "featureless column of blank frosted ice - no eyes, no nose, no mouth, "
        "no openings of any kind. Frost-crusted furs, breath steaming",
    "enemy/static_djinn":
        "A figure-shaped column of violet lightning rising from a cracked stone "
        "basin. It is HEADLESS - the arcs simply stop at the shoulders and "
        "there is nothing above them",

    # ---------- objects and empty rooms: no person in frame at all
    "brand/defeat":
        "A snapped sword half-sunk in still black water, gold embers guttering "
        "out on the surface around it, ripples spreading outward. An empty "
        "scene, no figure anywhere in it",
    "chron/gilded_lie":
        "A gilded ceremonial crown resting alone on black silk in a shaft of "
        "light, beautiful and empty, its gold leaf cracking and flaking. No "
        "wearer, no figure, nobody present",
    "ending/end_become":
        "An empty tower study at night. Nobody is present anywhere in the "
        "frame. An empty chair pushed back from a writing desk, a coat hung "
        "over the chair back, a quill standing upright in the ink, candles "
        "guttering, pages everywhere",
    "event/clock_surgeon":
        "Clockwork surgical instruments and an open pocket watch laid out in a "
        "row on a bloodstained cloth beside an empty operating table. Nobody is "
        "present anywhere in the frame",
    "event/wounded_companion":
        "A broken gilded breastplate and a dropped sword lying on cracked "
        "flagstones, blood pooling into the cracks, a long shadow across the "
        "stone. Nobody is present anywhere in the frame",
    "card/curse_silence":
        "A heavy gold padlock clamped shut over a rolled scroll, the writing on "
        "the scroll scratched out, dark vapour leaking from the seam. An object "
        "alone on black, no figure anywhere",
    "card/umbra_nightmare":
        "A black clawed shadow-beast crouched alone on an empty rumpled bed in "
        "cold moonlight. The bed is empty, nobody is lying in it",
    "card/umbra_whisper":
        "A torn empty hood lying on wet stone with dark vapour pouring out of "
        "the hollow opening. There is nothing inside the hood and no figure "
        "anywhere in the frame",
}


def main():
    rows, missing = [], []
    for key, body in BODY.items():
        base = ALL.get(key)
        if base is None:
            missing.append(key)
            continue
        at = base["prompt"].find(STYLE_MARK)
        style = base["prompt"][at:] if at > 0 else ""
        rows.append(dict(base, prompt=f"{body}. {style}"))

    if missing:
        print("NOT IN MANIFEST:", missing)

    with io.open(os.path.join(ROOT, "manifest_v5.py"), "w", encoding="utf-8") as f:
        f.write("# -*- coding: utf-8 -*-\n")
        f.write("# Generated by build_manifest_v5.py - do not edit by hand.\n")
        f.write("V5 = [\n")
        for r in rows:
            f.write("    {\n")
            for k in ("key", "group", "ar", "model", "prompt"):
                f.write("        %r: %r,\n" % (k, r[k]))
            f.write("    },\n")
        f.write("]\n")
    print("third-pass rewrites:", len(rows))


if __name__ == "__main__":
    main()
