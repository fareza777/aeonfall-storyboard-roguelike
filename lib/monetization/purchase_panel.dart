import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme.dart';
import 'monetization_service.dart';

class RemoveAdsPanel extends StatefulWidget {
  const RemoveAdsPanel({super.key});

  @override
  State<RemoveAdsPanel> createState() => _RemoveAdsPanelState();
}

class _RemoveAdsPanelState extends State<RemoveAdsPanel> {
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

  Future<void> _buy() async {
    if (_busy) return;
    setState(() => _busy = true);
    await _service.buyRemoveAds();
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _restore() async {
    if (_busy) return;
    setState(() => _busy = true);
    await _service.restorePurchases();
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _openPrivacy() async {
    await launchUrl(
      Uri.parse(MonetizationService.privacyPolicyUrl),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final removed = _service.adsRemoved;
    final product = _service.product;
    final price = product?.price ?? r'$4.99';
    return AePanel(
      border: removed ? Ae.good : Ae.volt,
      ornament: true,
      glow: removed ? Ae.good : Ae.volt,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            removed ? 'THE SANCTUM IS QUIET' : 'KEEP THE PAGE CLEAN',
            style: Ae.label(13, c: removed ? Ae.good : Ae.volt),
          ),
          const SizedBox(height: 7),
          Text(
            removed
                ? 'Ads are removed on this Google Play account.'
                : 'Remove Sanctum and run-result ads permanently.',
            style: Ae.body(14.5, c: Ae.bone, h: 1.4),
          ),
          const SizedBox(height: 12),
          if (!removed)
            AeButton(
              label: _busy ? 'Contacting Google Play…' : 'Remove Ads · $price',
              color: Ae.volt,
              enabled: !_busy && _service.purchaseAvailable,
              onTap: _buy,
            ),
          if (!removed) const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runAlignment: WrapAlignment.center,
            runSpacing: 8,
            children: [
              GestureDetector(
                onTap: _busy ? null : _restore,
                child: Text(
                  'RESTORE PURCHASE',
                  style: Ae.label(11.5, c: Ae.goldSoft),
                ),
              ),
              GestureDetector(
                onTap: _openPrivacy,
                child: Text(
                  'PRIVACY POLICY',
                  style: Ae.label(11.5, c: Ae.goldSoft),
                ),
              ),
            ],
          ),
          if (_service.errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _service.errorMessage!,
              style: Ae.body(12.5, c: Ae.blood, h: 1.35),
            ),
          ],
        ],
      ),
    );
  }
}
