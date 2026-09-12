# Aeonfall production listing — 2026-09-12

Prepared from the current working-tree source, including existing uncommitted changes. Only this document was created. No build, runtime test, upload, Console change, or git commit was performed. Source version: `2.2.3+14`; Android application ID: `com.aeonfall.game`. The existing AAB was not inspected or verified to match this source.

Copy only the text inside each field's code fence into its corresponding store field. Internal evidence and release-form notes are not public listing copy.

## English store listing

### Title

```text
Aeonfall: Roguelike RPG
```

### Short description

```text
Build your deck. Defy the Author. Shape your ending in a dark fantasy roguelike.
```

### Full description

```text
The world is a story. Its Author keeps starting over. How will you end it?

Aeonfall is a dark fantasy roguelike RPG built around tactical card battles, illustrated storytelling, and choices that shape your ending. Build a deck of Frames, find powerful relics, and climb three Acts of branching paths. A fallen run ends, but the Aeon Shards you earn can strengthen the next attempt.

BUILD A DECK THAT FIGHTS YOUR WAY
Spend Energy to attack, defend, and combine card effects in turn-based battles. Read enemy intent before committing your hand. Add new Frames, upgrade your cards, and use relics and potions to support your strategy.

TURN ELEMENTS INTO A CINEMATIC
Play matching elemental Frames in one turn to unleash your Vessel's signature Cinematic. Burn your enemies, build your defenses, or chain rapid attacks. Plan the turn that changes the fight.

DISCOVER SIX VESSELS
Begin with Vyn, Coralis, or Kai. Unlock Nyx and Solenne with Aeon Shards, and reach Act III to unlock Orin. Each Vessel brings a distinct starting deck, relic, and signature move.

CHOOSE YOUR ROUTE AND YOUR RISKS
Navigate branching maps through battles, elite encounters, story events, markets, rest sites, and treasure. Prepare for the boss at the end of each Act. The next path is your decision.

SHAPE THE LAST PAGE
Meet companions and call on their aid in battle. Gather pages, make merciful or cruel choices, and discover different endings shaped by what you did and who stayed beside you. Revisit your journey with The Story So Far and the Codex.

RETURN WITH MORE THAN A MEMORY
Spend Aeon Shards in the Sanctum on permanent upgrades and Vessel unlocks. Wins raise Ascension, adding tougher rules for future runs. Try another deck, another route, and another ending.

Core gameplay works offline, with progress saved on your device. Advertising and Google Play purchases require a connection. The game contains interstitial ads and optional rewarded ads, plus a one-time Remove Ads purchase that disables both ad formats. Store availability applies.

Choose your Vessel. Take the next Frame. Face the Author.
```

## Indonesian store listing

This translates the listing only. Reviewed UI and narrative text are English; Indonesian in-game localization was not found. The Indonesian description states this explicitly.

### Title

```text
Aeonfall: Roguelike RPG
```

### Short description

```text
Racik dek, tantang Penulis, dan tentukan akhir kisah roguelike fantasi gelap.
```

### Full description

