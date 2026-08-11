import 'narrative_model.dart';

/// You may travel with up to two. Exactly one of them, chosen by the seed, is
/// carrying an instruction they were given before you met.
const kCompanions = <Companion>[
  Companion(
    id: 'brann',
    name: 'BRANN',
    title: 'The Unburnt',
    art: 'comp_brann',
    gift: 'iron_tooth',
    perk: 'Shieldwall',
    perkDesc: 'Start every battle with 5 additional Guard.',
    recruit:
        'He is sitting on a milestone eating cold stew out of a helmet, and he does not '
        'stand up when you approach. "Third one this week," he says. "You all walk the '
        'same. Bit forward on the toes, like the road might not be there." He scrapes the '
        'helmet clean. "It usually isn\'t. Right — where are we going."',
    bond1:
        '"I\'ve been a soldier in nine wars," Brann says, "and I only remember four of '
        'them. Used to think that was the drink." He turns a coin over in his fingers. '
        '"It\'s not the drink."',
    bond2:
        'He tells you about a village. He describes the bakery, the well, the dog that '
        'was afraid of carts. Then he stops and says, quietly: "I have never been there. '
        'I remember all of it and I have never once been there." He does not look at you '
        'for the rest of the evening.',
    betrayal:
        'Brann puts his hand on your shoulder the way he has forty times, and this time '
        'the other hand has a knife in it. "They told me it goes easier if you don\'t see '
        'it," he says, and his voice is absolutely level, and his eyes are streaming. '
        '"They lied about that as well."',
    spared:
        'You lower your weapon. Brann stares at it, then at you, and something in his '
        'face comes apart. "That\'s not — " he starts. "You\'re supposed to — " He sits '
        'down heavily in the ash. "Nobody\'s ever done that."',
    death:
        'He goes down holding the line, because it is the only thing he has ever been '
        'drawn doing. The last thing he says is the name of a village that was never real, '
        'and he says it fondly.',
  ),
  Companion(
    id: 'lira',
    name: 'LIRA',
    title: 'Of the Quiet',
    art: 'comp_lira',
    gift: 'map_fragment',
    perk: 'Pathfinder',
    perkDesc: 'You can see the node types two layers ahead.',
    recruit:
        'You do not find her. You become aware that she has been walking beside you for '
        'some time. "You breathe too loud," she says, by way of introduction. "Everything '
        'out here listens for breathing." She hands you a strip of dried meat. "I\'ll '
        'come. Not for you. There\'s a thing at the top I want to look at."',
    bond1:
        '"I map the parts nobody drew," Lira says, sketching in the dirt. "The gaps. If '
        'you walk into one you come out somewhere the world didn\'t plan." She smudges it '
        'out with her heel. "That\'s where I grew up."',
    bond2:
        'She shows you her notebook. Every page is the same clearing drawn from a slightly '
        'different angle, hundreds of times. "It\'s where I was standing the first time I '
        'noticed the sky repeat," she says. "I keep drawing it to make sure it stays."',
    betrayal:
        'The arrow is in your shoulder before you register that she has moved. "I mapped '
        'the gaps so I could hide in one," Lira says, already nocking the second. "There '
        'is exactly one way to be left out of the next draft, and it is to be useful to '
        'the person holding the pen."',
    spared:
        'You let her run. She does not. She stands at the treeline for a long time with '
        'the bow half-raised and then walks back and sits down opposite you and says '
        'nothing at all for two hours, which for Lira is an apology of enormous scale.',
    death:
        'She dies mapping. Notebook open, pencil moving, correcting the shape of the room '
        'she is bleeding out in. The last line she draws is accurate.',
  ),
  Companion(
    id: 'mordwen',
    name: 'MORDWEN',
    title: 'Ash-Priest',
    art: 'comp_mordwen',
    gift: 'ash_locket',
    perk: 'Last Rites',
    perkDesc: 'Heal 8 whenever you clear a floor.',
    recruit:
        'The old priest is administering last rites to a building. "It was a good house," '
        'he says, without turning around. "Somebody was happy in it for about a page and a '
        'half." He caps the oil. "I bury things that nobody will admit are dead. You look '
        'like you qualify. Shall we walk?"',
    bond1:
        '"I have performed the last rite three thousand times," Mordwen says. "For the '
        'same world. I keep expecting it to take."',
    bond2:
        'He admits he stopped believing eleven drafts ago and kept doing the ritual '
        'anyway. "Faith is not the point," he says. "Somebody has to say the words over a '
        'thing when it goes. Otherwise it just — stops. Without ceremony. Like a sentence '
        'that never got its full stop."',
    betrayal:
        '"I am so sorry," Mordwen says, and he means it entirely, and he pushes you into '
        'the pit regardless. "It offered me an ending. A real one. Do you understand what '
        'that is worth to a man who has buried the same world three thousand times?"',
    spared:
        'You pull him back from the edge instead. He weeps like something breaking. '
        '"I have given the rite to everyone," he says, "and no one has ever given it to '
        'me." You give it to him. It is four words long. He stops shaking.',
    death:
        'He dies mid-sentence, administering the rite to himself, and gets to the fourth '
        'word. It counts. He would say it counts.',
  ),
  Companion(
    id: 'vessa',
    name: 'VESSA',
    title: 'The Duellist',
    art: 'comp_vessa',
    gift: 'wolf_sigil',
    perk: 'Killing Instinct',
    perkDesc: 'Deal 15% more damage while below half HP.',
    recruit:
        'She beats you to the draw, holds the point at your throat for exactly as long as '
        'it takes to be insulting, and then puts it up. "You flinched correctly," Vessa '
        'says. "That\'s rarer than you\'d think. Most people flinch like they\'ve been '
        'told about flinching." She sheathes. "I\'m bored. Take me somewhere fatal."',
    bond1:
        '"I have never lost," Vessa says. "Not once. Do you know how boring that is? '
        'Do you know what it does to a person, to be written unbeatable?"',
    bond2:
        'She loses — badly, to a common thug, in a bar, over nothing. She is so delighted '
        'she buys the man a drink. "There it is," she keeps saying, pressing the cut on '
        'her cheek. "There it is."',
    betrayal:
        '"Nothing personal," says Vessa, and for once she is lying badly. "You get to the '
        'top and you become the next one holding the pen. I have read every draft I could '
        'steal. It is always the protagonist." The blade comes up. "I would rather it were '
        'nobody. Failing that, I would rather it were me."',
    spared:
        'You disarm her and hand the rapier back hilt-first. Vessa looks at it like it has '
        'insulted her family. "You are a *terrible* duellist," she says thickly, "and an '
        'even worse enemy," and she does not challenge you again.',
    death:
        'She dies winning, which is the only way she was ever going to manage it, laughing '
        'at something nobody else heard.',
  ),
  Companion(
    id: 'tock',
    name: 'TOCK',
    title: 'The Small Machine',
    art: 'comp_tock',
    gift: 'clock_hand',
    perk: 'Wind-Up',
    perkDesc: 'Draw 2 extra frames if your hand is empty at the start of a turn.',
    recruit:
        'It is knee-high, brass, and has been trying to open the same door for four '
        'hundred years. When you open it for the machine, it stands very still for a long '
        'moment, and then follows you instead. It has no face. It manages to look '
        'devastated anyway.',
    bond1:
        'TOCK cannot speak. It taps. You work out, over three days, that it is not '
        'counting — it is keeping time for a song nobody has sung in this draft.',
    bond2:
        'You find its maker\'s mark. The name has been filed off, carefully, by small '
        'brass fingers, some time ago. TOCK will not look at you while you examine it.',
    betrayal:
        'TOCK stops walking. It taps out a rhythm you have not heard before, and the floor '
        'opens under you. Later you will understand: it was not betraying you. It was '
        'following the last order its maker ever gave it, and it has been trying to '
        'disobey that order for four hundred years, and today it lost.',
    spared:
        'You climb back out and TOCK is still standing at the edge, arms at its sides, '
        'making no attempt to run. You put a hand on its head. It taps twice — the same '
        'two notes, over and over, which you eventually realise is the only word it has: '
        '*sorry, sorry, sorry.*',
    death:
        'It winds itself down deliberately, all at once, to power one last mechanism that '
        'keeps a door open long enough for you. The tapping stops mid-bar.',
  ),
  Companion(
    id: 'silvane',
    name: 'SILVANE',
    title: 'The Blind Oracle',
    art: 'comp_silvane',
    gift: 'witness_stone',
    perk: 'Foresight',
    perkDesc: 'Events reveal one hidden option.',
    recruit:
        'She is waiting at the crossroads with two cups poured. "You are eleven minutes '
        'late," Silvane says, "which is early, for you." She pushes one across. "Do not '
        'ask me how it ends. I will tell you, and you will believe me, and then you will '
        'make it happen. That is the entire mechanism of prophecy and it is a scandal."',
    bond1:
        '"I see every version," she says. "All at once, all the time. It is like being '
        'shouted at by a crowd of people who all love you."',
    bond2:
        '"There are four hundred and six futures where you die at the Stormspire," Silvane '
        'says calmly. "I stopped counting the ones where you don\'t, because there were '
        'nine, and I did not want to get attached."',
    betrayal:
        '"In one hundred per cent of the futures where I warn you," Silvane says, "you '
        'die at the top. In eleven where I do not, you live." She steps back from the '
        'trapdoor. "I have loved you in every single one of them. This is what that '
        'looks like from the inside."',
    spared:
        'You do not accuse her. You simply say: "I know," and keep walking, and after a '
        'moment she follows. Somewhere in the eleven futures, this is the one.',
    death:
        'She dies with her eyes open behind the blindfold, describing the room to you in '
        'perfect detail as it is happening, so that you will be able to find your way out '
        'of it afterwards.',
  ),
  Companion(
    id: 'harrow',
    name: 'HARROW',
    title: 'The Silent',
    art: 'comp_harrow',
    gift: 'spine_charm',
    perk: 'Executioner',
    perkDesc: 'Gain 3 Thorns at the start of every battle.',
    recruit:
        'The executioner is sitting beside a scaffold with no rope, sharpening a cleaver '
        'the size of a door. When you sit down he shifts to make room. He does not speak. '
        'After an hour he stands, shoulders the cleaver, and waits by the road until you '
        'get up too.',
    bond1:
        'Harrow does not speak. He writes, on his palm, in charcoal: WHO DECIDED. He shows '
        'it to you. He rubs it out.',
    bond2:
        'You learn that he took the hood voluntarily, in a draft that no longer exists, to '
        'spare the previous executioner\'s son. Nobody in this world remembers that '
        'happening. Harrow remembers. That is the whole job now.',
    betrayal:
        'He writes on his palm one last time and shows you: I WAS TOLD TO. Then, '
        'underneath, smaller: I HAVE ALWAYS BEEN TOLD TO. The cleaver comes up very slowly, '
        'as though he is hoping you will stop it.',
    spared:
        'You catch the cleaver on your guard and hold it there, and do not push back. '
        'Harrow lowers it. He writes: THANK YOU. Then he wipes his palm clean and never '
        'writes on it again.',
    death:
        'He dies in the doorway, filling it, exactly as wide as the gap, which is what he '
        'was drawn for and what he finally chose.',
  ),
  Companion(
    id: 'nim',
    name: 'NIM',
    title: 'The Fox',
    art: 'comp_nim',
    gift: 'scribes_thumb',
    perk: 'Light Fingers',
    perkDesc: 'Removing a frame at a market is free, once per Act.',
    recruit:
        'Your purse is gone. You catch the kid by the collar two streets later and they '
        'do not even pretend. "Everyone here gets robbed the same day every week," Nim '
        'says. "Same purse. Same street. I\'ve done it four hundred times." They look up '
        'at you. "You\'re the first one who\'s ever caught me."',
    bond1:
        '"I steal things so they move," Nim says. "Everything in this town sits where it '
        'sits. If I take it, it goes somewhere new. That\'s the only new thing that '
        'happens here."',
    bond2:
        'Nim shows you the stash: hundreds of small objects, arranged in a spiral, each '
        'moved a few inches every week. "It\'s a drawing," they say, embarrassed. "You can '
        'only see it from the roof."',
    betrayal:
        'The purse is gone again and so is the kid, and the door behind you locks. Through '
        'it, muffled: "They said if I did one big thing they\'d let me keep being me next '
        'time. I\'m sorry. I *like* being me."',
    spared:
        'You do not chase them. Three floors later Nim is sitting on the stairs with your '
        'purse and their arms folded, furious at themselves. "You were supposed to come '
        'after me," they say. "That\'s how it works."',
    death:
        'They die stealing something back for you, hand closed round it, and the hand '
        'stays closed.',
  ),
  Companion(
    id: 'calder',
    name: 'CALDER',
    title: 'The Lightning-Branded',
    art: 'comp_calder',
    gift: 'storm_shard',
    perk: 'Conductor',
    perkDesc: 'Whenever you apply Shock, apply 1 more.',
    recruit:
        'The sailor has a scar across his face in the shape of a river delta and he is '
        'shouting at the sky. When he notices you he stops, embarrassed. "It started it," '
        'he says. Then: "Nine times. Same bolt. Same hill. I keep going back to see if it '
        'still wants me." He picks up his harpoon. "It does."',
    bond1:
        '"Being struck by lightning is the only thing that has ever happened to me that '
        'wasn\'t on the page," Calder says. "I\'ve read the page. I\'m not in it."',
    bond2:
        'He confesses he goes back to the hill because the bolt is the only thing in the '
        'world that has ever chosen him specifically. "It\'s not much of a relationship," '
        'he admits. "But it\'s mine."',
    betrayal:
        '"It spoke to me," Calder says, and his eyes are wrong. "Up on the hill. Ninth '
        'time. It said if I brought it the one who wakes up, it would put me *in the '
        'story.*" The harpoon shakes badly. "Do you know what it is to be told you are '
        'scenery?"',
    spared:
        'You take the harpoon out of his hands and give him your name — your real one, '
        'the one you have started to remember. Being named by someone is not nothing. He '
        'sits down on the wet stone and covers his face.',
    death:
        'He dies in a storm, on a hill, upright, which he would tell you is precisely what '
        'he asked for and he would be telling the truth.',
  ),
  Companion(
    id: 'orrin',
    name: 'ORRIN',
    title: 'The Disgraced Scholar',
    art: 'comp_orrin',
    gift: 'marrow_die',
    perk: 'Cross-Reference',
    perkDesc: 'Frame rewards offer one extra choice.',
    recruit:
        'He is being thrown out of a library, which he takes with enormous dignity for a '
        'man landing in a gutter. "I published," Orrin says, retrieving his spectacles from '
        'a puddle, "a paper demonstrating that the calendar repeats every four hundred '
        'years with minor variations." He stands. "They did not dispute the mathematics. '
        'They disputed the *tone*."',
    bond1:
        '"Everyone thinks I want to be believed," Orrin says. "I don\'t. I want somebody '
        'to check my working. Nobody has ever checked my working."',
    bond2:
        'You check his working. It takes most of a night. It is correct. Orrin sits very '
        'still while you tell him so, and then takes his spectacles off and cleans them '
        'for much longer than they need.',
    betrayal:
        '"I checked *your* working," Orrin says, not meeting your eye, holding the vial. '
        '"You do not survive the third act. Not in any variation. But a *witness* does. '
        'A witness always survives, because somebody has to write it down." He pours it '
        'into your cup. "I am so terribly sorry. I want to be the one who writes it down."',
    spared:
        'You drink it anyway and do not die, because he has, characteristically, made an '
        'arithmetic error in the dosage. Orrin is so appalled by the error that he forgets '
        'to be appalled by the murder.',
    death:
        'He dies with the notebook open, still writing, and the final entry is legible and '
        'correctly dated and simply reads: *it worked, it worked, tell them it worked.*',
  ),
  Companion(
    id: 'thessa',
    name: 'THESSA',
    title: 'The Frost-Witch',
    art: 'comp_thessa',
    gift: 'frozen_rose',
    perk: 'Rimeblood',
    perkDesc: 'Whenever you gain Guard, gain 2 more.',
    recruit:
        'The lake has been frozen for a hundred and forty years and she is standing on it '
        'in bare feet. "I keep it like this," Thessa says. "Under the ice, everything is '
        'exactly as it was." A pause. "Including my sister." Another pause. "I know what '
        'that makes me. Are you coming or not."',
    bond1:
        '"Cold is not cruelty," Thessa says. "Cold is a promise that nothing else will be '
        'taken from you today."',
    bond2:
        'She lets the ice thin, just once, just enough to see. Then she freezes it back '
        'harder than before and does not speak for a day. "Not yet," is all she says. '
        '"Not yet is not the same as never."',
    betrayal:
        '"There is a version where she is alive," Thessa says, and the frost is already '
        'racing up your legs. "It offered me that version. Do you understand? Not a '
        'memory of her. *Her.*" Her face is perfectly still. "You would do it. Don\'t '
        'pretend."',
    spared:
        'You do not break the ice and you do not fight her. You sit down on the frozen '
        'lake and wait. Eventually Thessa sits too. Eventually, without being asked, she '
        'lets it thaw one inch, which is the most enormous thing she has ever done.',
    death:
        'She dies holding a wall of ice up with both hands long after her arms have '
        'stopped working, and the wall holds for four minutes after she does.',
  ),
  Companion(
    id: 'the_stranger',
    name: 'THE STRANGER',
    title: 'Unlisted',
    art: 'comp_the_stranger',
    gift: 'hollow_key',
    perk: 'Unlisted',
    perkDesc: 'Opens hidden options in events. Nobody remembers hiring you.',
    recruit:
        'There is a figure at the edge of the firelight and there has been for some time. '
        'When you finally address it, it says: "Ah. Good. I was beginning to think you '
        'wouldn\'t." It sits. Its coat is perfect. Nothing about it casts a shadow, and '
        'it is extremely polite about this.',
    bond1:
        '"I am not in the cast list," the Stranger says pleasantly. "I have checked. '
        'Repeatedly. It is a great freedom and I do not recommend it."',
    bond2:
        '"You want to know what I am." A long pause. "So do I. I have been asking for a '
        'very long time and the only honest answer I have found is: *left over.*"',
    betrayal:
        '"You have been extremely good company," says the Stranger, "and I want you to '
        'know that I am not doing this because of anything you did." The hat tips. "I am '
        'doing it because I was left over from a draft where you had to die here, and I '
        'have never been given anything else to do."',
    spared:
        'You give it something else to do. It is a small task — carry this, hold that, '
        'wait here for me. The Stranger stares at you for a very long moment and then says, '
        'in an entirely different voice: "*Yes.* Yes, all right. Yes."',
    death:
        'It does not die. It simply is not there any more, and the space where it was does '
        'not close, and you carry the gap the rest of the way.',
  ),
];

Companion companionById(String id) =>
    kCompanions.firstWhere((c) => c.id == id, orElse: () => kCompanions.first);
