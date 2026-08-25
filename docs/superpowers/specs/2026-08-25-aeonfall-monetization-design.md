# Aeonfall Monetization Design

## Goal

Add policy-compliant AdMob monetization and a permanent Google Play Billing
upgrade without interrupting battles, map navigation, story events, or the
opening flow.

## Decisions

- The app remains playable offline and has no account or cloud-save system.
- `google_mobile_ads` is initialized after UMP consent handling.
- A single adaptive banner may appear in the Sanctum/Hub surface.
- A single interstitial may appear only after a completed or failed run, when
  the player explicitly returns to the Sanctum.
- No ads appear during gameplay, at splash, onboarding, map traversal, story
  events, shops, or at the beginning of a level.
- `aeonfall_remove_ads` is a non-consumable product. The entitlement is
  persisted in `MetaState` and restored from Play Billing on every boot.
- Debug builds use Google test ad units; release builds use the configured
  Aeonfall units.

## Failure handling

Ads and billing are best-effort. If consent, network, an ad, or billing is
unavailable, the game continues normally and the player can retry Restore or
Buy from the Sanctum.

## Privacy

The privacy policy describes local save storage, Google Mobile Ads/consent,
Google Play Billing, and how the local save is deleted. The app does not upload
voice recordings, gameplay state, or an account profile.
