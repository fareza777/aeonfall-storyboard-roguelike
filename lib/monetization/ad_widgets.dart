import 'package:flutter/material.dart';

import '../audio.dart';
import '../game.dart';
import '../theme.dart';
import 'monetization_service.dart';

/// Optional rewarded video in the Sanctum. Hidden when ads are removed or
/// the rewarded unit is not configured yet.
class WatchShardsPanel extends StatefulWidget {
  const WatchShardsPanel({super.key, this.onGranted});
  final VoidCallback? onGranted;

  @override
  State<WatchShardsPanel> createState() => _WatchShardsPanelState();
}

class _WatchShardsPanelState extends State<WatchShardsPanel> {
  final _service = MonetizationService.i;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _service.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _service.removeListener(_refresh);
    super.dispose();
  }

  Future<void> _watch() async {
    if (_busy) return;
    final m = Game.i.meta;
    if (m.shardWatchesLeft <= 0) return;
    setState(() => _busy = true);
    final earned = await _service.showRewarded(
      onEarned: () {
        m.shards += MonetizationService.shardWatchReward;
        m.noteShardWatch();
        Game.i.saveMeta();
      },
    );
    if (!mounted) return;
    if (earned) {
      Audio.i.sfx('relic');
      widget.onGranted?.call();
    }
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_service.rewardedReady) return const SizedBox.shrink();
    final left = Game.i.meta.shardWatchesLeft;
    final done = left <= 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: AePanel(
        border: done ? Ae.panelHi : Ae.volt,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('A PAGE FOR THE LEDGER', style: Ae.label(12, c: Ae.volt)),
            const SizedBox(height: 6),
            Text(
              done
                  ? 'That is all the extra ink for today.'
                  : 'Watch a short page for ${MonetizationService.shardWatchReward} Shards. $left left today.',
              style: Ae.body(14.5, c: Ae.bone, h: 1.4),
            ),
            if (!done) ...[
              const SizedBox(height: 12),
              AeButton(
                label: _busy ? 'Loading…' : 'Watch for Shards',
                color: Ae.volt,
                enabled: !_busy,
                onTap: _watch,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
