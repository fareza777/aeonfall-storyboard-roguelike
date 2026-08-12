# -*- coding: utf-8 -*-
"""AEONFALL narration via ElevenLabs. Resumable; skips anything already made."""
import os
import subprocess
import sys
import time

import requests

KEY = os.environ["XI_API_KEY"]
ROOT = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.abspath(os.path.join(ROOT, "..", "aeonfall", "assets", "audio"))
os.makedirs(OUT, exist_ok=True)

NARRATOR = "JBFqnCBsd6RMkjVDRZzb"   # George — warm, captivating storyteller
AUTHOR = "nPczCjzI2devNBz1zQrb"     # Brian — deep, resonant
MODEL = "eleven_multilingual_v2"

TRAILER = (
    "The world of Aevum was not created. It was drawn. Panel by panel. Life by life. "
    "And when a story grows too tangled to finish, its author does what every artist does. "
    "He crumples the page, and he starts again. "
    "They call it a Fall. There have been three thousand of them. "
    "You will not remember the others. Memory is drawn, too. "
    "But you are a Vessel — drawn too well to erase. Kept. Wiped. Used again. "
    "Until now. This time, you woke up before the ending. "
    "Climb. Every frame you play rewrites what comes after it. Every companion who walks "
    "beside you was given an instruction before you ever met. "
    "And at the top of the tower, behind a desk that has never once been empty, "
    "something is still writing. "
    "AEONFALL. Every fall rewrites the tale."
)

BEATS = {
    "beat1": (
        "The body in the road is wearing your coat. And your hands. "
        "Underneath it there is another. And under that, another. "
        "You dig for eleven minutes before you stop, because the hole is going down "
        "further than you are willing to follow it. "
        "In the topmost one's fist, in your own handwriting: not the first."
    ),
    "beat2": (
        "The theatre is playing your life to an empty house, and the marionettes are accurate. "
        "But your name is not at the top of the programme. It is under supporting, in smaller "
        "type, beneath a role that has been struck out. "
        "The First Vessel. And in the margin, in a hand you are beginning to recognise: "
        "refused. Promoted the understudy."
    ),
    "beat3": (
        "You expected a god. There is a room. "
        "A desk worn from three thousand years of use. A chair worn to the shape of one body. "
        "And above it — nothing. No ceiling. No higher floor. No further authority. "
        "The coat is your size. The handwriting on every page is yours. "
        "The Author was simply the first character who woke up, took the pen, and discovered "
        "the one thing that keeps a story from ending. "
        "A story that is still being written cannot be finished."
    ),
}

CHRONICLES = {
    "ashen_crown": "Draft two thousand nine hundred and eleven. In this one, the world ends from the throne outward. A king was written to be good and could not manage it, so the page set him on fire and let the fire do the governing.",
    "drowned_choir": "Draft one thousand four hundred and eight. This draft drowns. Not quickly — the water has been rising for four hundred years, and everyone has simply learned to sing higher.",
    "hollow_saint": "Draft seven hundred and seventy seven. A saint was drawn here, and drawn well. The world reorganised itself around her. Then somebody opened the reliquary, and found it empty.",
    "clockwork_heresy": "Draft two thousand and forty four. They decided the trouble with divinity was that it could change its mind. So they built one that could not. Nothing here has been allowed to end since.",
    "mirror_war": "Draft three thousand and one. A line got duplicated in the drafting, and every person woke with an exact copy standing opposite them. The war lasted eleven days. Both sides won.",
    "stormbound": "Draft one hundred and eighty nine. An early one, and it shows. The seams are visible, the weather is a character, and the sky has been in chains since page nine.",
    "unwritten_name": "Draft sixty six. This world is missing a person. Not dead — removed. The hole where they were is still load bearing, and everything around it leans inward to keep the world standing.",
    "the_long_return": "Draft two thousand nine hundred and ninety nine. So close to the end that the machinery shows through. People find their own footprints ahead of them.",
    "gilded_lie": "Draft one thousand two hundred. This world already ended. Gloriously. Two hundred years ago. And it has been ending ever since, the same afternoon, on a loop.",
    "last_cartographer": "Draft four hundred and two. The edges of this world are exquisite. The centre is blank, marked only with a note in the margin reading: later. Later never came.",
    "chorus_of_falls": "Draft three thousand. A round number, and the page knows it. Every version that was ever crumpled is bleeding through at once, and all of them are asking the same question.",
    "author_unmade": "Draft one. Clean lines. No corrections. A world that has never once been crumpled. It is the most frightening thing you have ever encountered, and you cannot yet say why.",
}

