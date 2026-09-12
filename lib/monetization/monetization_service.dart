import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../game.dart';
import 'rewarded_session.dart';

/// Natural pauses where a full-screen ad may appear. Never mid-fight or
/// mid-story: only after the player has finished something.
enum InterstitialBreak { runEnd, actClear, hub, combat }

/// Owns all optional network-backed services. The game remains playable when
/// any of these services are unavailable or declined by the player.
class MonetizationService extends ChangeNotifier {
  MonetizationService._();

  @visibleForTesting
  MonetizationService.forTesting({
    required Future<void> Function() persistPurchase,
    required Future<void> Function(PurchaseDetails) completePurchase,
  }) : _persistPurchase = persistPurchase,
       _completePurchase = completePurchase;

  Future<void> Function()? _persistPurchase;
  Future<void> Function(PurchaseDetails)? _completePurchase;

  static final MonetizationService i = MonetizationService._();

  static const productId = 'remove_ads';
  static const privacyPolicyUrl =
      'https://fareza777.github.io/aeonfall-storyboard-roguelike/privacy-policy.html';

  // Debug builds use Google test units. Release uses the Aeonfall AdMob units.
  static const _testInterstitialUnit = 'ca-app-pub-3940256099942544/1033173712';
  static const _testRewardedUnit = 'ca-app-pub-3940256099942544/5224354917';
  static const productionInterstitialUnit =
      'ca-app-pub-6279186647593327/5750438511';
  static const productionRewardedUnit =
      'ca-app-pub-6279186647593327/2910165528';

  static const interstitialGap = Duration(minutes: 4);
  static const shardWatchReward = 25;
  static const shardWatchesPerDay = 3;
  static const combatWatchGold = 35;
  static const combatsPerInterstitial = 3;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  ProductDetails? product;
  DateTime? _lastInterstitial;
  String? errorMessage;
  bool _started = false;
  bool _initialized = false;
  bool _adsReady = false;
  bool _purchaseAvailable = false;
  bool _fullscreenBusy = false;
  bool _loadingInterstitial = false;
  bool _loadingRewarded = false;
  int _adGeneration = 0;

  bool get adsRemoved => Game.i.meta.adsRemoved;
  bool get adsReady => _adsReady && !adsRemoved;
  bool get purchaseAvailable => _purchaseAvailable && product != null;
  String get interstitialUnitId =>
      kReleaseMode ? productionInterstitialUnit : _testInterstitialUnit;
  String get rewardedUnitId =>
      kReleaseMode ? productionRewardedUnit : _testRewardedUnit;
  bool get rewardedReady => adsReady && _rewarded != null && !_fullscreenBusy;

