# -*- coding: utf-8 -*-
"""Rewrites the 61 images a visual audit found showing a human face.

Every image in assets/img was reviewed on contact sheets. The ones listed
below render a recognisable human face. The rest already use a hood, a mask,
a helmet, a back turned or a silhouette, or are not people at all, and are
left untouched so the art that already works keeps working.

Diffusion models handle negation badly, so concealment is phrased positively:
the prompt describes the hood or the mask that IS there, rather than the face
that is not.
"""
import hashlib
import io
import os
import re

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

ALL = {}
for a in A0 + EXTRA + V2:
    ALL[a["key"]] = a

# --------------------------------------------------------- the audit result
FLAGGED = """
awake/saintcoralis
brand/defeat brand/onboard_2
chron/drowned_choir chron/gilded_lie
comp/brann comp/calder comp/mordwen comp/nim comp/orrin comp/silvane
comp/thessa comp/vessa
ending/end_become ending/end_sacrifice
vessel/ashcaller vessel/lumenherald vessel/saintcoralis
boss/the_author2
elite/hoar_marshal
enemy/bone_florist enemy/drowned_choirboy enemy/silence_priest
enemy/static_djinn enemy/unwritten_chorus enemy/voltaic_monk
event/assistant event/authors_study event/banquet_ghosts event/beggar_king
event/betrayal event/bleeding_statue event/borrowed_face event/choir_of_one
event/clock_surgeon event/collector_eyes event/debt_collector event/first_cut
event/glassblower event/hall_of_masks event/honest_merchant
event/kind_innkeeper event/marrow_market event/prisoner_ice
event/puppet_theatre event/second_opinion event/stitcher
event/thief_of_faces event/understudy_bench event/veterans
event/weeping_well event/wounded_companion
card/curse_silence card/frost_frostbite card/umbra_leech card/umbra_nightmare
card/umbra_whisper card/volt_overcharge
relic/mirror_coin relic/weeping_salt
site/restsite
""".split()

# ----------------------------------------------------------- concealment
VEILS = [
    "the head entirely hidden inside a deep shadowed hood, nothing but darkness "
    "under the cowl",
    "a smooth blank featureless mask of pale porcelain covering the whole head",
    "turned away from the viewer, back to us, the head never shown",
    "the head completely wrapped in layered cloth and a heavy veil",
    "a plain unadorned iron helm enclosing the entire head, no features worked "
    "into it",
    "a dark silhouette backlit against the glow, the head lost entirely in shadow",
    "the head bowed deep and hidden beneath a wide drooping hood",
    "the head swathed in drifting ash and smoke so nothing of it can be made out",
]

PLURAL = ("every single figure concealed the same way, hoods and veils and "
          "blank masks and backs turned")

REINFORCE = ("faceless, anonymous, featureless heads, no portraiture, "
             "no facial features")

# Several flagged images are objects or scenery where the model simply invented
# a face. Restating the subject is safer than veiling something that was never
# a person.
OVERRIDE = {
    "brand/defeat":
        "a shattered blank porcelain mask lying face-down on black water, gold "
        "embers dying out around it, ripples spreading, nothing else",
    "relic/mirror_coin":
        "an old tarnished silver coin, its struck likeness completely worn away "
        "to a smooth blank disc, only the milled edge and a few letters left",
    "relic/weeping_salt":
        "a small ornate reliquary frame holding a smooth blank salt-white oval "
        "stone, a single bead of water running down it",
    "event/borrowed_face":
        "an enormous blank stone mask half-buried in a cliffside, smooth and "
        "featureless, ash blowing across the empty oval of it",
    "event/weeping_well":
        "a ruined cloister well, a smooth blank stone oval set into the wall "
        "above it, water running down from the stone",
    "event/hall_of_masks":
        "a long hall hung with rows of smooth blank unpainted masks on hooks, "
        "not one of them carved with any features",
    "card/curse_silence":
        "a smooth blank mask bound shut with gold wire and chain, silence made "
        "into an object, no features on it at all",
    "card/umbra_whisper":
        "a torn empty hood with nothing inside it, dark vapour pouring out of "
        "the hollow opening toward the viewer",
    "event/thief_of_faces":
        "a coat and gloves laid out flat and empty on cracked flagstones, a "
        "stack of smooth blank masks beside them",
    "chron/gilded_lie":
        "a gilded ceremonial mask with no eyeholes and no features at all, "
        "smooth gold over a blank oval, cracked and flaking",
    "event/prisoner_ice":
        "an enormous hooded shape frozen inside a wall of blue glacier ice, "
        "only the empty dark hollow of its cowl visible",
    "event/collector_eyes":
        "a tall figure in a wide-brimmed hat and long coat, the space under the "
        "hat brim completely dark and empty, holding a lantern of glowing jars",
}