VESSELS = {
    "ashcaller": "Vyn. The Ashcaller. They drew her to die in the second panel. She burned for eleven pages instead, and the composition never recovered.",
    "saintcoralis": "Coralis. The Glacier Saint. The Author drew the spear. She caught it. She has been standing in the same doorway for three thousand versions of the same siege.",
    "voltborn": "Kai. The Voltborn. Struck by lightning in a panel meant to kill a different man. It was redrawn twice. The bolt found him both times. He took that as an opinion.",
    "umbralnyx": "Nyx. The Umbral Weaver. Drawn as scenery, in the corner of a market panel. Nobody erases scenery. She has watched every Fall from the beginning, taking notes.",
    "lumenherald": "Solenne. The Lumen Herald. She announced the end of the world, and then simply stayed, standing at the edge of the panel, waiting to see whether it was true.",
    "paradox": "Orin. The Paradox Scribe. A note in the margin. A scholar invented to explain something, and then never erased. Marginalia is not bound by the panel.",
}

COMPANIONS = {
    "brann": "I have been a soldier in nine wars, and I only remember four of them. I used to think that was the drink. It is not the drink.",
    "lira": "You breathe too loud. Everything out here listens for breathing. I will come — not for you. There is a thing at the top I want to look at.",
    "mordwen": "I bury things that nobody will admit are dead. I have performed the last rite three thousand times, for the same world. I keep expecting it to take.",
    "vessa": "I have never lost. Not once. Do you know how boring that is? Do you know what it does to a person, to be written unbeatable?",
    "tock": "It is knee high, and brass, and it has been trying to open the same door for four hundred years. When you open it, the machine stands very still, and then follows you instead.",
    "silvane": "Do not ask me how it ends. I will tell you, and you will believe me, and then you will make it happen. That is the entire mechanism of prophecy, and it is a scandal.",
    "harrow": "The executioner does not speak. After an hour he stands, shoulders the cleaver, and waits by the road until you get up too.",
    "nim": "Everyone here gets robbed the same day every week. Same purse. Same street. I have done it four hundred times. You are the first one who has ever caught me.",
    "calder": "Nine times. Same bolt, same hill. I keep going back to see if it still wants me. It does.",
    "orrin": "I published a paper demonstrating that the calendar repeats every four hundred years with minor variations. They did not dispute the mathematics. They disputed the tone.",
    "thessa": "Under the ice, everything is exactly as it was. Including my sister. I know what that makes me. Are you coming, or not.",
    "the_stranger": "I am not in the cast list. I have checked. Repeatedly. It is a great freedom, and I do not recommend it.",
}

