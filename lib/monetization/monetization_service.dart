import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../game.dart';

/// Owns all optional network-backed services. The game remains playable when
/// any of these services are unavailable or declined by the player.
class MonetizationService extends ChangeNotifier {
  MonetizationService._();

  static final MonetizationService i = MonetizationService._();

  static const productId = 'aeonfall_remove_ads';
  static const privacyPolicyUrl =
      'https://fareza777.github.io/aeonfall-storyboard-roguelike/privacy-policy.html';

  // These are Google test units until the real Aeonfall units are created in
  // AdMob. Release builds use the production constants below.
  static const _testBannerUnit = 'ca-app-pub-3940256099942544/6300978111';
  static const _testInterstitialUnit = 'ca-app-pub-3940256099942544/1033173712';
  static const productionBannerUnit =
      'ca-app-pub-6279186647593327/7063520187';
  static const productionInterstitialUnit =
      'ca-app-pub-6279186647593327/5750438511';

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  InterstitialAd? _interstitial;
  ProductDetails? product;
  DateTime? _lastInterstitial;
  String? errorMessage;
  bool _started = false;
  bool _initialized = false;
  bool _adsReady = false;
  bool _purchaseAvailable = false;

  bool get adsRemoved => Game.i.meta.adsRemoved;
  bool get adsReady => _adsReady && !adsRemoved;
  bool get purchaseAvailable => _purchaseAvailable;
  String get bannerUnitId =>
      kReleaseMode ? productionBannerUnit : _testBannerUnit;
  String get interstitialUnitId =>
      kReleaseMode ? productionInterstitialUnit : _testInterstitialUnit;

  /// Subscribe before the Flutter widget tree is returned, as recommended by
  /// Play Billing. The stream is intentionally kept for the app lifetime.
  void start() {
    if (_started) return;
    _started = true;
    _purchaseSubscription = InAppPurchase.instance.purchaseStream.listen(
      _handlePurchases,
      onError: (Object error) {
        errorMessage = 'Purchase updates are temporarily unavailable.';
        notifyListeners();
      },
    );
  }

  Future<void> initialize() async {
    start();
    if (_initialized) return;
    _initialized = true;

    await Future.wait<void>([_initializeAds(), _initializePurchases()]);
  }

  Future<void> _initializeAds() async {
    if (kIsWeb) return;

    try {
      if (Platform.isAndroid) {
        final settled = Completer<void>();
        ConsentInformation.instance.requestConsentInfoUpdate(
          ConsentRequestParameters(),
          () {
            if (!settled.isCompleted) settled.complete();
          },
          (_) {
            if (!settled.isCompleted) settled.complete();
          },
        );
        await settled.future.timeout(
          const Duration(seconds: 8),
          onTimeout: () {},
        );
        await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
        if (!await ConsentInformation.instance.canRequestAds()) return;
      }

      await MobileAds.instance.initialize();
      _adsReady = true;
      notifyListeners();
      _loadInterstitial();
    } catch (_) {
      // An ad network failure must never block the title screen or a run.
      _adsReady = false;
    }
  }

  Future<void> _initializePurchases() async {
    try {
      _purchaseAvailable = await InAppPurchase.instance.isAvailable();
      if (!_purchaseAvailable) return;
      final response = await InAppPurchase.instance.queryProductDetails({
        productId,
      });
      if (response.error == null && response.productDetails.isNotEmpty) {
        product = response.productDetails.first;
      } else if (response.error != null) {
        errorMessage = 'The ad-free upgrade is not available yet.';
      }
      notifyListeners();
      // A non-consumable should be restored after every app start. The stream
      // listener above is already active before this call.
      await InAppPurchase.instance.restorePurchases();
    } catch (_) {
      _purchaseAvailable = false;
      notifyListeners();
    }
  }

  void _loadInterstitial() {
    if (!adsReady || _interstitial != null) return;
    InterstitialAd.load(
      adUnitId: interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          notifyListeners();
        },
        onAdFailedToLoad: (_) {
          _interstitial = null;
          notifyListeners();
        },
      ),
    );
  }

  /// Shows at most one interstitial every ten minutes, and only from the run
  /// result screen. The route waits for the ad to finish before leaving.
  Future<void> showInterstitialIfDue() async {
    if (!adsReady || _interstitial == null) return;
    final last = _lastInterstitial;
    if (last != null &&
        DateTime.now().difference(last) < const Duration(minutes: 10)) {
      return;
    }

    final ad = _interstitial;
    _interstitial = null;
    _lastInterstitial = DateTime.now();
    final finished = Completer<void>();
    void complete() {
      if (!finished.isCompleted) finished.complete();
    }

    ad!.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdDismissedFullScreenContent: (value) {
        value.dispose();
        complete();
      },
      onAdFailedToShowFullScreenContent: (value, _) {
        value.dispose();
        complete();
      },
    );
    try {
      await ad.show();
      await finished.future.timeout(
        const Duration(seconds: 45),
        onTimeout: () {},
      );
    } catch (_) {
      ad.dispose();
    } finally {
      _loadInterstitial();
    }
  }

  Future<bool> buyRemoveAds() async {
    if (adsRemoved) return true;
    if (!_purchaseAvailable || product == null) {
      errorMessage = 'The Play Store upgrade is not ready yet.';
      notifyListeners();
      return false;
    }
    errorMessage = null;
    notifyListeners();
    try {
      return await InAppPurchase.instance.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product!),
      );
    } catch (_) {
      errorMessage = 'The purchase could not be started. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<void> restorePurchases() async {
    errorMessage = null;
    notifyListeners();
    try {
      await InAppPurchase.instance.restorePurchases();
    } catch (_) {
      errorMessage = 'Restore is unavailable right now.';
      notifyListeners();
    }
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID == productId &&
          (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored)) {
        Game.i.meta.adsRemoved = true;
        Game.i.saveMeta();
        errorMessage = null;
        notifyListeners();
      } else if (purchase.status == PurchaseStatus.error) {
        errorMessage =
            purchase.error?.message ?? 'The purchase was not completed.';
        notifyListeners();
      }

      if (purchase.pendingCompletePurchase) {
        try {
          await InAppPurchase.instance.completePurchase(purchase);
        } catch (_) {
          // The platform will redeliver an unfinished transaction next launch.
        }
      }
    }
  }

  Future<void> showPrivacyOptions() async {
    try {
      await ConsentForm.showPrivacyOptionsForm((formError) {
        if (formError != null) {
          errorMessage = 'Privacy options are unavailable right now.';
          notifyListeners();
        }
      });
    } catch (_) {
      errorMessage = 'Privacy options are unavailable right now.';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    _interstitial?.dispose();
    super.dispose();
  }
}
