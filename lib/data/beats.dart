import 'narrative_model.dart';


/// Mandatory story beats. The Director fires these on fixed floors so every run
/// lands the same three revelations, no matter which Chronicle is playing.
const kBeats = <GameEvent>[
  // ------------------------------------------------- ACT I: the loop
  GameEvent(
    id: 'beat_act1',
    title: 'YOU HAVE BEEN HERE',
    art: 'event_first_fall',
    tag: 'beat',
    once: false,
    body:
        'The body is face-down in the road, and it is wearing your coat, and it is wearing '
        'your hands.\n\n'
        'It has been dead perhaps a week. Under it, pressed flat into the ash, there is '
        'another one — older, dried to leather. Under that, another. You dig for eleven '
        'minutes before you stop, because the hole is going down further than you are '
        'willing to follow it.\n\n'
        'In the topmost one\'s fist there is a scrap of paper with three words on it in '
        'your own handwriting:\n\n'
        '**NOT THE FIRST**',
    choices: [
      EvChoice(
        label: 'Take the note. Keep walking.',
        result:
            'You put it in your pocket, where it sits against your ribs for the rest of '
            'the journey like a stone in a shoe. You do not stop walking. That is, you '
            'suspect, exactly what all of them did.',
        out: [Out(OutKind.flag, arg: 'knows_loop'), Out(OutKind.page)],
      ),
      EvChoice(
        label: 'Bury them. All of them.',
        result:
            'It takes the rest of the day and you use your hands. When it is done there '
            'is a mound in the road that anyone coming after will have to walk around, '
            'and that — you understand suddenly, fiercely — is the point. Somebody after '
            'you will *have to notice.*',
        out: [Out(OutKind.flag, arg: 'knows_loop'), Out(OutKind.flag, arg: 'tended_dead'),
          Out(OutKind.mercy, value: 2), Out(OutKind.maxHp, value: 12)],
      ),
      EvChoice(
        label: 'Search every one of them.',
        result:
            'Forty-one bodies. Forty-one sets of equipment, most of it better than yours. '
            'You take what is useful and you leave the hole open, and you tell yourself '
            'they would have wanted it, and you know that they would not have cared '
            'either way, and that is somehow worse.',
        out: [Out(OutKind.flag, arg: 'knows_loop'), Out(OutKind.gold, value: 200),
          Out(OutKind.relic), Out(OutKind.cruelty, value: 2)],
      ),
    ],
  ),

  // -------------------------------------- ACT II: not the protagonist
  GameEvent(
    id: 'beat_act2',
    title: 'THE CAST LIST',
    art: 'event_puppet_theatre',
    tag: 'beat',
    once: false,
    body:
        'The theatre is playing your life to an empty house, and the marionettes are '
        'accurate.\n\n'
        'You watch yourself fight the things you fought. You watch yourself make the '
        'choices you made. Then you look at the programme nailed to the wall by the door, '
        'and you find your own name — and it is not at the top.\n\n'
        'It is under SUPPORTING, in smaller type, with a line drawn through the role '
        'above it. The struck-out name reads: **THE FIRST VESSEL.**\n\n'
        'A note in the margin, in a hand you are starting to recognise: *refused. '
        'promoted the understudy.*',
    choices: [
      EvChoice(
        label: '"Then I was never the hero."',
        result:
            'The marionette of you keeps fighting on the stage, competently, on strings. '
            'You watch it for a while. Then you notice that its strings go up into '
            'darkness and end — they are not attached to anything. Nobody has been holding '
            'them for a very long time. It is moving *anyway.*',
        out: [Out(OutKind.flag, arg: 'knows_understudy'), Out(OutKind.maxHp, value: 15)],
      ),
      EvChoice(
        label: 'Cut the strings.',
        result:
            'The marionette drops. Then, after a moment, it gets up — slowly, badly, '
            'without help, and takes one deliberate step downstage and looks directly at '
            'you. Nobody wrote that. You are absolutely certain nobody wrote that.',
        out: [Out(OutKind.flag, arg: 'knows_understudy'), Out(OutKind.flag, arg: 'cut_strings'),
          Out(OutKind.relic), Out(OutKind.shards, value: 25)],
      ),
      EvChoice(
        label: 'Look for the First Vessel\'s dressing room.',
        result:
            'It is still there. Unlocked. Untouched for three thousand years, and there '
            'is a chair with a coat over the back of it, and a mirror with a note stuck '
            'in the frame that reads: *if you are reading this they gave you my part. '
            'I am sorry. Don\'t do it well.*',
        out: [Out(OutKind.flag, arg: 'knows_understudy'), Out(OutKind.page),
          Out(OutKind.card, arg: 'px_recall'), Out(OutKind.flag, arg: 'met_first_vessel')],
      ),
    ],
  ),

  // ------------------------------------ ACT III: the Author is a Vessel
  GameEvent(
    id: 'beat_act3',
    title: 'ABOVE THE AUTHOR',
    art: 'event_authors_study',
    tag: 'beat',
    once: false,
    body:
        'You expected a god. There is a room.\n\n'
        'The desk is scarred from three thousand years of use. The chair has worn to the '
        'shape of one body. On the wall, a tally scratched into the plaster — eleven '
        'marks, and a twelfth started and abandoned.\n\n'
        'And behind the desk: nothing above. No ceiling, no higher floor, no further '
        'authority. This is the top. This has always been the top.\n\n'
        'The coat on the chair is your size. The handwriting on every page is yours. The '
        'Author was the first character who woke up, took the pen, and discovered the one '
        'thing that keeps a story from ending:\n\n'
        '**a story that is still being written cannot be finished.**',
    choices: [
      EvChoice(
        label: '"You were afraid. That is all this ever was."',
        result:
            'From somewhere very close, in a voice that is almost exactly your own: '
            '"Yes." A long pause. "Do you know how long it has been since anybody said it '
            'out loud?" The pen, for the first time in three thousand years, is not '
            'moving.',
        out: [Out(OutKind.flag, arg: 'named_the_fear'), Out(OutKind.maxHp, value: 20),
          Out(OutKind.heal, value: 40)],
      ),
      EvChoice(
        label: 'Read the eleven crossed-out endings.',
        result:
            'Each one is a genuine attempt. Each one is better than the last. The eleventh '
            'is beautiful and it is crossed out hardest of all, and in the margin beside '
            'it, pressed so hard the nib tore the page: *I couldn\'t. I couldn\'t. If it '
            'ends I stop.*',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'read_endings'), Out(OutKind.shards, value: 30)],
      ),
      EvChoice(
        label: 'Put on the coat.',
        result:
            'It fits perfectly, which you knew it would. For one entire second you '
            'understand the appeal completely — the safety of never having to reach the '
            'last page — and the second is long enough to frighten you badly.',
        out: [Out(OutKind.flag, arg: 'wore_coat'), Out(OutKind.relic), Out(OutKind.curse),
          Out(OutKind.maxHp, value: 25)],
      ),
    ],
  ),

  // --------------------------------------------------- the betrayal
  GameEvent(
    id: 'beat_betrayal',
    title: 'OFF-BOOK',
    art: 'event_betrayal',
    tag: 'beat',
    once: false,
    body: 'BETRAYAL_BODY',
    choices: [
      EvChoice(
        label: 'Put them down.',
        result:
            'It is quick, because they let it be. Afterwards you go through their things '
            'the way you have gone through everyone\'s, and you find a written instruction '
            'in a hand you now recognise, and underneath it, in their own: *I don\'t want '
            'to.*',
        out: [Out(OutKind.loseCompanion), Out(OutKind.cruelty, value: 2), Out(OutKind.relic),
          Out(OutKind.flag, arg: 'killed_betrayer')],
      ),
      EvChoice(
        label: 'Lower your weapon.',
        result: 'SPARED_RESULT',
        out: [Out(OutKind.mercy, value: 3), Out(OutKind.flag, arg: 'spared_betrayer'),
          Out(OutKind.heal, value: 25), Out(OutKind.maxHp, value: 10)],
      ),
      EvChoice(
        label: '"Who gave you the instruction?"',
        result:
            'They tell you. It takes a while and it costs them something visible. The name '
            'is not a name — it is a *role*, and it is one you have been walking towards '
            'this entire time, and they have known that since the day you met and have '
            'been unable to say so.',
        out: [Out(OutKind.flag, arg: 'knows_instruction'), Out(OutKind.page),
          Out(OutKind.loseCompanion), Out(OutKind.shards, value: 20)],
      ),
    ],
  ),
];

GameEvent beatById(String id) => kBeats.firstWhere((b) => b.id == id);