```text
Dunia ini adalah sebuah cerita. Sang Penulis terus mengulangnya. Bagaimana kamu akan mengakhirinya?

Aeonfall adalah RPG roguelike fantasi gelap dengan pertarungan kartu taktis, kisah berilustrasi, dan pilihan yang membentuk akhir ceritamu. Racik dek Frame, temukan relik kuat, dan jelajahi jalur bercabang dalam tiga Babak. Saat kamu tumbang, petualangan berakhir, tetapi Aeon Shard yang diperoleh bisa memperkuat percobaan berikutnya.

RACIK DEK SESUAI GAYA BERTARUNGMU
Gunakan Energy untuk menyerang, bertahan, dan memadukan efek kartu dalam pertarungan bergiliran. Baca niat musuh sebelum memainkan kartu. Tambahkan Frame baru, tingkatkan kartu, serta manfaatkan relik dan ramuan untuk mendukung strategimu.

LEPASKAN SERANGAN CINEMATIC
Mainkan Frame berelemen sama dalam satu giliran untuk memicu Cinematic khas Vessel-mu. Bakar musuh, perkuat pertahanan, atau rangkai serangan cepat. Rencanakan giliran yang mengubah jalannya pertarungan.

KENALI ENAM VESSEL
Mulai bersama Vyn, Coralis, atau Kai. Buka Nyx dan Solenne dengan Aeon Shard, lalu capai Babak III untuk membuka Orin. Setiap Vessel memiliki dek awal, relik, dan jurus khas yang berbeda.

PILIH JALUR DAN RISIKOMU
Susuri peta bercabang berisi pertarungan, musuh elite, peristiwa cerita, pasar, tempat istirahat, dan harta. Persiapkan diri menghadapi bos di akhir setiap Babak. Kamu yang menentukan jalur berikutnya.

BENTUK HALAMAN TERAKHIR
Temui rekan perjalanan dan panggil bantuan mereka saat bertarung. Kumpulkan halaman, pilih belas kasih atau kekejaman, dan temukan akhir berbeda berdasarkan tindakanmu serta siapa yang tetap menemanimu. Ikuti kembali kisahmu melalui The Story So Far dan Codex.

KEMBALI DENGAN BEKAL BARU
Belanjakan Aeon Shard di Sanctum untuk peningkatan permanen dan membuka Vessel. Kemenangan menaikkan Ascension, dengan aturan yang lebih menantang untuk petualangan selanjutnya. Coba dek lain, jalur lain, dan akhir cerita lain.

Permainan utama dapat dimainkan tanpa internet, dengan progres disimpan di perangkat. Iklan dan pembelian Google Play memerlukan koneksi. Game memuat iklan interstisial dan iklan berhadiah opsional, serta pembelian Remove Ads satu kali untuk menonaktifkan kedua jenis iklan. Bergantung pada ketersediaan di toko.

Teks permainan dan cerita tersedia dalam bahasa Inggris.

Pilih Vessel-mu. Mainkan Frame berikutnya. Hadapi Sang Penulis.
```

## Eight gameplay hooks

Use as screenshot or promotional headlines alongside matching gameplay captures. These are alternatives for creative assets, not extra store-description fields.

| # | English headline | Indonesian headline | Source basis / capture guidance |
| --- | --- | --- | --- |
| 1 | Read Their Intent. Plan Your Turn. | Baca Niat Musuh. Rencanakan Giliranmu. | `lib/engine/battle.dart`: intent generation and `intentInfos()`; show intent badges and the card hand. |
| 2 | Build a Deck Worth Another Run. | Racik Dek untuk Petualangan Berikutnya. | `lib/ui/reward_screen.dart`, `lib/engine/director.dart`: card rewards and upgrades. Decks belong to individual runs; do not imply the deck carries over. |
| 3 | Match Elements. Unleash Your Cinematic. | Padukan Elemen. Lepaskan Cinematic. | `lib/engine/battle.dart`: `_checkCinematic()` and `_fireCinematic()`; three matching non-neutral Frames normally, four at Ascension 10+. |
| 4 | Six Vessels. Find Your Fighting Style. | Enam Vessel. Temukan Gaya Bertarungmu. | `lib/data/vessels.dart`, `lib/engine/run_state.dart`, `lib/ui/hub.dart`, `lib/game.dart`: six definitions, three starting options, three unlocks. |
| 5 | Three Acts. Choose Your Way to the Boss. | Tiga Babak. Pilih Jalan Menuju Bos. | `lib/engine/map_gen.dart`, `lib/engine/director.dart`, `lib/game.dart`: generated branching maps, Act progression, bosses. |
| 6 | Bring a Companion Into the Fight. | Panggil Rekanmu dalam Pertarungan. | `lib/engine/director.dart`: recruitment; `lib/engine/battle.dart`: `aidAvailable()` and `useAid()`, once per companion per fight when eligible. These are NPC companions, not multiplayer. |
| 7 | Your Choices Shape the Last Page. | Pilihanmu Membentuk Halaman Terakhir. | `lib/engine/director.dart`: `pickEnding()` evaluates final choice, mercy, cruelty, pages, companions, and flags; `lib/data/endings.dart`. |
| 8 | Fall. Upgrade. Face the Next Ascension. | Tumbang. Perkuat Diri. Hadapi Ascension. | `lib/game.dart`: Shard awards and win-based Ascension; `lib/ui/hub.dart`: permanent upgrades; `lib/data/ascension.dart`: escalating rules. Only wins raise Ascension. |

