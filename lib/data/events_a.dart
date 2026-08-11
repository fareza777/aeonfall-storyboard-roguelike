import 'narrative_model.dart';


/// Core wandering events. Choices set flags that later events read, so a run
/// accumulates a shape rather than a list of unrelated scenes.
const kEventsA = <GameEvent>[
  GameEvent(
    id: 'merchant_hours',
    title: 'THE MERCHANT OF BROKEN HOURS',
    art: 'event_merchant_hours',
    weight: 12,
    body:
        'His cart is full of clocks, and none of them agree. "Time in this draft is '
        'hand-wound," he says, tapping a jar in which something small is ticking. "I sell '
        'the hours people didn\'t use. Sleepers, mostly. Cowards. The very content."\n\n'
        'He looks at you with sudden, uncomfortable attention.\n\n'
        '"You have a great deal of unused time on you. More than a person should. Would '
        'you like to know why, or would you like to be paid?"',
    choices: [
      EvChoice(
        label: 'Ask why.',
        result:
            '"Because you have been here before," he says simply, and goes back to '
            'polishing a face. "Several thousand times. Your hours never get spent, they '
            'get *returned*." He shrugs. "I don\'t know what to make of it either. But '
            'here — knowledge is heavy. Carry something to balance it."',
        out: [Out(OutKind.flag, arg: 'knows_loop'), Out(OutKind.relic)],
      ),
      EvChoice(
        label: 'Take the payment.',
        hint: 'Sell your unused hours',
        result:
            'He counts out Aeon into your palm, more than you expected, and will not meet '
            'your eye while he does it. "Don\'t spend it all in one draft," he says, and '
            'does not laugh.',
        out: [Out(OutKind.gold, value: 180), Out(OutKind.hp, value: 8)],
      ),
      EvChoice(
        label: 'Smash the jar.',
        result:
            'The ticking stops. Somewhere behind you, very faintly, a bell that has been '
            'ringing your whole life stops with it. The merchant stares at the wreckage '
            'and then, unexpectedly, starts to laugh. "Oh, you *are* the interesting one," '
            'he says. "Take this. You\'ll want it."',
        out: [Out(OutKind.cruelty, value: 1), Out(OutKind.card, arg: 'px_reversal'), Out(OutKind.flag, arg: 'broke_clock')],
      ),
    ],
  ),
  GameEvent(
    id: 'two_doors',
    title: 'TWO DOORS, ONE LIE',
    art: 'event_two_doors',
    weight: 12,
    body:
        'Two doors stand free in the fog, unattached to any wall. The left one leaks a '
        'thin gold light. The right one leaks ink, slowly, from under the sill.\n\n'
        'Carved into the lintel above both, in a hand that shakes: ONE OF THESE IS A '
        'SHORTCUT. THE OTHER IS ALSO A SHORTCUT. I AM SORRY.',
    choices: [
      EvChoice(
        label: 'The door of light.',
        result:
            'It opens onto a warm room, and the warm room opens onto the road again, '
            'about a mile ahead. Something in you is lighter. Something else is missing '
            'and you cannot name it.',
        out: [Out(OutKind.heal, value: 22), Out(OutKind.removeCard)],
      ),
      EvChoice(
        label: 'The door of ink.',
        result:
            'It is not a room. It is the underside of a page — a lattice of pen-strokes '
            'seen from behind, and you can read them, and they are about you. You come out '
            'of it changed and holding something you did not have.',
        out: [Out(OutKind.relic), Out(OutKind.curse), Out(OutKind.flag, arg: 'saw_underside')],
      ),
      EvChoice(
        label: 'Walk between them.',
        hidden: true,
        result:
            'There is no wall. You simply walk between the two doors, and both of them '
            'slam behind you at once, offended. In the space where they were, a single '
            'torn page is drifting down. You catch it.',
        out: [Out(OutKind.page), Out(OutKind.shards, value: 12)],
      ),
    ],
  ),
  GameEvent(
    id: 'child_remembers',
    title: 'THE CHILD WHO REMEMBERS',
    art: 'event_child_remembers',
    weight: 11,
    body:
        'A child sits in the middle of a ruined street with a drawing on their knees. '
        'They hold it up as you approach, patiently, the way you show a thing to someone '
        'who has forgotten it.\n\n'
        'It is you. It is you lying down, in this street, at an angle a living body does '
        'not make. The drawing is old. The paper has gone soft at the folds from being '
        'held a great many times.\n\n'
        '"You\'re late," the child says, not unkindly. "You\'re usually here on the '
        'Tuesday."',
    choices: [
      EvChoice(
        label: '"How many times have you drawn this?"',
        result:
            'The child thinks about it seriously. "I run out of fingers," they say. Then, '
            'brightening: "But you\'ve never asked before! That\'s new. I\'ll draw that '
            'one too." They start a fresh page. Something in your chest unclenches by a '
            'degree you did not know was available.',
        out: [Out(OutKind.flag, arg: 'knows_loop'), Out(OutKind.maxHp, value: 8), Out(OutKind.mercy, value: 1)],
      ),
      EvChoice(
        label: 'Take the drawing and walk away.',
        result:
            'The child does not protest. Later you look at it again and the figure on the '
            'ground has shifted position slightly, as though settling. You put it away and '
            'do not look at it again for a long time.',
        out: [Out(OutKind.page), Out(OutKind.hp, value: 6)],
      ),
      EvChoice(
        label: 'Sit down and let them draw you alive.',
        result:
            'It takes an hour. The child is not a good artist but they are a determined '
            'one, and at the end of it there is a picture of you standing up, in this '
            'street, on this Tuesday. They give it to you very solemnly. "Now there\'s '
            'two," they say.',
        out: [Out(OutKind.heal, value: 30), Out(OutKind.mercy, value: 2), Out(OutKind.flag, arg: 'drawn_alive')],
      ),
    ],
  ),
  GameEvent(
    id: 'auction_names',
    title: 'THE AUCTION OF NAMES',
    art: 'event_auction_names',
    weight: 10,
    body:
        'A candlelit hall. Masked bidders. On the block, in a small glass case, a single '
        'word — someone\'s name, removed intact.\n\n'
        '"Lot forty-one," the auctioneer announces. "A good name. Two syllables. Four '
        'people still respond to it." The bidding is brisk.\n\n'
        'Lot forty-two, you notice, is already in its case. You can read it from here. '
        'It is yours. You did not know you had one.',
    choices: [
      EvChoice(
        label: 'Buy your own name back.',
        hint: 'Costs 200 Aeon',
        needGold: 200,
        result:
            'Nobody bids against you. The room goes very quiet while you pay, and the '
            'auctioneer hands the case over with something like respect. You do not open '
            'it yet. But you know it is there, and knowing changes how you stand.',
        out: [Out(OutKind.flag, arg: 'has_name'), Out(OutKind.maxHp, value: 15)],
      ),
      EvChoice(
        label: 'Buy lot forty-one instead. Give it back to whoever answers.',
        hint: 'Costs 140 Aeon',
        needGold: 140,
        result:
            'You find one of the four in the street outside, a woman who has been calling '
            'herself "you there" for eleven years. When you give it back she says it aloud '
            'twice and then cannot speak at all. She presses something into your hand '
            'without looking at you.',
        out: [Out(OutKind.mercy, value: 2), Out(OutKind.relic), Out(OutKind.flag, arg: 'gave_name')],
      ),
      EvChoice(
        label: 'Burn the ledger.',
        result:
            'Every case in the room cracks at once. Names go up like startled birds. It '
            'is chaos, and it is arguably a public service, and several very powerful '
            'people will remember your face. You leave rich and hunted.',
        out: [Out(OutKind.gold, value: 220), Out(OutKind.cruelty, value: 1), Out(OutKind.curse)],
      ),
    ],
  ),
  GameEvent(
    id: 'aging_mirror',
    title: 'THE MIRROR THAT AGES',
    art: 'event_aging_mirror',
    weight: 10,
    body:
        'The mirror is tall, cracked corner to corner, and it does not show the room.\n\n'
        'It shows you at sixty. Lined, grey, sitting in a chair by a window with ordinary '
        'light coming through it. You are holding a cup. You look tired in the specific '
        'way of someone who has been tired for years and does not mind.\n\n'
        'You have never once considered that you might get to be sixty.',
    choices: [
      EvChoice(
        label: 'Reach out and touch the glass.',
        result:
            'The old version of you looks up — not startled, expectant. They mouth '
            'something. You cannot hear it, but you can read it, and it is: *keep going, '
            'it is worth it, keep going.* Then the glass is just glass.',
        out: [Out(OutKind.heal, value: 25), Out(OutKind.maxHp, value: 10), Out(OutKind.flag, arg: 'saw_old_self')],
      ),
      EvChoice(
        label: 'Break it.',
        result:
            'You are still holding the shard when you realise it is showing the same room, '
            'the same chair, and the chair is empty. You put it in your pocket. It is '
            'extremely sharp.',
        out: [Out(OutKind.card, arg: 'ae_execute'), Out(OutKind.hp, value: 10), Out(OutKind.cruelty, value: 1)],
      ),
      EvChoice(
        label: 'Turn it to face the wall.',
        result:
            'You do it gently, the way you would turn down a photograph of someone you '
            'are not ready to look at. Something eases. You walk on with a steadier '
            'hand than you arrived with.',
        out: [Out(OutKind.heal, value: 14), Out(OutKind.upgradeCard)],
      ),
    ],
  ),
  GameEvent(
    id: 'campfire',
    title: 'CAMPFIRE CONFESSION',
    art: 'event_campfire',
    weight: 12,
    requireFlag: 'has_companion',
    body:
        'The fire is small and the night is very large. Your companion has been quiet for '
        'a long time — long enough that the quiet has become a thing being carried rather '
        'than a thing happening.\n\n'
        'Finally: "Can I tell you something I have never told anyone, in any of them?"',
    choices: [
      EvChoice(
        label: 'Listen.',
        result:
            'They talk for an hour. Most of it is not important. The important part is '
            'about four sentences long and arrives in the middle, unannounced, and neither '
            'of you comments on it. In the morning they walk closer to you than before.',
        out: [Out(OutKind.flag, arg: 'bonded'), Out(OutKind.heal, value: 18), Out(OutKind.mercy, value: 1)],
      ),
      EvChoice(
        label: 'Tell them yours first.',
        result:
            'You do not have one. You reach for a memory that is your own and find only '
            'the road, and before the road nothing. You say so. Your companion takes this '
            'in and then says, carefully: "Then I\'ll hold mine until you\'ve got one. So '
            'it\'s even."',
        out: [Out(OutKind.flag, arg: 'bonded'), Out(OutKind.maxHp, value: 8)],
      ),
      EvChoice(
        label: 'Say you would rather sleep.',
        result:
            'They nod, easily, as though it costs nothing. It costs something. You both '
            'lie down. Neither of you sleeps, and in the morning the distance between your '
            'bedrolls is measurable.',
        out: [Out(OutKind.flag, arg: 'refused_bond'), Out(OutKind.gold, value: 60)],
      ),
    ],
  ),
  GameEvent(
    id: 'wounded_companion',
    title: 'THE WOUNDED',
    art: 'event_wounded_companion',
    weight: 11,
    body:
        'They are slumped against a broken wall, and the wound is bad, and they know it. '
        'A stranger — nobody you have met, nobody who is going to matter to the plot.\n\n'
        '"Don\'t," they say, when you crouch. "I\'ve seen how this goes. You use something '
        'up on me and then you\'re short later and then you don\'t make it either." They '
        'try to smile. "I did the arithmetic. It doesn\'t work."',
    choices: [
      EvChoice(
        label: 'Do it anyway.',
        result:
            'You give up something you will want later. They live. They are so surprised '
            'to be alive that they cannot manage to say anything at all, and instead press '
            'their only possession into your hand and hold it there.',
        out: [Out(OutKind.hp, value: 16), Out(OutKind.relic), Out(OutKind.mercy, value: 2), Out(OutKind.flag, arg: 'saved_stranger')],
      ),
      EvChoice(
        label: 'Sit with them until it is over.',
        result:
            'It takes about twenty minutes. You do not fill it with anything. Afterwards '
            'you find you are steadier than you were, in the way people are after doing '
            'the difficult correct thing rather than the difficult impressive one.',
        out: [Out(OutKind.mercy, value: 1), Out(OutKind.upgradeCard), Out(OutKind.heal, value: 10)],
      ),
      EvChoice(
        label: 'Take what they are carrying and go.',
        result:
            'They do not argue. That is somehow the worst part — they simply watch you do '
            'it, having already predicted it, and their arithmetic remains unspoiled.',
        out: [Out(OutKind.gold, value: 130), Out(OutKind.cruelty, value: 2), Out(OutKind.curse)],
      ),
    ],
  ),
  GameEvent(
    id: 'ink_contract',
    title: 'INK AND BLOOD',
    art: 'event_ink_contract',
    weight: 10,
    body:
        'A stone altar. A quill. A contract, already written, in language so clear it is '
        'insulting:\n\n'
        '*The signatory shall be granted power sufficient to reach the top.*\n'
        '*The signatory shall arrive there as something the top will recognise as its own.*\n\n'
        'There is a space for a name. You are not sure you have one to put in it.',
    choices: [
      EvChoice(
        label: 'Sign it.',
        result:
            'The quill does not need ink. Power arrives immediately and physically, like '
            'stepping into a hot bath, and something small and specific goes out of you at '
            'the same moment, and you do not notice which until much later.',
        out: [Out(OutKind.relic), Out(OutKind.maxHp, value: 20), Out(OutKind.curse), Out(OutKind.flag, arg: 'signed')],
      ),
      EvChoice(
        label: 'Sign someone else\'s name.',
        result:
            'You write THE AUTHOR in a careful hand. The contract considers this for an '
            'uncomfortably long moment. Then it burns, and the power arrives anyway, and '
            'somewhere very far above you a pen stops moving for the first time in '
            'three thousand years.',
        out: [Out(OutKind.relic), Out(OutKind.flag, arg: 'forged_signature'), Out(OutKind.shards, value: 20)],
      ),
      EvChoice(
        label: 'Break the quill.',
        result:
            'It snaps like a finger. The altar cracks. Nothing else happens, and you walk '
            'away with exactly what you came in with, which is, you are beginning to '
            'suspect, the entire point.',
        out: [Out(OutKind.mercy, value: 1), Out(OutKind.heal, value: 20), Out(OutKind.flag, arg: 'broke_quill_once')],
      ),
    ],
  ),
  GameEvent(
    id: 'loop_revealed',
    title: 'THE CORRIDOR',
    art: 'event_loop_revealed',
    weight: 8,
    act: 2,
    body:
        'The corridor is circular and it is lined with bodies.\n\n'
        'They are all you. Some are recent. Some have been here long enough to be dust in '
        'the shape of a person. They are arranged with care — someone has laid each one '
        'out, closed the eyes, straightened the hands.\n\n'
        'You count to forty and stop counting, and the corridor continues, and it is '
        'circular, which means it has no end.',
    choices: [
      EvChoice(
        label: 'Look for the oldest one.',
        result:
            'You find it eventually: not dust, but a *sketch* — a body drawn in rough '
            'pencil, unfinished, never inked. The first one. It is holding a torn page in '
            'its hand and it has been holding it for three thousand drafts, waiting for '
            'somebody to come far enough back to take it.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'knows_loop'), Out(OutKind.maxHp, value: 12)],
      ),
      EvChoice(
        label: 'Straighten the newest one\'s hands, the way the others were.',
        result:
            'You realise, doing it, that you are the one who has been doing this. Every '
            'time. Arriving, finding them, arranging them, and then going on to become the '
            'next one somebody arranges. It is the only continuous act of care in three '
            'thousand years and you have been performing it without knowing.',
        out: [Out(OutKind.mercy, value: 3), Out(OutKind.heal, value: 40), Out(OutKind.flag, arg: 'tended_dead')],
      ),
      EvChoice(
        label: 'Take everything they are carrying.',
        result:
            'It is a great deal. Forty of you have been well equipped and none of them '
            'needed it in the end. You leave heavy, and you do not look at their faces '
            'while you work, and that is a decision you have now made.',
        out: [Out(OutKind.gold, value: 260), Out(OutKind.relic), Out(OutKind.cruelty, value: 3), Out(OutKind.curse)],
      ),
    ],
  ),
  GameEvent(
    id: 'burning_library',
    title: 'THE BURNING LIBRARY',
    art: 'event_burning_library',
    weight: 11,
    body:
        'The fire has about four minutes left to run and the library has considerably '
        'less. Three shelves are still reachable.\n\n'
        'One holds histories — every draft, catalogued. One holds blank books, thousands '
        'of them, unwritten. One holds a single volume, thin, with your handwriting on '
        'the spine, though you have never written anything.',
    choices: [
      EvChoice(
        label: 'Save the histories.',
        result:
            'You come out with three volumes and a burn along one forearm. They are '
            'catalogues of endings — every way this world has been crumpled. It is '
            'grim reading and it is *useful* reading.',
        out: [Out(OutKind.card, arg: 'px_annotate'), Out(OutKind.flag, arg: 'read_histories'), Out(OutKind.hp, value: 10)],
      ),
      EvChoice(
        label: 'Save the blank books.',
        result:
            'You get an armful of empty pages out of a burning building, which is an '
            'objectively ridiculous thing to have done, and you cannot say why it felt '
            'urgent. It keeps not feeling like a mistake.',
        out: [Out(OutKind.page), Out(OutKind.shards, value: 15), Out(OutKind.flag, arg: 'saved_blanks')],
      ),
      EvChoice(
        label: 'Save the thin volume with your handwriting.',
        result:
            'It is a diary. It is your diary. It covers eleven days you have never lived '
            'and it ends mid-sentence, and the last words are: *if you are reading this '
            'then it worked, do not trust the one who*',
        out: [Out(OutKind.flag, arg: 'read_diary'), Out(OutKind.maxHp, value: 10), Out(OutKind.relic)],
      ),
    ],
  ),
  GameEvent(
    id: 'iron_confessional',
    title: 'THE IRON CONFESSIONAL',
    art: 'event_iron_confessional',
    weight: 10,
    body:
        'A confessional booth of riveted iron stands alone in a field. Both doors are '
        'sealed. From inside, something is scratching — patiently, evenly, the way you '
        'scratch when you have been at it for centuries and have no expectation of '
        'finishing.\n\n'
        'A brass plate on the penitent\'s door reads: SEALED BY REQUEST OF THE OCCUPANT.',
    choices: [
      EvChoice(
        label: 'Sit down on the priest\'s side and listen.',
        result:
            'The scratching stops. A voice, cracked to nothing, says: "Oh. Oh, thank you." '
            'And then it confesses, for a long time, and none of it is remarkable — small '
            'unkindnesses, mostly, from a life nobody remembers. At the end it says: '
            '"Is that all right?" and you say yes, and it goes quiet in a way that is '
            'clearly rest.',
        out: [Out(OutKind.mercy, value: 2), Out(OutKind.maxHp, value: 14), Out(OutKind.relic, arg: 'mercy_blade')],
      ),
      EvChoice(
        label: 'Break the seal.',
        result:
            'There is nobody inside. There is a set of fingernail grooves in the iron '
            'going back four hundred years and there has never been anybody inside, and '
            'the scratching continues after you open it, from somewhere slightly to the '
            'left of where the sound should be.',
        out: [Out(OutKind.curse), Out(OutKind.relic), Out(OutKind.flag, arg: 'opened_booth')],
      ),
      EvChoice(
        label: 'Leave it alone.',
        result:
            'You walk on. The scratching follows for about a mile, at exactly your pace, '
            'and then stops all at once, and you find you have been holding your breath '
            'for some time.',
        out: [Out(OutKind.gold, value: 45)],
      ),
    ],
  ),
  GameEvent(
    id: 'thief_of_faces',
    title: 'THE THIEF OF FACES',
    art: 'event_thief_of_faces',
    weight: 10,
    body:
        'You catch it mid-theft: a thin figure peeling a sleeping man\'s face off like '
        'wet paper, with real care, the way you would remove a bandage.\n\n'
        'It freezes. Then, reasonably: "He isn\'t using it. He hasn\'t used it in four '
        'drafts. He sleeps through all of them." A pause. "I have never had one. Not one, '
        'in three thousand years. Do you know what that is like?"',
    choices: [
      EvChoice(
        label: '"Take mine instead. I\'ll manage."',
        result:
            'It does not believe you until you are already holding still. The theft is '
            'quick and does not hurt. Afterwards you have no reflection, which is '
            'inconvenient, and no one can quite describe you afterwards, which is '
            'extraordinarily useful.',
        out: [Out(OutKind.relic, arg: 'moth_wing'), Out(OutKind.maxHp, value: -10), Out(OutKind.mercy, value: 3), Out(OutKind.flag, arg: 'gave_face')],
      ),
      EvChoice(
        label: 'Stop it and wake the man.',
        result:
            'The man wakes, screams, and runs. The thief watches him go with an expression '
            'that has nowhere to sit. "He didn\'t even look at it," it says. Then it '
            'leaves, and you are certain you have done the correct thing and cannot get '
            'comfortable about it.',
        out: [Out(OutKind.gold, value: 90), Out(OutKind.card, arg: 'ae_marked')],
      ),
      EvChoice(
        label: 'Kill it.',
        result:
            'It does not fight. Under the coat there is nothing at all — a hollow, a shape '
            'with no interior, and it collapses like a dropped sheet. Among the folds you '
            'find every face it ever tried on. None of them fit it. It had been trying.',
        out: [Out(OutKind.relic), Out(OutKind.cruelty, value: 2), Out(OutKind.shards, value: 10)],
      ),
    ],
  ),
];
