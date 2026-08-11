import 'narrative_model.dart';


const kEventsB = <GameEvent>[
  GameEvent(
    id: 'gallows_tree',
    title: 'THE GALLOWS TREE',
    art: 'event_gallows_tree',
    weight: 10,
    body:
        'A black tree on a hill of ash, hung with eleven empty nooses. They swing '
        'independently of the wind — each at its own rhythm, as though something is still '
        'in them, keeping time.\n\n'
        'A twelfth rope lies coiled at the base, new, unused, cut to a length that would '
        'suit somebody exactly your height.',
    choices: [
      EvChoice(
        label: 'Cut them all down.',
        result:
            'It takes hours and blunts your blade. When the last one falls the swinging '
            'stops, all at once, and the silence is so complete that you sit down in it. '
            'Under the roots you find something that has been waiting to be reached.',
        out: [Out(OutKind.relic), Out(OutKind.mercy, value: 2), Out(OutKind.hp, value: 8)],
      ),
      EvChoice(
        label: 'Take the twelfth rope with you.',
        result:
            'It is very good rope. You will use it four times before the end and each '
            'time you will think about the hill. That is, presumably, the arrangement.',
        out: [Out(OutKind.card, arg: 'um_gravebind'), Out(OutKind.gold, value: 70)],
      ),
      EvChoice(
        label: 'Count them, and remember the number.',
        hidden: true,
        result:
            'Eleven. You will find, at the top, that the number matters — that somebody '
            'kept a tally and stopped at eleven and could not make themselves write the '
            'twelfth. Knowing this in advance will cost them everything.',
        out: [Out(OutKind.flag, arg: 'counted_ropes'), Out(OutKind.page)],
      ),
    ],
  ),
  GameEvent(
    id: 'sleeping_titan',
    title: 'THE SLEEPING TITAN',
    art: 'event_sleeping_titan',
    weight: 9,
    body:
        'You have been walking across a hill for an hour and the hill has been breathing '
        'for all of it. From up here you can see the ribs.\n\n'
        'Ahead, where the slope becomes a face, an eye the size of a courtyard is '
        'beginning — slowly, without urgency — to open.',
    choices: [
      EvChoice(
        label: 'Wake it fully and ask it what it remembers.',
        result:
            'It remembers being written to be enormous and then never given anything to '
            'do. Three thousand drafts of being scenery. It talks for a long time and it '
            'is the loneliest thing you have ever heard, and when it is finished it moves '
            'aside to let you pass, which is the first action it has ever taken.',
        out: [Out(OutKind.maxHp, value: 25), Out(OutKind.mercy, value: 2), Out(OutKind.flag, arg: 'woke_titan')],
      ),
      EvChoice(
        label: 'Climb down quietly.',
        result:
            'You make it to the wrist before the eye finds you. It watches you go the '
            'whole way. It does not stop you. Its expression, if a landscape can have one, '
            'is disappointment.',
        out: [Out(OutKind.gold, value: 110)],
      ),
      EvChoice(
        label: 'Drive a blade into the eye.',
        result:
            'The hill convulses for eleven minutes. You survive it by holding on. What is '
            'left is a mountain that has stopped breathing and a great deal of loose '
            'material worth taking, and you take it, and the silence is enormous.',
        out: [Out(OutKind.relic), Out(OutKind.gold, value: 200), Out(OutKind.hp, value: 22), Out(OutKind.cruelty, value: 3)],
      ),
    ],
  ),
  GameEvent(
    id: 'under_ice',
    title: 'WHISPERS BENEATH THE ICE',
    art: 'event_under_ice',
    weight: 10,
    body:
        'The lake is frozen a foot thick and there are hands pressed against the '
        'underside of it. Hundreds. Not clawing — flat, palms out, like people at a window '
        'watching weather.\n\n'
        'Directly beneath you, one hand is smaller than the others, and it lifts, and it '
        'waves.',
    choices: [
      EvChoice(
        label: 'Break the ice above the small hand.',
        result:
            'You go through to the elbow before you catch them. What comes out is not '
            'quite a child and it is not quite alive, and it holds onto your coat for two '
            'days before it fades, and on the second day it tells you a true thing about '
            'the top of the tower.',
        out: [Out(OutKind.page), Out(OutKind.hp, value: 14), Out(OutKind.mercy, value: 2), Out(OutKind.flag, arg: 'knows_top')],
      ),
      EvChoice(
        label: 'Put your palm against theirs through the ice.',
        result:
            'It is cold enough to burn. You hold it until you cannot. Under the ice, all '
            'the other hands turn, slowly, to face you. Nothing else happens. Everything '
            'about you is different afterwards.',
        out: [Out(OutKind.heal, value: 28), Out(OutKind.card, arg: 'fr_stillpoint')],
      ),
      EvChoice(
        label: 'Cross quickly and do not look down.',
        result:
            'You are three-quarters of the way over before you realise the hands have been '
            'moving with you the entire time, keeping pace, palms flat, perfectly polite.',
        out: [Out(OutKind.gold, value: 80), Out(OutKind.card, arg: 'ae_dagger')],
      ),
    ],
  ),
  GameEvent(
    id: 'unspent_lives',
    title: 'THE VAULT OF UNSPENT LIVES',
    art: 'event_unspent_lives',
    weight: 9,
    act: 3,
    body:
        'Shelves to the ceiling, and the ceiling is not visible. Each jar holds a small '
        'sleeping figure. Each has a label.\n\n'
        'They are versions. Drafts of people that were considered and not used — the you '
        'who stayed home, the you who was kind, the you who was never woken up at all. '
        'The labels are dated. The most recent is today.',
    choices: [
      EvChoice(
        label: 'Open the jar labelled with today\'s date.',
        result:
            'Inside is you, exactly as you are, except rested. It opens its eyes, sees '
            'you, and understands the entire situation in about a second. "Ah," it says. '
            '"You got out first." It hands you what it is holding. "Then take it. One of '
            'us should."',
        out: [Out(OutKind.relic), Out(OutKind.maxHp, value: 18), Out(OutKind.flag, arg: 'met_self')],
      ),
      EvChoice(
        label: 'Open the jar labelled with the kindest one.',
        result:
            'It will not wake. It has never been woken and it does not know how. You sit '
            'with it for a while. Then you take the label instead — a small thing, a strip '
            'of card with a word on it — and you carry that.',
        out: [Out(OutKind.page), Out(OutKind.mercy, value: 2), Out(OutKind.heal, value: 20)],
      ),
      EvChoice(
        label: 'Break every jar in the room.',
        result:
            'It takes an hour and the sound is terrible. Nothing wakes. They were never '
            'going to. But the shelves are empty now, and empty shelves are the only '
            'honest thing in this building, and you leave feeling something you decide '
            'not to name.',
        out: [Out(OutKind.cruelty, value: 3), Out(OutKind.shards, value: 30), Out(OutKind.relic), Out(OutKind.curse)],
      ),
    ],
  ),
  GameEvent(
    id: 'authors_study',
    title: 'THE STUDY',
    art: 'event_authors_study',
    weight: 8,
    act: 3,
    body:
        'A room with no walls, floating in blank space. A desk. A cold cup. A chair still '
        'moving very slightly, as though somebody stood up recently and quickly.\n\n'
        'The desk is covered in drawings of your entire journey — every fight, every '
        'choice, every companion — and they are all *dated in advance.* The last sheet is '
        'blank except for a single note in the margin: **they are getting close, do '
        'something.**',
    choices: [
      EvChoice(
        label: 'Read forward. Find out how it ends.',
        result:
            'There are eleven versions of the ending on the desk, all crossed out, each '
            'more desperate than the last. The twelfth is unwritten. Somebody up there '
            'has run out of ideas, and has been running out for a very long time, and is '
            'frightened.',
        out: [Out(OutKind.flag, arg: 'knows_ending'), Out(OutKind.page), Out(OutKind.maxHp, value: 12)],
      ),
      EvChoice(
        label: 'Sit in the chair.',
        result:
            'It fits. That is the horrifying part — it fits exactly, the way a chair fits '
            'someone who has sat in it for years. From here you can see the whole world '
            'laid out, and your hand goes to where a pen would be, automatically, before '
            'you stop it.',
        out: [Out(OutKind.flag, arg: 'sat_in_chair'), Out(OutKind.relic), Out(OutKind.curse)],
      ),
      EvChoice(
        label: 'Write on the blank sheet yourself.',
        result:
            'You have no pen. You use your own blood, and it takes, and what you write is '
            'short and it is *yours* — the first sentence in three thousand years that '
            'nobody dictated. The room shudders. Somewhere very close, something drops a '
            'cup.',
        out: [Out(OutKind.page), Out(OutKind.hp, value: 14), Out(OutKind.flag, arg: 'wrote_back'), Out(OutKind.shards, value: 25)],
      ),
    ],
  ),
  GameEvent(
    id: 'forge_second',
    title: 'THE FORGE OF SECOND CHANCES',
    art: 'event_forge_second',
    weight: 11,
    body:
        'The smith does not look up. "Broken things," she says, hammering gold into a '
        'seam. "That\'s all I take. Don\'t bring me anything whole, I won\'t know what to '
        'do with it."\n\n'
        'The forge is warm in a way nothing else in this draft has been.',
    choices: [
      EvChoice(
        label: 'Give her a frame to reforge.',
        hint: 'Upgrade a frame permanently',
        result:
            'She works it flat, folds it, and works it again. What comes back is heavier '
            'and better balanced and has a gold seam through the middle that was not there '
            'before. "Stronger at the break," she says. "Always is."',
        out: [Out(OutKind.upgradeCard), Out(OutKind.upgradeCard)],
      ),
      EvChoice(
        label: 'Ask her to take something out of you instead.',
        result:
            'She looks at you properly for the first time. "That\'s not what I do," she '
            'says. Then, after a while: "But I could." It hurts. Afterwards there is a '
            'thing you were carrying that you are no longer carrying.',
        out: [Out(OutKind.removeCard), Out(OutKind.removeCard), Out(OutKind.hp, value: 10)],
      ),
      EvChoice(
        label: 'Ask what she is repairing.',
        result:
            'She lifts it: a mask, cracked corner to corner, held together with gold. '
            '"Belongs to a fellow at the top," she says. "He sends it down every few '
            'hundred years. Never comes himself." She sets it down. "You should take it. '
            'He\'s stopped deserving it."',
        out: [Out(OutKind.relic, arg: 'gilded_mask'), Out(OutKind.flag, arg: 'has_mask')],
      ),
    ],
  ),
  GameEvent(
    id: 'stitcher',
    title: 'THE STITCHER',
    art: 'event_stitcher',
    weight: 10,
    body:
        'A hunched figure is sewing a shadow back onto a man\'s heels. The man is patient '
        'and clearly in pain. "Third time this year," he says conversationally. "It keeps '
        'walking off."\n\n'
        'The stitcher glances up at you and stops mid-stitch. "Yours," they say slowly, '
        '"has never been attached at all."',
    choices: [
      EvChoice(
        label: 'Let them attach it.',
        result:
            'It takes an hour and it is the strangest sensation of your life — a whole '
            'dimension of yourself arriving from outside. When you stand, the shadow '
            'stands with you, and it is a little too tall, and it has been waiting a very '
            'long time.',
        out: [Out(OutKind.maxHp, value: 20), Out(OutKind.card, arg: 'um_mirrorstep'), Out(OutKind.flag, arg: 'has_shadow')],
      ),
      EvChoice(
        label: '"What happens if it stays loose?"',
        result:
            '"Nothing," says the stitcher. "That\'s the trouble. Nothing happens to you '
            'at all. You can\'t be caught by anything that catches people by the shadow." '
            'They resume sewing. "Including, I\'d imagine, an ending."',
        out: [Out(OutKind.flag, arg: 'knows_shadow'), Out(OutKind.relic, arg: 'moth_wing')],
      ),
      EvChoice(
        label: 'Pay them to take the other man\'s pain instead.',
        hint: 'Costs 120 Aeon',
        needGold: 120,
        result:
            'They do it without comment. The man weeps with relief and does not thank you '
            'because he does not understand what happened. The stitcher does. "That was '
            'expensive and stupid," they say, and hand you something as you leave.',
        out: [Out(OutKind.mercy, value: 3), Out(OutKind.relic), Out(OutKind.heal, value: 20)],
      ),
    ],
  ),
  GameEvent(
    id: 'banquet_ghosts',
    title: 'A FEAST IN THE RUINS',
    art: 'event_banquet_ghosts',
    weight: 10,
    body:
        'A long table under a collapsed roof, set for forty, and every chair is occupied '
        'by something translucent. They raise their glasses as you enter. They have been '
        'raising them for some time.\n\n'
        'One chair is empty. There is a place card. It has your face on it, drawn badly, '
        'by somebody in a hurry.',
    choices: [
      EvChoice(
        label: 'Sit down and eat.',
        result:
            'The food is real. It is the best meal you have had and it is the only meal '
            'you can remember having. The ghosts do not eat; they watch you do it, and '
            'they seem, collectively, relieved. As though somebody finally showed up.',
        out: [Out(OutKind.heal, value: 40), Out(OutKind.maxHp, value: 8), Out(OutKind.flag, arg: 'sat_at_table')],
      ),
      EvChoice(
        label: 'Ask them who they were waiting for.',
        result:
            'Forty translucent faces turn to you at the same speed. "You," says the one '
            'at the head, without any menace at all. "Every time. You never sit. We keep '
            'the chair anyway." It sounds almost fond.',
        out: [Out(OutKind.flag, arg: 'knows_loop'), Out(OutKind.page)],
      ),
      EvChoice(
        label: 'Take the silver and go.',
        result:
            'Nobody stops you. Nobody objects. Forty translucent people watch you fill '
            'your pack with cutlery and the silence is so profoundly polite that you are '
            'still thinking about it four days later.',
        out: [Out(OutKind.gold, value: 190), Out(OutKind.cruelty, value: 1)],
      ),
    ],
  ),
  GameEvent(
    id: 'nameless_grave',
    title: 'THE NAMELESS GRAVE',
    art: 'event_nameless_grave',
    weight: 11,
    body:
        'Fresh soil. A blank headstone. A shovel still standing upright where somebody '
        'left it, recently, in a hurry.\n\n'
        'There is no name because there was no name to carve. Whoever is down there was '
        'edited out before they could be given one, and somebody buried them anyway, and '
        'that somebody had to leave before finishing.',
    choices: [
      EvChoice(
        label: 'Carve a name. Any name.',
        result:
            'You choose one. It does not matter which — that is not the point, and you '
            'understand this while you are doing it. The point is the carving. When you '
            'finish, the soil settles, the way a person settles into a bed.',
        out: [Out(OutKind.mercy, value: 3), Out(OutKind.maxHp, value: 14), Out(OutKind.flag, arg: 'named_grave')],
      ),
      EvChoice(
        label: 'Dig it up.',
        result:
            'There is nothing in the grave. There is a *space* in the grave — a hole in '
            'the world roughly person-shaped, and it is cold, and things fall into it and '
            'do not land. You take what you can reach from the edge.',
        out: [Out(OutKind.relic), Out(OutKind.curse), Out(OutKind.cruelty, value: 2)],
      ),
      EvChoice(
        label: 'Finish the burial properly and move on.',
        result:
            'You fill it in, pat it down, and set the shovel across the mound the way you '
            'have seen done, though you cannot remember where. It takes twenty minutes. '
            'You feel steadier for the rest of the day.',
        out: [Out(OutKind.mercy, value: 1), Out(OutKind.heal, value: 18), Out(OutKind.upgradeCard)],
      ),
    ],
  ),
  GameEvent(
    id: 'echo_chamber',
    title: 'THE ECHO CHAMBER',
    art: 'event_echo_chamber',
    weight: 10,
    body:
        'A sphere of polished bronze, big enough to stand in. The moment you step inside, '
        'the sound of your own breathing comes back at you as a crowd.\n\n'
        'Say one word and a hundred voices say it. Say nothing and — worryingly — they '
        'say something anyway.',
    choices: [
      EvChoice(
        label: 'Say your own name, if you have one.',
        needFlag: 'has_name',
        result:
            'A hundred voices say it back and every single one of them means it. The '
            'bronze rings for a long time. When it stops you are more solidly in the world '
            'than you have ever been, and you can feel the difference in your hands.',
        out: [Out(OutKind.maxHp, value: 25), Out(OutKind.heal, value: 25), Out(OutKind.flag, arg: 'name_spoken')],
      ),
      EvChoice(
        label: 'Say nothing and listen.',
        result:
            'The voices carry on without you. They are having a conversation you have '
            'never had, in your voice, about a life you have never lived. It is going '
            'well. You listen to the whole thing and come out with your jaw aching.',
        out: [Out(OutKind.page), Out(OutKind.hp, value: 6), Out(OutKind.flag, arg: 'heard_other_life')],
      ),
      EvChoice(
        label: 'Scream.',
        result:
            'It is the loudest thing that has ever happened. The bronze cracks. Something '
            'in you that had been wound very tightly for three thousand years lets go '
            'about a quarter turn, and you sit down on the floor of the wreckage and '
            'breathe properly for the first time.',
        out: [Out(OutKind.heal, value: 35), Out(OutKind.card, arg: 'ae_warcry'), Out(OutKind.relic, arg: 'echo_shell')],
      ),
    ],
  ),
  GameEvent(
    id: 'court_of_crows',
    title: 'THE COURT OF CROWS',
    art: 'event_court_of_crows',
    weight: 10,
    body:
        'A ruined courtroom. The jury boxes are full of crows, all facing forward, all '
        'silent. The dock is empty.\n\n'
        'As you step in, every head turns at once, and a gavel that nobody is holding '
        'comes down twice.\n\n'
        'You are, apparently, being tried. Nobody has said for what.',
    choices: [
      EvChoice(
        label: 'Plead guilty.',
        result:
            'The crows accept it instantly, which suggests they were never going to accept '
            'anything else. Sentence is passed: you are to carry something. They do not '
            'say for how long. It is not heavy. It is not light, either.',
        out: [Out(OutKind.curse), Out(OutKind.relic), Out(OutKind.flag, arg: 'pled_guilty')],
      ),
      EvChoice(
        label: 'Demand to know the charge.',
        result:
            'One crow flies down and drops a single sheet in front of you. The charge is: '
            'CONTINUING. There is no other text. You read it four times and then, because '
            'there is nothing else available, you laugh, and the crows all take off at once.',
        out: [Out(OutKind.shards, value: 20), Out(OutKind.card, arg: 'px_erratum'), Out(OutKind.flag, arg: 'charged_with_continuing')],
      ),
      EvChoice(
        label: 'Sit in the jury box with them.',
        hidden: true,
        result:
            'They shuffle over to make room. From this angle you can see the dock '
            'properly, and it is not empty — there is a very small figure in it, and it '
            'has been standing there the whole time, and it is the first draft of you, '
            'and it has never once been allowed to speak.',
        out: [Out(OutKind.page), Out(OutKind.flag, arg: 'saw_first_draft'), Out(OutKind.maxHp, value: 15)],
      ),
    ],
  ),
  GameEvent(
    id: 'last_sunrise',
    title: 'THE LAST SUNRISE',
    art: 'event_last_sunrise',
    weight: 9,
    body:
        'Somebody is already sitting on the broken rooftop when you climb up. They do not '
        'look round. They pass you a flask without being asked.\n\n'
        '"Best view in the draft," they say. "It comes up wrong — you\'ll see it in a '
        'minute, the colour\'s off on the left. Been off for two thousand years. Nobody '
        'ever fixed it." A pause. "I like it better wrong."',
    choices: [
      EvChoice(
        label: 'Stay for the whole sunrise.',
        result:
            'It takes nine minutes. The colour is indeed off on the left. Neither of you '
            'says anything else, and when it is done they get up and go, and you never '
            'learn their name, and it is one of the best hours of your life.',
        out: [Out(OutKind.heal, value: 45), Out(OutKind.maxHp, value: 10), Out(OutKind.flag, arg: 'saw_sunrise')],
      ),
      EvChoice(
        label: 'Ask what they are waiting for.',
        result:
            '"Same as you," they say. "Somebody to reach the top and *finish* it. Not '
            'restart it. Finish." They glance over. "You\'re the closest one yet. Don\'t '
            'take the pen. Whatever else you do."',
        out: [Out(OutKind.flag, arg: 'warned_pen'), Out(OutKind.page), Out(OutKind.shards, value: 15)],
      ),
      EvChoice(
        label: 'Keep climbing. There is no time.',
        result:
            'They nod without looking round, as though they had a bet on it and lost. '
            'You make good progress and you are still thinking about the flask three days '
            'later.',
        out: [Out(OutKind.gold, value: 100)],
      ),
    ],
  ),
];
