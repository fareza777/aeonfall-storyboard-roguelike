import 'narrative_model.dart';

/// Fourth event book — weighted hard towards Act II, which previously drew
/// from the same undifferentiated pool as Act I and therefore felt like more
/// of the first act with bigger numbers.
const kEventsD = <GameEvent>[
  GameEvent(
    id: 'the_department',
    title: 'THE DEPARTMENT OF ENDINGS',
    art: 'event_department',
    weight: 11,
    act: 2,
    body:
        'An open-plan office, lit badly, staffed entirely by people writing endings. Each desk '
        'has a small brass plate: A GOOD ONE. A QUICK ONE. ONE THAT HURTS BUT IS FAIR.\n\n'
        'Nobody is being supervised. Nobody has been supervised for a very long time. They keep '
        'coming in because the work is the work.\n\n'
        'The desk at the far end has no plate and no chair and a stack of paper three feet '
        'high, and everyone here walks around it without looking at it.',
    plain: 'An office where clerks draft endings. Read one, submit your own, or ask about the empty desk.',
    choices: [
      EvChoice(
        label: 'Read the one marked ONE THAT HURTS BUT IS FAIR.',
        result:
            'It is nine lines long and it is the best thing you have read in your life and you '
            'have to put it down twice. In it, you do not win. In it, what you do instead is '
            'sufficient. The clerk watches you get to the end and says, without hope, "It has '
            'been rejected four hundred times."',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'read_the_fair_end'),
          Out(OutKind.maxHp, value: 14), Out(OutKind.shards, value: 25)],
      ),
      EvChoice(
        label: 'Sit down at a free desk and write one.',
        result:
            'They give you paper without comment, the way a place does when somebody arriving '
            'and starting work is not remarkable. What you write is bad. Two of them read it '
            'anyway and one of them fixes a line, and the fixed line is better, and it is '
            'filed.\n\nIt is in the system now. That is not nothing.',
        out: [Out(OutKind.flag, arg: 'filed_an_ending'), Out(OutKind.relic),
          Out(OutKind.mercy, value: 2), Out(OutKind.maxHp, value: 12)],
      ),
      EvChoice(
        label: 'Ask about the desk with no chair.',
        hidden: true,
        result:
            'The room goes quiet in the way rooms do.\n\n"That is his," says somebody, eventually. '
            '"He wrote eleven. They are all in that pile. He has not been down in three thousand '
            'years and we are not allowed to throw them away and we are not allowed to use '
            'them." A pause. "We are not entirely sure he is allowed to use them either."',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'read_endings'),
          Out(OutKind.shards, value: 35), Out(OutKind.relic)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_veterans',
    title: 'THE VETERANS',
    art: 'event_veterans',
    weight: 11,
    act: 2,
    body:
        'Six of them round a fire, all carrying your kind of wear. They go quiet when you come '
        'up, then one shifts along the log to make room, which answers the question.\n\n'
        '"Second act," says the oldest, looking at you. Not a question. "You will have noticed '
        'the middle is where it gets long."\n\n'
        'They are Vessels. Every one of them. None of them are still walking the road, and none '
        'of them will say what stopped them, and all of them are extremely glad to see somebody '
        'who still is.',
    plain: 'Six retired Vessels at a fire. Ask advice, ask why they stopped, or ask them to come.',
    choices: [
      EvChoice(
        label: 'Ask what they know that you do not.',
        result:
            'Four hours. No war stories. Purely practical — where the ground gives, which of the '
            'elites is faster than it looks, what the Author does on the third turn and how to '
            'be somewhere else when he does it. Nobody talks over anybody. It is the single most '
            'useful conversation of the run.',
        out: [Out(OutKind.randomCard), Out(OutKind.upgradeCard), Out(OutKind.upgradeCard),
          Out(OutKind.flag, arg: 'met_veterans')],
      ),
      EvChoice(
        label: 'Ask why they stopped.',
        result:
            'The oldest answers for all of them, because they have clearly agreed she does.\n\n'
            '"We got to the top," she says. "All six. Separately, different drafts." She puts '
            'another branch on. "You do not fail at the top. That is the part nobody tells you. '
            'You succeed, and then you find out what succeeding is, and then you come down here '
            'and sit by a fire."',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'knows_the_summit'),
          Out(OutKind.maxHp, value: 16), Out(OutKind.shards, value: 30)],
      ),
      EvChoice(
        label: 'Ask one of them to walk with you.',
        result:
            'Five say no immediately and one does not say anything for a long moment, and then '
            'stands up and starts putting a pack together, and the other five watch this happen '
            'with expressions you cannot read at all.\n\n"Right," she says. "Well. Someone '
            'should see it."',
        out: [Out(OutKind.companion), Out(OutKind.mercy, value: 2),
          Out(OutKind.flag, arg: 'recruited_veteran')],
      ),
    ],
  ),

  GameEvent(
    id: 'the_rewrite_room',
    title: 'THE REWRITE',
    art: 'event_rewrite_room',
    weight: 10,
    act: 2,
    body:
        'You walk into a room you were in an hour ago and it is different. Not damaged — '
        '*revised.* The window is on the other wall. The chair is a better chair. There is a '
        'second door that was definitely not there.\n\n'
        'On the table, fresh, still tacky: a page of this scene, with your own dialogue on it, '
        'crossed out and rewritten in the margin. The new version is better. It is a much '
        'better version of what you said.\n\n'
        'You did not say it.',
    plain: 'A room you were in has been rewritten, including your dialogue. Accept it, refuse, or read further.',
    choices: [
      EvChoice(
        label: 'Say the new line out loud.',
        result:
            'It fits your mouth perfectly. Of course it does. It is better than anything you '
            'have said since you woke up and it is not yours, and the room settles around it '
            'with a small satisfied click, like a lock finding its bolt.\n\n'
            'You will use that line again. You will not be able to help it.',
        out: [Out(OutKind.upgradeCard), Out(OutKind.upgradeCard), Out(OutKind.curse),
          Out(OutKind.flag, arg: 'took_the_line')],
      ),
      EvChoice(
        label: 'Say the original. Badly. On purpose.',
        result:
            'It comes out clumsy and it does not land and it is unmistakably yours. The room '
            'does not click. The second door is not there when you look back at it, and the '
            'chair is the worse chair again, and you feel — for the first time in two acts — '
            'like the author of a sentence.',
        out: [Out(OutKind.maxHp, value: 18), Out(OutKind.flag, arg: 'kept_your_line'),
          Out(OutKind.relic)],
      ),
      EvChoice(
        label: 'Turn the page over.',
        result:
            'The scene continues on the back. It goes four pages past where you are standing. '
            'It is all written. You read to the end of the fourth page and stop, because the '
            'last line on it is a stage direction and the stage direction is your name followed '
            'by two words you would rather not have read.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'read_ahead'),
          Out(OutKind.shards, value: 40), Out(OutKind.hp, value: 10)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_quiet_town',
    title: 'THE TOWN THAT WAS SPARED',
    art: 'event_quiet_town',
    weight: 10,
    act: 2,
    body:
        'Intact. Completely intact, in an act where nothing is. Washing on lines, bread in the '
        'ovens, children in the square, no ash on anything at all.\n\n'
        'They are pleased to see you and they feed you and they will not, under any '
        'circumstances, discuss why the Falls have never come here. The subject closes like a '
        'door. Three separate people change it in the same three seconds.\n\n'
        'The bell tower has no bell in it. There is a rope, and the rope is worn.',
    plain: 'An untouched town refuses to explain why it was spared. Rest, investigate, or pull the rope.',
    choices: [
      EvChoice(
        label: 'Accept the hospitality and ask nothing.',
        result:
            'The best night you have had. Real food, a real bed, people who talk about weather '
            'and crops and a wedding. In the morning they fill your pack and walk you to the '
            'gate and one of the older women holds your hand a moment too long and says '
            '"I am sorry" for no reason either of you acknowledges.',
        out: [Out(OutKind.heal, value: 45), Out(OutKind.maxHp, value: 10),
          Out(OutKind.gold, value: 90)],
      ),
      EvChoice(
        label: 'Find out what they are paying.',
        result:
            'They are paying one. Every Fall, one of them goes up the road and does not come '
            'back, and in exchange the town stays drawn. It is a rota. It is on a board in the '
            'town hall in neat handwriting going back further than the buildings.\n\n'
            'The next name on the board is a child in the square. You watched her playing.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'knows_the_tithe'),
          Out(OutKind.hp, value: 8), Out(OutKind.shards, value: 35)],
      ),
      EvChoice(
        label: 'Pull the bell rope.',
        hidden: true,
        result:
            'No bell, no sound — and every single person in the town stops moving at once and '
            'looks at the tower, and then at each other, and something enormous goes out of '
            'them all simultaneously.\n\n"That has not rung since the first one," somebody says. '
            '"It means the rota is finished." They are not sure whether to be joyful. Neither '
            'are you, because you do not know whether it is true or whether you just made it '
            'true by pulling.',
        out: [Out(OutKind.page), Out(OutKind.mercy, value: 4), Out(OutKind.relic),
          Out(OutKind.flag, arg: 'rang_the_bell'), Out(OutKind.companion)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_understudy_room',
    title: 'THE DRESSING ROOM',
    art: 'event_understudy_room',
    weight: 10,
    act: 2,
    body:
        'Somebody has been living in here. A cot, a kettle, three thousand years of small '
        'domestic wear on a room that was built for twenty minutes of use before a performance.\n\n'
        'The mirror has notes stuck all round the frame. Blocking. Line readings. Diagrams of '
        'the fight at the top of the tower, dozens of them, each an improvement on the last.\n\n'
        'The most recent one is dated this act. It is a diagram of you.',
    plain: 'The Understudy\'s living quarters, full of studies of your fight. Take them, destroy them, or wait.',
    choices: [
      EvChoice(
        label: 'Take the diagrams.',
        result:
            'They are extraordinary. Somebody has watched you for one act and found four things '
            'about the way you fight that you did not know, two of which are weaknesses and two '
            'of which are not, and has annotated all four in a hand that is trying very hard to '
            'be helpful and not entirely succeeding.',
        out: [Out(OutKind.upgradeCard), Out(OutKind.randomCard), Out(OutKind.shards, value: 25),
          Out(OutKind.flag, arg: 'took_the_diagrams')],
      ),
      EvChoice(
        label: 'Burn the lot.',
        result:
            'Three thousand years of preparation in a metal bin, and it takes eleven minutes, '
            'and you stay for all of it. What is left in the bottom is the earliest sheet, half '
            'survived, and it is not a diagram — it is a drawing of the door of this room from '
            'the inside, done by somebody who had recently worked out that it did not open.',
        out: [Out(OutKind.cruelty, value: 3), Out(OutKind.shards, value: 45),
          Out(OutKind.flag, arg: 'burned_the_studies'), Out(OutKind.relic)],
      ),
      EvChoice(
        label: 'Sit down and wait for whoever lives here.',
        result:
            'Four hours. It comes in, sees you in its chair, and does not attack — stops in the '
            'doorway with the flat blank surprise of somebody who has rehearsed every version of '
            'this except the one where you simply waited.\n\n"Oh," it says. And then, after a '
            'moment, it puts the kettle on, because there is nothing else to do.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'knows_understudy'),
          Out(OutKind.mercy, value: 3), Out(OutKind.maxHp, value: 15), Out(OutKind.relic)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_long_stair',
    title: 'THE LONG STAIR',
    art: 'event_long_stair',
    weight: 11,
    act: 2,
    body:
        'Stairs. Up. No landings, no windows, no end visible. Cut into the wall at intervals, '
        'in a great many different hands, are numbers — people counting the steps.\n\n'
        'The counts do not agree. 4,000. 11,000. 4,000 again. One says 6, crossed out '
        'furiously and rewritten as 6,000, then crossed out again.\n\n'
        'Somebody has written near the bottom, low, where you would see it sitting down: '
        '**IT IS DIFFERENT EVERY TIME. STOP COUNTING. IT IS A TRICK TO KEEP YOU BUSY.**',
    plain: 'An endless staircase that changes length. Climb steadily, count anyway, or rest partway.',
    choices: [
      EvChoice(
        label: 'Climb without counting.',
        result:
            'It takes as long as it takes and you have no idea how long that is, and because you '
            'are not counting you notice other things instead: the change in the air, the point '
            'where the stone stops being cut and starts being drawn, the four places where '
            'somebody sat down and did not get up.',
        out: [Out(OutKind.maxHp, value: 12), Out(OutKind.flag, arg: 'stopped_counting'),
          Out(OutKind.relic)],
      ),
      EvChoice(
        label: 'Count anyway. Add your number.',
        result:
            'Eight thousand, four hundred and six. You cut it into the wall with everything you '
            'have left, at the height of somebody who has stopped being able to stand up '
            'straight, and it will disagree with the next one, and the next one will cut theirs '
            'anyway, and this is apparently what people are.',
        out: [Out(OutKind.hp, value: 14), Out(OutKind.shards, value: 30),
          Out(OutKind.flag, arg: 'counted_the_stair'), Out(OutKind.page)],
      ),
      EvChoice(
        label: 'Stop halfway and sleep on the steps.',
        result:
            'You wake up further up than you went to sleep. Considerably further. Nothing carried '
            'you — the stair simply has fewer steps below you than it did, and you are choosing, '
            'firmly, not to think about what that means about the last four hours of climbing.',
        out: [Out(OutKind.heal, value: 30), Out(OutKind.flag, arg: 'slept_on_the_stair'),
          Out(OutKind.shards, value: 15)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_second_opinion',
    title: 'THE SECOND OPINION',
    art: 'event_second_opinion',
    weight: 10,
    act: 2,
    body:
        'A surgeon\'s tent, well-lit, spotless, run by somebody with excellent hands and no '
        'patients.\n\n'
        '"I can take the thing out of you," she says, before you have said anything. "The one '
        'you have been carrying since the first act. I can see it from here. It is not a '
        'metaphor and it is not doing you any good."\n\n'
        'She washes her hands while you think about it. "It will cost you. Everything in the '
        'middle of a story costs. But you will be lighter, and you will be faster, and you will '
        'be slightly less yourself."',
    plain: 'A surgeon offers to remove a burden — you lose part of what makes you you. Accept, decline, or ask.',
    choices: [
      EvChoice(
        label: 'Let her take it out.',
        result:
            'Forty minutes. You are awake for all of it and it does not hurt, which is worse. '
            'What she puts in the dish is small and dark and yours, and you are unmistakably '
            'better afterwards in every way you can measure, and something you used to do '
            'automatically you now have to remember to do.',
        out: [Out(OutKind.removeCard), Out(OutKind.removeCard), Out(OutKind.upgradeCard),
          Out(OutKind.maxHp, value: 20), Out(OutKind.cruelty, value: 2),
          Out(OutKind.flag, arg: 'had_it_removed')],
      ),
      EvChoice(
        label: 'Keep it. It is load-bearing.',
        result:
            'She accepts this immediately and without argument, which suggests she has heard it '
            'before and does not think it is stupid. "Then eat something," she says, "and let me '
            'look at the shoulder, because the shoulder is not load-bearing and it is a mess."',
        out: [Out(OutKind.heal, value: 35), Out(OutKind.maxHp, value: 10),
          Out(OutKind.flag, arg: 'kept_the_weight'), Out(OutKind.mercy, value: 1)],
      ),
      EvChoice(
        label: '"Why do you have no patients?"',
        result:
            '"Because I am very good," she says, "and the ones I fix go on up the road, and the '
            'road does not send anybody back down." She dries her hands. "I have fixed two '
            'hundred and eleven people. I know what happened to none of them. I would like you '
            'to be the first one who comes back and tells me. That is the whole fee."',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'owes_the_surgeon'),
          Out(OutKind.heal, value: 20), Out(OutKind.relic), Out(OutKind.mercy, value: 2)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_inventory',
    title: 'THE INVENTORY',
    art: 'event_inventory',
    weight: 10,
    act: 2,
    body:
        'A clerk with a clipboard steps out of a doorway that is not attached to a building and '
        'asks, politely, to count what you are carrying.\n\n'
        '"Not to take it," she says. "To *count* it. There is a discrepancy." She shows you the '
        'sheet. It lists everything you have, correctly, including two things you picked up an '
        'hour ago.\n\n'
        'At the bottom, in a different column, it lists three more items. You do not have those. '
        'The column is headed **ISSUED**.',
    plain: 'A clerk\'s inventory lists three items you were issued but never received. Ask, refuse, or check.',
    choices: [
      EvChoice(
        label: 'Ask where the three issued items went.',
        result:
            'She checks, frowns, checks again, and then goes very still.\n\n"They were signed '
            'for," she says. "At the start of the run. By you." She turns the sheet round. The '
            'signature is yours and the date is the day you woke up and you have no memory of '
            'any of it, and the three items are not in your pack, and somebody has them.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'knows_theft'),
          Out(OutKind.shards, value: 30), Out(OutKind.relic)],
      ),
      EvChoice(
        label: 'Let her do the full count.',
        result:
            'Two hours of the most boring and most thorough process in Aevum. At the end she '
            'reconciles the discrepancy in your favour, issues a replacement on the spot from a '
            'bag that should not hold it, and thanks you sincerely for your patience in a way '
            'that suggests nobody has ever given it.',
        out: [Out(OutKind.relic), Out(OutKind.gold, value: 120), Out(OutKind.mercy, value: 2)],
      ),
      EvChoice(
        label: 'Refuse the count and walk on.',
        result:
            'She does not follow. She writes something short, and the doorway closes, and for '
            'the next two floors every merchant you meet quotes you a slightly worse price than '
            'the one on the tag and none of them can explain why.',
        out: [Out(OutKind.loseGold, value: 70), Out(OutKind.cruelty, value: 1)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_understanding',
    title: 'THE PERSON WHO UNDERSTANDS',
    art: 'event_understanding',
    weight: 9,
    act: 2,
    body:
        'They fall into step beside you and, within about four minutes, say three things about '
        'your situation that you have not been able to put into words yourself.\n\n'
        'It is enormous. It is the first time since you woke up that you have not had to '
        'explain anything.\n\n'
        'On the fifth thing they get it very slightly wrong — a shade too neat, a fraction too '
        'flattering — and the wrongness is small enough to ignore and specific enough to be a '
        'technique.',
    plain: 'A stranger understands you unnervingly well, but slightly too well. Open up, test them, or leave.',
    choices: [
      EvChoice(
        label: 'Talk anyway. You need this.',
        result:
            'Three hours, and you say things out loud that you did not know were in there, and '
            'they listen properly, and at the end of it you are better. Genuinely better. They '
            'also now know everything, and they leave at a junction rather than a settlement, '
            'and they go the way you are going.',
        out: [Out(OutKind.heal, value: 30), Out(OutKind.maxHp, value: 14),
          Out(OutKind.flag, arg: 'told_the_stranger'), Out(OutKind.curse)],
      ),
      EvChoice(
        label: 'Feed them something untrue and watch.',
        result:
            'They take it, absorb it, and reflect it back forty minutes later slightly improved, '
            'exactly as they did with everything true — which tells you what you needed. You '
            'part on excellent terms. You have learned a great deal and given away nothing, '
            'and it has cost you the only conversation like it in two acts.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'tested_the_listener'),
          Out(OutKind.shards, value: 30), Out(OutKind.relic)],
      ),
      EvChoice(
        label: 'Ask who briefed them.',
        hidden: true,
        result:
            'They stop walking. They do not deny it. What they say is: "Everyone who walks beside '
            'you was given an instruction before you met. Every single one. Including the ones '
            'who are going to keep it." A beat. "I am telling you this instead of doing mine. '
            'That is all I have got."',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'knows_betrayal'),
          Out(OutKind.companion), Out(OutKind.mercy, value: 3), Out(OutKind.maxHp, value: 12)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_hall_of_props',
    title: 'THE PROP STORE',
    art: 'event_hall_of_props',
    weight: 10,
    act: 2,
    body:
        'Racking to the ceiling, in aisles, labelled. Every object that has ever mattered in '
        'this story is in here on a shelf with a tag.\n\n'
        'THE SWORD THAT WAS PROMISED — used 41 times.\n'
        'THE LETTER THAT ARRIVES TOO LATE — used 300+ times, DO NOT REPAIR.\n'
        'THE THING IN THE BOX — never used.\n\n'
        'The last one has a thick layer of dust and a tag with no draft numbers on it at all.',
    plain: 'A warehouse of story objects. Take a proven one, take the unused box, or read the log.',
    choices: [
      EvChoice(
        label: 'Take something with a long service record.',
        result:
            'It works. It has worked three hundred times and it works again and there is a '
            'particular comfort in that, and also a particular flatness, because you can feel '
            'the groove it wants to run in and the groove is not going anywhere new.',
        out: [Out(OutKind.relic), Out(OutKind.upgradeCard), Out(OutKind.gold, value: 60)],
      ),
      EvChoice(
        label: 'Take THE THING IN THE BOX.',
        result:
            'It has never been used. Not once, in three thousand years, which either means it '
            'does not work or means nobody has ever been in a position where it was the right '
            'answer.\n\nIt is heavier than the box suggests. You do not open it. You are '
            'extremely aware of it for the rest of the act.',
        out: [Out(OutKind.relic), Out(OutKind.shards, value: 40),
          Out(OutKind.flag, arg: 'took_the_box'), Out(OutKind.curse)],
      ),
      EvChoice(
        label: 'Read the checkout log instead.',
        result:
            'Same handwriting on every line for three thousand years, on both sides of the '
            'column — issued by, returned by. One person has taken every object out and put '
            'every object back, forty-one times, alone, and signed for it each time, and the '
            'signature gets shakier and never stops.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'read_the_log'),
          Out(OutKind.shards, value: 35), Out(OutKind.maxHp, value: 10)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_flood_plain',
    title: 'WHAT THE WATER KEEPS',
    art: 'event_flood_plain',
    weight: 10,
    act: 2,
    body:
        'The valley floor is water now, and shallow, and absolutely clear, and under it — laid '
        'out flat and undisturbed, the way things are when a place drowns slowly — is a town '
        'with all its doors open.\n\n'
        'People are wading. Dozens of them, trousers rolled, moving very slowly, looking down. '
        'Nobody is salvaging. They are just looking.\n\n'
        '"You can see everything," one of them says. "That is the whole thing. You can finally '
        'see all of it."',
    plain: 'A drowned town lies perfectly visible under clear water. Wade and look, dive, or drain it.',
    choices: [
      EvChoice(
        label: 'Wade out and look with them.',
        result:
            'Three hours. Kitchens, workshops, a school with the chairs still square to the '
            'desks. Nothing is broken. It was not destroyed — the water simply arrived and '
            'stayed and preserved every single thing exactly as it was, which is the only '
            'honest archive in this world.',
        out: [Out(OutKind.page), Out(OutKind.mercy, value: 2), Out(OutKind.heal, value: 20),
          Out(OutKind.flag, arg: 'saw_the_town')],
      ),
      EvChoice(
        label: 'Go into one of the buildings.',
        result:
            'The building you pick is a printer\'s. Under two feet of clear water, the plates '
            'are still set for the last thing it ever ran, and the last thing it ever ran was '
            'an evacuation notice, and the notice is dated the day before the flood, and it was '
            'never distributed because it was still on the press.',
        out: [Out(OutKind.page), Out(OutKind.relic), Out(OutKind.shards, value: 30),
          Out(OutKind.flag, arg: 'found_the_notice')],
      ),
      EvChoice(
        label: 'Break the ridge and drain it.',
        result:
            'It takes most of a day and the water goes out in about eleven minutes, and what is '
            'underneath is not a preserved town at all — it is a preserved town for about four '
            'seconds, in air, and then it is mud and collapse and the sound of forty years of '
            'held breath being let out at once.\n\nThe waders do not shout at you. That is worse.',
        out: [Out(OutKind.cruelty, value: 4), Out(OutKind.relic), Out(OutKind.gold, value: 200),
          Out(OutKind.flag, arg: 'drained_the_valley')],
      ),
    ],
  ),

  GameEvent(
    id: 'the_understudy_letter',
    title: 'A LETTER FROM YOURSELF',
    art: 'event_understudy_letter',
    weight: 10,
    act: 2,
    body:
        'It is nailed to a post at head height, addressed to you by name, in your handwriting, '
        'weathered by about eight months of a world that has not had eight months.\n\n'
        'The first line is: *by the time you read this you will have decided I am a trick.*\n\n'
        'The second line is: *I am not going to be able to prove otherwise, so I am going to '
        'skip that part and just tell you the four things.*',
    plain: 'A letter from a previous you lists four warnings. Read all, read one, or burn it.',
    choices: [
      EvChoice(
        label: 'Read all four.',
        result:
            'Three of them are practical and immediately useful. The fourth is not a warning at '
            'all — it is an instruction about what to do at the top, and it is short, and it is '
            'unambiguous, and it is not what you expected, and you will carry it the whole rest '
            'of the way whether or not you intend to follow it.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'read_the_letter'),
          Out(OutKind.upgradeCard), Out(OutKind.relic), Out(OutKind.maxHp, value: 12)],
      ),
      EvChoice(
        label: 'Read only the first. Stop there.',
        result:
            'It is about the next elite and it is correct and it saves you a very great deal. '
            'You fold the rest without looking and put it away, and you take it out twice more '
            'that day and put it back both times.',
        out: [Out(OutKind.relic), Out(OutKind.flag, arg: 'partial_letter'),
          Out(OutKind.shards, value: 20)],
      ),
      EvChoice(
        label: 'Burn it unread.',
        result:
            'It goes up fast, being old. You feel briefly and genuinely free — nobody\'s '
            'instructions, not even your own — and then you spend the evening constructing four '
            'increasingly elaborate guesses about what was in it, which is worse than knowing '
            'and considerably worse than not caring.',
        out: [Out(OutKind.maxHp, value: 16), Out(OutKind.cruelty, value: 1),
          Out(OutKind.flag, arg: 'burned_the_letter')],
      ),
    ],
  ),

  GameEvent(
    id: 'the_orchard',
    title: 'THE ORCHARD OF SECOND TRIES',
    art: 'event_orchard',
    weight: 10,
    act: 2,
    body:
        'Every tree is grafted. Not one is a single plant — each has four or five different '
        'trunks fused into one, and the joins are old and ugly and completely successful, and '
        'the fruit is extraordinary.\n\n'
        'The orchardist is up a ladder. "None of them took on their own," she says. "Every one '
        'of these is four failures held against each other until they grew into something." '
        'She comes down. "It is not a metaphor. Or — it is, but it is also just how you do it."',
    plain: 'An orchard of trees grafted from failures. Eat, learn the technique, or ask about the empty row.',
    choices: [
      EvChoice(
        label: 'Eat, and take a basket.',
        result:
            'It is the best fruit in Aevum and there is a great deal of it and she will not take '
            'money, only help, and you spend an afternoon holding a ladder steady for somebody '
            'who has spent forty years making broken things work.',
        out: [Out(OutKind.heal, value: 40), Out(OutKind.maxHp, value: 14),
          Out(OutKind.mercy, value: 2)],
      ),
      EvChoice(
        label: 'Learn how the grafting is done.',
        result:
            'It is mostly patience and one counterintuitive cut. You are bad at it and she is '
            'unbothered by that and by the end of the day you have joined two things that had '
            'no business joining, and it holds, and you can do it again.',
        out: [Out(OutKind.upgradeCard), Out(OutKind.upgradeCard), Out(OutKind.randomCard),
          Out(OutKind.flag, arg: 'learned_grafting')],
      ),
      EvChoice(
        label: 'Ask about the empty row at the end.',
        result:
            '"That one I have not managed," she says. "Eleven attempts. It is the same graft '
            'every time and every time it takes for a season and then rejects." She looks down '
            'the empty row. "I will do a twelfth. Not this year. But I will."',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'knows_eleven'),
          Out(OutKind.relic), Out(OutKind.maxHp, value: 10)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_night_market',
    title: 'THE NIGHT MARKET',
    art: 'event_night_market',
    weight: 11,
    act: 2,
    body:
        'It sets up at dusk in a place that is a field at noon, and everything in it is being '
        'sold by somebody who should not exist — cut characters, retired props, three separate '
        'stalls run by things that were once the same thing.\n\n'
        'The currency is not gold. Above the entrance, on a board:\n\n'
        '**WE TAKE: TIME. MEMORY. A TRUE THING SAID ALOUD.**\n\n'
        'The third one appears to be the most valuable and the queue for it is the shortest.',
    plain: 'A market that trades in time, memory, or spoken truths. Pay with one of the three.',
    choices: [
      EvChoice(
        label: 'Pay with time.',
        result:
            'You do not notice it going. You notice, later, that the light is wrong for the hour '
            'you thought it was, and that your hands are a little older than they were, and that '
            'what you bought is genuinely excellent and is going to matter.',
        out: [Out(OutKind.relic), Out(OutKind.relic), Out(OutKind.hp, value: 12),
          Out(OutKind.flag, arg: 'paid_with_time')],
      ),
      EvChoice(
        label: 'Pay with a memory.',
        result:
            'They let you choose, which is the cruel part, and you choose a good one on purpose '
            'because the bad ones are load-bearing. It comes out cleanly. There is a shape in '
            'you now where a specific afternoon used to be, and you can feel the edges of it, '
            'and what you got is worth it and you will keep checking whether it is worth it.',
        out: [Out(OutKind.removeCard), Out(OutKind.relic), Out(OutKind.gold, value: 180),
          Out(OutKind.flag, arg: 'sold_a_memory')],
      ),
      EvChoice(
        label: 'Say a true thing out loud.',
        result:
            'The whole market goes quiet for it. Not respectfully — *commercially*, the way a '
            'floor goes quiet when a large lot comes up. You say it. It is not flattering and it '
            'is about why you are still walking, and it is true, and the price they pay is '
            'enormous and they pay it instantly and without haggling.',
        out: [Out(OutKind.relic), Out(OutKind.relic), Out(OutKind.shards, value: 50),
          Out(OutKind.page), Out(OutKind.flag, arg: 'said_it_aloud')],
      ),
    ],
  ),

  GameEvent(
    id: 'the_wall_of_names',
    title: 'THE WALL',
    art: 'event_wall_of_names',
    weight: 10,
    act: 2,
    body:
        'Two miles of it, and every inch carved with names. Not a memorial — the lettering is '
        'too rushed and the spacing is wrong and in places somebody has clearly been carving '
        'while walking.\n\n'
        'A woman is working near the end with a hammer and a chisel and a list.\n\n'
        '"Everyone who was in a draft and is not in this one," she says. "I am four hundred '
        'years behind. I will not catch up. That is fine — the point is not catching up, the '
        'point is that it is being done at all."',
    plain: 'A woman is carving the names of everyone erased. Help, find your name, or add one.',
    choices: [
      EvChoice(
        label: 'Take the second chisel.',
        result:
            'You do eleven names. It takes all day and your hands are ruined and eleven is '
            'nothing against four hundred years, and she does not tell you it is nothing, '
            'because it is eleven more than there were this morning.',
        out: [Out(OutKind.mercy, value: 4), Out(OutKind.maxHp, value: 14),
          Out(OutKind.relic), Out(OutKind.flag, arg: 'carved_names')],
      ),
      EvChoice(
        label: 'Look for your own name.',
        result:
            'It is there. Nine times, at nine different points along the wall, in nine different '
            'depths of weathering. The oldest one is nearly worn out. The newest one is from '
            'this act, and it is finished, and she carved it before you arrived because the list '
            'she is working from does not distinguish between the erased and the about-to-be.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'knows_loop'),
          Out(OutKind.shards, value: 35), Out(OutKind.hp, value: 6)],
      ),
      EvChoice(
        label: 'Give her a name she does not have.',
        hidden: true,
        result:
            'You give her the Author\'s.\n\nShe checks the list. It is not on it. She checks '
            'again, and then a third time, going back through four hundred years of pages, and '
            'when she looks up her face has changed entirely.\n\n"He is not erased," she says. '
            '"He is not in any draft. He has never been in a draft." She sets the chisel down. '
            '"Then what has he been doing all this time?"',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'named_the_author'),
          Out(OutKind.relic), Out(OutKind.shards, value: 45), Out(OutKind.maxHp, value: 12)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_rehearsal',
    title: 'THE REHEARSAL',
    art: 'event_rehearsal',
    weight: 10,
    act: 2,
    body:
        'Fifty people in a field, running your fight. Not a memory and not a vision — a '
        'rehearsal, with a director, with marks on the ground, with somebody in your part who '
        'keeps getting a beat wrong and being taken back to the top.\n\n'
        'They are extremely good. They have clearly done this a great many times.\n\n'
        'The director sees you, checks a page, checks you, and says — to the company, without '
        'any particular urgency — "**Right. Everybody. That is the actual one.**"',
    plain: 'A company is rehearsing your final fight. Watch, join, or stop it.',
    choices: [
      EvChoice(
        label: 'Watch the whole run-through.',
        result:
            'They do it end to end. You see the fight you have not had yet, staged by people who '
            'have staged it four hundred times, and it is enormously informative and it ends '
            'with your part dying, and the director says "Better. Again from the top," and they '
            'go again.',
        out: [Out(OutKind.page), Out(OutKind.upgradeCard), Out(OutKind.shards, value: 35),
          Out(OutKind.flag, arg: 'saw_the_rehearsal')],
      ),
      EvChoice(
        label: 'Take your own part off the understudy.',
        result:
            'The company adjusts instantly and without comment, which is the most professional '
            'thing you have ever seen. You do the fight. You do it badly in three places and the '
            'director fixes all three, brusquely, correctly, and by the fourth pass you are '
            'doing something you could not do this morning.',
        out: [Out(OutKind.upgradeCard), Out(OutKind.upgradeCard), Out(OutKind.randomCard),
          Out(OutKind.maxHp, value: 12), Out(OutKind.flag, arg: 'rehearsed_it')],
      ),
      EvChoice(
        label: 'Tell them the ending is not fixed yet.',
        result:
            'The director says "Yes it is," and holds up the page, and the page is blank from '
            'the fight onwards — and she looks at it, and turns it over, and turns it back, and '
            'the company waits, and for the first time in four hundred years nobody in that '
            'field knows what happens next.',
        out: [Out(OutKind.flag, arg: 'unfixed_the_ending'), Out(OutKind.page),
          Out(OutKind.relic), Out(OutKind.mercy, value: 3), Out(OutKind.maxHp, value: 16)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_pyre_keeper',
    title: 'THE KEEPER OF THE PYRE',
    art: 'event_pyre_keeper',
    weight: 10,
    act: 2,
    body:
        'The fire is the size of a house and it has been burning since before the ridge above '
        'it eroded into its present shape. A man feeds it. That is his entire function and he '
        'performs it with the absorbed competence of somebody who is good at one thing.\n\n'
        '"Drafts," he says. "Rejected pages. It has to burn or they come back." He throws '
        'another armful on. "There is one I have not been able to put in. It is under the '
        'stool. Do not ask me why."',
    plain: 'A man burns rejected drafts forever, except one he keeps. Burn it, read it, or take it.',
    choices: [
      EvChoice(
        label: 'Put it in the fire for him.',
        result:
            'He does not stop you and he does not watch. It goes up like everything else. '
            'Afterwards he works faster for about an hour and then slower for the rest of the '
            'day, and near the end he says, to the fire, "That was the one where she lived."',
        out: [Out(OutKind.cruelty, value: 2), Out(OutKind.relic), Out(OutKind.shards, value: 30),
          Out(OutKind.flag, arg: 'burned_the_kept_page')],
      ),
      EvChoice(
        label: 'Read it first.',
        result:
            'Four pages. A version of the second act where a specific person does not die, and '
            'it is worse — genuinely, structurally worse, saggy in the middle, and you can see '
            'exactly why it was rejected and exactly why he cannot burn it, and both of those '
            'things are now permanently in your head at the same time.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'read_the_kept_page'),
          Out(OutKind.maxHp, value: 12), Out(OutKind.shards, value: 25)],
      ),
      EvChoice(
        label: 'Take it away with you.',
        result:
            'He lets you. He very deliberately does not look at what you are doing while you do '
            'it, and he says nothing at all, and when you leave he is feeding the fire at '
            'exactly the same rate as when you arrived and his shoulders are down.',
        out: [Out(OutKind.relic), Out(OutKind.mercy, value: 3), Out(OutKind.page),
          Out(OutKind.flag, arg: 'carry_the_kept_page')],
      ),
    ],
  ),

  GameEvent(
    id: 'the_borrowed_army',
    title: 'THE BORROWED ARMY',
    art: 'event_borrowed_army',
    weight: 9,
    act: 2,
    body:
        'Four hundred soldiers, drawn up in good order, in a valley, with a commander who '
        'salutes you.\n\n'
        '"We were written for a war that got cut," she says. "We have been at readiness for '
        'nine hundred years. We will follow anybody who gives us an objective and we will not '
        'ask whether it is a good one, and I am telling you that so that you understand exactly '
        'what you are being offered."',
    plain: 'Four hundred purposeless soldiers offer to follow you anywhere. Take them, refuse, or release them.',
    choices: [
      EvChoice(
        label: 'Take them.',
        result:
            'They are magnificent and they are absolutely obedient and by the second day you '
            'have stopped explaining your reasoning to anybody, because nobody requires it, and '
            'on the third day you catch yourself giving an order you would not have given in '
            'front of one person who could say no.',
        out: [Out(OutKind.relic), Out(OutKind.relic), Out(OutKind.cruelty, value: 3),
          Out(OutKind.curse), Out(OutKind.flag, arg: 'took_the_army')],
      ),
      EvChoice(
        label: 'Give them an objective they can finish.',
        result:
            'You send them to the wall of names, with chisels. The commander repeats the order '
            'back twice to make sure, and then asks — carefully, as though it might be a trap — '
            'whether there is an end condition. You tell her the end condition is when the list '
            'is finished. She writes it down like a woman being handed something precious.',
        out: [Out(OutKind.mercy, value: 4), Out(OutKind.page), Out(OutKind.relic),
          Out(OutKind.flag, arg: 'gave_them_work')],
      ),
      EvChoice(
        label: 'Tell them the war was cut and they may go.',
        result:
            'It takes an hour to land. Then it lands. Four hundred people finding out at the '
            'same moment that there is nothing to be at readiness for, and about half of them '
            'sit down where they are standing, and the commander stays upright and asks you, '
            'quietly, what she is supposed to do now — and you do not have an answer, and you '
            'say so, and she says that is the first honest order she has ever been given.',
        out: [Out(OutKind.page), Out(OutKind.mercy, value: 2), Out(OutKind.companion),
          Out(OutKind.shards, value: 40), Out(OutKind.flag, arg: 'released_the_army')],
      ),
    ],
  ),

  GameEvent(
    id: 'the_two_of_you',
    title: 'THE OTHER ONE',
    art: 'event_two_of_you',
    weight: 10,
    act: 2,
    body:
        'There is another Vessel on the road and they are having a worse time than you. Same '
        'act, same direction, further along the process of coming apart.\n\n'
        'They are also, unmistakably, in the middle of the same run. Not a draft. Not a memory. '
        'Now.\n\n'
        '"There is only one of us at the top," they say, before anything else. "I checked. '
        'There is one chair and one page and it does not take two."',
    plain: 'Another living Vessel says only one can reach the top. Fight, ally, or find out if it is true.',
    choices: [
      EvChoice(
        label: 'Fight them for it.',
        result:
            'It is quick and it is ugly and it is between two people who use the same eight '
            'moves. You win. You are much worse afterwards in a way that has nothing to do with '
            'the injuries, and you take what they were carrying, because leaving it would be '
            'sentimental and you are past that now.',
        out: [Out(OutKind.relic), Out(OutKind.relic), Out(OutKind.hp, value: 25),
          Out(OutKind.cruelty, value: 5), Out(OutKind.flag, arg: 'killed_the_other')],
      ),
      EvChoice(
        label: 'Walk together and settle it at the top.',
        result:
            'Two acts is a long way. By the end of the first day you have stopped watching them '
            'sleep. By the end of the second you have divided the watches. Neither of you brings '
            'up the chair again and both of you are thinking about it constantly, and the '
            'walking is, regardless, the least alone you have been.',
        out: [Out(OutKind.companion), Out(OutKind.maxHp, value: 18), Out(OutKind.mercy, value: 2),
          Out(OutKind.flag, arg: 'walked_together')],
      ),
      EvChoice(
        label: '"Who told you there is one chair?"',
        hidden: true,
        result:
            'They open their mouth, and stop.\n\n"...it was in the briefing," they say, slowly. '
            '"At the start. Before I woke up properly." They sit down on the verge. "I have never '
            'once checked. I have been walking towards killing somebody for two acts on the '
            'strength of a thing I was told before I was awake."',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'knows_the_briefing'),
          Out(OutKind.companion), Out(OutKind.mercy, value: 3), Out(OutKind.maxHp, value: 14)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_slow_room',
    title: 'THE SLOW ROOM',
    art: 'event_slow_room',
    weight: 9,
    act: 2,
    body:
        'Time is wrong in here. Not stopped — *thick.* A cup knocked off the table an unknown '
        'while ago is a third of the way to the floor and visibly moving.\n\n'
        'Somebody has set up a workbench and is using this. Tools, materials, and a note pinned '
        'up that reads: **ONE HOUR OUT THERE. AS LONG AS YOU LIKE IN HERE. THE PRICE IS THAT '
        'YOU AGE FOR ALL OF IT.**\n\n'
        'The chair at the bench has been sat in by somebody for a very long time.',
    plain: 'A room where you can work for years at the cost of ageing for them. Work, rest, or leave.',
    choices: [
      EvChoice(
        label: 'Work the bench until you have finished something.',
        result:
            'You do not know how long. Long enough to get properly good at something you were '
            'clumsy at this morning. You come out an hour later by the world\'s reckoning, with '
            'grey in your hair that was not there, holding a thing you made yourself out of '
            'time you will not get back.',
        out: [Out(OutKind.upgradeCard), Out(OutKind.upgradeCard), Out(OutKind.upgradeCard),
          Out(OutKind.relic), Out(OutKind.maxHp, value: -12),
          Out(OutKind.flag, arg: 'worked_the_slow_room')],
      ),
      EvChoice(
        label: 'Sleep in here. Get properly rested.',
        result:
            'Weeks of sleep in an hour. You come out with everything knitted and nothing hurting '
            'and a very slight sense that you have been away, and the ageing is small enough '
            'that you would have to be looking for it.',
        out: [Out(OutKind.heal, value: 60), Out(OutKind.maxHp, value: -4),
          Out(OutKind.flag, arg: 'slept_slow')],
      ),
      EvChoice(
        label: 'Ask who has been sitting in the chair.',
        result:
            'Nobody answers because nobody is there. But the work on the bench is half done and '
            'the tools are laid out for a right-handed person and there is a cup with something '
            'still warm in it, and the warmth in a room this slow means somebody left roughly '
            'four seconds ago and has been gone for years.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'missed_them'),
          Out(OutKind.shards, value: 35), Out(OutKind.relic)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_censor',
    title: 'THE CENSOR',
    art: 'event_censor',
    weight: 10,
    act: 2,
    body:
        'A checkpoint, staffed by one official with a stamp and a very thick book of what may '
        'not be depicted.\n\n'
        '"Not people," he says, wearily, seeing your face. "Content. I remove content." He '
        'stamps something. "You are carrying four things that are not permitted in the third '
        'act. I am obliged to take them. I am also obliged to tell you that the list was '
        'written by somebody who has not read it in three thousand years."\n\n'
        'He waits. He has left a very long pause.',
    plain: 'A censor must confiscate four things, but hints the rules are unenforced. Comply, argue, or read the book.',
    choices: [
      EvChoice(
        label: 'Hand them over.',
        result:
            'He takes all four, stamps the form, gives you a receipt, and then — because the form '
            'is stamped and the job is done and nothing further is required of him — gives you '
            'something off his own desk that is not on any list because nobody has ever thought '
            'to put it on one.',
        out: [Out(OutKind.removeCard), Out(OutKind.removeCard), Out(OutKind.relic),
          Out(OutKind.gold, value: 140), Out(OutKind.mercy, value: 1)],
      ),
      EvChoice(
        label: 'Take the pause. Argue every one.',
        result:
            'Two hours. He is delighted. He has not had an argument in eleven hundred years and '
            'he is extremely good at it and he loses three of the four on their merits, and he '
            'concedes each one with visible professional pleasure and stamps the form '
            'PERMITTED — UNDER PROTEST, and the protest is his own.',
        out: [Out(OutKind.relic), Out(OutKind.shards, value: 35), Out(OutKind.page),
          Out(OutKind.flag, arg: 'argued_the_censor')],
      ),
      EvChoice(
        label: 'Ask to read the book of prohibitions.',
        result:
            'It is four hundred pages and every entry is a thing that was, at some point, in a '
            'draft. Read as a list of prohibitions it is bureaucracy. Read as a list of what has '
            'been taken out of this world, one item at a time, over three thousand years, it is '
            'the most complete account of the Author that exists, and it is sitting on a desk at '
            'a checkpoint nobody uses.',
        out: [Out(OutKind.page), Out(OutKind.page), Out(OutKind.flag, arg: 'read_the_prohibitions'),
          Out(OutKind.shards, value: 45)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_understudys_friend',
    title: 'SOMEBODY ELSE\'S COMPANION',
    art: 'event_understudys_friend',
    weight: 9,
    act: 2,
    body:
        'They are sitting by the road with a pack that has two of everything in it and they are '
        'waiting for somebody who is not going to arrive.\n\n'
        '"He went up," they say. "Two days. He said stay here, and I said that is stupid, and '
        'he said it anyway, so." They shrug. "So I am staying here."\n\n'
        'The pack has two bedrolls, two cups, two of a small carved thing that is clearly a '
        'joke between two people, and enough food for one person for a very long time.',
    plain: 'Someone waits for a companion who went ahead and will not return. Tell them, wait, or bring them.',
    choices: [
      EvChoice(
        label: 'Tell them what is at the top.',
        result:
            'They take it well, which is to say they take it silently and completely and without '
            'any argument at all, and then they repack the bag properly for one person, which '
            'takes about four minutes and is the single hardest thing you have watched anybody '
            'do in this world.',
        out: [Out(OutKind.mercy, value: 3), Out(OutKind.page), Out(OutKind.relic),
          Out(OutKind.flag, arg: 'told_them_the_truth')],
      ),
      EvChoice(
        label: 'Sit down and wait with them a while.',
        result:
            'Half a day. You do not tell them anything. They tell you a great deal — mostly '
            'about him, all of it small and specific and funny — and by the end of it you know '
            'a person who is definitely dead better than you know most people who are not.',
        out: [Out(OutKind.heal, value: 25), Out(OutKind.mercy, value: 2),
          Out(OutKind.maxHp, value: 10), Out(OutKind.page)],
      ),
      EvChoice(
        label: 'Tell them to come with you and find out.',
        result:
            'They are up and packed in ninety seconds, which tells you exactly how long they had '
            'been wanting somebody to say that. They carry the double pack the whole way and '
            'will not let you take any of it, and neither of you mentions the second bedroll.',
        out: [Out(OutKind.companion), Out(OutKind.maxHp, value: 12),
          Out(OutKind.flag, arg: 'brought_them_along')],
      ),
    ],
  ),

  GameEvent(
    id: 'the_gallery_of_falls',
    title: 'THE GALLERY',
    art: 'event_gallery_of_falls',
    weight: 10,
    act: 2,
    body:
        'A long hall, well kept, hung with three thousand paintings. Each one shows a world '
        'ending. They are hung in order and they are all by the same hand and they get, '
        'unmistakably, better.\n\n'
        'The early ones are crude and furious. The middle period is technically superb and '
        'emotionally absent. The most recent forty are quiet, small, and almost unbearable.\n\n'
        'There is a space at the end with a nail in the wall and no painting on it.',
    plain: 'Three thousand paintings of world-endings, improving over time. Study, take one, or use the empty nail.',
    choices: [
      EvChoice(
        label: 'Study the most recent forty.',
        result:
            'They are not triumphant. They are not even dramatic. They are the work of somebody '
            'who has stopped enjoying this and cannot stop doing it, and who has got so good at '
            'it that the badness of what is being depicted comes through completely, and who '
            'keeps hanging them where they can be seen.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'saw_the_gallery'),
          Out(OutKind.shards, value: 40), Out(OutKind.maxHp, value: 12)],
      ),
      EvChoice(
        label: 'Take the earliest one off the wall.',
        result:
            'Crude, furious, and signed — the only signed one in the hall. The signature is not '
            'a name. It is two words, pressed hard enough to go through the canvas: '
            '**me again.**',
        out: [Out(OutKind.page), Out(OutKind.relic), Out(OutKind.flag, arg: 'took_the_first'),
          Out(OutKind.shards, value: 30)],
      ),
      EvChoice(
        label: 'Hang something of your own on the empty nail.',
        hidden: true,
        result:
            'You have nothing to hang, so you hang what you have: the map, or the letter, or '
            'whatever is in your pack that is about this run rather than the last three '
            'thousand.\n\nIt is the only object in the gallery that is not a picture of an '
            'ending. It stays up. The hall does not object, and the hall has objected to '
            'things before.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'hung_something'),
          Out(OutKind.maxHp, value: 18), Out(OutKind.relic), Out(OutKind.mercy, value: 2)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_conscript',
    title: 'THE CONSCRIPT',
    art: 'event_conscript',
    weight: 10,
    act: 2,
    body:
        'A young soldier steps into the road, entirely alone, and stands in your way with '
        'obvious terror and complete determination.\n\n'
        '"I am supposed to stop you," they say. "That is the order. I know how this goes. I '
        'have watched it go this way four times." Their hands are shaking badly. "I am doing it '
        'anyway, because if I do not, they send somebody who will be worse at it, and then '
        'there are two of us."',
    plain: 'A terrified soldier blocks your path out of duty. Fight, talk them down, or go around.',
    choices: [
      EvChoice(
        label: 'Go around. Refuse the fight.',
        result:
            'You walk into the field and round them, and they turn to keep facing you the whole '
            'way, and neither of you says anything else. At the treeline you look back. They are '
            'still standing in the road, in the correct position, guarding a route nobody is on.',
        out: [Out(OutKind.mercy, value: 3), Out(OutKind.flag, arg: 'spared_the_conscript'),
          Out(OutKind.maxHp, value: 8)],
      ),
      EvChoice(
        label: 'Tell them to report that you got past.',
        result:
            'It takes a while, because it is not in the order, and then you can see them work out '
            'that "he got past" is a true sentence that will also be a survivable one.\n\nThey '
            'thank you very formally and very badly and then, at the last moment, tell you the '
            'thing about the elite up ahead that they were absolutely not supposed to tell you.',
        out: [Out(OutKind.mercy, value: 2), Out(OutKind.relic), Out(OutKind.shards, value: 25),
          Out(OutKind.flag, arg: 'freed_the_conscript'), Out(OutKind.companion)],
      ),
      EvChoice(
        label: 'Fight. They chose to stand there.',
        result:
            'It lasts eleven seconds. They were not lying about having watched it four times; '
            'they had simply never been the one in it. You take what they have, which is a '
            'standard-issue nothing, and the road is clear, and you make good time.',
        out: [Out(OutKind.cruelty, value: 4), Out(OutKind.gold, value: 70),
          Out(OutKind.randomCard), Out(OutKind.flag, arg: 'killed_the_conscript')],
      ),
    ],
  ),

  GameEvent(
    id: 'the_maintenance',
    title: 'MAINTENANCE',
    art: 'event_maintenance',
    weight: 10,
    act: 2,
    body:
        'A hatch in the ground, propped open, with legs sticking out of it and swearing coming '
        'up. Below: pipes, cabling, and the working underside of the world, all of it labelled '
        'in the same handwriting as everything else.\n\n'
        '"Hold this," says the engineer, without looking up, and hands you something that is '
        'humming.\n\n'
        'On the wall of the crawlspace, in paint, very large: **DO NOT SHUT DOWN. RESTART IS '
        'NOT A SUPPORTED OPERATION.**',
    plain: 'An engineer maintains the machinery under the world. Help, ask about the sign, or find the shutdown.',
    choices: [
      EvChoice(
        label: 'Hold the thing. Ask what it does.',
        result:
            'Four hours in a crawlspace. It is continuity — the reason a chair is in the same '
            'place when you look back at it. It is held together with brackets and improvisation '
            'and one engineer, and it has never been given a maintenance window, and she has '
            'been doing this alone since the fourteenth Fall.',
        out: [Out(OutKind.page), Out(OutKind.relic), Out(OutKind.mercy, value: 2),
          Out(OutKind.flag, arg: 'helped_maintenance')],
      ),
      EvChoice(
        label: 'Ask why restart is not supported.',
        result:
            '"Because it has been tried," she says, from inside the panel. "Three thousand times, '
            'roughly. Each one is a Fall. He thinks he is starting over." She backs out and looks '
            'at you. "He is not. There is no clean boot. Every one of them comes back up with '
            'everything the last one had still in it, which is why this," — she gestures at the '
            'crawlspace — "gets worse every time."',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'knows_no_restart'),
          Out(OutKind.shards, value: 45), Out(OutKind.maxHp, value: 14)],
      ),
      EvChoice(
        label: 'Find the shutdown anyway.',
        hidden: true,
        result:
            'It is at the far end and it is not hidden and it is not locked, because locking it '
            'would suggest somebody thought it should not be reachable. It is a lever. It is '
            'labelled. There is a stool in front of it, worn, at exactly the height of somebody '
            'sitting and looking at a lever for a very long time.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'found_the_lever'),
          Out(OutKind.relic), Out(OutKind.shards, value: 50)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_good_ending_salesman',
    title: 'THE GOOD ENDING',
    art: 'event_good_ending_salesman',
    weight: 9,
    act: 2,
    body:
        'He has a case, and in the case is an ending, and it is genuinely good. He lets you '
        'read it. Everyone lives, the loop stops, the cost is proportionate and paid by the '
        'right person.\n\n'
        '"It is real," he says. "It works. It has been costed and checked and it will run." He '
        'closes the case. "The price is that it is not yours. You will reach the top and '
        'something else will happen and you will not remember wanting anything different, and '
        'the world will get this, and it will be fine."',
    plain: 'A salesman offers a genuinely good ending you will not experience or remember choosing.',
    choices: [
      EvChoice(
        label: 'Buy it. Take the outcome, lose the ending.',
        result:
            'He is careful to make sure you have understood, twice, and then takes payment, and '
            'the transaction is completed with a handshake that he holds a beat too long — the '
            'grip of somebody who has done this eleven times and has stopped being able to tell '
            'himself it is a sale.',
        out: [Out(OutKind.loseGold, value: 200), Out(OutKind.flag, arg: 'bought_the_ending'),
          Out(OutKind.page), Out(OutKind.relic), Out(OutKind.mercy, value: 3)],
        needGold: 200,
      ),
      EvChoice(
        label: 'Refuse. Whatever happens has to be yours.',
        result:
            'He does not argue and he does not seem disappointed. He notes something in a book. '
            '"Twelfth refusal," he says. "Out of three thousand approaches." He looks up. "I '
            'keep the list because the refusals are the only part of this job that is '
            'interesting."',
        out: [Out(OutKind.maxHp, value: 20), Out(OutKind.flag, arg: 'refused_the_ending'),
          Out(OutKind.page), Out(OutKind.shards, value: 30)],
      ),
      EvChoice(
        label: 'Ask who wrote it.',
        hidden: true,
        result:
            'He turns the case round and shows you the inside of the lid. There is a name plate. '
            'It does not say a name — it says a desk number, and a date three thousand years ago, '
            'and the words **NOT FOR USE BY AUTHOR.**\n\n"He wrote it," the salesman says. '
            '"First year. Before he got frightened. He is not allowed to use it himself. That is '
            'the one rule he made and it is the only one he has ever kept."',
        out: [Out(OutKind.page), Out(OutKind.page), Out(OutKind.flag, arg: 'knows_the_good_end'),
          Out(OutKind.relic), Out(OutKind.shards, value: 50)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_understudy_grave',
    title: 'THE PLOT',
    art: 'event_understudy_grave',
    weight: 9,
    act: 2,
    body:
        'A burial plot, tended, with forty-one graves in neat rows and one open at the end with '
        'a spade stuck in the spoil heap.\n\n'
        'The headstones do not have names. They have draft numbers.\n\n'
        'Somebody has been digging these, one per Fall, for three thousand years, and the one '
        'at the end is fresh, and the spade is clean, and the earth is waiting.',
    plain: 'A graveyard of your past drafts, with one fresh grave open. Fill it, take the spade, or wait.',
    choices: [
      EvChoice(
        label: 'Fill the open grave in.',
        result:
            'It takes two hours and it is enormously satisfying and completely irrational, and '
            'when it is done there is a flat patch of turned earth at the end of a row and no '
            'space prepared for you, and you will think about that at the top of the tower.',
        out: [Out(OutKind.maxHp, value: 20), Out(OutKind.flag, arg: 'filled_the_grave'),
          Out(OutKind.mercy, value: 2), Out(OutKind.relic)],
      ),
      EvChoice(
        label: 'Take the spade.',
        result:
            'It is a very good spade and it has been used a great deal and there is a name '
            'burned into the handle, worn nearly out. Not a draft number. An actual name, which '
            'means somebody down here was a person before they were a job.',
        out: [Out(OutKind.page), Out(OutKind.relic), Out(OutKind.flag, arg: 'took_the_spade')],
      ),
      EvChoice(
        label: 'Wait for the gravedigger.',
        result:
            'They come at dusk with the next headstone under one arm, see the grave still empty '
            'and you sitting on the wall, and stop.\n\n"You are early," they say. Then they look '
            'at the stone in their hand, and at you, and put it down face-first in the grass, '
            'which is the first time in three thousand years anybody has declined to place one.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'met_the_gravedigger'),
          Out(OutKind.companion), Out(OutKind.maxHp, value: 14), Out(OutKind.mercy, value: 2)],
      ),
    ],
  ),
];
