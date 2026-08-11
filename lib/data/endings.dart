import 'narrative_model.dart';

/// Twelve endings. Which one you get depends on what you did, not what you
/// picked at the last screen — the final choice only selects the *branch*.
const kEndings = <Ending>[
  Ending(
    id: 'end_true',
    title: 'THE UNWRITTEN DAWN',
    art: 'ending_end_true',
    epitaph: 'You finished it.',
    body:
        'You do not take the pen and you do not break it. You pick up the eleventh '
        'crossed-out ending — the beautiful one, the one that was almost brave enough — '
        'and you read it aloud, all the way to the end, in a room with somebody in it.\n\n'
        'That is all finishing a story requires. Somebody has to be there when it stops.\n\n'
        'The black sun does not explode. It sets. It takes about nine minutes and the '
        'colour is off on the left, and behind it there is an ordinary blue sky that has '
        'been waiting three thousand years for permission.\n\n'
        'Everyone who ever died in a crumpled draft does not come back. That is not what '
        'an ending is. But they *stay* dead now, properly, with the full stop after them, '
        'and the world goes on being a world with no one drawing it.\n\n'
        'You are the last thing on the last page. There is no next draft to reuse you in.\n\n'
        'You have never been so relieved.',
  ),
  Ending(
    id: 'end_become',
    title: 'THE NEW HAND',
    art: 'ending_end_become',
    epitaph: 'You took the pen.',
    body:
        'The coat fits. Of course it fits.\n\n'
        'You tell yourself you will do it better — kinder drafts, fewer Falls, characters '
        'who get to keep their names. And you will, for a while. The first hundred are '
        'genuinely gentler.\n\n'
        'It is around draft four hundred that you notice you have stopped finishing them. '
        'It is around draft nine hundred that you understand why the last one couldn\'t '
        'either. A story that ends is a story where you stop.\n\n'
        'Three thousand drafts from now, someone will climb all the way up here with soot '
        'in their mouth and a torn page in their fist, and they will look at you, and they '
        'will say: *you were afraid, that is all this ever was.*\n\n'
        'And you will say yes. And you will mean it. And you will keep writing.',
  ),
  Ending(
    id: 'end_break',
    title: 'THE SNAPPED QUILL',
    art: 'ending_end_erase',
    epitaph: 'You ended it. All of it.',
    body:
        'You break the pen across your knee.\n\n'
        'The world does not end dramatically. It stops being *added to*, which turns out '
        'to be the same thing arriving quietly. Colour goes first. Then distance. Then '
        'the parts of things that nobody was currently looking at.\n\n'
        'People do not scream. There is no time to; they simply reach the edge of what was '
        'drawn of them and stop, mid-gesture, the way a sentence stops at a page break '
        'that has no next page.\n\n'
        'It is mercy. You are almost sure it is mercy. Three thousand drafts of the same '
        'siege, the same betrayal, the same forty-one bodies in the same road — and you '
        'have finally made it stop.\n\n'
        'You are the last thing to fade, and you have time for exactly one thought, and '
        'the thought is: *I never asked any of them.*',
  ),
  Ending(
    id: 'end_free',
    title: 'THE DOOR THAT WAS ALWAYS THERE',
    art: 'ending_end_free',
    epitaph: 'You walked out.',
    body:
        'There is a door in the study that nobody drew. It has been there the whole time '
        'because nobody drew it — an oversight, a gap, the kind of place Lira used to '
        'talk about.\n\n'
        'You open it. Beyond is an ordinary sunlit field, in no particular style, rendered '
        'by nobody. It is not beautiful. It is just *there*, the way things are there when '
        'no one is deciding about them.\n\n'
        'Behind you the world you came from carries on collapsing on schedule. You could '
        'stay. You could take the pen. You could break it.\n\n'
        'You step through, and the grass is real under your boots, and it does not mean '
        'anything, and that is the entire gift.\n\n'
        'You do not look back. Everyone who has ever been drawn wants very badly for you '
        'not to look back.',
  ),
  Ending(
    id: 'end_sacrifice',
    title: 'THE HELD PAGE',
    art: 'ending_end_sacrifice',
    epitaph: 'You held it open.',
    body:
        'You do not finish it and you do not end it. You get underneath it and you hold '
        'it up.\n\n'
        'Everything a Vessel is for — being load-bearing, being impossible to erase — you '
        'finally use on purpose. The Fall arrives and finds you standing in it, and it '
        'cannot get past, and it will never be able to get past, and that is the '
        'arrangement now.\n\n'
        'The world continues. It is not fixed. There are still tyrants and drowned choirs '
        'and children drawing your body in the road. But nothing crumples. Every story '
        'that starts gets to reach its own last line, badly or well, on its own terms.\n\n'
        'You are in the load-bearing wall of the world now. Nobody will ever thank you, '
        'because nobody will ever know there was a wall.\n\n'
        'Brann would have understood immediately. You think about that a lot.',
  ),
  Ending(
    id: 'end_loop',
    title: 'THE LONG RETURN',
    art: 'ending_end_loop',
    epitaph: 'You went back.',
    body:
        'You put the page down, and you turn around, and you walk back down the tower.\n\n'
        'Past the vault, past the theatre, past the corridor of your own arranged bodies. '
        'You straighten the newest one\'s hands on the way. You always have.\n\n'
        'At the bottom there is a road and ash in your mouth and no memory of lying down.\n\n'
        'It is not defeat. You know something now that none of the forty-one knew, and you '
        'are carrying it, and the carrying costs nothing. Next time you will get further. '
        'Next time you will get to the study with the mercy intact and the pages in your '
        'fist and a companion still walking beside you.\n\n'
        'Three thousand drafts and every single one of them was a rehearsal.\n\n'
        'You are getting very good at this.',
  ),
  Ending(
    id: 'end_companion',
    title: 'TWO SILHOUETTES',
    art: 'ending_end_companion',
    epitaph: 'Neither of you was alone.',
    body:
        'You reach the study together, which nobody has ever done.\n\n'
        'That turns out to be the whole answer. The Author\'s fear was of *stopping* — of '
        'the moment after the last line when there is nothing and no one. Three thousand '
        'drafts of holding the pen because putting it down meant being alone with the '
        'silence.\n\n'
        'You put it down. And the silence comes. And there is somebody in it with you.\n\n'
        'You walk out down an ash road at dawn, two silhouettes, arguing amiably about '
        'whether the sunrise colour is wrong on the left. It is. It always was. Neither '
        'of you is going to fix it.\n\n'
        'Behind you the last page is blank and staying blank, and nothing in the world '
        'needs you to be load-bearing ever again.',
  ),
  Ending(
    id: 'end_tyrant',
    title: 'THE MOUNTAIN OF MASKS',
    art: 'ending_end_tyrant',
    epitaph: 'You won. That was all you did.',
    body:
        'You take the pen with hands that have taken a great deal already.\n\n'
        'You are extremely good at this. That is the tragedy of it — three thousand drafts '
        'of practice at doing whatever was necessary, and now the necessary things are '
        'yours to define.\n\n'
        'The drafts get shorter under your hand. Crueller and more efficient. You stop '
        'bothering with the parts where people are happy for a page and a half; they were '
        'always the parts that made crumpling hurt.\n\n'
        'You sit on a throne of masks in a world that runs beautifully and contains, as '
        'far as anyone can tell, no one at all who is glad about anything.\n\n'
        'It never once occurs to you that this is what you were afraid of. That is the '
        'part the previous one got right and you did not: he was at least still afraid.',
  ),
  Ending(
    id: 'end_hollow',
    title: 'THE EMPTY ARMOUR',
    art: 'ending_end_hollow',
    epitaph: 'There was nobody left to finish it.',
    body:
        'You reach the study with everything you needed and nothing you were.\n\n'
        'Somewhere behind you — the merchant\'s jar, the wounded stranger, the child with '
        'the drawing, forty-one sets of equipment taken off forty-one of your own bodies '
        '— you spent it. All of it. Every exchange was correct. Every exchange was worth '
        'it. You have never once been wrong about what a thing was worth.\n\n'
        'The pen is right there. You can pick it up. You can break it.\n\n'
        'You stand in front of the desk for a very long time and discover that there is '
        'nobody inside you to have an opinion.\n\n'
        'They find the armour still standing there, upright, in perfect condition, several '
        'drafts later. It has to be moved by hand. It is surprisingly heavy and completely '
        'empty.',
  ),
  Ending(
    id: 'end_burn',
    title: 'EVERY PAGE AT ONCE',
    art: 'ending_end_burn',
    epitaph: 'You lit it.',
    body:
        'You do not break the pen. You burn the archive.\n\n'
        'Three thousand drafts, every crumpled version, every catalogued Fall — all of it '
        'goes up at once in a gold column visible from every point in the world '
        'simultaneously, because the world is paper and this is what paper does.\n\n'
        'Nothing can be restarted from a draft that no longer exists. Nothing can be '
        'reused. Every character in every version is, for the first time, *unrepeatable.*\n\n'
        'It is not kind. Whole drafts of people who were mid-sentence are simply gone, '
        'and they do not get a full stop, they get a burn line.\n\n'
        'But there is no next one. There is no next one, and you stand in the middle of '
        'the light with your arms open, and the last thing you ever feel is warm.',
  ),
  Ending(
    id: 'end_freeze',
    title: 'THE PERFECT STILL',
    art: 'ending_end_freeze',
    epitaph: 'You kept it exactly as it was.',
    body:
        'You do the thing Thessa did to a lake, and you do it to a world.\n\n'
        'Nothing ends because nothing moves. The Fall arrives and finds a world with no '
        'give in it — every person, every hour, every falling grain of ash held at the '
        'exact position it occupied at the moment you decided.\n\n'
        'Under the ice everything is exactly as it was. Including the people you could not '
        'save. Including the ones you could.\n\n'
        'You are the only moving thing. You walk between them for a long time, adjusting '
        'nothing, because adjusting is drawing and drawing is how this started.\n\n'
        '*Not yet is not the same as never,* she used to say. You have made a world out '
        'of not yet, and you will live in it, and one day — not today — you may be brave '
        'enough to let it thaw one inch.',
  ),
  Ending(
    id: 'end_ascend',
    title: 'THE THING ABOVE THE AUTHOR',
    art: 'ending_end_ascend',
    epitaph: 'You went further up than there was.',
    body:
        'There is nothing above the Author. Everyone knows that. It is the entire point.\n\n'
        'You go up anyway.\n\n'
        'Not by stairs — there are none — but by the gap Lira used to talk about, the '
        'unfinished part, the place the world was never drawn into. You walk into the '
        'blank and you keep walking and the world falls away underneath you like a page '
        'turning.\n\n'
        'What is up here is not a god. It is a desk that nobody is sitting at, and a chair '
        'pushed in neatly, and a note in handwriting nobody has ever seen before:\n\n'
        '*gone out. back later. — please do not start another one without me.*\n\n'
        'You read it four times. Then you sit down on the floor beside the desk, not in '
        'the chair, and you wait, and for the first time in three thousand years the '
        'waiting is not a loop.\n\n'
        'It is just waiting. Somebody is coming back.',
  ),
];

Ending endingById(String id) =>
    kEndings.firstWhere((e) => e.id == id, orElse: () => kEndings.first);
