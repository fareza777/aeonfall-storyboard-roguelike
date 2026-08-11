import 'package:flutter/material.dart';

import '../audio.dart';
import '../data/story_digest.dart';
import '../engine/run_state.dart';
import '../theme.dart';
import 'widgets.dart';

/// The running "what has happened so far" recap, in plain sentences.
void showStorySoFar(BuildContext context, RunState r) {
  Audio.i.sfx('page', volume: .5);
  final lines = StoryDigest.soFar(r);
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => Container(
      height: MediaQuery.of(context).size.height * .85,
      decoration: const BoxDecoration(
        color: Ae.ink2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: Ae.gold, width: 2)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 46, height: 4, color: Ae.panelHi),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
            child: Heading('THE STORY SO FAR',
                sub: 'Everything you have worked out this run', size: 24),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
              children: [
                for (final l in lines) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 7, right: 10),
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                              color: Ae.gold, shape: BoxShape.circle),
                        ),
                      ),
                      Expanded(child: Text(l, style: Ae.body(16.5, h: 1.55))),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
                const SizedBox(height: 8),
                AePanel(
                  border: Ae.frost,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('RIGHT NOW', style: Ae.label(13, c: Ae.frost)),
                      const SizedBox(height: 8),
                      Text(StoryDigest.objective(r),
                          style: Ae.body(17, c: Ae.bone, w: 600)),
                      const SizedBox(height: 6),
                      Text(StoryDigest.stake(r), style: Ae.body(15, c: Ae.dim)),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text('IF YOU ARE COMPLETELY LOST', style: Ae.label(13)),
                const SizedBox(height: 10),
                for (var i = 0; i < StoryDigest.premise.length; i++) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 26,
                        child: Text('${i + 1}.',
                            style: Ae.body(15, c: Ae.gold, w: 800)),
                      ),
                      Expanded(
                        child: Text(StoryDigest.premise[i],
                            style: Ae.body(15.5, c: Ae.dim, h: 1.5)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
