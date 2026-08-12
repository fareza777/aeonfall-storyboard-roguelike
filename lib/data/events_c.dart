import 'narrative_model.dart';

/// Third event book. The game shipped with 24 wandering events against roughly
/// 24 event nodes in a single run, which meant one playthrough could exhaust
/// every piece of writing in it. These are weighted towards Act I and the
/// act-agnostic pool.
const kEventsC = <GameEvent>[
  GameEvent(
    id: 'the_weather_man',
    title: 'THE WEATHER',
    art: 'event_weather_man',
    weight: 10,
    act: 1,
    body:
        'A man is standing in the road with both arms up, holding the rain off an area about '
        'the size of a kitchen. He has clearly been doing it a while. His arms shake.\n\n'
        '"It only rains here," he says, without turning round. "Two panels wide. Every draft. '
        'Somebody liked how it looked once and never took it out." Under the dry patch there '
        'is a chair, a cup, and a small grave with no name on it.\n\n'
        '"I can\'t put my arms down," he says. "You understand. She\'s under there."',
    plain: 'A man holds back permanent rain over a grave. Help him, replace him, or leave.',
    choices: [
      EvChoice(
        label: 'Take over. Give him one hour.',
        result:
            'Your arms are burning inside four minutes. He sits in the chair and drinks from '
            'the cup and does not say anything at all, and after an hour he stands up and takes '
            'the weight back without being asked. What he presses into your hand on the way out '
            'is still warm from being held that long.',
        out: [Out(OutKind.relic), Out(OutKind.mercy, value: 2), Out(OutKind.hp, value: 6)],
      ),
      EvChoice(
        label: 'Cut the rain out of the panel.',
        result:
            'It comes away like a sticker. Underneath there is nothing — not sky, not weather, '
            'just the flat white of a page that was never filled in. He looks up into it for a '
            'long time. "Oh," he says. Then he lies down on the grave and does not get up, and '
            'the white does not care either way.',
        out: [Out(OutKind.shards, value: 25), Out(OutKind.cruelty, value: 2),
          Out(OutKind.flag, arg: 'cut_the_weather')],
      ),
      EvChoice(
        label: 'Ask who is under the grave.',
        hidden: true,
        result:
            '"Me," he says. "Third draft. They kept the grave and redrew the man." He shifts his '
            'grip. "I\'m holding the rain off myself. I have been for two thousand years. It is '
            'the only job I have ever been given and I would like it on record that I have not '
            'once put my arms down."\n\nYou write it down. He watches you do it, and something '
            'in his face comes loose.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'knows_reuse'), Out(OutKind.maxHp, value: 10)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_understudy_bench',
    title: 'THE BENCH',
    art: 'event_understudy_bench',
    weight: 10,
    act: 1,
    body:
        'Nine people are sitting on a bench outside a door, in costume, waiting. They are all '
        'you. Different builds, different scars, one with your face at maybe sixteen.\n\n'
        'None of them look up. They have the specific patience of people who have been told to '
        'wait somewhere and have taken that instruction extremely seriously for a very long '
        'time.\n\n'
        'There is a tenth space on the bench. It has your name on a strip of card taped to it.',
    plain: 'Nine unused versions of you wait to be called. Sit with them, wake them, or pass.',
    choices: [
      EvChoice(
        label: 'Sit down in the tenth space.',
        result:
            'The moment you sit, all nine of them look at you at once, and every single one of '
            'them looks relieved. "Oh good," says the sixteen-year-old. "You went. We weren\'t '
            'sure anybody ever went." They spend the rest of the afternoon telling you '
            'everything they were each rehearsed for, and none of it overlaps, and all of it '
            'is useful.',
        out: [Out(OutKind.randomCard), Out(OutKind.randomCard),
          Out(OutKind.flag, arg: 'sat_with_drafts'), Out(OutKind.maxHp, value: 8)],
      ),
      EvChoice(
        label: 'Tell them the door is never going to open.',
        result:
            'You expect a scene. What you get is nine people quietly standing up, one after '
            'another, and walking off in nine different directions without a word — and the '
            'bench, and the door, and the corridor, all going thin behind them like something '
            'that was only being held up by the waiting.',
        out: [Out(OutKind.mercy, value: 3), Out(OutKind.shards, value: 20),
          Out(OutKind.flag, arg: 'dismissed_drafts')],
      ),
      EvChoice(
        label: 'Take the strip of card with your name on it.',
        result:
            'It peels off cleanly. On the back, in the same cramped hand that is on every '
            'margin in this world: *tenth attempt. if this one also refuses, stop making them.* '
            '\n\nThe nine of them watch you read it. Nobody says anything. Everybody understands '
            'what it means that you are the tenth.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'knows_tenth'), Out(OutKind.relic)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_lost_property',
    title: 'LOST PROPERTY',
    art: 'event_lost_property',
    weight: 11,
    body:
        'A booth at a crossroads, staffed by nobody, with a ledger open on the counter. Behind '
        'it: shelves of things characters dropped and the story never bothered to have them '
        'pick up again.\n\n'
        'A wedding ring. A child\'s shoe. Forty-one identical letters, all unopened, all '
        'addressed to the same person. A sword with somebody\'s grip worn into it.\n\n'
        'The ledger has one instruction at the top of every page: **TAKE WHAT YOU CAN CARRY. '
        'SIGN FOR IT.**',
    plain: 'A lost-property booth of dropped plot items. Take one, take everything, or read the ledger.',
    choices: [
      EvChoice(
        label: 'Take one thing and sign for it honestly.',
        result:
            'You write your name, the date, and what you took. The ink sinks in and goes gold. '
            'Somewhere a very long way off, something that had been waiting to be signed for '
            'finally is, and the relief of it comes down the road like a change in the weather.',
        out: [Out(OutKind.relic), Out(OutKind.mercy, value: 1), Out(OutKind.gold, value: 80)],
      ),
      EvChoice(
        label: 'Clear the shelves.',
        result:
            'You take all of it and you do not sign. The booth does not stop you. Two floors '
            'later you notice that everything you took has your own initials scratched into it '
            'somewhere, in your own hand, from before you got here — and that you have therefore '
            'been robbing yourself, which is at least efficient.',
        out: [Out(OutKind.relic), Out(OutKind.gold, value: 220), Out(OutKind.curse),
          Out(OutKind.cruelty, value: 2)],
      ),
      EvChoice(
        label: 'Read forty-one pages back in the ledger.',
        result:
            'Forty-one entries. Same handwriting throughout — yours. Same item signed out and '
            'returned, signed out and returned. The last column is headed OUTCOME and it says '
            'the same word forty-one times, and the word is *lost.*',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'knows_loop'), Out(OutKind.shards, value: 20)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_kind_innkeeper',
    title: 'THE INN THAT IS ALWAYS OPEN',
    art: 'event_kind_innkeeper',
    weight: 12,
    act: 1,
    body:
        'Warm light, a made bed, bread that is still hot. The innkeeper will not take money. '
        'She says the room is always ready and always has been.\n\n'
        'On the wall of the room, at about the height of somebody lying down, there are '
        'scratch marks. Count them and you get to three hundred before you stop counting, '
        'because you have recognised the way the seventh one hooks at the end. You do that. '
        'That is how your hand does that.',
    plain: 'A free inn you have clearly stayed at hundreds of times. Rest, refuse, or ask her.',
    choices: [
      EvChoice(
        label: 'Sleep. Take the bed.',
        result:
            'It is the best sleep you have ever had, and you wake up knowing it was also the '
            'best sleep you had the previous three hundred times, which does not make it worse. '
            'Breakfast is on the table. She has already gone out.',
        out: [Out(OutKind.heal, value: 40), Out(OutKind.maxHp, value: 6)],
      ),
      EvChoice(
        label: 'Refuse the room and sit up with her instead.',
        result:
            'You talk until it gets light. She has run this inn through every draft and she '
            'remembers all of them, which is not supposed to be possible, and about an hour '
            'before dawn she tells you why she is allowed to: nobody ever wrote her leaving. '
            'She has no exit. So she stayed, and stayed, and started keeping the light on.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'knows_keeper'),
          Out(OutKind.mercy, value: 2), Out(OutKind.heal, value: 15)],
      ),
      EvChoice(
        label: 'Add a scratch to the wall before you go.',
        hidden: true,
        result:
            'Three hundred and one. You do it deliberately, low down, where the next one will '
            'see it at eye level lying down.\n\nUnder it, small, you scratch: *you are not the '
            'first and you do not have to be the last.* It is the single most useful thing you '
            'have done since you woke up.',
        out: [Out(OutKind.flag, arg: 'left_a_message'), Out(OutKind.page),
          Out(OutKind.mercy, value: 2)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_tax_of_names',
    title: 'THE TOLLKEEPER',
    art: 'event_tax_of_names',
    weight: 10,
    body:
        'The bridge is fine. The tollkeeper is a thin shape in a booth with a slot in the front '
        'and a sign that reads: **ONE NAME.**\n\n'
        '"Not yours," it says, when you reach for a coin. "Anybody\'s. A name you know. You put '
        'it in the slot and it comes out of you and out of the world and off every page it was '
        'on." It taps the wood. "Most people have somebody they would rather stop carrying."',
    plain: 'A toll bridge that charges one name — you forget that person permanently. Pay, refuse, or pay your own.',
    choices: [
      EvChoice(
        label: 'Pay with a name you were glad to be rid of.',
        result:
            'You do not remember what you said. You remember deciding to say it, and the sound '
            'of the slot, and then a lightness that is not quite as good as you had hoped. '
            'Something in your pack is now unaccounted for. You cannot think why you were '
            'carrying it.',
        out: [Out(OutKind.gold, value: 150), Out(OutKind.removeCard),
          Out(OutKind.cruelty, value: 2), Out(OutKind.flag, arg: 'paid_a_name')],
      ),
      EvChoice(
        label: 'Refuse. Swim the river instead.',
        result:
            'The river is not water and it is not deep, but it is extremely cold and it does not '
            'like being crossed by somebody who has not paid for the privilege. You come out the '
            'far side hurt and carrying every single name you walked up with.',
        out: [Out(OutKind.hp, value: 16), Out(OutKind.mercy, value: 3),
          Out(OutKind.flag, arg: 'kept_every_name')],
      ),
      EvChoice(
        label: 'Put your own name in the slot.',
        hidden: true,
        result:
            'The tollkeeper actually leans forward. "That has happened once," it says. "It did '
            'not go well for the booth."\n\nNothing comes out of you. The slot jams. Whatever you '
            'are, it is apparently not a name the machinery was built to accept, and the '
            'tollkeeper looks at you afterwards with something you would have to call respect.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'unnameable'),
          Out(OutKind.relic), Out(OutKind.maxHp, value: 12)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_practice_room',
    title: 'THE PRACTICE ROOM',
    art: 'event_practice_room',
    weight: 10,
    act: 1,
    body:
        'A wooden floor, a mirror wall, and a training dummy that has been hit so many times '
        'the stuffing has gone to powder. Someone has been working in here for a long time '
        'without an audience.\n\n'
        'Chalked on the mirror, in a hand you know: **IT IS NOT THAT YOU ARE WEAK. IT IS THAT '
        'YOU KEEP BEING GIVEN THE SAME EIGHT MOVES.**\n\n'
        'Under it, a list of things to try. Most are crossed out. Two are not.',
    plain: 'A training room left by a previous you. Train, take the notes, or break the mirror.',
    choices: [
      EvChoice(
        label: 'Work the two that are not crossed out.',
        result:
            'They are awkward and they are not comfortable and they are also, unmistakably, not '
            'in the eight. You drill them until your hands stop arguing. When you leave, the '
            'dummy is worse and you are better.',
        out: [Out(OutKind.upgradeCard), Out(OutKind.upgradeCard), Out(OutKind.hp, value: 5)],
      ),
      EvChoice(
        label: 'Take the whole list, crossings-out included.',
        result:
            'The failures are the useful part. Thirty-one things that do not work, tested by '
            'somebody with your exact reach and your exact bad shoulder. You will not waste a '
            'single one of those thirty-one nights again.',
        out: [Out(OutKind.randomCard), Out(OutKind.randomCard), Out(OutKind.shards, value: 25),
          Out(OutKind.flag, arg: 'read_the_failures')],
      ),
      EvChoice(
        label: 'Put the dummy through the mirror.',
        result:
            'Glass everywhere and, behind it, not a wall — another practice room, identical, '
            'chalk and all, and behind that another, going back further than the building has '
            'any right to. Somebody has been at this a very long time. You take something off '
            'the floor of the third one along.',
        out: [Out(OutKind.relic), Out(OutKind.hp, value: 10),
          Out(OutKind.flag, arg: 'broke_the_mirror')],
      ),
    ],
  ),

  GameEvent(
    id: 'the_two_guards',
    title: 'THE TWO GUARDS',
    art: 'event_two_guards',
    weight: 10,
    act: 1,
    body:
        'Two guards, one gate. They have been posted here since before either of them can '
        'account for. One has a spear. One has a book. Neither has been relieved.\n\n'
        '"He\'s to stop anyone going through," says the one with the book, pleasantly.\n\n'
        '"She\'s to record everyone who does," says the one with the spear.\n\n'
        'They have clearly been arguing about the implications of this for several hundred '
        'years and have arrived at a truce that involves neither of them ever finding out.',
    plain: 'Two guards with contradictory orders block a gate. Talk, fight, or point out the contradiction.',
    choices: [
      EvChoice(
        label: 'Say it out loud: your orders cancel.',
        result:
            'A long, awful silence. Then the one with the spear sits down on the ground, very '
            'suddenly, the way people do when a load they had stopped noticing comes off.\n\n'
            '"Then we can go," she says. It is not a question, and she says it three more times '
            'on the way out of the gate, quieter each time.',
        out: [Out(OutKind.mercy, value: 3), Out(OutKind.relic),
          Out(OutKind.flag, arg: 'freed_the_guards')],
      ),
      EvChoice(
        label: 'Bribe your way through and say nothing.',
        result:
            'They take the money, both of them, without meeting each other\'s eyes. The gate '
            'opens. Behind you they resume the argument at exactly the point it was at when you '
            'arrived, and will be at that point when the next one comes.',
        out: [Out(OutKind.loseGold, value: 90), Out(OutKind.gold, value: 0)],
        needGold: 90,
      ),
      EvChoice(
        label: 'Go through the wall instead.',
        result:
            'The wall is thinner than the gate and nobody was ever assigned to it. You are '
            'halfway to the next ridge before either of them notices, and what you hear behind '
            'you is not an alarm — it is one of them, delightedly, telling the other that '
            'technically neither order was broken.',
        out: [Out(OutKind.gold, value: 60), Out(OutKind.hp, value: 4), Out(OutKind.randomCard)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_borrowed_face',
    title: 'THE BORROWED FACE',
    art: 'event_borrowed_face',
    weight: 9,
    body:
        'The traveller coming the other way has your face. Not a version of it — yours, down to '
        'the crooked incisor, worn by somebody with entirely the wrong posture underneath.\n\n'
        '"Sorry," they say immediately, seeing you clock it. "It was in the drawer. They tell '
        'you to take a face and go, and there\'s not a lot of choice at short notice." They '
        'rub at the jaw, embarrassed. "I can give it back. It\'ll hurt both of us. Or you can '
        'have one of the spares and we both keep walking."',
    plain: 'Someone is wearing your face. Take it back, let them keep it, or swap.',
    choices: [
      EvChoice(
        label: 'Take your face back.',
        result:
            'It hurts exactly as much as advertised and takes most of an hour. Underneath, they '
            'have no face at all — just a smooth readiness, waiting for the next assignment. '
            'They thank you sincerely and walk off into the ash, and you find that you cannot '
            'stop thinking about the thanking.',
        out: [Out(OutKind.hp, value: 14), Out(OutKind.maxHp, value: 14),
          Out(OutKind.flag, arg: 'reclaimed_face')],
      ),
      EvChoice(
        label: 'Let them keep it.',
        result:
            'They are so surprised they have to sit down. Then they give you everything they '
            'were carrying, which is not much and is all of it, and go off up the road wearing '
            'your face like somebody who intends to do something respectable with it.\n\n'
            'You will hear about them later. It will be good news, which will be new.',
        out: [Out(OutKind.mercy, value: 3), Out(OutKind.relic),
          Out(OutKind.flag, arg: 'gave_the_face')],
      ),
      EvChoice(
        label: 'Ask who told them to take a face and go.',
        hidden: true,
        result:
            'They do not know a name. They know a room — desk, high window, the smell of ink '
            'that never fully dries — and they know that whoever is in it does not look up when '
            'you come in, and they know that the drawer of faces is on the left, and that it is '
            'a very deep drawer.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'knows_top'), Out(OutKind.shards, value: 20)],
      ),
    ],
  ),

  GameEvent(
    id: 'field_of_arms',
    title: 'THE FIELD OF ARMS',
    art: 'event_field_of_arms',
    weight: 10,
    act: 1,
    body:
        'A wheat field, except it is not wheat. Arms, from the elbow, planted in rows, every '
        'one of them holding a weapon up out of the soil. Some of the weapons are very good. '
        'All of the hands are still gripping.\n\n'
        'A woman is walking the rows with a basket, unbending fingers one at a time, gently, '
        'the way you would take something off a sleeping child.\n\n'
        '"They can\'t let go on their own," she says. "That\'s the whole problem. That was '
        'always the whole problem."',
    plain: 'A field of buried arms still gripping weapons. Help her, take a weapon, or burn it.',
    choices: [
      EvChoice(
        label: 'Work the rows with her until dark.',
        result:
            'Four hundred hands. Your back gives out around the two hundredth and she does not '
            'slow down and does not comment. At the end she divides the basket in half without '
            'discussion, which is the first time anybody in this world has treated you like a '
            'colleague.',
        out: [Out(OutKind.relic), Out(OutKind.gold, value: 110), Out(OutKind.mercy, value: 2),
          Out(OutKind.flag, arg: 'worked_the_field')],
      ),
      EvChoice(
        label: 'Take the best weapon and go.',
        result:
            'The fingers do not want to come off it. You get it eventually. It is superb, and '
            'it is warm at the grip, and it stays warm for two days, and on the third day you '
            'stop noticing, which is the part you will think about later.',
        out: [Out(OutKind.randomCard), Out(OutKind.upgradeCard),
          Out(OutKind.cruelty, value: 2)],
      ),
      EvChoice(
        label: 'Burn the field.',
        result:
            'It goes up fast, and every hand opens at once — four hundred weapons dropping into '
            'the ash in a sound like applause. The woman does not stop you. Afterwards she '
            'stands in the smoke for a long time and says, without any particular emotion, '
            '"Thirty years I have been doing that one at a time."',
        out: [Out(OutKind.shards, value: 30), Out(OutKind.hp, value: 8),
          Out(OutKind.mercy, value: 1), Out(OutKind.flag, arg: 'burned_the_field')],
      ),
    ],
  ),

  GameEvent(
    id: 'the_apology_stone',
    title: 'THE APOLOGY',
    art: 'event_apology_stone',
    weight: 9,
    body:
        'A standing stone, taller than a house, covered top to bottom in the same six words '
        'carved over and over in the same hand, thousands of times, getting smaller as they '
        'run out of room:\n\n'
        '**I DID NOT KNOW ANOTHER WAY**\n\n'
        'Near the base, where the carver would have been kneeling, the letters are shaky and '
        'very deep, as though somebody stayed there a long time after they had stopped '
        'believing it.',
    plain: 'A monument carved with one repeated apology. Answer it, add to it, or deface it.',
    choices: [
      EvChoice(
        label: 'Say out loud: then find one.',
        result:
            'Nothing dramatic. A slight, definite change in the air, like a room where somebody '
            'has just stopped talking. You are fairly sure you were heard. You are not at all '
            'sure by what, and the not-being-sure follows you for two floors.',
        out: [Out(OutKind.flag, arg: 'answered_the_stone'), Out(OutKind.page),
          Out(OutKind.maxHp, value: 10)],
      ),
      EvChoice(
        label: 'Carve the seventh word: YET.',
        result:
            'It takes three hours and ruins your blade and it is the only word on the entire '
            'stone that is not in the original hand. It will still be there when everything '
            'else here is not.',
        out: [Out(OutKind.mercy, value: 3), Out(OutKind.relic),
          Out(OutKind.flag, arg: 'carved_yet')],
      ),
      EvChoice(
        label: 'Break it down for what is inside.',
        result:
            'There is something inside, because of course there is. It is worth a great deal and '
            'it was clearly put there by the carver, and the note wrapped round it says *for '
            'whoever stops believing it first,* and you will spend a while deciding whether '
            'that means you won or lost.',
        out: [Out(OutKind.gold, value: 190), Out(OutKind.relic), Out(OutKind.cruelty, value: 2)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_smallest_god',
    title: 'THE SMALLEST GOD',
    art: 'event_smallest_god',
    weight: 9,
    act: 1,
    body:
        'A shrine the size of a shoebox, at the side of the road, with a god in it about the '
        'length of your thumb. It is asleep. There is a bowl in front of it with three grains '
        'of something in the bottom.\n\n'
        'A note, propped up, in handwriting from several drafts ago:\n\n'
        '*it grants exactly what it can afford, which is not much, and it has never once '
        'refused. please do not ask it for a lot.*',
    plain: 'A tiny god grants small wishes at cost to itself. Ask small, ask big, or feed it.',
    choices: [
      EvChoice(
        label: 'Ask for something small.',
        result:
            'It wakes, listens with enormous seriousness to a request about your knee, and fixes '
            'your knee. Then it goes back to sleep looking marginally thinner. Your knee is '
            'perfect. It will be perfect for the rest of the run and you will notice it every '
            'single day.',
        out: [Out(OutKind.heal, value: 22), Out(OutKind.maxHp, value: 6),
          Out(OutKind.mercy, value: 1)],
      ),
      EvChoice(
        label: 'Ask for something enormous.',
        result:
            'It does not refuse. It has never once refused. It gives you what you asked for and '
            'the giving costs it everything, and what is in the shrine afterwards is a shape '
            'about the length of your thumb that is no longer a god.\n\n'
            'The thing you asked for works exactly as well as you wanted it to.',
        out: [Out(OutKind.relic), Out(OutKind.maxHp, value: 30), Out(OutKind.cruelty, value: 4),
          Out(OutKind.flag, arg: 'spent_the_god')],
      ),
      EvChoice(
        label: 'Put food in the bowl and ask for nothing.',
        result:
            'It wakes up, looks at the bowl, looks at you, and then looks at the bowl again in a '
            'way that suggests this has not happened before within its memory, which is long.\n\n'
            'It does not grant you anything. It walks to the edge of the shrine and sits with '
            'its feet over the side and keeps you company until you have finished eating, which '
            'turns out to be the thing you actually needed.',
        out: [Out(OutKind.mercy, value: 3), Out(OutKind.heal, value: 14),
          Out(OutKind.page), Out(OutKind.flag, arg: 'fed_the_god')],
      ),
    ],
  ),

  GameEvent(
    id: 'the_rope_bridge',
    title: 'THE CROSSING',
    art: 'event_rope_bridge',
    weight: 11,
    body:
        'The bridge is rope and it is old and the gorge under it does not appear to have a '
        'bottom drawn in yet. Halfway across, sitting on the planks with their legs through the '
        'gap, is a child who is very obviously not a child.\n\n'
        '"You can go past me," it says. "Everybody goes past me. Or you can sit down for a bit '
        'and I\'ll tell you which of the next three things is the one that kills you." It '
        'swings its heels. "It\'s not a trick. I\'m just extremely bored."',
    plain: 'A bored creature on a bridge offers to warn you about a coming danger. Listen, pass, or push.',
    choices: [
      EvChoice(
        label: 'Sit down and listen.',
        result:
            'It talks for an hour, mostly about the gorge and how nobody drew the bottom, and '
            'then — almost as an afterthought — tells you the thing. It is specific and it is '
            'unpleasant and it is correct, and you will recognise it when you see it and you '
            'will already be moving.',
        out: [Out(OutKind.flag, arg: 'warned'), Out(OutKind.relic),
          Out(OutKind.shards, value: 20)],
      ),
      EvChoice(
        label: 'Walk past without stopping.',
        result:
            'It does not mind. It says "safe crossing" to your back, and means it, and you are '
            'most of the way to the far side before you understand that it was going to tell '
            'you for free and you have declined the only free thing in this world.',
        out: [Out(OutKind.gold, value: 40)],
      ),
      EvChoice(
        label: 'Cut the bridge behind you.',
        result:
            'It goes down without a sound and without any particular surprise, which is somehow '
            'the worst part. You are across. Nothing is following you. There is a length of very '
            'good rope in your hand and you cannot remember deciding to keep it.',
        out: [Out(OutKind.cruelty, value: 4), Out(OutKind.card, arg: 'um_gravebind'),
          Out(OutKind.curse), Out(OutKind.flag, arg: 'cut_the_bridge')],
      ),
    ],
  ),

  GameEvent(
    id: 'the_glassblower',
    title: 'THE GLASSBLOWER',
    art: 'event_glassblower',
    weight: 9,
    act: 1,
    body:
        'Heat, and a woman turning a rod, and on the shelves behind her about two hundred '
        'perfect glass hearts. Not decorative. Anatomical. Each one has a small dark thing '
        'suspended in the middle of it.\n\n'
        '"Regrets," she says, without looking up. "People bring them and I set them in glass so '
        'they can put them down somewhere. It works." She turns the rod. "It also means that '
        'if you break one, they get it back. All at once. Wherever they are."',
    plain: 'A glassblower stores people\'s regrets in glass hearts. Give one, take one, or break them.',
    choices: [
      EvChoice(
        label: 'Give her one of yours.',
        result:
            'She takes it out of you with the tongs, which does not hurt and should, and sets it '
            'in glass while you watch. On the shelf it looks tiny and manageable and like '
            'somebody else\'s. You walk out several pounds lighter in a way that has nothing to '
            'do with weight.',
        out: [Out(OutKind.removeCard), Out(OutKind.heal, value: 25),
          Out(OutKind.maxHp, value: 8), Out(OutKind.flag, arg: 'set_a_regret')],
      ),
      EvChoice(
        label: 'Ask for the oldest one on the shelf.',
        result:
            'She has to get the ladder. It is dusty and the dark thing inside it is bigger than '
            'any of the others and it is, she says, the first one she ever took — from somebody '
            'who came in three thousand years ago with ink on their hands and could not '
            'say what it was they had done.',
        out: [Out(OutKind.page), Out(OutKind.relic), Out(OutKind.flag, arg: 'knows_first_regret')],
      ),
      EvChoice(
        label: 'Break every heart on the shelves.',
        result:
            'Two hundred people, everywhere in Aevum, get it all back at the same moment. You '
            'feel it happen. You will never know what most of them did with it. She sits down '
            'in the glass and says, quite calmly, "Some of them needed that. Some of them are '
            'going to die of it. You did not get to choose which."',
        out: [Out(OutKind.shards, value: 45), Out(OutKind.cruelty, value: 4),
          Out(OutKind.relic), Out(OutKind.curse), Out(OutKind.flag, arg: 'broke_the_hearts')],
      ),
    ],
  ),

  GameEvent(
    id: 'the_first_word',
    title: 'THE FIRST WORD',
    art: 'event_first_word',
    weight: 8,
    act: 1,
    body:
        'Cut into the bedrock, so large you only recognise it as writing once you have climbed '
        'the ridge, is a single word. It is the oldest thing you have seen here. Everything in '
        'Aevum is downhill of it.\n\n'
        'The word is **ONCE**.\n\n'
        'Somebody has been trying to add to it. There are tool marks after the E, thousands of '
        'them, from many different hands across a very long time, and not one of them has '
        'managed to cut a second letter.',
    plain: 'The world\'s first word is carved in bedrock and nobody has ever added to it. Try, study, or leave.',
    choices: [
      EvChoice(
        label: 'Try to cut the next letter.',
        result:
            'You cannot. Not because the rock is hard — because your hand will not do it, in the '
            'way a hand will not do certain things. You understand, holding the chisel, that '
            'every one of those thousands of marks was made by somebody who found this out at '
            'exactly this moment, and that all of them kept trying anyway.',
        out: [Out(OutKind.flag, arg: 'tried_the_word'), Out(OutKind.maxHp, value: 14),
          Out(OutKind.page)],
      ),
      EvChoice(
        label: 'Study the tool marks instead.',
        result:
            'Different centuries, different metals, one constant: every single attempt begins '
            'with the same two strokes. Everybody who has ever stood here was trying to cut the '
            'same second letter. It is a U. Everybody wanted the word to become *ounce* — a '
            'measurement, a small definite amount, something you could hold.',
        out: [Out(OutKind.page), Out(OutKind.shards, value: 30),
          Out(OutKind.flag, arg: 'read_the_marks')],
      ),
      EvChoice(
        label: 'Sleep on the word.',
        hidden: true,
        result:
            'You wake up knowing something you did not know, in the specific way of information '
            'that was put there rather than worked out: **once is not the beginning of a '
            'sentence. It is the whole sentence. It was a promise that this would happen one '
            'time.**\n\nSomebody broke that promise three thousand times.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'knows_the_promise'),
          Out(OutKind.maxHp, value: 16), Out(OutKind.heal, value: 20)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_debt_collector',
    title: 'THE COLLECTOR',
    art: 'event_debt_collector',
    weight: 10,
    body:
        'He has a ledger and a mild manner and he has been waiting for you specifically, which '
        'he apologises for.\n\n'
        '"You owe," he says. "Not money. Nine deaths ago you were carried three miles by '
        'somebody who did not have to. You do not remember it. The debt does not care whether '
        'you remember it." He turns the ledger round so you can see. "I collect on behalf of '
        'people who never got thanked. It is not a good job."',
    plain: 'A collector says you owe a kindness from a past life. Pay, refuse, or ask who carried you.',
    choices: [
      EvChoice(
        label: 'Pay it. Whatever it costs.',
        result:
            'It costs a great deal and he takes it without any satisfaction and writes one line '
            'in the ledger and closes it. "Settled," he says. Then, unexpectedly: "You are the '
            'fourth to pay. Out of nine." He does not say what happened to the other five.',
        out: [Out(OutKind.loseGold, value: 130), Out(OutKind.mercy, value: 4),
          Out(OutKind.relic), Out(OutKind.flag, arg: 'paid_the_debt')],
        needGold: 130,
      ),
      EvChoice(
        label: 'Refuse. You did not agree to it.',
        result:
            'He nods, as though this is the expected answer and he has stopped minding. He makes '
            'a different mark. "It goes back on their side of the book," he says. "They will '
            'carry it. They have been carrying it for nine drafts and they will carry it for '
            'this one too, and they will do it again next time, because that is the sort of '
            'person they are, which is precisely why it is a debt."',
        out: [Out(OutKind.cruelty, value: 3), Out(OutKind.gold, value: 60),
          Out(OutKind.flag, arg: 'refused_the_debt')],
      ),
      EvChoice(
        label: '"Who carried me?"',
        result:
            'He tells you. It is a name you have not heard yet and will hear again, and he can '
            'see that it means nothing to you, and he says the thing that costs him something '
            'to say: "They will not remember either. You could still find them. It would not be '
            'settling the debt. It would be better than settling the debt."',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'knows_carrier'),
          Out(OutKind.companion), Out(OutKind.mercy, value: 2)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_undrawn_room',
    title: 'THE UNDRAWN ROOM',
    art: 'event_undrawn_room',
    weight: 9,
    body:
        'A door in a hillside, and behind it a room that has been blocked in and never '
        'finished. Construction lines only. A table indicated by four strokes. A window that is '
        'a rectangle with the word LIGHT written inside it.\n\n'
        'In the middle of the floor, fully rendered — the only finished thing in here, in '
        'colour, with shadow — is a bowl of fruit. Somebody spent a lot of time on the fruit '
        'and then walked away from the entire rest of the room.',
    plain: 'An unfinished room with one perfectly drawn bowl of fruit. Eat, study, or finish the room.',
    choices: [
      EvChoice(
        label: 'Eat the fruit.',
        result:
            'It is the best thing you have ever eaten and it is genuinely, completely real, '
            'because somebody made it real on purpose in a room where nothing else is. You are '
            'not hungry for two floors and you are not tired for three.',
        out: [Out(OutKind.heal, value: 35), Out(OutKind.maxHp, value: 12)],
      ),
      EvChoice(
        label: 'Work out why the fruit and nothing else.',
        result:
            'Because it was a warm-up. There is a date scratched in the corner and it is the '
            'oldest date you have seen in Aevum, and this is where somebody sat down to find '
            'out whether they could do this at all — did one bowl of fruit, discovered they '
            'could, and left immediately to go and make a world.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'knows_beginning'),
          Out(OutKind.shards, value: 35)],
      ),
      EvChoice(
        label: 'Finish the room yourself.',
        hidden: true,
        result:
            'You are not good at it. The table is wrong and the window is worse and the light is '
            'a flat unconvincing yellow.\n\nIt stays. All of it. Badly drawn and permanent, in '
            'a world where nothing has been permanent for three thousand years — because you '
            'are not the Author and you are therefore not able to take it back.',
        out: [Out(OutKind.page), Out(OutKind.relic), Out(OutKind.maxHp, value: 18),
          Out(OutKind.flag, arg: 'drew_something')],
      ),
    ],
  ),

  GameEvent(
    id: 'the_choir_of_one',
    title: 'THE CHOIR OF ONE',
    art: 'event_choir_of_one',
    weight: 9,
    act: 1,
    body:
        'Forty voices, in harmony, coming out of one person. She is standing in the middle of '
        'a ruined chancel with her eyes shut, holding a chord that has no business being '
        'sustainable.\n\n'
        'When she stops she is out of breath in forty different ways.\n\n'
        '"They cut the choir," she says. "Budget, or pacing, or somebody decided it slowed the '
        'scene. But the music was already written. So." She shrugs. "Somebody has to sing it."',
    plain: 'One singer performs a whole cut choir\'s part. Sing with her, listen, or ask about the piece.',
    choices: [
      EvChoice(
        label: 'Take one of the forty parts off her.',
        result:
            'You are not a singer. It does not matter. For eleven minutes she only has to carry '
            'thirty-nine and you can see, from the side, exactly how much difference one is. '
            'She does not thank you. At the end she just says the bar number where you should '
            'come back in, as though you will be here next time.',
        out: [Out(OutKind.mercy, value: 3), Out(OutKind.maxHp, value: 12),
          Out(OutKind.flag, arg: 'sang_a_part'), Out(OutKind.relic)],
      ),
      EvChoice(
        label: 'Sit down and listen to the whole thing.',
        result:
            'It takes two hours. It is not a religious piece. It is a list — every name that was '
            'ever cut from this story, set to music so that saying all of them out loud remains '
            'possible for one person in one lifetime. Your name is in it. It is near the end and '
            'she sings it exactly like all the others.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'heard_the_list'),
          Out(OutKind.heal, value: 20), Out(OutKind.shards, value: 25)],
      ),
      EvChoice(
        label: 'Tell her the audience is gone.',
        result:
            '"I know," she says, entirely unbothered, and takes a breath, and starts the second '
            'movement.\n\nYou leave while she is still going. You can hear it from the ridge. '
            'You can hear it from the next ridge. You are fairly sure you can still hear it two '
            'floors later, which is not acoustically possible.',
        out: [Out(OutKind.cruelty, value: 1), Out(OutKind.gold, value: 70)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_wound_that_talks',
    title: 'THE WOUND',
    art: 'event_wound_that_talks',
    weight: 9,
    body:
        'There is a cut across your forearm that you did not have this morning, and it is '
        'speaking. Not loudly. Conversationally.\n\n'
        '"You keep getting this one," it says. "Every draft. Same arm, same angle. I think '
        'they like how it reads." A pause. "I\'m not trying to alarm you. I only get to talk '
        'when the page is thin. It won\'t last."\n\n'
        'It is right about the page. You can see the grain of it through the ash.',
    plain: 'A recurring wound speaks to you while reality is thin. Listen, close it, or ask what is under the page.',
    choices: [
      EvChoice(
        label: 'Let it talk itself out.',
        result:
            'It tells you about the other times. Not the deaths — the small things, what you '
            'said, who you were with, what you were like before you got tired. It is the only '
            'record of those drafts that exists anywhere and it is held in a cut on your arm, '
            'and when it finishes it closes itself, gently, and does not speak again.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'knows_loop'),
          Out(OutKind.heal, value: 18), Out(OutKind.maxHp, value: 10)],
      ),
      EvChoice(
        label: 'Close it now and keep moving.',
        result:
            'It stops mid-sentence. The arm is fine — better than fine, healed clean, no mark. '
            'Around midnight you catch yourself trying to remember what it had been about to '
            'say, and you will do that again on and off for the rest of the run.',
        out: [Out(OutKind.heal, value: 30), Out(OutKind.cruelty, value: 1)],
      ),
      EvChoice(
        label: '"What is under the page?"',
        hidden: true,
        result:
            'A long silence. Then: "Another page." Another silence. "It goes down further than '
            'anybody has ever gone and every single one of them has your handwriting on it, and '
            'the deepest one I have ever been able to see is not a story at all. It is somebody '
            'practising. Over and over. Getting better."',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'knows_practice'),
          Out(OutKind.shards, value: 35), Out(OutKind.relic)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_relay',
    title: 'THE RELAY',
    art: 'event_relay',
    weight: 10,
    act: 1,
    body:
        'A runner comes over the ridge at a dead sprint, hands you a sealed tube without '
        'stopping, gasps "**four miles, north, do not open it**" and is gone downhill before '
        'you have taken a breath.\n\n'
        'They did not check who you were. They have clearly been doing this leg for a long time '
        'and have stopped believing anybody is ever at the handover point, and today somebody '
        'was, and they did not slow down enough to enjoy it.',
    plain: 'A courier hands you a sealed message to carry four miles. Run it, open it, or drop it.',
    choices: [
      EvChoice(
        label: 'Run it. Four miles, north.',
        result:
            'It is uphill and it is further than four miles and there is somebody at the other '
            'end, an old man on a stool who has been at that spot for eleven years without a '
            'single delivery. He takes the tube in both hands. He does not open it either. '
            '"Next leg," he says, and points, and you understand this goes on for a very long '
            'way and that it is the most functional thing in Aevum.',
        out: [Out(OutKind.relic), Out(OutKind.mercy, value: 3), Out(OutKind.hp, value: 6),
          Out(OutKind.flag, arg: 'ran_the_relay')],
      ),
      EvChoice(
        label: 'Open it.',
        result:
            'Inside, on good paper: **STILL HERE. STILL NOT FINISHED. KEEP GOING.**\n\nNo '
            'signature, no destination, no date. It is not a message to anybody. It is a message '
            'that exists in order to be carried, and you have just stopped it, and you are '
            'holding the only copy.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'opened_the_tube'),
          Out(OutKind.cruelty, value: 2), Out(OutKind.shards, value: 25)],
      ),
      EvChoice(
        label: 'Set it down at the roadside and go on.',
        result:
            'You prop it upright where the next one will see it. Somebody will run it. You are '
            'reasonably confident somebody will run it. You think about it more than you expect '
            'to over the following two days.',
        out: [Out(OutKind.gold, value: 50)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_last_reader',
    title: 'THE LAST READER',
    art: 'event_last_reader',
    weight: 8,
    body:
        'An enormous chair, scaled for something much larger than a person, in the middle of '
        'nowhere. It has been sat in. The cushion holds the shape.\n\n'
        'On the arm, a bookmark, placed with care at a specific point.\n\n'
        'The chair is cold. Whatever sat here got up some time ago and has not come back, and '
        'the bookmark is at page four hundred and eleven of something, and you are standing on '
        'page four hundred and twelve.',
    plain: 'A huge empty reading chair, bookmark left mid-story. Sit, move the bookmark, or leave it.',
    choices: [
      EvChoice(
        label: 'Sit in the chair.',
        result:
            'From up here you can see the whole act laid out — the road, the ridge, the '
            'switchbacks, the boss waiting at the top — and it all looks small and quite well '
            'arranged and, unmistakably, like something laid out to be looked at.\n\n'
            'You get down quickly. You are careful not to look up.',
        out: [Out(OutKind.flag, arg: 'sat_in_the_chair'), Out(OutKind.page),
          Out(OutKind.maxHp, value: 12)],
      ),
      EvChoice(
        label: 'Move the bookmark forward.',
        result:
            'You move it three hundred pages on, past everything, to the end.\n\nNothing happens '
            'that you can see. But everything from here to the top of the act feels very '
            'slightly hurried afterwards, the way a scene does when somebody has decided they '
            'know how it goes.',
        out: [Out(OutKind.shards, value: 40), Out(OutKind.cruelty, value: 2),
          Out(OutKind.flag, arg: 'moved_the_bookmark')],
      ),
      EvChoice(
        label: 'Leave it exactly where it is.',
        result:
            'You do not touch it. You go round the chair rather than past it, and you catch '
            'yourself walking quietly, and you keep walking quietly for a good while after '
            'there is any reason to.',
        out: [Out(OutKind.mercy, value: 2), Out(OutKind.relic)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_understudy_deal',
    title: 'A REASONABLE OFFER',
    art: 'event_understudy_deal',
    weight: 9,
    act: 1,
    body:
        'It is wearing a coat like yours and it has been waiting by the road with the patient '
        'confidence of somebody who has run the numbers.\n\n'
        '"Swap," it says. "You take the bench. I take the road. You get to stop, which you want '
        'more than you have admitted to yourself, and the story gets somebody who has been '
        'preparing for three thousand years." It spreads its hands. "I am better at this than '
        'you. That is not an insult. It is just how long I have had."',
    plain: 'An understudy offers to take your place. Refuse, accept partly, or test it.',
    choices: [
      EvChoice(
        label: '"No. It has to be somebody who did not prepare."',
        result:
            'It thinks about that properly, which you were not expecting, and then nods once, '
            'and steps off the road to let you past.\n\n"That might be right," it says, as you '
            'go. It sounds like it has been hoping somebody would say something it had not '
            'already thought of.',
        out: [Out(OutKind.maxHp, value: 16), Out(OutKind.flag, arg: 'refused_the_swap'),
          Out(OutKind.relic)],
      ),
      EvChoice(
        label: 'Take what it has learned. Keep the road.',
        result:
            'It gives it over willingly — three thousand years of watching, condensed into the '
            'four things that actually matter. Then it goes and sits on the bench anyway, '
            'because there is nowhere else, and says it will be there if you come back.',
        out: [Out(OutKind.randomCard), Out(OutKind.upgradeCard), Out(OutKind.upgradeCard),
          Out(OutKind.flag, arg: 'took_the_lessons')],
      ),
      EvChoice(
        label: 'Ask what it plans to do at the top.',
        hidden: true,
        result:
            '"Finish it," it says, immediately, and then hears itself, and stops.\n\n"...which is '
            'what he said," it adds, quietly. "Three thousand years ago. That is exactly what he '
            'said." It sits down at the roadside and does not get up while you are still in '
            'sight, and you leave it working out how close it came.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'knows_understudy'),
          Out(OutKind.shards, value: 30), Out(OutKind.mercy, value: 2)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_boundary_stone',
    title: 'THE EDGE OF THE PANEL',
    art: 'event_boundary_stone',
    weight: 9,
    body:
        'You have walked off the side. Not far — three or four paces — and the ground under you '
        'is still ground but it has stopped being convincing, and behind you the world has an '
        'edge to it like a cut sheet.\n\n'
        'Out here there is one thing: a stone, with a rusted ring set into the top, and a chain '
        'going down into the white. The chain is taut. Something on the other end of it is '
        'holding on.',
    plain: 'Off the edge of the world, a chain leads into blank white. Pull it, cut it, or go back.',
    choices: [
      EvChoice(
        label: 'Pull the chain up.',
        result:
            'It takes a long time and what comes up is a person — soaked in nothing, blinking, '
            'entirely unhurt and entirely undrawn below the elbows. They have been holding on '
            'out here since a draft with a different sky. The first thing they say is a question '
            'about somebody, and the somebody has not existed for two thousand years, and you '
            'have to be the one to tell them.',
        out: [Out(OutKind.companion), Out(OutKind.mercy, value: 3),
          Out(OutKind.flag, arg: 'pulled_them_up'), Out(OutKind.page)],
      ),
      EvChoice(
        label: 'Cut the chain.',
        result:
            'It goes without a splash, because there is nothing out there to splash into. The '
            'stone stays. The ring stays. You will pass three more of these before the act is '
            'out, and every one of them will be taut, and you will not cut another.',
        out: [Out(OutKind.cruelty, value: 4), Out(OutKind.shards, value: 40),
          Out(OutKind.flag, arg: 'cut_the_chain')],
      ),
      EvChoice(
        label: 'Go back before the ground stops working.',
        result:
            'You are two paces from the edge when the ground behind you stops entirely, and you '
            'make it, and you lie on the drawn side breathing hard and looking at a sky that you '
            'now know is a decision somebody made.',
        out: [Out(OutKind.hp, value: 8), Out(OutKind.flag, arg: 'saw_the_edge'),
          Out(OutKind.shards, value: 15)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_good_dog',
    title: 'THE DOG',
    art: 'event_good_dog',
    weight: 11,
    body:
        'There is a dog. It is not on fire, it is not made of teeth, it has no additional eyes. '
        'It is a dog, and it is delighted, and it has been waiting at this exact bend in the '
        'road for a period of time that does not bear examining.\n\n'
        'Its collar has a name on it. The name is not a dog\'s name. It is a person\'s name, '
        'and it is written in the same hand as everything else in this world, and underneath it '
        'says: **KEPT.**',
    plain: 'A friendly dog with a person\'s name on its collar. Take it with you, free it, or read the collar.',
    choices: [
      EvChoice(
        label: 'Take it with you.',
        result:
            'It walks at your left knee for the rest of the act. It is a very good dog. It is '
            'better at spotting things than you are, and twice it stops dead before you have '
            'seen anything at all, and both times it is right.',
        out: [Out(OutKind.companion), Out(OutKind.mercy, value: 2), Out(OutKind.heal, value: 15)],
      ),
      EvChoice(
        label: 'Take the collar off.',
        result:
            'The moment it comes off, the dog looks up at you with an expression that is far too '
            'complicated, and says — in a perfectly ordinary voice, a person\'s voice, tired '
            'past all bearing — "**thank you**". Then it is a dog again, and it is delighted '
            'again, and it will not be anything else for the rest of the run.',
        out: [Out(OutKind.page), Out(OutKind.mercy, value: 4), Out(OutKind.relic),
          Out(OutKind.flag, arg: 'freed_the_kept')],
      ),
      EvChoice(
        label: 'Look up the name.',
        result:
            'You have seen it before. It is on the cast list in the theatre, under SUPPORTING, '
            'with a line through it — and next to the line, in the margin: *would not stop '
            'objecting. reduced.*',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'knows_reduction'),
          Out(OutKind.shards, value: 25), Out(OutKind.companion)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_scriptorium_fire',
    title: 'THE SCRIPTORIUM',
    art: 'event_scriptorium_fire',
    weight: 10,
    act: 1,
    body:
        'The building is going up and there are people inside it going the wrong way — carrying '
        'armfuls of paper *in*, not out, stacking it against the walls where the fire is worst.\n\n'
        '"Bad drafts," one of them shouts at you, cheerfully, hair singeing. "Every one of these '
        'is a version where it ends badly. If they burn, they can\'t be picked up again." She '
        'is going back in. "You can help or you can move."',
    plain: 'People are burning bad drafts of the future. Help burn, save one, or drag them out.',
    choices: [
      EvChoice(
        label: 'Help burn them.',
        result:
            'You carry in eleven armfuls. The heat is unspeakable. Somewhere around the eighth '
            'you register that you have read the top sheet of the one you are holding, and that '
            'it is about you, and that it ends the way you have privately been expecting, and '
            'you put it on the fire yourself and stand there until it is gone.',
        out: [Out(OutKind.hp, value: 12), Out(OutKind.flag, arg: 'burned_a_bad_end'),
          Out(OutKind.maxHp, value: 14), Out(OutKind.mercy, value: 2)],
      ),
      EvChoice(
        label: 'Save one from the pile.',
        result:
            'You pull one out at random and put out the edge of it with your sleeve. It is a '
            'version where everybody lives and it is four pages long and it is, transparently, '
            'not good enough — which is why it was in the pile. You keep it anyway.',
        out: [Out(OutKind.page), Out(OutKind.relic), Out(OutKind.hp, value: 8),
          Out(OutKind.flag, arg: 'saved_a_draft')],
      ),
      EvChoice(
        label: 'Drag the people out instead.',
        result:
            'Three of them. They fight you the entire way and one of them is furious for an hour '
            'afterwards, and then stops being furious very suddenly and sits down in the road '
            'with her hands over her face. The building goes. Not all of it burns.',
        out: [Out(OutKind.mercy, value: 4), Out(OutKind.hp, value: 18),
          Out(OutKind.companion), Out(OutKind.flag, arg: 'saved_the_scribes')],
      ),
    ],
  ),

  GameEvent(
    id: 'the_honest_merchant',
    title: 'THE HONEST MERCHANT',
    art: 'event_honest_merchant',
    weight: 11,
    body:
        'He has one item on the blanket and a hand-lettered sign that reads, in full:\n\n'
        '**THIS IS CURSED. I AM TELLING YOU IT IS CURSED. IT IS ALSO VERY GOOD. THE PRICE IS '
        'FAIR FOR EXACTLY WHAT IT IS. I WILL NOT ARGUE ANYONE INTO THIS.**\n\n'
        'He does not look up when you stop. He appears to have decided some time ago that this '
        'is the only sales technique he can live with, and to have accepted what it does to '
        'his volumes.',
    plain: 'A merchant honestly selling one cursed but powerful item. Buy, decline, or ask his story.',
    choices: [
      EvChoice(
        label: 'Buy it. He told you exactly what it is.',
        result:
            'He takes the money, writes the sale in a small book, and says "good luck" in the '
            'flat tone of somebody who means it and has watched this go badly before. The item '
            'is everything the sign promised in both directions.',
        out: [Out(OutKind.loseGold, value: 110), Out(OutKind.relic), Out(OutKind.curse),
          Out(OutKind.shards, value: 20)],
        needGold: 110,
      ),
      EvChoice(
        label: 'Decline, and tell him the sign is why.',
        result:
            'He looks up for the first time. "Right," he says. Then, after a moment, he gives '
            'you something small off the back of the cart that is not cursed and is not for '
            'sale, and says: "For reading it. Nobody reads it."',
        out: [Out(OutKind.randomCard), Out(OutKind.gold, value: 70),
          Out(OutKind.mercy, value: 1)],
      ),
      EvChoice(
        label: 'Ask why he bothers with the sign.',
        result:
            'Because he sold one without a sign, once, to somebody who did not ask. He tells you '
            'the whole thing in about ninety seconds, without self-pity, and at the end of it he '
            'says: "It is not a good sign. It does not undo it. It is only the sign I can '
            'manage." Then he goes back to not looking up.',
        out: [Out(OutKind.page), Out(OutKind.mercy, value: 2), Out(OutKind.relic),
          Out(OutKind.flag, arg: 'heard_the_merchant')],
      ),
    ],
  ),

  GameEvent(
    id: 'the_map_that_lies',
    title: 'THE MAP',
    art: 'event_map_that_lies',
    weight: 10,
    body:
        'Pinned to a post at a junction: a map of this act. It is accurate. It is more accurate '
        'than it has any business being — it shows the routes, the elites, the shape of the '
        'switchbacks above the treeline.\n\n'
        'It also shows, marked in red, four places that are not on your route at all, each with '
        'the same three-word annotation in a small tired hand:\n\n'
        '**DO NOT STOP.**',
    plain: 'An accurate map marks four places to avoid. Take it, go to a red mark, or leave it for others.',
    choices: [
      EvChoice(
        label: 'Take the map.',
        result:
            'It folds into a pocket and it does not stop being accurate, which is more than can '
            'be said for anything else here. You will make three decisions differently in the '
            'next hour because of it, and all three will be correct.',
        out: [Out(OutKind.relic), Out(OutKind.shards, value: 20)],
      ),
      EvChoice(
        label: 'Go and look at one of the red marks.',
        result:
            'You should not have. It is not a monster and it is not a trap. It is a small '
            'domestic scene, perfectly preserved, involving people who are extremely happy, and '
            'it has been left there so that anybody who is having a difficult time can look at '
            'it and understand precisely what was taken away and by whom.\n\nThe annotation was '
            'kindness. You disregarded it.',
        out: [Out(OutKind.page), Out(OutKind.hp, value: 14), Out(OutKind.curse),
          Out(OutKind.flag, arg: 'saw_the_red_mark'), Out(OutKind.shards, value: 35)],
      ),
      EvChoice(
        label: 'Copy it and leave the original pinned up.',
        result:
            'It takes an hour you did not have and your copy is worse than the original in every '
            'respect except the one that matters, which is that there are now two of them. You '
            'pin the good one back up and take the bad one, and the annotation on yours is in '
            'your handwriting now.',
        out: [Out(OutKind.mercy, value: 3), Out(OutKind.relic),
          Out(OutKind.flag, arg: 'left_a_message'), Out(OutKind.hp, value: 4)],
      ),
    ],
  ),

  GameEvent(
    id: 'the_thing_in_the_well',
    title: 'THE WELL',
    art: 'event_thing_in_the_well',
    weight: 10,
    act: 1,
    body:
        'The bucket comes up with a note in it instead of water. The note says: **is it still '
        'going?**\n\n'
        'The handwriting is careful and small and slightly out of date. There is a pencil tied '
        'to the rope, worn down to a stub by a very large number of replies.\n\n'
        'Whoever is down there has been asking this question, and getting answers, for longer '
        'than the pencil should have lasted.',
    plain: 'Something at the bottom of a well asks if the world is still going. Answer, lie, or go down.',
    choices: [
      EvChoice(
        label: 'Write back: yes. Still going.',
        result:
            'You send the bucket down. It comes up almost immediately with a single word — '
            '**good** — and then, after a pause and clearly as an afterthought, a small object '
            'that has been down there a long time and was evidently being saved for somebody '
            'who answered.',
        out: [Out(OutKind.relic), Out(OutKind.mercy, value: 2), Out(OutKind.shards, value: 20)],
      ),
      EvChoice(
        label: 'Write back: no. It ended.',
        result:
            'Nothing comes up. Not for a long time. Then the rope goes slack in your hands all '
            'at once, the way a rope does when there is no longer any reason for anybody to hold '
            'the other end, and you stand at the top of a well listening to a silence you '
            'personally arranged.',
        out: [Out(OutKind.cruelty, value: 4), Out(OutKind.shards, value: 45),
          Out(OutKind.flag, arg: 'lied_to_the_well')],
      ),
      EvChoice(
        label: 'Climb down.',
        result:
            'Two hundred feet, no water, and at the bottom a small dry room with a chair, a '
            'stack of every note that ever came down, sorted by date, and nobody in it. The '
            'pencil is on the arm of the chair. The most recent note in the stack is in your '
            'handwriting and you have not written it yet.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'knows_loop'),
          Out(OutKind.hp, value: 10), Out(OutKind.relic)],
      ),
    ],
  ),
];