## Public release notes

Snapshot-based production notes, not a verified changelog against the live release. Avoid adding “new,” “improved,” or “fixed” without a confirmed comparison. Use these only for a build confirmed to contain the reviewed features. Both locale bodies are under 500 characters.

### English release notes

```text
Face the Author in three Acts of tactical card battles and branching story choices. Discover six Vessels, recruit companions, and build lasting strength with Sanctum upgrades. Optional rewarded ads offer extra resources. A one-time Remove Ads purchase disables interstitial and rewarded ads; purchase restoration is available.
```

### Indonesian release notes

```text
Hadapi Sang Penulis dalam tiga Babak pertarungan kartu taktis dan pilihan cerita bercabang. Kenali enam Vessel, rekrut rekan, dan perkuat diri dengan peningkatan Sanctum. Iklan berhadiah opsional memberi sumber daya tambahan. Pembelian Remove Ads satu kali menonaktifkan iklan interstisial dan berhadiah; pemulihan pembelian tersedia. Teks permainan berbahasa Inggris.
```

## Internal release-form notes

| Field / topic | Source-supported note | Uncertainty before submission |
| --- | --- | --- |
| Store title | Use **Aeonfall: Roguelike RPG** as chosen. Persistent upgrades make “roguelite” a useful internal description, while the chosen title retains the broader genre keyword. | `android/app/src/main/AndroidManifest.xml` still labels the app “Aeonfall: Storyboard RPG”; the local privacy policy also uses that name. Those files were left untouched. |
| Version / release name | `pubspec.yaml` declares `2.2.3+14`. Suggested internal release name: `2.2.3 (14) — production`. Application ID comes from `android/app/build.gradle.kts`. | Confirm actual uploaded bundle version, package, signing, and contents in Console. Source values and an AAB filename do not establish artifact identity or production status. |
| Category | Suggested category: Game / Role Playing; card battles and strategy are useful discovery concepts. | This is editorial positioning, not a verified existing Console selection or ranking claim. |
| App access | No app-owned login/account flow found in the reviewed game flow. Core play starts locally. | Google Play is needed for purchase/restore. Character unlocks are progression gates, not account gates. Complete reviewer access answers against the submitted build. |
| Contains ads | **Yes.** Interstitial and rewarded AdMob integration is present, with production unit IDs selected in release mode. | Live ad serving, account approval, mediation, regional availability, and consent-message configuration were not checked. |
| In-app purchases | A single queried product, `remove_ads`, uses `buyNonConsumable`. It disables interstitial and rewarded display eligibility. Restore runs at initialization and is exposed in the purchase panel. | Product activation, countries, price, and successful purchase/restore were not verified. The UI's `$4.99` fallback is not proof of the live price. No subscription product was found in this integration. |
| Rewarded ads | Sanctum: 25 Shards per successful watch, with a locally tracked limit of three per day. Combat reward screen: 35 run gold/Aeon when the reward is earned. | Ad availability is not guaranteed. Do not describe all advertising as opt-in: interstitials are automatic when eligible. |
| Interstitial timing | Four-minute session gap; combat break eligibility at every third recorded combat clear; Act-clear, return-to-hub, and run-end paths also exist. Rewarded display stamps the interstitial clock. | This is code scheduling, not measured delivery frequency. Counters and ad availability affect whether an ad actually appears. |
| Offline / saves | `lib/game.dart` stores metadata and run state using SharedPreferences. Bundled art/audio and local battle/map logic support offline core play. | No offline device test performed. Do not promise cloud sync, cross-device gameplay saves, or exact mid-turn restoration. Purchase restoration is separate from save restoration. |
| Language | Reviewed gameplay and story strings are English. | Indonesian copy localizes the store entry only. |
| Content rating / audience | Source includes combat, death, curses, cruelty choices, and dark fantasy narrative. Local policy says the app is not directed to under-13s. | No final age rating or audience declaration is established by source. Complete the actual rating questionnaire from the shipped visuals/text; verify Console and ad audience settings. Do not claim a child-directed ad configuration based on policy prose. |

