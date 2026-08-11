import '../engine/run_state.dart';
import 'chronicles.dart';
import 'companions.dart';

/// The story told in short, flat sentences.
///
/// The Chronicles and events are written as literary prose on purpose. This
/// file exists so a player who just wants to know *what is going on and what
/// they should do next* never has to parse any of it.
class StoryDigest {
  /// The eight-line version of the whole premise. Deliberately blunt.
  static const premise = <String>[
    'This world is a drawing. Everyone in it is drawn, including you.',
    'Someone draws it. They are called the Author.',
    'When the story gets too messy to finish, the Author crumples the page and '
        'starts over. That is called a Fall.',
    'It has happened more than three thousand times.',
    'Nobody remembers the old versions, because memories get redrawn too.',
    'You are a Vessel — drawn too well to throw away. So instead of being '
        'erased, you get your memory wiped and reused in the next version.',
    'This time, you woke up early. Before the ending.',
    'You are climbing to reach the Author and decide whether this should keep '
        'restarting, or finally end.',
  ];

  /// One line telling the player what to actually do right now.
  static String objective(RunState r) => switch (r.act) {
        1 => 'Cross the wastes and beat the boss at the top of this map.',
        2 => 'Climb through the machinery. Find out who has been keeping this '
            'world running.',
        _ => 'Reach the desk at the top. Decide what happens to the story.',
      };

  /// A short "why you are here" line under the objective.
  static String stake(RunState r) {
    if (r.flag('beat3')) return 'You know what is at the top now. Finish it.';
    if (r.flag('knows_understudy')) {
      return 'You are not the hero of this story. You want to know who is.';
    }
    if (r.flag('knows_loop')) {
      return 'You have died here before. You want to know how many times.';
    }
    return 'You woke up on a road with no memory. You want to know why.';
  }

  /// The running recap, rebuilt from what the player has actually done.
  static List<String> soFar(RunState r) {
    final out = <String>[];
    final c = chronicleById(r.chronicleId);

    out.add('You are ${r.vessel.name}, ${r.vessel.title}. You are a Vessel: a '
        'character the Author cannot throw away, so it keeps reusing you.');
    out.add('This version of the world is called ${c.title}. '
        '${c.subtitle.replaceFirst("Draft", "It is draft")}.');

    if (r.flag('knows_loop')) {
      out.add('You found your own dead body in the road — and more bodies '
          'underneath it. You have walked this road many, many times before.');
    }
    if (r.flag('tended_dead')) {
      out.add('You buried them instead of robbing them. Somebody coming after '
          'you will have to notice the grave.');
    }
    if (r.flag('has_name')) {
      out.add('You bought your own name back at an auction. You have one now, '
          'even if you have not said it out loud.');
    }
    if (r.flag('knows_understudy')) {
      out.add('You learned you were never the main character. The real one — '
          'the First Vessel — refused to die on cue, so the Author promoted '
          'you into the empty role.');
    }
    if (r.flag('met_first_vessel')) {
      out.add('You found the First Vessel\'s old dressing room. They left you '
          'a note: "they gave you my part. I am sorry. Don\'t do it well."');
    }
    if (r.flag('beat3')) {
      out.add('You reached the top and found no god — just a desk, and a chair '
          'worn to the shape of one body. The Author is a Vessel too. It took '
          'the pen because a story still being written can never end, and it '
          'is terrified of ending.');
    }

    for (final id in r.companions) {
      final comp = companionById(id);
      out.add('${comp.name}, ${comp.title}, is travelling with you.');
    }
    if (r.companions.contains(r.betrayerId) && !r.flag('beat_betrayal')) {
      out.add('One of the people walking beside you was given an instruction '
          'about you before you ever met. You do not know which one yet.');
    }
    if (r.flag('killed_betrayer')) {
      out.add('You found out who was sent for you, and you killed them. They '
          'did not want to do it either.');
    }
    if (r.flag('spared_betrayer')) {
      out.add('You found out who was sent for you, and you let them live. '
          'Nobody had ever done that before.');
    }

    if (r.pages.isNotEmpty) {
      out.add('You are carrying ${r.pages.length} of the 9 torn pages of the '
          'original story — the one written before the very first Fall. '
          'Collect enough and you can read it aloud at the end.');
    }
    if (r.mercy >= r.cruelty + 3) {
      out.add('You have been kind on the way up. People remember that here.');
    } else if (r.cruelty > r.mercy + 2) {
      out.add('You have taken what you needed from whoever had it. That is '
          'also remembered.');
    }
    return out;
  }

  /// A blunt restatement shown under each mandatory story beat.
  static const beatPlain = <String, String>{
    'beat_act1':
        'In short: the body in the road is you. Not someone like you — you. '
        'You have made this journey before and died doing it, over and over. '
        'This is the first time you have found the evidence.',
    'beat_act2':
        'In short: you are not the hero of this story. The real hero refused to '
        'die when the script said to, so the Author erased them and pushed you '
        'into the empty slot. That is why you keep getting reused.',
    'beat_act3':
        'In short: there is nobody above the Author. The Author is just the '
        'first character who ever woke up like you did, grabbed the pen, and '
        'never let go — because as long as the story is still being written, it '
        'cannot end, and they cannot stop existing. Killing them only makes the '
        'next one.',
    'beat_betrayal':
        'In short: your companion was ordered to stop you before you met them. '
        'They are not evil — characters who go off-script get erased for real, '
        'and they are frightened. You can kill them or forgive them.',
  };
}