SCRUB_INLINE = [
    (re.compile(r"(?i)\b(his|her|its|the) face\b"), r"\1 hood"),
    (re.compile(r"(?i)\bfaces\b"), "hooded heads"),
    (re.compile(r"(?i)\bface\b"), "hood"),
    (re.compile(r"(?i)\bsmiling\b"), "motionless"),
    (re.compile(r"(?i)\bsmiles?\b"), "stillness"),
    (re.compile(r"(?i)\bportraits?\b"), "figure study"),
    (re.compile(r"(?i)\bexpressions?\b"), "posture"),
    (re.compile(r"(?i)\bstaring\b"), "turned"),
    (re.compile(r"(?i)\beyes?\b"), "gaze"),
    (re.compile(r"(?i)\bbearded\b"), "cowled"),
    (re.compile(r"(?i)\bbeard\b"), "cowl"),
]

# A comma-segment carrying a facial attribute. Dropped outright from character
# sheets, where the prompt is a short attribute list and losing one item costs
# nothing.
FACE_ATTR = re.compile(
    r"(?i)\b(beard|moustache|stubble|lips?|teeth|grin|grinning|smile|smiling|"
    r"smirk|scowl|frown|jaw|cheeks?|brow|nose|freckl|eyes?|face|gaze|"
    r"blindfold\w*)\b")

CHAR_SHEET = ("comp", "vessel", "awake")
STYLE_MARK = "dark fantasy storyboard illustration"


def veil_for(key):
    return VEILS[int(hashlib.md5(key.encode()).hexdigest(), 16) % len(VEILS)]


def rewrite(key, prompt):
    at = prompt.find(STYLE_MARK)
    body, style = (prompt[:at], prompt[at:]) if at > 0 else (prompt, "")

    overridden = key in OVERRIDE
    if overridden:
        # The subject has been restated as an object with no face in it, so a
        # hood clause on top would be nonsense.
        body = OVERRIDE[key] + ", "
    elif key.split("/")[0] in CHAR_SHEET:
        body = ",".join(s for s in body.split(",") if not FACE_ATTR.search(s))
    else:
        for pat, rep in SCRUB_INLINE:
            body = pat.sub(rep, body)

    if overridden:
        return body.rstrip(" ,") + ", " + REINFORCE + ", " + style

    crowd = PLURAL if re.search(
        r"(?i)\b(people|figures|crowd|others|men|women|children|rows|choir|"
        r"congregation|veterans|guards|statues|them|they|both)\b",
        prompt) else ""
    tail = " {}. {}{}, ".format(veil_for(key),
                                crowd + ". " if crowd else "", REINFORCE)
    return body.rstrip(" ,") + "," + tail + style


def main():
    missing = [k for k in FLAGGED if k not in ALL]
    if missing:
        print("NOT IN MANIFEST:", missing)

    rows = [dict(ALL[k], prompt=rewrite(k, ALL[k]["prompt"]))
            for k in FLAGGED if k in ALL]

    with io.open(os.path.join(ROOT, "manifest_v3.py"), "w", encoding="utf-8") as f:
        f.write("# -*- coding: utf-8 -*-\n")
        f.write("# Generated by build_manifest_v3.py - do not edit by hand.\n")
        f.write("V3 = [\n")
        for r in rows:
            f.write("    {\n")
            for k in ("key", "group", "ar", "model", "prompt"):
                f.write("        %r: %r,\n" % (k, r[k]))
            f.write("    },\n")
        f.write("]\n")

    import collections
    c = collections.Counter(r["key"].split("/")[0] for r in rows)
    print("to regenerate:", len(rows))
    for k in sorted(c):
        print("   {:8} {:3}".format(k, c[k]))


if __name__ == "__main__":
    main()
