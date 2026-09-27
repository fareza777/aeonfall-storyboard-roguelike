# -*- coding: utf-8 -*-
"""Second pass on the images where concealment did not take.

Appending "the face is hidden" to a prompt that opens with "a scarred veteran
mercenary" does not work: the model paints the mercenary and ignores the rest.
Roughly half the v3 rewrites came back with a face anyway.

What did work in v3 were the entries whose *subject* was restated as something
with no face in it — the worn coin, the empty bed, the blank reliquary. So this
pass does that for every remaining one: empty armour, empty robes, a back
turned, an empty room. The scene survives; the person is simply not in frame.

Each body below replaces only the subject. The group's own style tail is kept
from the existing manifest entry so the art stays consistent.
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

ALL = {}
for a in A0 + EXTRA + V2 + V3:
    ALL[a["key"]] = a

STYLE_MARK = "dark fantasy storyboard illustration"
CLOSER = ("faceless, no people depicted, no facial features anywhere, "
          "no portraiture")

BODY = {
    # ---- character sheets: empty garments, or strictly from behind
    "comp/brann":
        "an empty suit of battered mismatched plate armour standing upright on "
        "its own, the helm visor a black hollow with nothing inside it, a "
        "greatsword planted in the ground beside it",
    "comp/calder":
        "a tall figure in a storm-soaked greatcoat seen strictly from behind, "
        "back squarely to the viewer, lightning arcing off the shoulders, the "
        "head never shown",
    "comp/mordwen":
        "a long grey funeral robe standing upright and empty, the deep cowl "
        "containing only darkness, a tall iron staff held in an empty sleeve",
    "comp/nim":
        "a small wiry figure in a patched scarf and an oversized coat, seen "
        "strictly from behind with the hood up, back to the viewer",
    "comp/orrin":
        "a scholar's heavy travelling coat and satchel standing upright and "
        "empty, a wide-brimmed hat floating above a hollow of shadow where a "
        "head would be",
    "comp/thessa":
        "a figure sheathed entirely in rime and hoarfrost, the head a smooth "
        "blank column of frosted ice with no features cut into it",
    "comp/vessa":
        "a duellist's high-collared coat standing upright and empty, a rapier "
        "held in an empty glove, the collar rising to a hollow of shadow",
    # ---- scenes: the room, not the person
    "brand/defeat":
        "a cracked empty porcelain half-mask sinking face-down into black "
        "water, gold embers guttering out around it, ripples spreading",
    "chron/gilded_lie":
        "a smooth gilded oval plaque with absolutely nothing carved into it, "
        "gold leaf cracking and flaking away from black lacquer beneath",
    "ending/end_become":
        "an empty writing desk in a high tower room seen past the back of an "
        "empty chair, a coat hung over the chair, a quill standing in the ink",
    "elite/hoar_marshal":
        "a riderless white skeletal stag draped in frozen war banners, empty "
        "ceremonial armour strapped across its back with nothing inside it",
    "enemy/static_djinn":
        "a column of violet lightning in the rough shape of a person, made "
        "entirely of arcing electricity with no body and no head, rising out "
        "of a cracked stone basin",
    "enemy/voltaic_monk":
        "empty monastic robes seated cross-legged and levitating inside a ring "
        "of lightning, the cowl fallen open onto nothing but darkness",
    "event/borrowed_face":
        "an enormous smooth blank stone oval half-buried in a cliffside, not a "
        "single feature cut into it, ash blowing across the bare rock",
    "event/clock_surgeon":
        "a surgeon's table seen from above with a long sheet drawn fully over "
        "the shape on it, clockwork instruments and an open pocket watch laid "
        "out in a row beside it",
    "event/first_cut":
        "two empty chairs at a small kitchen table, two cups still steaming, "
        "warm afternoon light across the boards, nobody in the room",
    "event/honest_merchant":
        "a merchant's blanket laid on the ground with one object on it and a "
        "hand-lettered wooden sign, an empty stool behind it, nobody present",
    "event/puppet_theatre":
        "a tiny stage of marionettes hanging slack on their strings, their "
        "heads plain unpainted wooden balls with nothing painted on them",
    "event/second_opinion":
        "the inside of a clean surgeon's tent, an empty operating table under "
        "a hanging lamp, instruments laid out in a row, nobody present",
    "event/hall_of_masks":
        "a long hall hung with rows of smooth blank unpainted oval masks on "
        "hooks, not one of them cut with eyes or a mouth",
    "event/understudy_bench":
        "a long bench outside a closed stage door with nine identical empty "
        "coats folded along it in a row and one bare space at the end",
    "event/veterans":
        "a campfire ringed by six empty bedrolls and six hooded cloaks propped "
        "over packs, nobody sitting at the fire",
    "event/weeping_well":
        "a ruined cloister well with a smooth blank stone oval set into the "
        "wall above it, water running down from the featureless stone",
    "event/wounded_companion":
        "a suit of gilded armour lying broken open on cracked flagstones with "
        "nothing inside it, a sword just out of reach",
    "card/curse_silence":
        "a smooth blank mask with no mouth, bound shut in gold wire and chain, "
        "floating in dark vapour",
    "card/umbra_nightmare":
        "an empty bed with the covers thrown back and a small black clawed "
        "shape crouched on the pillow, nobody in the bed",
    "card/umbra_whisper":
        "two empty hoods facing one another, dark vapour pouring between the "
        "hollow openings where heads should be",
    "card/volt_overcharge":
        "a suit of segmented armour overloaded with arcs of golden lightning, "
        "seen from behind, the helm a sealed blank shell",
}


def main():
    rows = []
    missing = []
    for key, body in BODY.items():
        base = ALL.get(key)
        if base is None:
            missing.append(key)
            continue
        at = base["prompt"].find(STYLE_MARK)
        style = base["prompt"][at:] if at > 0 else ""
        rows.append(dict(base, prompt=f"{body}, {CLOSER}, {style}"))

    if missing:
        print("NOT IN MANIFEST:", missing)

    with io.open(os.path.join(ROOT, "manifest_v4.py"), "w", encoding="utf-8") as f:
        f.write("# -*- coding: utf-8 -*-\n")
        f.write("# Generated by build_manifest_v4.py - do not edit by hand.\n")
        f.write("V4 = [\n")
        for r in rows:
            f.write("    {\n")
            for k in ("key", "group", "ar", "model", "prompt"):
                f.write("        %r: %r,\n" % (k, r[k]))
            f.write("    },\n")
        f.write("]\n")
    print("second-pass rewrites:", len(rows))


if __name__ == "__main__":
    main()