## Data safety: factual preparation notes, not completed declarations

### App-owned data and integrations

- `lib/game.dart` and `lib/engine/run_state.dart` persist progress, recent run history, settings, Shards, reward-watch counters, and the ad-free entitlement locally. No developer-operated account, cloud-save backend, or gameplay upload call was found in the reviewed `lib` code. Local storage alone does not establish what embedded SDKs transmit.
- `pubspec.lock` resolves `google_mobile_ads` to **9.1.0**, `in_app_purchase` to **3.3.0**, and `in_app_purchase_android` to **0.5.2**. These are Flutter package versions, not verified native SDK versions in the production bundle.
- Android consent code requests UMP consent information, loads a form when required, and checks `canRequestAds()` before Mobile Ads initialization. The hub exposes `showPrivacyOptions()`. This establishes implementation intent, not confirmation that deployed messages, region handling, or user choices work correctly.
- `adsRemoved` gates loading/display eligibility, but `_initializeAds()` does not exit before consent and SDK initialization merely because ads were purchased away. Do not promise that Remove Ads stops every SDK data transfer or consent-related request.
- Billing code queries product details, buys/restores the entitlement, receives purchase updates, and completes pending purchases. It persists an `adsRemoved` boolean. No developer-server receipt upload or server-side purchase validation is shown. Do not claim independent receipt validation or that no purchase-related data is processed.
- The app-owned manifest requests internet access; it does not explicitly request camera, microphone, or location access. Transitive SDK permissions require checking the merged production manifest. IP-derived approximate location does not require a GPS permission.

### AdMob disclosure baseline

Google's current SDK guidance describes automatic collection and sharing of IP addresses, product interactions, diagnostics, and device/account identifiers for advertising, analytics, and fraud prevention. It states SDK data uses TLS in transit. The page covers the latest native SDK; verify its applicability to the submitted dependency graph. [Google Mobile Ads data disclosure](https://developers.google.com/admob/android/privacy/play-data-disclosure) (reviewed 2026-09-12).

The following are candidate Play form mappings, not final selections:

| Candidate data type | Evidence and proposed treatment | What remains unresolved |
| --- | --- | --- |
| Location → Approximate location | Ad SDK IP processing can infer general location. Include this in collection/sharing review. | Actual production SDK/configuration and the applicable Console mapping. No evidence of app-owned precise-location collection. |
| App activity → App interactions | SDK interaction events warrant collection/sharing review. | Exact enabled events and purposes in the shipped SDK and any ad partners. |
| App info and performance → Diagnostics / other performance data | SDK performance telemetry warrants collection/sharing review. | Select precise subtypes, including crash logs only if applicable to the shipped SDK; no separate Crashlytics/Sentry integration was found. |
| Device or other IDs | Advertising/app-set identifiers warrant collection/sharing review. | Merged `AD_ID` permission, native SDK behavior, consent/limited-ad settings, and other identifier use. |
| Financial info → Purchase history | Purchase and restore processing warrants a Billing-specific assessment for app functionality. | Determine off-device flows and applicable sharing exceptions using the shipped Billing SDK's disclosures and current Play definitions. A locally stored entitlement does not alone settle this answer. |
| Financial info → User payment info | Reviewed Dart code does not collect card numbers or billing credentials; the payment flow is handled through Google Play. | Assess the actual integration boundary; do not infer that the app receives payment credentials merely because it sells an upgrade. |
| Personal info → User IDs | No app-owned account/user ID system found. | Check SDK-related identifiers and their correct form category; Google Play account use is not evidence of an app-owned login. |

Do not select “no data collected” based on offline gameplay. Use the SDK baseline for the ad-related collected/shared assessment. Final flags must account for the exact deployed SDKs, configuration, and applicable Play definitions.

### Remaining form answers and policy alignment

