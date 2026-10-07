# Aeonfall 2.2.6 correctness release

Implement the first three issues in the audit's **findings table**, as stated
to the user: inaccurate damage forecasts (Ward, Ascension, Footnote), duplicate
reward claims after save/restore, and the Archive upgrade's missing extra choice.
Build a new signed AAB, upload and submit/publish the production update, and push
the verified changes to origin/main. Google review is an external state, not
something this implementation may claim to bypass.

## Requirements

- Do not change other audit findings, artwork, pricing, ad placement or country coverage.
- Preserve existing metadata, unlocks, Shards, purchase entitlement and old run saves.
- Damage previews must share the real attack's scaling/rounding and consume Ward per hit.
- Footnote counts the hand after the played card is removed.
- Save pending reward contents and claim flags with the same run as the granted benefit.
- Resume a pending combat/cache reward instead of replaying combat or rerolling offers.
- Gold, card, potion, relic, extra relic and rewarded gold can each be granted at most once.
- Continuing resolves the node once; pending boss rewards still advance the Act/finale.
- Archive adds one distinct card choice, including with A19 and Marrow Die.
- Update source/build version to 2.2.6+18 only after confirming the Console's highest bundle.
- Verify existing and new tests, static analysis, signed bundle identity and actual Console state.

## Authorization and environment

The user explicitly requested implementation, AAB upload, publishing and push to main.
They previously requested no additional confirmations. The checkout is clean on main,
so work remains in this checkout; no separate worktree or unrelated branch is created.
The existing production release and highest uploaded bundle are 17 (2.2.5), across
178 countries/regions, confirmed in Play Console on 2026-10-07.

Audit reference: `C:/Storyboard Roguelite Claude/audit/2026-10-07/AEONFALL-FULL-AUDIT.md`.
