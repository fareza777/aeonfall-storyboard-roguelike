# Aeonfall Release Operations Design

## Build

Release version is `2.2.0+11`. The AAB is signed using the existing ignored
release key configuration. Keystore files, passwords, and local signing config
are never committed.

## Play Console

Create the app, populate the listing and App Content declarations, create the
one-time ad-free product, and upload the AAB to closed testing. Use the same
four Google Groups already active for Vocatim. Stop before production access or
production rollout.

## AdMob and YouTube

Create the Aeonfall AdMob app and two ad units, add conservative frequency
controls, and connect the hosted `app-ads.txt`. Upload the trailer to YouTube
as unlisted and use its URL in the Play listing.

## Verification

Run Flutter tests, static analysis, release AAB build, Remotion typecheck/render,
asset dimension/alpha checks, and a final repository secret/status audit before
commit and push.
