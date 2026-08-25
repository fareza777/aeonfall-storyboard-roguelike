import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'monetization_service.dart';

/// A quiet, anchored banner used only in the Sanctum. It takes no space when
/// consent, network, or the permanent ad-free entitlement makes it ineligible.
class SanctumBanner extends StatefulWidget {
  const SanctumBanner({super.key});

  @override
  State<SanctumBanner> createState() => _SanctumBannerState();
}

class _SanctumBannerState extends State<SanctumBanner> {
  final _service = MonetizationService.i;
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _service.addListener(_serviceChanged);
    _load();
  }

  void _serviceChanged() {
    if (!mounted) return;
    if (_service.adsRemoved) {
      _ad?.dispose();
      setState(() {
        _ad = null;
        _loaded = false;
      });
    } else if (_ad == null && _service.adsReady) {
      _load();
    } else {
      setState(() {});
    }
  }

  void _load() {
    if (_service.adsRemoved || !_service.adsReady || _ad != null) return;
    final ad = BannerAd(
      adUnitId: _service.bannerUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (value) {
          if (!mounted) {
            value.dispose();
            return;
          }
          setState(() {
            _ad = value as BannerAd;
            _loaded = true;
          });
        },
        onAdFailedToLoad: (value, _) {
          value.dispose();
          if (mounted) setState(() => _loaded = false);
        },
      ),
    );
    ad.load();
  }

  @override
  void dispose() {
    _service.removeListener(_serviceChanged);
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null || _service.adsRemoved) {
      return const SizedBox.shrink();
    }
    return SafeArea(
      top: false,
      child: Container(
        height: ad.size.height.toDouble() + 10,
        alignment: Alignment.center,
        padding: const EdgeInsets.only(top: 6),
        color: Colors.black.withValues(alpha: .14),
        child: SizedBox(
          width: ad.size.width.toDouble(),
          height: ad.size.height.toDouble(),
          child: AdWidget(ad: ad),
        ),
      ),
    );
  }
}
