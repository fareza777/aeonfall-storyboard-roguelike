import 'dart:async';
import 'dart:convert';

import 'package:aeonfall/game.dart';
import 'package:aeonfall/monetization/monetization_service.dart';
import 'package:aeonfall/monetization/purchase_panel.dart';
import 'package:aeonfall/monetization/rewarded_session.dart';
import 'package:aeonfall/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

PurchaseDetails purchase(PurchaseStatus status, {String id = 'remove_ads'}) =>
    PurchaseDetails(
      productID: id,
      verificationData: PurchaseVerificationData(
        localVerificationData: '',
        serverVerificationData: '',
        source: 'test',
      ),
      transactionDate: null,
      status: status,
    )..pendingCompletePurchase = true;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    // Create the singleton outside a widget test's fake clock zone.
    Game.i.meta.adsRemoved = false;
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final name in ['xyz.luan/audioplayers.global', 'xyz.luan/audioplayers',
      'xyz.luan/audioplayers.global/events',
      'xyz.luan/audioplayers/events/aeon_music',
      'xyz.luan/audioplayers/events/aeon_voice',
      for (var i = 0; i < 6; i++) 'xyz.luan/audioplayers/events/aeon_sfx_$i']) {
      messenger.setMockMethodCallHandler(MethodChannel(name), (_) async => null);
    }
  });

  test(
    'reward grants once immediately but navigation waits for dismissal',
    () async {
      var grants = 0;
      var finished = false;
      final session = RewardedSession(() => grants++);
      session.finished.then((_) => finished = true);
      session.earn();
      session.earn();
      await Future<void>.delayed(Duration.zero);
      expect(grants, 1);
      expect(finished, isFalse);
      session.close();
      session.close();
      expect(await session.finished, isTrue);
      expect(grants, 1);
    },
  );

  test('dismissal or show failure without earning grants nothing', () async {
    var grants = 0;
    final session = RewardedSession(() => grants++);
    session.close();
    session.earn();
    expect(await session.finished, isFalse);
    expect(grants, 0);
  });

  test('purchase acknowledgement waits for successful persistence', () async {
    final saved = Completer<void>();
    var acknowledgements = 0;
    final service = MonetizationService.forTesting(
      persistPurchase: () => saved.future,
      completePurchase: (_) async {
        acknowledgements++;
      },
    );
    final processing = service.handlePurchases([
      purchase(PurchaseStatus.purchased),
    ]);
    await Future<void>.delayed(Duration.zero);
    expect(acknowledgements, 0);
    saved.complete();
    await processing;
    expect(acknowledgements, 1);
    service.dispose();
  });

  test(
    'failed persistence remains unacknowledged and restore can retry',
    () async {
      var fail = true;
      var acknowledgements = 0;
      final service = MonetizationService.forTesting(
        persistPurchase: () async {
          if (fail) throw StateError('disk failure');
        },
        completePurchase: (_) async {
          acknowledgements++;
        },
      );
      await service.handlePurchases([purchase(PurchaseStatus.purchased)]);
      expect(acknowledgements, 0);
      expect(service.errorMessage, isNotNull);
      fail = false;
      await service.handlePurchases([purchase(PurchaseStatus.restored)]);
      expect(acknowledgements, 1);
      expect(service.errorMessage, isNull);
      service.dispose();
    },
  );

  test(
    'pending, canceled and unrelated purchases never grant or acknowledge',
    () async {
      var grants = 0;
      var acknowledgements = 0;
      final service = MonetizationService.forTesting(
        persistPurchase: () async {
          grants++;
        },
        completePurchase: (_) async {
          acknowledgements++;
        },
      );
      await service.handlePurchases([
        purchase(PurchaseStatus.pending),
        purchase(PurchaseStatus.canceled),
        purchase(PurchaseStatus.purchased, id: 'unrelated'),
      ]);
      expect(grants, 0);
      expect(acknowledgements, 0);
      service.dispose();
    },
  );

  testWidgets('missing product shows no fabricated price and disables buy', (
    tester,
  ) async {
    Game.i.meta.adsRemoved = false;
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RemoveAdsPanel())),
    );
    expect(find.textContaining(r'$4.99'), findsNothing);
    expect(find.text('UPGRADE UNAVAILABLE'), findsOneWidget);
    expect(tester.widget<AeButton>(find.byType(AeButton)).enabled, isFalse);
  });

  testWidgets(
    'startup purchase waits for metadata then persists without losing progress',
    (tester) async {
      await tester.runAsync(() async {
      SharedPreferences.setMockInitialValues({
        'aeonfall_meta_v1': jsonEncode({'shards': 123, 'adsRemoved': false}),
      });
      var saved = false;
      final persistence = Game.i.persistRemoveAds().then((_) => saved = true);
      await Future<void>.delayed(Duration.zero);
      expect(saved, isFalse);
      unawaited(Game.i.boot());
      await persistence;
      final prefs = await SharedPreferences.getInstance();
      final meta = jsonDecode(prefs.getString('aeonfall_meta_v1')!);
      expect(meta['adsRemoved'], isTrue);
      expect(meta['shards'], 123);
      });
    },
  );
}
