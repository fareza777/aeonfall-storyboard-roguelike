# -*- coding: utf-8 -*-
"""Tag every _say() call site in battle.dart with the log kind the UI needs."""
import io
import os
import re

F = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                 '..', 'aeonfall', 'lib', 'engine', 'battle.dart')

s = io.open(F, encoding='utf-8').read()

SUBS = [
    # --- a frame you played -------------------------------------------
    ("    ].join(' '));\n    lastPlayed = c;",
     "    ].join(' '), kind: 'card');\n    lastPlayed = c;"),
    # --- an attacking foe ---------------------------------------------
    ("        ].join(' · '));\n      case IntentKind.block:",
     "        ].join(' · '), kind: 'foe');\n      case IntentKind.block:"),
    ("guards ${it.value}');",
     "guards ${it.value}', kind: 'foe');"),
    ("?? 'Strength'}');",
     "?? 'Strength'}', kind: 'foe');"),
    ("'${it.statusAmt}');\n      case IntentKind.special:",
     "'${it.statusAmt}', kind: 'foe');\n      case IntentKind.special:"),
    ("does not stir');",
     "does not stir', kind: 'foe');"),
    # --- a foe's special move -----------------------------------------
    ("    ].join(' '));\n  }\n\n  void _junk",
     "    ].join(' '), kind: 'foe');\n  }\n\n  void _junk"),
    # --- conditions ticking down --------------------------------------
    ("_say('Burn → $label $b');",
     "_say('Burn → $label $b', kind: 'tick');"),
    ("_say('Poison → $label $p');",
     "_say('Poison → $label $p', kind: 'tick');"),
    ("_say('Regen → $label +${t.s('regen')}');",
     "_say('Regen → $label +${t.s('regen')}', kind: 'tick');"),
    ("_say('DOOM → $label $d', kind: 'reaction');",
     "_say('DOOM → $label $d', kind: 'death');"),
    # --- something died -----------------------------------------------
    ("is erased', kind: 'reaction');",
     "is erased', kind: 'death');"),
]

missing = []
for old, new in SUBS:
    if old not in s:
        missing.append(old[:64].replace('\n', '\\n'))
        continue
    s = s.replace(old, new, 1)

io.open(F, 'w', encoding='utf-8', newline='\n').write(s)

print('tagged', len(SUBS) - len(missing), 'of', len(SUBS))
for m in missing:
    print('  MISS:', m)

for kind in ['card', 'foe', 'tick', 'death', 'reaction', 'cinematic']:
    print(kind, '->', len(re.findall(r"kind: '%s'" % kind, s)))
