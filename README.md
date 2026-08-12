# AEONFALL

> *Every fall rewrites the tale.*

A fully illustrated storyboard roguelite for Android. Every run is a different **draft**
of the same doomed world, rendered in AI-generated painterly key art, scored with an
original soundtrack, and narrated by a voice cast.

---

## The premise

The world of Aevum was not created. It was **drawn** — panel by panel, life by life.
When a story grows too tangled to finish, its Author does what every artist does:
crumples the page and starts again. That erasure is a **Fall**. There have been more
than three thousand.

You are a **Vessel** — a character drawn too well to erase. Load-bearing. Remove you and
the whole composition collapses, so the Author keeps you, wipes you, and uses you again
in the next draft.

Erasure is imperfect. This run is the first time one of you woke up *before the ending*.

Three revelations land in every run, in order:

1. **Act I — you have done this before.** You find your own corpse. Then the one under it.
2. **Act II — you are not the protagonist.** You are the understudy, promoted when the
   First Vessel refused to die on cue.
3. **Act III — the Author is also a Vessel.** There is nothing above the desk. The Author
   was simply the first character who woke up and discovered that *a story still being
   written cannot be finished.*

---

## Systems

| System | Detail |
|---|---|
| **Vessels** | 6 playable characters, each with a distinct deck archetype and signature Cinematic |
| **Frames (cards)** | 128 cards, all upgradeable — 256 distinct states |
| **Sigils (relics)** | 56 relics across 12 trigger types |
| **Elements** | Ember, Frost, Volt, Umbra, Lumen |
| **Reactions** | All 10 element pairs produce a distinct reaction (Vaporize, Superconduct, Eclipse…) |
| **Conditions** | 24 status effects |
| **Bestiary** | 54 foes, 14 elites, 9 bosses — plus 8 random enemy mutators |
| **Chronicles** | 12 narrative spines; the run's antagonist, tone and locations change with it |
| **Companions** | 12, up to 2 per run. One of them was given an instruction before you met |
| **Events** | 24 authored branching events plus 4 mandatory story beats |
| **Endings** | 12, chosen by what you *did*, not what you clicked at the end |
| **Map** | 3 acts × 15 branching layers, procedurally generated per seed |

**Elemental auras** are the core of combat. Every elemental attack paints its aura on the
target; striking an existing aura with a *different* element triggers a reaction. Play
three frames of one element in a single turn to fire your Vessel's **Cinematic**.

Runs are seeded and shareable (`ASH-QUILL-441`). Deck, map, chronicle, companions,
betrayer, enemy mutators, shop stock and event pool all derive from that seed.

---

## Assets

Everything shipped in the APK was generated for this project.

- **450 illustrations** (27 MB WebP) — FLUX 1.1 Pro / FLUX dev / FLUX schnell via Replicate
- **7 music loops** (3 MB) — MusicGen stereo-large via Replicate, cross-faded for seamless looping
- **46 narration tracks** (4 MB) — ElevenLabs, two voices: a narrator and the Author
- **23 sound effects** — synthesised procedurally with numpy (`tools/gen_sfx.py`)

No API keys ship inside the app. All generation happens at build time via the scripts in
`tools/`, and the results are baked into `aeonfall/assets/`.

---

## Layout

```
aeonfall/                 Flutter app
  lib/
    engine/               seeded RNG, battle resolver, map generator, narrative director
    data/                 cards, relics, enemies, vessels, chronicles, companions, events
    ui/                   splash, onboarding, hub, trailer, map, battle, event, shop…
  assets/img|audio|fonts
tools/                    asset generation pipeline (Python)
keystore/                 release signing key — BACK THIS UP
```

## Building

```bash
cd aeonfall && flutter build apk --release
```

Signing reads `android/key.properties`, which points at `keystore/aeonfall-release.jks`.
**Keep both safe** — Google Play will not accept an update signed with a different key.

Regenerating assets (only needed if you change the manifests):

```bash
cd tools
set REPLICATE_API_TOKEN=...  &&  python gen_art.py      # illustrations
set REPLICATE_API_TOKEN=...  &&  python gen_music.py    # soundtrack
set XI_API_KEY=...           &&  python gen_voice.py    # narration
python gen_sfx.py                                       # sound effects
python make_icon.py                                     # launcher icons
```

## Tests

```bash
cd aeonfall && flutter test
```

`simulation_test.dart` auto-plays thousands of battles across every vessel, act, seed and
enemy pattern to catch engine crashes without a device.