  /// Subscribe before the Flutter widget tree is returned, as recommended by
  /// Play Billing. The stream is intentionally kept for the app lifetime.
  void start() {
    if (_started) return;
    _started = true;
    _purchaseSubscription = InAppPurchase.instance.purchaseStream.listen(
      handlePurchases,
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
      _loadRewarded();
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
      } else {
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
    if (!adsReady || _interstitial != null || _loadingInterstitial) return;
    _loadingInterstitial = true;
    final generation = _adGeneration;
    InterstitialAd.load(
      adUnitId: interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (generation != _adGeneration || !adsReady) {
            ad.dispose();
            return;
          }
          _loadingInterstitial = false;
          _interstitial = ad;
          notifyListeners();
        },
        onAdFailedToLoad: (_) {
          if (generation != _adGeneration) return;
          _loadingInterstitial = false;
          _interstitial = null;
          notifyListeners();
        },
      ),
    );
  }

  void _loadRewarded() {
    if (!adsReady || _rewarded != null || _loadingRewarded) return;
    _loadingRewarded = true;
    final generation = _adGeneration;
    RewardedAd.load(
      adUnitId: rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          if (generation != _adGeneration || !adsReady) {
            ad.dispose();
            return;
          }
          _loadingRewarded = false;
          _rewarded = ad;
          notifyListeners();
        },
        onAdFailedToLoad: (_) {
          if (generation != _adGeneration) return;
          _loadingRewarded = false;
          _rewarded = null;
          notifyListeners();
        },
      ),
    );
  }

  bool _interstitialAllowed(InterstitialBreak at) {
    if (_fullscreenBusy || !adsReady || _interstitial == null) return false;
    final last = _lastInterstitial;
    if (last != null && DateTime.now().difference(last) < interstitialGap) {
      return false;
    }
    if (at == InterstitialBreak.hub) {
      // Backing out of the map with no fight finished is not a pause.
      if ((Game.i.run?.combatClears ?? 0) < 1) return false;
    }
    if (at == InterstitialBreak.combat) {
      final clears = Game.i.run?.combatClears ?? 0;
      if (clears < combatsPerInterstitial ||
          clears % combatsPerInterstitial != 0) {
        return false;
      }
    }
    return true;
  }

  /// Full-screen ad at a finished beat. The caller awaits so navigation waits.
  Future<void> showInterstitialIfDue([
    InterstitialBreak at = InterstitialBreak.runEnd,
  ]) async {
    if (!_interstitialAllowed(at)) return;
    _fullscreenBusy = true;

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
      await finished.future;
    } catch (_) {
      ad.dispose();
    } finally {
      _fullscreenBusy = false;
      notifyListeners();
      _loadInterstitial();
    }
  }

  /// Optional rewarded video. Returns true only if the player earned the gift.
  Future<bool> showRewarded({required VoidCallback onEarned}) async {
    if (!rewardedReady) {
      _loadRewarded();
      return false;
    }
    _fullscreenBusy = true;
    final ad = _rewarded!;
    _rewarded = null;
    notifyListeners();
    final session = RewardedSession(onEarned);

    ad.fullScreenContentCallback = FullScreenContentCallback<RewardedAd>(
      onAdDismissedFullScreenContent: (value) {
        value.dispose();
        session.close();
      },
      onAdFailedToShowFullScreenContent: (value, _) {
        value.dispose();
        session.close();
      },
    );
    try {
      // A rewarded video is already a full-screen impression. Stamp the
      // interstitial clock so Continue does not fire another ad immediately.
      _lastInterstitial = DateTime.now();
      await ad.show(
        onUserEarnedReward: (_, __) {
          session.earn();
        },
      );
      return await session.finished;
    } catch (_) {
      ad.dispose();
      session.close();
      return await session.finished;
    } finally {
      _lastInterstitial = DateTime.now();
      _fullscreenBusy = false;
      notifyListeners();
      _loadRewarded();
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

  @visibleForTesting
  Future<void> handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != productId) continue;
      if (purchase.productID == productId &&
          (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored)) {
        try {
          await (_persistPurchase ?? Game.i.persistRemoveAds)();
        } catch (_) {
          errorMessage =
              'Purchase could not be saved. Please restore it again.';
          notifyListeners();
          continue;
        }
        _discardAds();
        errorMessage = null;
        notifyListeners();
      } else if (purchase.status == PurchaseStatus.error) {
        errorMessage =
            purchase.error?.message ?? 'The purchase was not completed.';
        notifyListeners();
      }

      if (purchase.pendingCompletePurchase &&
          (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored)) {
        try {
          await (_completePurchase ?? InAppPurchase.instance.completePurchase)(
            purchase,
          );
        } catch (_) {
          // The platform will redeliver an unfinished transaction next launch.
        }
      }
    }
  }

  Future<void> showPrivacyOptions() async {
    if (_fullscreenBusy) return;
    _adsReady = false;
    _discardAds();
    notifyListeners();
    try {
      final dismissed = Completer<void>();
      await ConsentForm.showPrivacyOptionsForm((formError) {
        if (formError != null) {
          errorMessage = 'Privacy options are unavailable right now.';
          notifyListeners();
        }
        if (!dismissed.isCompleted) dismissed.complete();
      });
      await dismissed.future;
      if (await ConsentInformation.instance.canRequestAds()) {
        await MobileAds.instance.initialize();
        _adsReady = true;
        _loadInterstitial();
        _loadRewarded();
      }
      notifyListeners();
    } catch (_) {
      errorMessage = 'Privacy options are unavailable right now.';
      notifyListeners();
    }
  }

  void _discardAds() {
    _adGeneration++;
    _interstitial?.dispose();
    _rewarded?.dispose();
    _interstitial = null;
    _rewarded = null;
    _loadingInterstitial = false;
    _loadingRewarded = false;
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    _interstitial?.dispose();
    _rewarded?.dispose();
    super.dispose();
  }
}
