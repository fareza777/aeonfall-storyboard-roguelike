import 'narrative_model.dart';

/// Each run is a different *draft* of the same doomed world. The three great
/// reveals always land — but the draft decides what the world calls them.
const kChronicles = <Chronicle>[
  Chronicle(
    id: 'ashen_crown',
    number: 2911,
    title: 'THE ASHEN CROWN',
    subtitle: 'Draft 2,911 — in which the king burns first',
    art: 'chron_ashen_crown',
    antagonist: 'The Pyre Marshal',
    premise:
        'In this draft the world ends from the throne outward. A king was written to be '
        'good and could not manage it, so the page set him on fire and let the fire do '
        'the governing. Ash falls on everything now. It falls indoors.',
    actOne:
        'You wake in the Ashfall Wastes with soot in your mouth and no memory of lying '
        'down. There is a road. There is always a road — roads are cheap to draw. At the '
        'end of it, someone is ringing a bell that has no clapper, and the sound arrives '
        'anyway.',
    actTwo:
        'Past the wastes the machinery starts. Someone has been keeping this world running '
        'by hand, gear by gear, and they have not slept in three thousand years. They are '
        'not glad to see you. They have seen you before.',
    actThree:
        'The ash thins. Beyond it the world simply stops being drawn — mountains fading '
        'into clean white paper, an horizon that was never finished. Something is up there '
        'still working. You can hear the nib.',
  ),
  Chronicle(
    id: 'drowned_choir',
    number: 1408,
    title: 'THE DROWNED CHOIR',
    subtitle: 'Draft 1,408 — in which the water came up through the hymns',
    art: 'chron_drowned_choir',
    antagonist: 'The Bell Beneath',
    premise:
        'This draft drowns. Not quickly — the water has been rising for four hundred years '
        'and everyone has simply learned to sing higher. The cathedrals are full to the '
        'transept. The choir has not stopped.',
    actOne:
        'You come up out of black water in a nave with no roof, coughing, holding something '
        'you do not remember picking up. A choirboy floats past, still singing. He turns '
        'his head to watch you go by.',
    actTwo:
        'Above the waterline the brass begins — a great lung of machinery breathing the '
        'flood back out, one thousand years behind schedule. Its keeper offers you tea and '
        'calls you by a name you have not been given yet.',
    actThree:
        'The water ends. So does everything else. There is a shore made of blank paper and '
        'a tide of static, and past it a study with the lamp still lit.',
  ),
  Chronicle(
    id: 'hollow_saint',
    number: 777,
    title: 'THE HOLLOW SAINT',
    subtitle: 'Draft 777 — in which the miracle was a printing error',
    art: 'chron_hollow_saint',
    antagonist: 'The Dawn Executor',
    premise:
        'A saint was drawn in this draft and drawn well — too well. The world reorganised '
        'itself around her the way iron filings organise around a magnet. Then somebody '
        'opened the reliquary and found it empty, and the filings have been screaming ever '
        'since.',
    actOne:
        'Pilgrims on the salt road, walking towards a light that has been out for a century. '
        'You join them because standing still in this draft is a decision, and you have not '
        'decided anything yet.',
    actTwo:
        'The pilgrimage ends at a bazaar of mirrors where the faithful sell their reflections '
        'for one more mile of faith. Yours does not sell. The merchant looks at it a long '
        'time and then gives it back for free.',
    actThree:
        'Beyond the last shrine there is a door with light behind it, and the light is '
        'somebody working late. You have been walking towards a desk this entire time.',
  ),
  Chronicle(
    id: 'clockwork_heresy',
    number: 2044,
    title: 'THE CLOCKWORK HERESY',
    subtitle: 'Draft 2,044 — in which they built a god out of gears to be safe',
    art: 'chron_clockwork_heresy',
    antagonist: 'The Clocksmith Prime',
    premise:
        'This draft decided that the problem with divinity was that it could change its '
        'mind. So they built one that could not. It has been ticking ever since, and '
        'nothing in this world has been allowed to end, including the parts that badly '
        'want to.',
    actOne:
        'The Ashfall Wastes, but the ash is metal filings and the wind has a rhythm to it. '
        'Every hour, everything alive stops for one second. Nobody can explain why. Nobody '
        'has ever been able to.',
    actTwo:
        'The Clockwork Abyss goes down further than the world is tall. You descend past '
        'workshops where they are still assembling the sunrise by hand, three centuries '
        'behind, and gaining.',
    actThree:
        'At the bottom of the machine there is no machine. There is a room, and a chair, '
        'and someone who stopped being able to put the pen down a very long time ago.',
  ),
  Chronicle(
    id: 'mirror_war',
    number: 3001,
    title: 'THE MIRROR WAR',
    subtitle: 'Draft 3,001 — in which everybody met themselves',
    art: 'chron_mirror_war',
    antagonist: 'Mirrorlord Vane',
    premise:
        'Somewhere in the drafting a line got duplicated, and every person in this world '
        'woke up with an exact copy standing opposite them. The war that followed lasted '
        'eleven days. Both sides won. Neither side is sure which one it is.',
    actOne:
        'You find a body on the road. It is wearing your face and your boots, and it has '
        'been dead about a week. Its hand is closed around something. You take it. Of '
        'course you take it.',
    actTwo:
        'The Mirror Bazaar is doing brisk trade in the question of which of you is real. '
        'The going rate is high. Several people have paid it and gone home satisfied, and '
        'their copies have also gone home satisfied.',
    actThree:
        'At the end there is only one of everything again. That should be a relief. It is '
        'not. Someone edited the duplicates out, and they did it with a pen.',
  ),
  Chronicle(
    id: 'stormbound',
    number: 189,
    title: 'STORMBOUND',
    subtitle: 'Draft 189 — in which they chained the sky to the ground',
    art: 'chron_stormbound',
    antagonist: 'Stormfather Zell',
    premise:
        'An early draft, and it shows — the seams are visible, the weather is a character, '
        'and the sky has been in chains since page nine. It has not forgiven anybody. It '
        'is not going to.',
    actOne:
        'Lightning strikes the same hill every four minutes and has done since before you '
        'were drawn. Somebody built a shrine there. Somebody always does.',
    actTwo:
        'The Stormspire is a prison and the prisoner is the weather. Its warden has begun '
        'to feel that the arrangement is unkind, which is a dangerous thing for a warden '
        'to feel.',
    actThree:
        'Above the clouds it is completely silent. There is nothing up here but the last '
        'page and the person still writing on it.',
  ),
  Chronicle(
    id: 'unwritten_name',
    number: 66,
    title: 'THE UNWRITTEN NAME',
    subtitle: 'Draft 66 — in which somebody was scratched out',
    art: 'chron_unwritten_name',
    antagonist: 'The Editor of Names',
    premise:
        'This draft is missing a person. Not dead — removed. The hole where they were is '
        'still load-bearing, and everything around it has had to lean inward to keep the '
        'world standing. Everyone leans. Nobody mentions it.',
    actOne:
        'A village where every headstone is blank and the mourners cannot remember who '
        'they came for. They are still crying. Grief outlasts its object.',
    actTwo:
        'You find the ledger. Every name in it has been struck through in red, including '
        'names of things — a river, a colour, a particular way light fell on a particular '
        'morning. All of it edited out for length.',
    actThree:
        'The red pen is still wet. Somebody is still working. You are the next entry, and '
        'you can see your own name from here.',
  ),
  Chronicle(
    id: 'the_long_return',
    number: 2999,
    title: 'THE LONG RETURN',
    subtitle: 'Draft 2,999 — in which the road only goes one way and it is backwards',
    art: 'chron_the_long_return',
    antagonist: 'The First Vessel',
    premise:
        'A draft so close to the end that the machinery has started showing through. People '
        'find their own footprints ahead of them. Doors open onto rooms they have already '
        'left. Everyone in this world has the constant sense of having just missed '
        'something, and they are right.',
    actOne:
        'The road out of the wastes curves. You walk it for six hours and arrive at the '
        'place you started, which is now six hours older and glad to see you.',
    actTwo:
        'A corridor lined with your own bodies. They are all facing the same direction. '
        'You are facing that direction too.',
    actThree:
        'The last door is the first door. It always was. Someone has been standing behind '
        'it the whole time, waiting to see whether this is the run where you finally do '
        'not open it.',
  ),
  Chronicle(
    id: 'gilded_lie',
    number: 1200,
    title: 'THE GILDED LIE',
    subtitle: 'Draft 1,200 — in which the ending was very beautiful and completely false',
    art: 'chron_gilded_lie',
    antagonist: 'The Warden of the Fall',
    premise:
        'This draft has already ended. Gloriously — the tyrant fell, the sun came back, '
        'everybody wept. It ended two hundred years ago and it has been ending ever since, '
        'the same afternoon, on a loop, because it was too good a final page to turn.',
    actOne:
        'The celebration is still going. The bunting has rotted and been redrawn eleven '
        'times. The crowd cheers on cue. Somebody in the back row has started screaming '
        'and nobody has noticed for a decade.',
    actTwo:
        'Under the party there is machinery keeping the afternoon going. It is not '
        'sophisticated. It is mostly a very tired person with a very heavy lever.',
    actThree:
        'To get out you have to turn the page. To turn the page you have to admit that '
        'the beautiful ending was a lie, and that the person who wrote it knew.',
  ),
  Chronicle(
    id: 'last_cartographer',
    number: 402,
    title: 'THE LAST CARTOGRAPHER',
    subtitle: 'Draft 402 — in which the middle of the world was never drawn',
    art: 'chron_last_cartographer',
    antagonist: 'The Vault Custodian',
    premise:
        'The edges of this draft are exquisite. The centre is blank — a hole in the map '
        'the size of a continent, marked only with a note in the margin reading "later". '
        'Later never came. People live around the rim and do not talk about the middle.',
    actOne:
        'You are hired to carry a map to the edge of the blank. The client does not '
        'explain why. Halfway there you notice the map is redrawing itself to avoid '
        'somewhere.',
    actTwo:
        'Inside the blank there is nothing, and the nothing is furnished. Chairs. A '
        'kettle. Someone lived here while deciding what to put here, and then stopped '
        'deciding.',
    actThree:
        'The margin note is in handwriting you recognise. You have seen it on every page '
        'of your own life.',
  ),
  Chronicle(
    id: 'chorus_of_falls',
    number: 3000,
    title: 'THE CHORUS OF FALLS',
    subtitle: 'Draft 3,000 — in which all the previous drafts are audible at once',
    art: 'chron_chorus_of_falls',
    antagonist: 'AEONFALL',
    premise:
        'A round number, and the page knows it. Every version of this world that has ever '
        'been crumpled is bleeding through at once. You can hear all of them. Some of them '
        'are singing. Most of them are asking the same question, which is: is this the one '
        'where it works.',
    actOne:
        'Three suns, because three drafts are overlapping here. None of them agree on what '
        'time it is. The crops have given up.',
    actTwo:
        'Every stranger you meet has met you before, in a version that went differently. '
        'Several of them will not look at you. One of them apologises for something that '
        'has not happened.',
    actThree:
        'At the end all three thousand drafts converge on a single desk, and the sound is '
        'unbearable, and then it stops, because somebody has looked up.',
  ),
  Chronicle(
    id: 'author_unmade',
    number: 1,
    title: 'AUTHOR UNMADE',
    subtitle: 'Draft 1 — in which nothing has gone wrong yet',
    art: 'chron_author_unmade',
    antagonist: 'The Author',
    premise:
        'The first draft. Clean lines, no corrections, a world that has never once been '
        'crumpled. Everything here is exactly as it was meant to be. That is the most '
        'frightening thing you have ever encountered, and you cannot yet say why.',
    actOne:
        'A morning. An ordinary one. Bread cooling on a sill and a road that goes somewhere '
        'pleasant. You have never felt more certain that you are about to ruin something.',
    actTwo:
        'You start finding the corrections — small ones, in the margins, in a hand that has '
        'not begun to shake yet. Somebody is already unhappy with this.',
    actThree:
        'The desk is new. The chair is new. The person sitting in it has not yet learned '
        'that the only way to keep a story from ending is to never let it finish. You are '
        'about to teach them.',
  ),
];

Chronicle chronicleById(String id) =>
    kChronicles.firstWhere((c) => c.id == id, orElse: () => kChronicles.first);