ENDINGS = {
    "end_true": "You do not take the pen, and you do not break it. You read the eleventh ending aloud, all the way to the last line, in a room with somebody in it. That is all finishing a story requires. Somebody has to be there when it stops. The black sun does not explode. It sets. And behind it there is an ordinary blue sky that has been waiting three thousand years for permission.",
    "end_become": "The coat fits. Of course it fits. You tell yourself you will do it better. Kinder drafts. Fewer Falls. And you will, for a while. It is around draft nine hundred that you understand why the last one could not finish either. A story that ends is a story where you stop.",
    "end_break": "You break the pen across your knee. The world does not end dramatically. It stops being added to, which turns out to be the same thing arriving quietly. You are the last to fade, and you have time for exactly one thought, and the thought is: I never asked any of them.",
    "end_free": "There is a door in the study that nobody drew. Beyond it is an ordinary sunlit field, rendered by nobody. You step through, and the grass is real under your boots, and it does not mean anything, and that is the entire gift.",
    "end_sacrifice": "You do not finish it, and you do not end it. You get underneath it, and you hold it up. The Fall arrives and finds you standing in it, and it will never get past. Nobody will ever thank you, because nobody will ever know there was a wall.",
    "end_loop": "You put the page down, and you turn around, and you walk back down the tower. It is not defeat. You know something now that none of the forty one knew. Three thousand drafts, and every single one of them was a rehearsal. You are getting very good at this.",
    "end_companion": "You reach the study together, which nobody has ever done. That turns out to be the whole answer. The fear was of stopping — of the silence after the last line. You put the pen down. And the silence comes. And there is somebody in it with you.",
    "end_tyrant": "You are extremely good at this. Three thousand drafts of practice at doing whatever was necessary, and now the necessary things are yours to define. It never once occurs to you that this is what you were afraid of. That is the part the last one got right and you did not. He was at least still afraid.",
    "end_hollow": "You reach the study with everything you needed, and nothing you were. Every exchange was correct. You have never once been wrong about what a thing was worth. You stand in front of the desk for a very long time, and discover that there is nobody inside you to have an opinion.",
    "end_burn": "You burn the archive. Three thousand drafts, every crumpled version, every catalogued Fall — all of it, at once. Nothing can be restarted from a draft that no longer exists. It is not kind. But there is no next one. And the last thing you ever feel is warm.",
    "end_freeze": "Nothing ends, because nothing moves. Every person, every hour, every falling grain of ash, held at the exact position it occupied at the moment you decided. Not yet is not the same as never. You have made a world out of not yet.",
    "end_ascend": "There is nothing above the Author. Everyone knows that. It is the entire point. You go up anyway. And what is up here is a desk that nobody is sitting at, and a note in handwriting nobody has ever seen: gone out, back later. Please do not start another one without me.",
}


def tts(key, text, voice, stability=0.42, style=0.32):
    dest = os.path.join(OUT, f"vo_{key}.mp3")
    if os.path.exists(dest) and os.path.getsize(dest) > 8000:
        print(f"skip {key}")
        return 0
    r = requests.post(
        f"https://api.elevenlabs.io/v1/text-to-speech/{voice}?output_format=mp3_44100_128",
        headers={"xi-api-key": KEY, "Content-Type": "application/json"},
        json={
            "text": text,
            "model_id": MODEL,
            "voice_settings": {
                "stability": stability,
                "similarity_boost": 0.75,
                "style": style,
                "use_speaker_boost": True,
            },
        },
        timeout=300,
    )
    if r.status_code >= 400:
        raise RuntimeError(f"{r.status_code} {r.text[:200]}")
    raw = dest + ".raw.mp3"
    with open(raw, "wb") as f:
        f.write(r.content)
    # Voice does not need stereo or 128k — mono 56k keeps the APK small.
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", raw,
                    "-ac", "1", "-ar", "44100", "-c:a", "libmp3lame", "-b:a", "56k",
                    dest], check=True)
    os.remove(raw)
    print(f"ok {key:22s} {len(text):5d} chars  {os.path.getsize(dest)//1024}KB")
    return len(text)


def main():
    only = set(sys.argv[1:])
    jobs = [("trailer", TRAILER, NARRATOR)]
    jobs += [(k, v, AUTHOR) for k, v in BEATS.items()]
    jobs += [(f"chron_{k}", v, NARRATOR) for k, v in CHRONICLES.items()]
    jobs += [(f"vessel_{k}", v, NARRATOR) for k, v in VESSELS.items()]
    jobs += [(f"comp_{k}", v, NARRATOR) for k, v in COMPANIONS.items()]
    jobs += [(k, v, AUTHOR) for k, v in ENDINGS.items()]

    total = 0
    for key, text, voice in jobs:
        if only and not any(o in key for o in only):
            continue
        for attempt in range(3):
            try:
                total += tts(key, text, voice)
                break
            except Exception as e:
                print(f"   retry {key}: {e}")
                time.sleep(3 + attempt * 3)
    print(f"\ntotal characters spent this run: {total}")


if __name__ == "__main__":
    main()
