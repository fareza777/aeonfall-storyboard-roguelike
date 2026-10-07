# Aeonfall Correctness Release Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the three authorized audit findings and deliver a verified 2.2.6+18 production update and main push.

**Architecture:** Reuse the engine's damage calculation rather than duplicate multipliers. Persist a typed pending reward with offers and claim flags inside RunState, restoring it from the map. Carry Archive's entitlement into run reward generation without breaking old saves.

**Tech Stack:** Flutter 3.44.6, Dart 3.12.2, existing Android release signing and Google Play Console.

**Spec:** `docs/superpowers/specs/2026-10-07-aeonfall-correctness-release.md`.

## Global Constraints

- Do not change other audit findings, artwork, pricing, ad placement or country coverage.
- Preserve existing metadata, unlocks, Shards, purchase entitlement and old run saves.
- Source/build version: 2.2.6+18; applicationId: com.aeonfall.game.
- No force push, credential disclosure or new external access grants.
- Execute inline without additional workflow confirmations; upload/publish/main push are explicitly authorized.

## Review Focus

- Several hits/foes with fewer Wards than attacks must not become zero incoming damage.
- Preview must not consume a real Ward, Guard, momentum or RNG draw.
- Reload after each reward category must not duplicate a benefit or change offered IDs.
- Reload a completed boss reward must not replay the battle or strand the next Act/finale.
- Legacy saves lacking new fields and an Archive purchased during an active run must remain usable.

---

### Task 1: Damage forecast regressions

**Files:** Modify `lib/engine/battle.dart`; create `test/forecast_regression_test.dart`.

**Interfaces:** Consumes existing Battle/play/stepFoes/projectedHit; produces corrected incomingFrom, incomingAfterGuard and previewDamage with their current signatures.

- [ ] Write real-battle tests with hand-derived expectations: A9 strike 7 -> 8; Ward 1 against 3x10 -> 20; Ward 1 and Guard 7 -> 13; Ward shared across foes; Footnote with two other cards -> 10. Include no-preview-side-effects and modifier/rounding checks.
- [ ] Run `C:/flutter/bin/flutter.bat test --no-pub test/forecast_regression_test.dart --reporter expanded`. Expected: the audited A9/Ward/Footnote contracts fail before production changes.
- [ ] Extract scaled raw foe damage used by execution and forecast; use projectedHit for Strength/Weak/etc. Iterate hit-by-hit with a local Ward/Guard balance, handling stealth and piercing. Count Footnote's other cards using `hand.length - (hand.contains(c) ? 1 : 0)`.
- [ ] Run focused tests and the whole repository suite. Expected: all pass, with the already-known offscreen BEGIN test warning documented rather than hidden.
- [ ] Commit the engine fix and its tests.

### Task 2: Durable pending rewards

**Files:** Create `lib/engine/pending_reward.dart`, `test/reward_resume_test.dart`; modify `lib/engine/run_state.dart`, `lib/game.dart`, `lib/ui/reward_screen.dart`, `lib/ui/map_screen.dart`.

**Interfaces:** PendingReward stores act/node ID, gold, screen metadata, card/relic/potion/extra-relic IDs and six claim flags. RunState owns nullable pendingReward and serializes it. RewardScreen uses that state; MapScreen restores it before showing an intro.

- [ ] Drive the actual reward UI, claim 65 gold, encode/decode RunState, reconstruct the screen and tap the row again. Expected gold: 185, not 250. Check card/potion claims, stable offers and map resume separately.
- [ ] Run `C:/flutter/bin/flutter.bat test --no-pub test/reward_resume_test.dart --reporter expanded`. Expected: duplicate/resume tests fail on the old implementation.
- [ ] Add backwards-compatible JSON fields and persist offers once when entering reward. Move claim flags from widget lifetime to the run snapshot. Mark a rewarded callback only once; save the claim and benefit together.
- [ ] Restore pending reward from MapScreen. Clear it only when its node resolves; count combat clears with that resolution. Keep the boss transition behavior and reject stale-node claims.
- [ ] Run focused tests and the whole suite. Expected: gold/card/potion/relic/rewarded state survives restore; old saves and Act transitions still pass.
- [ ] Commit reward persistence and its tests.

### Task 3: Archive upgrade

**Files:** Create `test/archive_regression_test.dart`; modify `lib/engine/run_state.dart`, `lib/engine/director.dart`, and Game's upgrade synchronization if needed.

**Interfaces:** RunState stores Archive's bonus; Director.newRun initializes it, cardReward adds it to Ascension's count and Marrow Die. Game restores/synchronizes an existing entitlement without touching other metadata.

- [ ] Assert literal counts: base 3, Archive 4, Archive+Marrow 5, A19+Archive 3, A19+Archive+Marrow 4. Verify unique IDs, serialization and a legacy run's upgrade entitlement.
- [ ] Run `C:/flutter/bin/flutter.bat test --no-pub test/archive_regression_test.dart --reporter expanded`. Expected: Archive cases fail before the fix.
- [ ] Persist the run bonus with a false/zero legacy default, initialize from MetaState, add it to the generator and synchronize active runs for an owned upgrade. Existing pending offers remain fixed, not rerolled.
- [ ] Run focused tests and the whole suite. Expected: all counts correct with no duplicate offers and legacy progress preserved.
- [ ] Commit Archive fix and its tests.

### Task 4: Verify, package and publish

**Files:** Modify `pubspec.yaml`; add release notes under `docs/releases/2026-10-07-2.2.6.md`. Release binaries stay ignored.

**Interfaces:** Consumes Tasks 1-3 and confirmed Console bundle maximum 17; produces signed com.aeonfall.game versionCode 18/versionName 2.2.6, main commit and production submission.

- [ ] Run whole suite and `C:/flutter/bin/flutter.bat analyze --no-pub`. Expected: no test failures or analyzer issues. Obtain a fresh-context review and address important findings with RED->GREEN tests.
- [ ] Set `version: 2.2.6+18`; record truthful release notes: damage previews, resumed reward claims, Archive reward choices.
- [ ] Build `C:/flutter/bin/flutter.bat build appbundle --release`. Expected: exit 0, signed bundle produced. Inspect bundle manifest/signature/hash, not just the filename.
- [ ] Commit and non-force push the verified changes to origin/main. Expected: remote main matches HEAD.
- [ ] Upload the exact verified bundle to Aeonfall production in the existing account, preserve 178-country coverage and add the truthful notes. Save/review and submit/publish as Console allows. Expected: Console shows version 18 in production submission/review or available status; do not label review as already live.
- [ ] Save final Console proof and report AAB path, commit, tests and exact publishing status.