- **Purposes:** Advertising/marketing, analytics, and fraud prevention/security are candidate ad-SDK purposes. Purchase restoration supports app functionality. Verify purposes per data type rather than applying every purpose to every row.
- **Required versus optional:** Rewarded viewing is optional, but SDK initialization and eligible interstitials are not triggered solely by a rewarded-view choice. Neither an ad-free purchase nor non-personalized ads proves all collection is optional. Confirm actual controls and data flows before choosing form flags.
- **Ephemeral processing:** Retention was not established from this app source. Do not mark data ephemeral solely because Dart does not save it.
- **Encryption in transit:** The cited Google page supports TLS for that SDK's data. An app-wide “all data encrypted in transit” answer still needs confirmation for Billing, consent, and any configured ad partners in the production build.
- **Deletion / accounts:** No app account creation/deletion flow was found. Clearing app storage removes local progress/settings; it is not a purchase refund, revocation, or deletion of Google's records. Confirm OS backup behavior, applicable no-account form options, and provider deletion/retention controls. No developer-hosted data-deletion endpoint was found.
- **Privacy policy:** The code links to [the configured Aeonfall privacy policy](https://fareza777.github.io/aeonfall-storyboard-roguelike/privacy-policy.html). Only the local `docs/privacy-policy.html` content was read; live availability and deployment parity were not verified. It lists `fajar.mreza@gmail.com` for support/privacy contact; verify ownership and inbox monitoring before submission.
- **Known wording issue:** The local policy calls interstitial and rewarded advertising “optional,” whereas code permits automatic interstitials. Align that wording with actual behavior before publishing the policy. It also uses the older store title and asserts audience/ad configuration that cannot be confirmed locally. No policy edits were made in this task.
- **External settings still needed:** Verify the bundle's merged permissions/native dependencies, active Billing product, UMP messages and privacy-options behavior, AdMob partners/mediation and audience settings, live policy, and current Console data-safety questions. The Play Console Help data-safety page could not be retrieved during this review; no claim of a completed policy audit is made.

## Source evidence for listing claims

Paths below are relative to the Aeonfall project root; they identify implementation read for this document rather than evidence of a tested release.

| Claim | Implementation evidence |
| --- | --- |
| Turn-based deckbuilding, enemy intent, Cinematics | `lib/engine/battle.dart`: turn flow, card resolution, intent reporting, `_checkCinematic()`, `_fireCinematic()`; `lib/data/ascension.dart`: threshold changes. |
| Six distinct Vessels, three initially available | `lib/data/vessels.dart`; `lib/engine/run_state.dart`: starting `vessels`; `lib/ui/hub.dart`: Nyx/Solenne unlocks; `lib/game.dart`: Orin unlock on reaching Act III. |
| Branching three-Act progression | `lib/engine/map_gen.dart`: node types and generation; `lib/engine/director.dart`: run/Act flow; `lib/game.dart`: Act progression. |
| Story decisions and multiple endings | `lib/engine/director.dart`: `pickEnding()` and `finaleChoices()`; `lib/data/endings.dart`; `lib/ui/story_sheet.dart`: The Story So Far. |
| Companions with battle assistance | `lib/engine/director.dart`: recruitment; `lib/engine/battle.dart`: `useAid()` and eligibility. |
| Permanent upgrades and escalating difficulty | `lib/ui/hub.dart`: `_upgrades`; `lib/engine/run_state.dart`: upgrade effects; `lib/game.dart`: Shard awards and Ascension cap of 20; `lib/data/ascension.dart`: rules. |
| Ads, rewards, removal and restoration | `lib/monetization/monetization_service.dart`, `ad_widgets.dart`, `purchase_panel.dart`; `lib/ui/reward_screen.dart`, `map_screen.dart`, `hub.dart`; `lib/ui/splash.dart`: initialization. |
| Local persistence and network boundaries | `lib/game.dart`, `lib/engine/run_state.dart`, `lib/main.dart`, `pubspec.yaml`, `pubspec.lock`, `android/app/src/main/AndroidManifest.xml`. |

No awards, ranks, download totals, multiplayer, AI-generated live stories, unlimited content, guaranteed unique runs, or unverified performance improvements are claimed.
