import 'narrative_model.dart';

/// Fifth event book — Act III. The tower, the desk, and the things that live
/// close enough to the top to have opinions about it.
const kEventsE = <GameEvent>[
  GameEvent(
    id: 'the_waiting_room',
    title: 'THE WAITING ROOM',
    art: 'event_waiting_room',
    weight: 11,
    act: 3,
    body:
        'Chairs against three walls, a closed door in the fourth, and eleven people who have '
        'been here long enough to have stopped pretending to read.\n\n'
        'They are the eleven crossed-out endings. Not descriptions of them — them. Each one is '
        'a complete, finished, workable conclusion to this story, sitting in a chair, waiting '
        'to be called, and none of them has been called.\n\n'
        'The eleventh is the youngest and the most beautiful and is sitting closest to the door.',
    plain: 'Eleven rejected endings wait in a room. Talk to one, open the door, or sit with them.',
    choices: [
      EvChoice(
        label: 'Talk to the eleventh.',
        result:
            'It is gracious about it. It explains itself in about four sentences and the four '
            'sentences are the best case anybody has ever made for anything, and then it says: '
            '"He got as far as the last line. It is a good last line. He has never been able to '
            'write it down, because writing it down is the part where it is over."',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'read_endings'),
          Out(OutKind.maxHp, value: 18), Out(OutKind.shards, value: 40)],
      ),
      EvChoice(
        label: 'Open the door yourself.',
        result:
            'Every one of them looks up. The door is not locked and has never been locked, and '
            'behind it is a corridor, and the corridor goes up.\n\n'
            'Not one of them stands. "We are not allowed to go through," says the third. "We are '
            'allowed to be called." The distinction has held them here for three thousand years '
            'and is, on inspection, a rule that only exists because everyone in the room has '
            'agreed to it.',
        out: [Out(OutKind.flag, arg: 'opened_the_door'), Out(OutKind.page),
          Out(OutKind.relic), Out(OutKind.shards, value: 35)],
      ),
      EvChoice(
        label: 'Sit down and wait with them.',
        result:
            'An hour. Nobody says much. It is the only room in Aevum where nobody wants anything '
            'from you, and when you get up to go the fourth one says "good luck" and the others '
            'take it up, one after another, all eleven of them, and none of them mean it '
            'competitively.',
        out: [Out(OutKind.heal, value: 40), Out(OutKind.mercy, value: 3),
          Out(OutKind.maxHp, value: 14), Out(OutKind.flag, arg: 'sat_with_endings')],
      ),
    ],
  ),

  GameEvent(
    id: 'the_ink_well',
    title: 'THE SUPPLY',
    art: 'event_ink_well',
    weight: 10,
    act: 3,
    body:
        'A cistern the size of a cathedral, three-quarters empty, with a tide line showing '
        'where it used to be full. Everything in this world is made of what is in here and '
        'there is not very much left.\n\n'
        'A steward is taking a measurement, which is what he does, and writing it in a book '
        'below three thousand previous measurements, every one of them lower than the last.\n\n'
        '"He does not know," the steward says. "He has never once asked."',
    plain: 'The world\'s ink supply is running out and the Author has never asked. Tell him, take some, or read the book.',
    choices: [
      EvChoice(
        label: 'Take a measure of it with you.',
        result:
            'The steward fills a flask without being asked and hands it over, and says "That is '
            'about four minutes of world," in the tone of somebody quoting a figure they think '
            'about constantly. It is the single most valuable object you have carried.',
        out: [Out(OutKind.relic), Out(OutKind.shards, value: 50),
          Out(OutKind.flag, arg: 'carry_the_ink')],
      ),
      EvChoice(
        label: 'Read three thousand years of measurements.',
        result:
            'The curve is not steady. It is fine for the first eight hundred years and then '
            'there is a step — one Fall where an enormous amount went out at once — and after '
            'that the decline is constant and identical, every draft, as though the same amount '
            'is being spent on the same thing over and over.\n\n'
            'The step is at draft nine.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'knows_the_ninth'),
          Out(OutKind.shards, value: 45), Out(OutKind.maxHp, value: 12)],
      ),
      EvChoice(
        label: 'Take the book to the top and show him.',
        hidden: true,
        result:
            'The steward stares at you. Then he tears out the last four hundred pages, folds '
            'them, and puts them into your hands with both of his.\n\n"Three thousand years I '
            'have been keeping this," he says, "and it has never once occurred to me that it '
            'could be *shown to him*. That is — " He stops. "That is a very stupid thing for me '
            'not to have thought of."',
        out: [Out(OutKind.page), Out(OutKind.page), Out(OutKind.flag, arg: 'carrying_the_ledger'),
          Out(OutKind.relic), Out(OutKind.mercy, value: 3)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_first_vessels_room',
    title: 'THE FIRST ONE\'S ROOM',
    art: 'event_first_vessels_room',
    weight: 10,
    act: 3,
    body:
        'Somebody lived here before all of this. Before there was a road, before there were '
        'Falls, when there was one Vessel and one story and nobody had yet needed the word '
        '"draft".\n\n'
        'It is a good room. Small, warm, arranged by somebody who intended to stay. There are '
        'books they were partway through and a meal they did not finish and a coat on a hook '
        'that is your size.\n\n'
        'On the desk, one page, face down.',
    plain: 'The First Vessel\'s untouched room. Read the page, take the coat, or leave it as it is.',
    choices: [
      EvChoice(
        label: 'Turn the page over.',
        result:
            'It is a resignation. Formal, brief, and courteous — a person declining, in writing, '
            'to be the protagonist of something, and giving their reasons, and the reasons are '
            'good.\n\nIt was never delivered. It is face down on the desk because they never got '
            'the chance to hand it to anybody, and everything that has happened in three '
            'thousand years is downstream of a letter nobody read.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'met_first_vessel'),
          Out(OutKind.shards, value: 45), Out(OutKind.maxHp, value: 14)],
      ),
      EvChoice(
        label: 'Take the coat.',
        result:
            'It fits and it is warm and it has been waiting on a hook for three thousand years '
            'for somebody it fits.\n\nIn the inside pocket, worn soft from being carried: a list '
            'of eleven things to do that day. Ten are crossed off. The eleventh is *tell him*.',
        out: [Out(OutKind.relic), Out(OutKind.page), Out(OutKind.maxHp, value: 16),
          Out(OutKind.flag, arg: 'wore_the_first_coat')],
      ),
      EvChoice(
        label: 'Eat the meal. Sit in the chair. Stay an hour.',
        result:
            'The food is still good, because nothing here has been allowed to move on. You sit '
            'in somebody\'s chair in somebody\'s room and finish somebody\'s meal, and for one '
            'hour this is a place where a person lives rather than a place where a person '
            'stopped, and the room is visibly better for it.',
        out: [Out(OutKind.heal, value: 50), Out(OutKind.mercy, value: 3),
          Out(OutKind.maxHp, value: 12), Out(OutKind.flag, arg: 'stayed_in_the_room')],
      ),
    ],
  ),

  GameEvent(
    id: 'the_last_companion',
    title: 'THE ONE WHO STAYED',
    art: 'event_last_companion',
    weight: 10,
    act: 3,
    body:
        'They are still walking beside you and you have both now been up the switchbacks long '
        'enough that the ground has stopped pretending to be ground.\n\n'
        'They stop. "You know I was given an instruction," they say. "Everyone was. You worked '
        'that out two acts ago and you have been polite about it since, and I would rather we '
        'did not go up there with it unsaid."\n\n'
        'They take something out of their pack and hold it, not offering it, just holding it '
        'where you can see it.',
    plain: 'Your companion admits they were given orders about you. Ask, forgive, or send them away.',
    choices: [
      EvChoice(
        label: '"What was the instruction?"',
        result:
            '"Make sure you get there," they say. "That is all it says. It does not say alive." '
            'They turn the thing over in their hands. "I have assumed for two acts that it meant '
            'the second one, and I have been carrying this in case, and I have decided on the '
            'way up that I am not going to find out which it meant."\n\nThey drop it down the '
            'slope. It goes a long way.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'companion_chose'),
          Out(OutKind.maxHp, value: 20), Out(OutKind.mercy, value: 3), Out(OutKind.relic)],
      ),
      EvChoice(
        label: '"It does not matter. Keep walking."',
        result:
            'They do not accept that, exactly, but they accept that you have said it, and they '
            'fall back into step. The thing stays in their hand for another hundred yards and '
            'then goes into the pack, and neither of you mentions it again, and it is in the '
            'pack at the top.',
        out: [Out(OutKind.maxHp, value: 12), Out(OutKind.flag, arg: 'let_it_lie'),
          Out(OutKind.shards, value: 25)],
      ),
      EvChoice(
        label: 'Send them back down.',
        result:
            'They argue and you do not, and eventually they go, and about forty yards down they '
            'turn round and shout the thing they were told about the fight at the top — the '
            'whole thing, everything they were briefed with, at the top of their voice, into a '
            'wind that is carrying it in exactly the wrong direction for anybody else to hear.',
        out: [Out(OutKind.loseCompanion), Out(OutKind.page), Out(OutKind.relic),
          Out(OutKind.upgradeCard), Out(OutKind.flag, arg: 'sent_them_down')],
      ),
    ],
  ),

  GameEvent(
    id: 'the_scaffold',
    title: 'THE SCAFFOLD',
    art: 'event_scaffold',
    weight: 10,
    act: 3,
    body:
        'The tower is not finished. From this close you can see that it never was — the top '
        'forty feet are scaffolding and construction lines, and the scaffolding has been up so '
        'long that it has been repaired more often than the building.\n\n'
        'There is a foreman\'s hut at the base with a schedule pinned inside. The completion '
        'date has been crossed out and rewritten three thousand times and the current one is '
        'blank.\n\n'
        'Nobody has worked on it since the first Fall. The scaffolding is load-bearing now.',
    plain: 'The tower was never finished; its scaffolding now holds it up. Climb it, study it, or take it down.',
    choices: [
      EvChoice(
        label: 'Climb the scaffolding rather than the stair.',
        result:
            'Faster, more dangerous, and completely outside the route anybody intended. Two '
            'thirds of the way up you pass a level with no door onto it — a whole floor that '
            'was drawn and then sealed — and you get a look through a gap at what is in there '
            'before the wind moves you on.',
        out: [Out(OutKind.page), Out(OutKind.relic), Out(OutKind.hp, value: 14),
          Out(OutKind.flag, arg: 'climbed_outside')],
      ),
      EvChoice(
        label: 'Read three thousand crossed-out completion dates.',
        result:
            'The intervals are the giveaway. They are not random. Every single date is exactly '
            'one draft further out, set the day after a Fall, by somebody who sits down after '
            'destroying a world and immediately schedules the finish of the building.\n\n'
            'The current one is blank because for the first time nobody has set a new date.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'knows_no_date'),
          Out(OutKind.shards, value: 45), Out(OutKind.maxHp, value: 12)],
      ),
      EvChoice(
        label: 'Start taking the scaffolding down.',
        hidden: true,
        result:
            'You get four sections off before you understand what you are doing, and what you are '
            'doing is forcing the issue: a building cannot stay unfinished forever if the thing '
            'holding it up is gone.\n\nIt does not fall. It leans, very slightly, in a direction '
            'it has not leaned in three thousand years, and somewhere above you a pen stops.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'forced_the_issue'),
          Out(OutKind.relic), Out(OutKind.hp, value: 20), Out(OutKind.shards, value: 50)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_understudy_final',
    title: 'THE LAST BENCH',
    art: 'event_understudy_final',
    weight: 10,
    act: 3,
    body:
        'It is sitting on the bottom step of the last stair, out of costume, with its hands '
        'between its knees.\n\n'
        '"I am not going to fight you," it says. "I worked it out on the way here." It looks '
        'up. "If I take the part, I become the person who took the part. That is the whole '
        'mechanism. That is what happened to him." A long pause. "He was an understudy too. '
        'Nobody ever says that out loud."',
    plain: 'The Understudy has given up the fight and explains the Author was one too. Listen, invite, or pass.',
    choices: [
      EvChoice(
        label: 'Sit down on the step with it.',
        result:
            'It tells you the whole thing. Three thousand years of preparation reduced to a '
            'twenty-minute briefing, given freely, holding nothing back, by somebody who has '
            'decided that the only useful thing left to do with it is hand it to whoever is '
            'actually going up.',
        out: [Out(OutKind.page), Out(OutKind.upgradeCard), Out(OutKind.upgradeCard),
          Out(OutKind.relic), Out(OutKind.flag, arg: 'took_the_briefing')],
      ),
      EvChoice(
        label: '"Then come up with me. Both of us."',
        result:
            'It says no four times and gets up on the fifth, and does not say anything on the '
            'way, and about halfway up says "this is not in any of the diagrams" in a voice that '
            'is not frightened.',
        out: [Out(OutKind.companion), Out(OutKind.maxHp, value: 22), Out(OutKind.mercy, value: 3),
          Out(OutKind.flag, arg: 'brought_the_understudy')],
      ),
      EvChoice(
        label: 'Walk past it and up.',
        result:
            'It does not stop you and does not call after you. On the fourth landing you realise '
            'you can still hear it breathing below, and that it is still sitting there, and that '
            'it is going to be sitting there regardless of how this goes, which is either the '
            'saddest or the safest position in the building.',
        out: [Out(OutKind.shards, value: 30), Out(OutKind.cruelty, value: 1)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_readers_chair',
    title: 'SOMEBODY IS LOOKING',
    art: 'event_readers_chair',
    weight: 9,
    act: 3,
    body:
        'The light in the stairwell changes and you understand, with complete and unwelcome '
        'clarity, that you are being looked at. Not watched — *read.* There is a difference and '
        'you can feel it.\n\n'
        'Whatever is doing it is not in the building. It is outside the building in a direction '
        'the building does not have.\n\n'
        'On the landing, chalked hastily by somebody who felt this before you: **IF IT IS STILL '
        'LOOKING, YOU ARE STILL HERE. THAT IS THE DEAL. DO NOT BE BORING.**',
    plain: 'Something outside the story is reading you. Perform, ignore it, or address it.',
    choices: [
      EvChoice(
        label: 'Give it something worth looking at.',
        result:
            'You do the next four floors properly — deliberately, well, with your whole attention '
            '— and the light stays, and the attention stays, and you are aware the entire time '
            'that you are doing this for an audience and that doing it for an audience has made '
            'you better at it and that this is exactly the trap the Author fell into.',
        out: [Out(OutKind.upgradeCard), Out(OutKind.upgradeCard), Out(OutKind.maxHp, value: 14),
          Out(OutKind.flag, arg: 'played_to_the_reader')],
      ),
      EvChoice(
        label: 'Ignore it completely.',
        result:
            'It takes real effort and about two floors, and then the light goes ordinary, and '
            'the pressure comes off, and everything is a great deal quieter and very slightly '
            'thinner — the walls a shade less detailed, the sound a little flatter, as though '
            'less is being spent on a scene nobody is watching.',
        out: [Out(OutKind.flag, arg: 'ignored_the_reader'), Out(OutKind.heal, value: 30),
          Out(OutKind.shards, value: 25)],
      ),
      EvChoice(
        label: 'Speak to it directly.',
        hidden: true,
        result:
            'You say: *I know you are there, and I am not doing this for you.*\n\n'
            'The light does not change. But something enormous and entirely outside the building '
            'adjusts its position slightly, the way a person does when a book turns out to be '
            'better than they expected — and you understand, far too late to unknow it, that '
            'being interesting was never the deal. Being *finished* is what would end this.',
        out: [Out(OutKind.page), Out(OutKind.page), Out(OutKind.flag, arg: 'spoke_to_the_reader'),
          Out(OutKind.relic), Out(OutKind.shards, value: 55)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_draft_nine',
    title: 'DRAFT NINE',
    art: 'event_draft_nine',
    weight: 10,
    act: 3,
    body:
        'A landing with a door that is bricked up properly — mortar, matched stone, done by '
        'somebody who intended it to stay bricked.\n\n'
        'Scratched into the brick, not by the mason: **NINE.**\n\n'
        'Everyone in Aevum knows about the ninth Fall the way people know about a thing that is '
        'never described. The ink ledger stepped here. The endings in the waiting room start '
        'being quiet here. Whatever is behind this wall is the reason the last two thousand '
        'years have been the way they have.',
    plain: 'A bricked-up door to the ninth draft. Open it, leave it, or listen.',
    choices: [
      EvChoice(
        label: 'Take the wall down.',
        result:
            'Behind it: a landing exactly like this one, and a stairwell exactly like this one, '
            'and a body on the steps in a coat exactly like yours, sitting up against the wall '
            'with its hands in its lap, having very obviously chosen to sit down and stop.\n\n'
            'Draft nine got further than any of the others. Draft nine got all the way here, and '
            'looked at the last flight, and sat down.',
        out: [Out(OutKind.page), Out(OutKind.page), Out(OutKind.flag, arg: 'knows_the_ninth'),
          Out(OutKind.relic), Out(OutKind.maxHp, value: 16), Out(OutKind.hp, value: 12)],
      ),
      EvChoice(
        label: 'Put your ear to it.',
        result:
            'Nothing for a long time. Then, faintly, from a long way inside: somebody breathing. '
            'Slow, and regular, and unhurried, and absolutely not the breathing of a dead thing '
            'or a trapped one.\n\nSomebody is behind that wall and has been for two thousand '
            'years and is comfortable.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'heard_the_ninth'),
          Out(OutKind.shards, value: 45), Out(OutKind.maxHp, value: 10)],
      ),
      EvChoice(
        label: 'Leave it. Somebody bricked it for a reason.',
        result:
            'You go up. You are entirely certain it was the correct decision and you are also '
            'aware that you have just done, on a small scale, the exact thing that the Author '
            'has been doing on a large one for three thousand years, which is to seal a difficult '
            'page rather than read it.',
        out: [Out(OutKind.maxHp, value: 8), Out(OutKind.flag, arg: 'left_the_ninth'),
          Out(OutKind.shards, value: 20)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_pen',
    title: 'THE PEN ON THE STAIR',
    art: 'event_pen',
    weight: 10,
    act: 3,
    body:
        'A pen, on a step, at about the point where somebody coming down in a hurry would have '
        'dropped it.\n\n'
        'It is not ornate. It is a working tool that has been used continuously for three '
        'thousand years and has the wear to prove it, and the nib has been reshaped by hand at '
        'least eleven times.\n\n'
        'It is still wet.',
    plain: 'The Author\'s pen, dropped and still wet. Take it, break it, or leave it.',
    choices: [
      EvChoice(
        label: 'Pick it up.',
        result:
            'It sits in your hand like something that has been waiting to. That is the '
            'frightening part — not that it is powerful, but that it is *comfortable*, and that '
            'you can feel exactly how easy it would be to start making small corrections, and '
            'how reasonable the first four would seem.',
        out: [Out(OutKind.relic), Out(OutKind.flag, arg: 'took_the_pen'),
          Out(OutKind.shards, value: 50), Out(OutKind.curse)],
      ),
      EvChoice(
        label: 'Break it.',
        result:
            'It snaps easily, which you were not expecting. Ink everywhere, on the stone, on '
            'your hands, going into the grain and staying.\n\nNothing stops. The world does not '
            'flicker. It was never the pen. It was somebody willing to hold one, and that is '
            'still upstairs.',
        out: [Out(OutKind.flag, arg: 'broke_the_pen'), Out(OutKind.maxHp, value: 18),
          Out(OutKind.shards, value: 40), Out(OutKind.cruelty, value: 1)],
      ),
      EvChoice(
        label: 'Leave it where it fell.',
        hidden: true,
        result:
            'You step over it and go up, and it is the single most difficult thing you have done '
            'in three acts, and about six steps later you understand why it was left in the '
            'middle of the stair at a height nobody could miss.\n\nIt was not dropped. It was '
            '*offered*, and you have declined, and whatever is at the top now has to deal with '
            'somebody who declined.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'refused_the_pen'),
          Out(OutKind.maxHp, value: 25), Out(OutKind.relic), Out(OutKind.mercy, value: 3)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_audience_of_one',
    title: 'THE ONLY WITNESS',
    art: 'event_audience_of_one',
    weight: 9,
    act: 3,
    body:
        'One chair, set up on a landing facing the stair, occupied by a small old woman with a '
        'flask and a folded blanket. She has clearly been coming here for a very long time and '
        'has a system.\n\n'
        '"Forty-one," she says. "You are forty-one. I have watched every one of you go up." She '
        'pours something into the cup of the flask and holds it out. "I do not help and I do '
        'not warn. That was the arrangement I made and I have kept it. But I do watch, and '
        'somebody ought to."',
    plain: 'A woman has witnessed all forty-one attempts. Drink with her, ask about the others, or ask her to stop.',
    choices: [
      EvChoice(
        label: 'Take the cup. Sit for ten minutes.',
        result:
            'It is tea and it is extremely good and neither of you says anything much. At the '
            'end she takes the cup back, and rinses it, and folds the blanket over her arm, and '
            'says: "Right." Which is, apparently, all she has ever said to any of you, and is '
            'somehow enough.',
        out: [Out(OutKind.heal, value: 45), Out(OutKind.maxHp, value: 14),
          Out(OutKind.mercy, value: 2), Out(OutKind.flag, arg: 'sat_with_the_witness')],
      ),
      EvChoice(
        label: 'Ask what the other forty did.',
        result:
            '"Everything," she says. "One went up singing. One went up asleep, carried. Nine '
            'went up angry and none of the nine came down." She is quiet a moment. "Thirty-one '
            'went up frightened and did it anyway. That is the biggest group by a very long way '
            'and nobody ever asks about them."',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'knows_the_forty'),
          Out(OutKind.maxHp, value: 16), Out(OutKind.shards, value: 40)],
      ),
      EvChoice(
        label: '"You could stop watching. You could go."',
        hidden: true,
        result:
            'She looks at you as though you have said something obscene, and then as though you '
            'have said something obvious, and then she starts, extremely quietly, to cry.\n\n'
            '"It has been three thousand years," she says, "and not one of you has ever '
            'suggested that." She does not go. But she does put the blanket down.',
        out: [Out(OutKind.page), Out(OutKind.mercy, value: 4), Out(OutKind.relic),
          Out(OutKind.companion), Out(OutKind.flag, arg: 'released_the_witness')],
      ),
    ],
  ),

  GameEvent(
    id: 'the_correction_fluid',
    title: 'THE WHITE JAR',
    art: 'event_correction_fluid',
    weight: 9,
    act: 3,
    body:
        'On a shelf in an alcove, a jar of something white and thick, with a brush in the lid. '
        'Beside it, a rag, and a great many rings on the wood where the jar has been set down '
        'and picked up over three thousand years.\n\n'
        'This is what erasure actually is, up close. Not a force. A jar.\n\n'
        'There is about a third of it left and somebody has scratched a line on the glass with '
        'the word **ENOUGH** next to it, at about the level it is at now.',
    plain: 'The jar used to erase things, a third full, with a warning line at the current level. Take, empty, or leave.',
    choices: [
      EvChoice(
        label: 'Take the jar.',
        result:
            'It is heavier than a jar of that size should be. You are now carrying the ability to '
            'remove something from this world permanently, which is the exact power the entire '
            'story is about, and it is in your bag next to your food.',
        out: [Out(OutKind.relic), Out(OutKind.removeCard), Out(OutKind.removeCard),
          Out(OutKind.flag, arg: 'took_the_jar'), Out(OutKind.shards, value: 40)],
      ),
      EvChoice(
        label: 'Pour it out.',
        result:
            'It goes into the stone and does not come back up. The alcove is left with a jar, a '
            'brush, a rag, and three thousand years of rings, and no means of correcting '
            'anything at all.\n\nThere is no more of this. There is not a supply. That was the '
            'supply.',
        out: [Out(OutKind.flag, arg: 'emptied_the_jar'), Out(OutKind.maxHp, value: 22),
          Out(OutKind.mercy, value: 4), Out(OutKind.page), Out(OutKind.shards, value: 45)],
      ),
      EvChoice(
        label: 'Read what is written under the shelf.',
        result:
            'Bent double, you can see it: a list, in the Author\'s hand, of everything the jar '
            'has been used on. It is four hundred entries long. The last eleven are all the same '
            'two words, written eleven times over three thousand years, each one shakier than '
            'the last: **the ending. the ending. the ending.**',
        out: [Out(OutKind.page), Out(OutKind.page), Out(OutKind.flag, arg: 'read_endings'),
          Out(OutKind.shards, value: 50), Out(OutKind.maxHp, value: 12)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_room_of_beginnings',
    title: 'FIRST DRAFTS',
    art: 'event_room_of_beginnings',
    weight: 9,
    act: 3,
    body:
        'Not endings — beginnings. Three thousand opening pages, boxed and shelved, each one the '
        'first page of a version of this world.\n\n'
        'They are all good. That is the thing you notice. Every single one of them is a strong, '
        'confident, well-made opening by somebody who was excited.\n\n'
        'The most recent box is this draft. The page in it is the day you woke up, and it is '
        'still good, and somebody wrote it three thousand years into being tired and it is '
        '*still good.*',
    plain: 'Three thousand opening pages, all excellent. Read yours, read the first, or take one.',
    choices: [
      EvChoice(
        label: 'Read your own opening page.',
        result:
            'You are described with real affection. That is what undoes you slightly — not that '
            'you were made, but that whoever made you liked you, on the page where you started, '
            'before any of this. The handwriting is steady. There is a small note in the margin '
            'that says *this one might be all right.*',
        out: [Out(OutKind.page), Out(OutKind.maxHp, value: 20), Out(OutKind.heal, value: 30),
          Out(OutKind.flag, arg: 'read_your_beginning')],
      ),
      EvChoice(
        label: 'Read the very first one.',
        result:
            'It is not better than the others. It is barely different. The gap between draft one '
            'and draft three thousand is almost nothing at the opening — all of the difference, '
            'every bit of it, is in what happens after the first page, and the first page has '
            'never been the problem, and three thousand years have been spent rewriting it.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'knows_the_pattern'),
          Out(OutKind.shards, value: 45), Out(OutKind.maxHp, value: 14)],
      ),
      EvChoice(
        label: 'Take an opening page that was never used.',
        hidden: true,
        result:
            'There are boxes on the bottom shelf with no draft numbers — openings that were '
            'written and never begun. You take one at random.\n\nIt starts with two people who '
            'already know each other. Everything in Aevum starts with somebody waking up alone. '
            'This one does not, and it never got used, and you are holding the only copy.',
        out: [Out(OutKind.page), Out(OutKind.relic), Out(OutKind.companion),
          Out(OutKind.maxHp, value: 16), Out(OutKind.flag, arg: 'took_a_beginning')],
      ),
    ],
  ),

  GameEvent(
    id: 'the_locked_floor',
    title: 'THE SEALED FLOOR',
    art: 'event_locked_floor',
    weight: 9,
    act: 3,
    body:
        'A whole level of the tower with no door onto the stair. You only know it is there '
        'because the flights above and below do not add up, and because there is a window on '
        'the outside that the inside does not account for.\n\n'
        'Through the window, from the scaffolding, at a bad angle: a room with a table in it, '
        'laid for two, with two chairs pulled out as though both occupants stood up at the same '
        'moment and did not come back.\n\n'
        'Everything on the table is three thousand years old and none of it has been cleared.',
    plain: 'A sealed floor holds a table laid for two, abandoned mid-meal. Break in, look longer, or leave.',
    choices: [
      EvChoice(
        label: 'Get in through the window.',
        result:
            'Two places. Two half-finished meals. Two sets of notes, in two different hands, on '
            'the same manuscript — and the second hand is not the Author\'s, and it is arguing, '
            'kindly and at length, for a completely different third act.\n\n'
            'The argument stops mid-sentence on the last page.',
        out: [Out(OutKind.page), Out(OutKind.page), Out(OutKind.flag, arg: 'knows_the_second_hand'),
          Out(OutKind.relic), Out(OutKind.hp, value: 12)],
      ),
      EvChoice(
        label: 'Stay on the scaffold and look properly.',
        result:
            'Ten minutes at a bad angle in a high wind. You get: two chairs, one manuscript, one '
            'coat over the back of the far chair that is not the Author\'s size — and, on the '
            'wall, a second nail, empty, where a second coat used to hang.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'saw_the_second_chair'),
          Out(OutKind.shards, value: 40)],
      ),
      EvChoice(
        label: 'Leave it sealed and climb on.',
        result:
            'It is not your business and you have a tower to get up, and you tell yourself both '
            'of those things twice, and you are on the next flight before you admit that you '
            'have just left the only room in the building where two people were once happy.',
        out: [Out(OutKind.shards, value: 25), Out(OutKind.maxHp, value: 8)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_last_meal',
    title: 'THE LAST MEAL',
    art: 'event_last_meal',
    weight: 10,
    act: 3,
    body:
        'On the last landing before the top: a table, food, and a chair. One place. The food is '
        'hot and it is specifically the food you would choose, which is not a coincidence and '
        'is not meant to be.\n\n'
        'A card is propped against the jug. It reads:\n\n'
        '*you have not eaten properly in three acts. whatever happens up here, that is a stupid '
        'way to arrive. sit down.*\n\n'
        'It is signed with a single initial. It is not one you recognise.',
    plain: 'A hot meal laid out for you before the final climb. Eat, refuse, or check who left it.',
    choices: [
      EvChoice(
        label: 'Sit down and eat all of it.',
        result:
            'It is very good and you are much hungrier than you had let yourself notice, and by '
            'the end of it you are a different quality of tired — the ordinary kind, the kind '
            'that a person who has eaten is.\n\nWhatever is upstairs is going to meet somebody '
            'who had a hot meal first. That changes more than it sounds like it should.',
        out: [Out(OutKind.heal, value: 60), Out(OutKind.maxHp, value: 18),
          Out(OutKind.flag, arg: 'ate_the_meal')],
      ),
      EvChoice(
        label: 'Refuse it. It could be anything.',
        result:
            'You go up hungry and careful and entirely correct in your reasoning, and nothing '
            'bad happens as a result of the caution, and you will find out afterwards that it '
            'was exactly what it looked like and that the person who left it waited on the '
            'landing below for two hours to see whether you would.',
        out: [Out(OutKind.flag, arg: 'refused_the_meal'), Out(OutKind.shards, value: 30),
          Out(OutKind.hp, value: 6)],
      ),
      EvChoice(
        label: 'Go and find whoever left it.',
        result:
            'They are one landing down, sitting on the steps, and they are extremely embarrassed '
            'to have been caught. They are not important to the plot. They work in the building. '
            'They have watched forty people go up this stair on an empty stomach and this is the '
            'first time they have done anything about it.',
        out: [Out(OutKind.companion), Out(OutKind.heal, value: 35), Out(OutKind.mercy, value: 3),
          Out(OutKind.page), Out(OutKind.flag, arg: 'found_the_cook')],
      ),
    ],
  ),

  GameEvent(
    id: 'the_mirror_stair',
    title: 'THE MIRRORED FLIGHT',
    art: 'event_mirror_stair',
    weight: 9,
    act: 3,
    body:
        'A flight of stairs going up, and beside it, at the same angle, a flight going down '
        'that is the exact reflection of it. Same steps, same wear, same three thousand years '
        'of feet.\n\n'
        'On the down-stair, coming towards you at exactly your pace, is you. Not a copy — the '
        'geometry is a mirror and you are its subject and everything you do it does.\n\n'
        'Except that it is smiling, and you are not, and it has been smiling for four steps.',
    plain: 'A mirrored staircase shows a reflection that is not obeying. Confront it, ignore it, or copy it.',
    choices: [
      EvChoice(
        label: 'Stop. Make it stop.',
        result:
            'It stops. It keeps smiling. Then it raises one hand and taps the glass — except '
            'there is no glass, and it is not a reflection, and it has been walking down a real '
            'staircase towards a real bottom of the tower for four hundred steps while you have '
            'been climbing.\n\nIt goes past you. It does not look back.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'passed_the_other'),
          Out(OutKind.shards, value: 40), Out(OutKind.hp, value: 10)],
      ),
      EvChoice(
        label: 'Keep climbing. Do not engage.',
        result:
            'You go up and it goes down and neither of you deviates, and at the moment you pass '
            'level with each other everything in you says *turn your head* and you do not, and '
            'the effort of not doing it is more tiring than the last two flights combined.',
        out: [Out(OutKind.maxHp, value: 14), Out(OutKind.flag, arg: 'did_not_look'),
          Out(OutKind.shards, value: 25)],
      ),
      EvChoice(
        label: 'Smile back.',
        hidden: true,
        result:
            'It stops dead. The smile goes. For the first time it does something you did not '
            'do — it looks *frightened* — and it turns and goes back down the way it came at a '
            'speed that is not a walk.\n\nWhatever it was expecting, it was not expecting the '
            'thing coming up the tower to be in a good mood about it.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'smiled_back'),
          Out(OutKind.maxHp, value: 20), Out(OutKind.relic), Out(OutKind.mercy, value: 2)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_final_edit',
    title: 'THE FINAL EDIT',
    art: 'event_final_edit',
    weight: 10,
    act: 3,
    body:
        'The corridor is being revised while you are in it. Not violently — carefully. A door '
        'is moved eighteen inches. A window becomes slightly larger. The light is warmed by an '
        'amount somebody has clearly thought about.\n\n'
        'Every single change is an improvement. The corridor is better than it was four minutes '
        'ago and it will be better again in four more.\n\n'
        'None of the changes have anything to do with you. You are being worked around.',
    plain: 'The corridor is being improved around you, ignoring you entirely. Interfere, watch, or add something.',
    choices: [
      EvChoice(
        label: 'Stand exactly where the next change is going.',
        result:
            'The change does not happen. The corridor waits. You stand in the space where a '
            'better window was about to be and nothing at all occurs for eleven minutes, and '
            'then — with what you can only describe as reluctance — the work moves to a '
            'different wall and continues.\n\nIt can be made to wait. That is new information.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'made_it_wait'),
          Out(OutKind.maxHp, value: 18), Out(OutKind.shards, value: 40)],
      ),
      EvChoice(
        label: 'Watch and learn how it is done.',
        result:
            'It is not magic. It is craft — the same decision made over and over, always in the '
            'direction of better, by somebody with three thousand years of practice and nothing '
            'whatsoever to spend it on except a corridor that nobody is going to use.',
        out: [Out(OutKind.upgradeCard), Out(OutKind.upgradeCard), Out(OutKind.page),
          Out(OutKind.flag, arg: 'watched_the_edit')],
      ),
      EvChoice(
        label: 'Put something of your own in the corridor.',
        result:
            'You leave a thing from your pack on the sill of the improved window. Deliberately '
            'placed, badly matched, wrong for the room.\n\nThe next revision moves the door and '
            'warms the light and adjusts the skirting. It does not touch your object. It works '
            'around it — carefully, and permanently, as though the corridor now has a feature.',
        out: [Out(OutKind.page), Out(OutKind.relic), Out(OutKind.maxHp, value: 16),
          Out(OutKind.flag, arg: 'left_a_feature'), Out(OutKind.mercy, value: 2)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_understudy_of_the_author',
    title: 'THE ASSISTANT',
    art: 'event_assistant',
    weight: 9,
    act: 3,
    body:
        'Two floors below the study, at a much smaller desk, somebody is doing the actual work. '
        'Filing. Cross-referencing. Keeping three thousand years of drafts in an order that '
        'allows any of them to be found.\n\n'
        'They do not look up. "He is upstairs," they say. "He is always upstairs. You want the '
        'stair on the left."\n\n'
        'Then, after a moment, still not looking up: "I have been here longer than he has. '
        'Nobody ever asks me anything."',
    plain: 'The Author\'s assistant has been there longer than he has. Ask them, help them, or go up.',
    choices: [
      EvChoice(
        label: 'Ask them something.',
        result:
            'They put the pen down properly, which takes a moment, because it has been a long '
            'time.\n\nThey tell you the thing that is not in any draft, any ledger, any ending: '
            'that he was not the first one at that desk, and that the person who was is not '
            'dead, and that the reason the ninth floor is bricked up is that he could not bring '
            'himself to do either of the two available things about it.',
        out: [Out(OutKind.page), Out(OutKind.page), Out(OutKind.flag, arg: 'knows_the_first_author'),
          Out(OutKind.relic), Out(OutKind.shards, value: 50)],
      ),
      EvChoice(
        label: 'Help them file for an hour.',
        result:
            'It is dull and enormous and they do not thank you, and about forty minutes in they '
            'start talking, and by the end of the hour you have a complete and unsentimental '
            'account of what it is like to work for somebody who is frightened, from the only '
            'person who has watched it up close for three thousand years.',
        out: [Out(OutKind.page), Out(OutKind.mercy, value: 3), Out(OutKind.companion),
          Out(OutKind.maxHp, value: 14), Out(OutKind.flag, arg: 'helped_the_assistant')],
      ),
      EvChoice(
        label: 'Take the stair on the left.',
        result:
            'You go. Behind you the filing continues, at the same rate, and will continue at the '
            'same rate through whatever happens above, because it is the only thing in this '
            'building that has never once stopped.',
        out: [Out(OutKind.shards, value: 20)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_open_window',
    title: 'THE OPEN WINDOW',
    art: 'event_open_window',
    weight: 9,
    act: 3,
    body:
        'On the second-to-last landing there is a window, and it is open, and it is the only '
        'open window in the entire tower.\n\n'
        'It is not a trap. It is at exactly the right height to climb out of, and there is a '
        'ledge, and the ledge goes to a roof, and the roof goes down, and somebody has left a '
        'rope coiled beside it that is long enough and in good condition.\n\n'
        'It is an exit. Somebody built an exit, here, at the last possible moment, on purpose.',
    plain: 'A deliberate escape route, one floor from the top. Take it, close it, or check who left it.',
    choices: [
      EvChoice(
        label: 'Close the window and go up.',
        result:
            'You shut it and you drop the latch, which is a small and very loud noise in a '
            'stairwell, and you are aware that anybody above will have heard it and will know '
            'exactly what it means.\n\nYou have removed your own way out. You did it on purpose. '
            'That is now a fact about you that is going up the stairs.',
        out: [Out(OutKind.maxHp, value: 26), Out(OutKind.flag, arg: 'shut_the_window'),
          Out(OutKind.relic)],
      ),
      EvChoice(
        label: 'Leave it open for whoever comes next.',
        result:
            'You go up past it and leave the rope coiled and the latch off, and you spend the '
            'last flight thinking about the fact that you have just done for the forty-second '
            'what somebody did for you.',
        out: [Out(OutKind.mercy, value: 4), Out(OutKind.page), Out(OutKind.maxHp, value: 14),
          Out(OutKind.flag, arg: 'left_it_open')],
      ),
      EvChoice(
        label: 'Look for who left the rope.',
        hidden: true,
        result:
            'There is a mark on the sill — a small careful notch, the sort somebody cuts when '
            'they want a thing to be findable later without being obvious. It matches a notch '
            'you have seen once before, on the frame of a mirror in a dressing room, in a '
            'building at the bottom of an act you left two floors ago.\n\n'
            'The Understudy built you an exit before it ever met you.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'knows_who_left_it'),
          Out(OutKind.relic), Out(OutKind.maxHp, value: 20), Out(OutKind.mercy, value: 3)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_offer_at_the_top',
    title: 'THE OFFER',
    art: 'event_offer_at_the_top',
    weight: 9,
    act: 3,
    body:
        'A voice, from the last flight, without any particular drama:\n\n'
        '"You can have the desk."\n\n'
        'Nothing else for a while. Then: "I am not being clever. It is a genuine offer and it '
        'is the only one I have. You come up, I go down, you keep it going. You would be good '
        'at it — you are already better at it than I was at your stage." A pause. '
        '"It is not a trick. It is what I want. It has been what I wanted for two thousand '
        'years and there has never been anybody to offer it to."',
    plain: 'The Author offers you his job. Refuse, ask what happens to him, or accept in principle.',
    choices: [
      EvChoice(
        label: '"No. Somebody has to finish it."',
        result:
            'A very long silence from above.\n\nThen, quietly, in the voice of a man who has just '
            'had a door closed that he had left open for two thousand years: "Yes. I know." And '
            'then, after another pause, almost businesslike: "Come up, then."',
        out: [Out(OutKind.flag, arg: 'refused_the_desk'), Out(OutKind.maxHp, value: 24),
          Out(OutKind.page), Out(OutKind.relic)],
      ),
      EvChoice(
        label: '"What happens to you if I take it?"',
        result:
            '"I stop," he says. Immediately, with no hesitation at all, as though it is the '
            'answer he has had ready the longest. "That is the point. That has always been the '
            'point. I am not asking you to save the world. I am asking you to relieve me."',
        out: [Out(OutKind.page), Out(OutKind.page), Out(OutKind.flag, arg: 'knows_the_ask'),
          Out(OutKind.maxHp, value: 18), Out(OutKind.shards, value: 50)],
      ),
      EvChoice(
        label: '"Come down and we will finish it together."',
        hidden: true,
        result:
            'He does not answer for a long time. When he does, it is not from above.\n\nIt is '
            'from the landing behind you, at ordinary volume, at ordinary height, in the voice '
            'of somebody who has just walked down three thousand years of stairs and is finding '
            'it strange to be at the bottom of them:\n\n"...all right."',
        out: [Out(OutKind.page), Out(OutKind.page), Out(OutKind.flag, arg: 'brought_him_down'),
          Out(OutKind.relic), Out(OutKind.maxHp, value: 30), Out(OutKind.mercy, value: 4)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_stack_of_paper',
    title: 'THE STACK',
    art: 'event_stack_of_paper',
    weight: 9,
    act: 3,
    body:
        'On a landing, unattended: three feet of manuscript, squared off, weighted with a '
        'stone.\n\n'
        'It is this run. All of it. From the day you woke up to the landing you are standing on, '
        'written as it happened, by somebody keeping up in real time.\n\n'
        'The top sheet is your hand reaching for the top sheet.',
    plain: 'A live manuscript of your current run. Read ahead, read back, or add a page.',
    choices: [
      EvChoice(
        label: 'Read back to a decision you regret.',
        result:
            'It is exactly as you remember it, which is the unbearable part — no excuses in the '
            'prose, no softening, no context you had forgotten. It is written by somebody who '
            'was paying complete attention and who did not editorialise, and reading it is worse '
            'and more useful than any amount of thinking about it has been.',
        out: [Out(OutKind.page), Out(OutKind.maxHp, value: 16), Out(OutKind.heal, value: 25),
          Out(OutKind.flag, arg: 'read_yourself')],
      ),
      EvChoice(
        label: 'Look for pages past this one.',
        result:
            'There are none. The stack ends at your hand on the stack. Not blank pages — no '
            'pages.\n\nWhatever happens on the next flight has not been written yet, by anybody, '
            'for the first time in three thousand years, and the person who has been keeping up '
            'in real time is currently waiting to see.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'nothing_written_yet'),
          Out(OutKind.maxHp, value: 22), Out(OutKind.shards, value: 45)],
      ),
      EvChoice(
        label: 'Write the next page yourself.',
        hidden: true,
        result:
            'There is a pen on the stone. You write four lines about what you intend to do and '
            'you put it on the top of the stack.\n\nIt stays. It does not get corrected and it '
            'does not get improved and it is, unmistakably, worse writing than everything under '
            'it — and it is the first page in the entire manuscript that was written by the '
            'person it is about.',
        out: [Out(OutKind.page), Out(OutKind.page), Out(OutKind.flag, arg: 'wrote_your_own_page'),
          Out(OutKind.maxHp, value: 26), Out(OutKind.relic), Out(OutKind.mercy, value: 2)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_thing_that_was_cut_first',
    title: 'THE FIRST CUT',
    art: 'event_first_cut',
    weight: 8,
    act: 3,
    body:
        'It is in an alcove and it is very small and it has been there since before the first '
        'Fall. It is the first thing that was ever removed from this story.\n\n'
        'It is a scene. Two pages. Nothing dramatic — two people talking in a kitchen about '
        'something that does not matter, warmly, at length, going nowhere.\n\n'
        'The note attached to it, in the earliest and steadiest version of the handwriting, '
        'says: **cut for pace. reinstate if there is room.**\n\n'
        'There was never room.',
    plain: 'The first scene ever cut: two people talking warmly about nothing. Read it, reinstate it, or leave it.',
    choices: [
      EvChoice(
        label: 'Read the two pages.',
        result:
            'They are the best thing in the tower and they are completely inessential and both '
            'of those are true at once. Nothing happens. The conversation does not advance '
            'anything. It is two people who like each other, and it was the first thing to go, '
            'and every single cut in three thousand years has been made on the same principle.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'read_the_first_cut'),
          Out(OutKind.heal, value: 35), Out(OutKind.maxHp, value: 16)],
      ),
      EvChoice(
        label: 'Put it back into the manuscript.',
        result:
            'You carry it up and you slide it into the stack, in roughly the right place, badly, '
            'out of order, with the paper the wrong size.\n\nThe pace of this act is now worse. '
            'Measurably. And there are two people in a kitchen in it who have not existed for '
            'three thousand years, and they are talking, and nothing is coming of it.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'reinstated_the_scene'),
          Out(OutKind.maxHp, value: 24), Out(OutKind.mercy, value: 4), Out(OutKind.relic)],
      ),
      EvChoice(
        label: 'Take it with you unread.',
        result:
            'It weighs nothing and it goes in the inside pocket and you do not look at it, and '
            'you are aware for the rest of the climb that you are carrying two pages of '
            'somebody\'s ordinary afternoon into whatever is at the top.',
        out: [Out(OutKind.relic), Out(OutKind.flag, arg: 'carry_the_first_cut'),
          Out(OutKind.shards, value: 35)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_understudy_ledger',
    title: 'THE ATTENDANCE BOOK',
    art: 'event_attendance_book',
    weight: 9,
    act: 3,
    body:
        'By the door at the foot of the last stair, on a lectern, a book with two columns: '
        'WENT UP and CAME DOWN.\n\n'
        'The left column has forty-one entries. The right column has one.\n\n'
        'The single entry in the right-hand column is dated three thousand years ago, and the '
        'name in it is not a Vessel\'s. It is the Author\'s, and beside it, in his own hand, '
        'in the remarks column: *came down once. went back up. do not require a second line.*',
    plain: 'A ledger shows forty-one went up and only the Author ever came down. Sign, read, or take it.',
    choices: [
      EvChoice(
        label: 'Sign the left column.',
        result:
            'Forty-two. You write it properly, full name, date, in ink, and you look at the '
            'empty right-hand column beside it for a while before you go up.\n\n'
            'It is a very ordinary act and it is also a commitment, and both of you upstairs '
            'know that the book is by the door for exactly that reason.',
        out: [Out(OutKind.flag, arg: 'signed_the_book'), Out(OutKind.maxHp, value: 20),
          Out(OutKind.relic)],
      ),
      EvChoice(
        label: 'Read the remarks column all the way back.',
        result:
            'Forty-one remarks, all in the same hand, all written after the fact by the only '
            'person who was there. They are not clinical. They are obituaries — short, exact, '
            'and written by somebody who paid attention to each one and remembered what they '
            'were like.\n\nHe has written a paragraph about every single person he has killed.',
        out: [Out(OutKind.page), Out(OutKind.page), Out(OutKind.flag, arg: 'read_the_remarks'),
          Out(OutKind.shards, value: 50), Out(OutKind.maxHp, value: 14)],
      ),
      EvChoice(
        label: 'Take the book up with you.',
        hidden: true,
        result:
            'It is heavy and it is awkward and you carry it up under one arm like a man '
            'delivering a summons.\n\nThere is no version of the conversation upstairs that is '
            'improved by him being able to pretend he does not remember, and you have just made '
            'certain of that, and the weight of the thing is a good weight.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'carrying_the_book'),
          Out(OutKind.relic), Out(OutKind.maxHp, value: 22), Out(OutKind.mercy, value: 2)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_quiet_before',
    title: 'THE LANDING',
    art: 'event_quiet_before',
    weight: 12,
    act: 3,
    body:
        'The last landing. One flight above you is the door.\n\n'
        'There is nothing here. No event, no merchant, no voice. Somebody has swept it. There '
        'is a bench against the wall and a window with the shutter open and a view over the '
        'whole of everything you have walked through, all three acts of it, laid out and small '
        'and further away than it has any business being.\n\n'
        'Nobody is going to interrupt you. That is the point of this landing. It has been kept '
        'empty on purpose and it has been kept empty forty-one times.',
    plain: 'A deliberately empty landing before the final door. Rest, look back, or go straight up.',
    choices: [
      EvChoice(
        label: 'Sit on the bench a while.',
        result:
            'Twenty minutes of nothing at all. It is the first time in three acts that nothing '
            'has been required of you, and you had not noticed how much of you was braced, and '
            'quite a lot of it comes down.',
        out: [Out(OutKind.heal, value: 55), Out(OutKind.maxHp, value: 16),
          Out(OutKind.flag, arg: 'used_the_landing')],
      ),
      EvChoice(
        label: 'Look out of the window at the whole run.',
        result:
            'From up here it reads. The road, the towns, the switchbacks, the places you turned '
            'back and the places you did not — all of it visible at once and all of it, '
            'unmistakably, shaped. It was made to be walked and you walked it, and both halves '
            'of that sentence are true, and neither cancels the other.',
        out: [Out(OutKind.page), Out(OutKind.maxHp, value: 20),
          Out(OutKind.flag, arg: 'saw_it_whole'), Out(OutKind.shards, value: 40)],
      ),
      EvChoice(
        label: 'Do not stop. Go up.',
        result:
            'You are through the landing in four seconds and on the last flight before you have '
            'thought about it, which is either the bravest thing you have done or the most '
            'frightened, and you will not know which until the door.',
        out: [Out(OutKind.flag, arg: 'did_not_stop'), Out(OutKind.upgradeCard),
          Out(OutKind.shards, value: 25)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_spare_chair',
    title: 'THE SPARE CHAIR',
    art: 'event_spare_chair',
    weight: 9,
    act: 3,
    body:
        'Somebody has carried a chair up three thousand stairs and left it on a landing, facing '
        'the study door, four feet back.\n\n'
        'It is not the Author\'s chair. It is an ordinary chair from a room a very long way '
        'down. The legs are scuffed from the climb. Whoever brought it up here did it in one '
        'go, alone, and did not sit in it, and went away again.\n\n'
        'It is placed exactly where a second person would sit if there were going to be a '
        'conversation rather than a fight.',
    plain: 'Someone carried up a second chair for a conversation. Take it in, leave it, or sit in it.',
    choices: [
      EvChoice(
        label: 'Carry it through the door with you.',
        result:
            'It is awkward through a doorway and you get it wedged and have to back out and try '
            'again, which is not how anybody has ever entered this room, and by the time you are '
            'through you are irritated and out of breath and holding a chair, and it is very '
            'hard for what is behind the desk to make that into a confrontation.',
        out: [Out(OutKind.flag, arg: 'brought_the_chair'), Out(OutKind.maxHp, value: 24),
          Out(OutKind.mercy, value: 3), Out(OutKind.relic)],
      ),
      EvChoice(
        label: 'Sit in it for a minute first.',
        result:
            'From here the door is a door. Not a climax — a door, four feet away, ordinary, with '
            'a handle at handle height and a draught coming under it.\n\nSomebody put a chair '
            'here so that the last thing you did before going in was sit down and see it that '
            'way. It works.',
        out: [Out(OutKind.heal, value: 30), Out(OutKind.maxHp, value: 14),
          Out(OutKind.flag, arg: 'sat_in_the_chair'), Out(OutKind.page)],
      ),
      EvChoice(
        label: 'Leave it. This is not a conversation.',
        result:
            'You go past it and you do not look at it and you are entirely clear about what you '
            'are going in there to do.\n\nThe chair stays on the landing. It has been there for '
            'forty-one attempts. It will be there for the forty-third.',
        out: [Out(OutKind.upgradeCard), Out(OutKind.cruelty, value: 2),
          Out(OutKind.flag, arg: 'left_the_chair')],
      ),
    ],
  ),

  GameEvent(
    id: 'the_returned_thing',
    title: 'THE THING THAT CAME BACK',
    art: 'event_returned_thing',
    weight: 8,
    act: 3,
    body:
        'Something you erased is on the stair in front of you.\n\n'
        'Not a ghost and not a reproach. It is simply here, intact, entirely uninterested in '
        'you, going about a small piece of business of its own, and it does not appear to know '
        'that it was ever removed.\n\n'
        'Whatever the jar of white does, it is not permanent. Somebody upstairs has been '
        'relying on it being permanent for three thousand years.',
    plain: 'Something you erased has come back, unaware. Speak to it, watch it, or tell the Author.',
    choices: [
      EvChoice(
        label: 'Speak to it.',
        result:
            'It is friendly and slightly vague and has no memory of the gap at all — for it, no '
            'time passed, because during the gap there was no it to pass for.\n\nIt asks where '
            'you are going. You tell it. It says "oh, that\'s a long way up," and wishes you '
            'well, and goes on down.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'erasure_fails'),
          Out(OutKind.maxHp, value: 18), Out(OutKind.mercy, value: 2)],
      ),
      EvChoice(
        label: 'Watch it until you are certain.',
        result:
            'Ten minutes. It is real, it is stable, it casts a shadow, it interacts with the '
            'stair. There is no flicker and no thinness and nothing provisional about it at '
            'all.\n\nErasure is not deletion. Erasure is *storage.* Everything that has ever '
            'been taken out of this world is still somewhere, and somebody has spent three '
            'thousand years believing otherwise.',
        out: [Out(OutKind.page), Out(OutKind.page), Out(OutKind.flag, arg: 'knows_erasure_fails'),
          Out(OutKind.shards, value: 55), Out(OutKind.maxHp, value: 14)],
      ),
      EvChoice(
        label: 'Take it upstairs with you.',
        hidden: true,
        result:
            'It comes willingly, because it has no reason not to, and it chats on the way up '
            'about nothing in particular.\n\nYou are about to walk into a room and put in front '
            'of a frightened man the single piece of evidence that the thing he has been doing '
            'for three thousand years has never once worked.',
        out: [Out(OutKind.companion), Out(OutKind.page), Out(OutKind.flag, arg: 'brought_the_proof'),
          Out(OutKind.relic), Out(OutKind.maxHp, value: 20)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_last_door',
    title: 'THE DOOR',
    art: 'event_last_door',
    weight: 10,
    act: 3,
    body:
        'It is an ordinary door. That is the thing nobody who describes it ever gets right — '
        'there is no ironwork, no inscription, no light under it. It is a door into a study, in '
        'a building, at the top of some stairs.\n\n'
        'The handle is worn on one side only. From the inside.\n\n'
        'He has come out of this room a great many times and gone back in every time, and '
        'nobody has ever come the other way.',
    plain: 'The final door, worn only from the inside. Knock, walk in, or wait.',
    choices: [
      EvChoice(
        label: 'Knock.',
        result:
            'Two knocks, at normal volume.\n\nThere is a very long pause, and then the sound of a '
            'chair being pushed back — not violently, just a man getting up — and footsteps that '
            'stop on the other side of the door, and then nothing for four full seconds while '
            'somebody who has not been knocked on in three thousand years works out what the '
            'protocol is.',
        out: [Out(OutKind.flag, arg: 'knocked'), Out(OutKind.maxHp, value: 22),
          Out(OutKind.mercy, value: 3), Out(OutKind.relic)],
      ),
      EvChoice(
        label: 'Open it and walk in.',
        result:
            'The handle turns easily. It is not locked. It has never been locked, in three '
            'thousand years, at the top of a tower guarded by everything in the world.\n\n'
            'He is at the desk with his back to you and he does not turn round, and he says — '
            'in a voice that has been practising this for a very long time and is still not '
            'ready — "You are early."',
        out: [Out(OutKind.flag, arg: 'walked_in'), Out(OutKind.upgradeCard),
          Out(OutKind.maxHp, value: 16), Out(OutKind.shards, value: 40)],
      ),
      EvChoice(
        label: 'Wait until he comes out.',
        hidden: true,
        result:
            'You sit down against the opposite wall and you wait.\n\nIt takes eleven hours. He '
            'has to eat eventually; that is the whole of your reasoning and it turns out to be '
            'correct. The door opens and a tired man in his shirtsleeves steps out onto the '
            'landing holding a plate, and sees you sitting on the floor, and neither of you is '
            'holding anything, and the entire architecture of the last three thousand years '
            'fails to apply.',
        out: [Out(OutKind.page), Out(OutKind.page), Out(OutKind.flag, arg: 'waited_him_out'),
          Out(OutKind.relic), Out(OutKind.maxHp, value: 28), Out(OutKind.mercy, value: 4)],
      ),
    ],
  ),
];
