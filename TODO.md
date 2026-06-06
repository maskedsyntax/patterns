# TODO — Android Play Store Release

## 1. Code Fixes

- [x] Enable PDF export on Android.
  - In `lib/widgets/platform.dart`, added `|| Platform.isAndroid` to `isPdfExportSupported`.

- [x] Fix review prompt Android fallback.
  - `openStoreListing()` on Android automatically uses the app's package name — no parameter needed. No code change required; already works.

- [ ] Verify `FilePicker` import/export on Android scoped storage.
  - JSON backup save and restore have not been tested on Android.
  - Test both flows on the emulator: export a backup, wipe data, re-import.

- [ ] Verify PDF export works end-to-end on Android.
  - `ReportExportSaver.save()` falls through to the generic `FilePicker.platform.saveFile` path on Android — confirm it works after enabling the feature flag above.

## 2. Release Signing — DONE

- [x] Generate the Android upload keystore.
  - `/Users/batman/patterns-upload-keystore.jks` (PKCS12, alias `patterns_upload`, CN=Aftaab Siddiqui).
  - Regenerated 2026-06-06 with a fresh password; signing cert SHA256 `EF:4F:C3:4E...`.
  - [ ] Back up the .jks + password to a secure offline location (password manager / encrypted backup).
- [x] Create `android/key.properties` (gitignored).
- [x] Verify `flutter build appbundle` succeeds with the release keystore.
  - Built `build/app/outputs/bundle/release/app-release.aab` (47.7MB).
  - Verified signed with the upload keystore cert, not debug-signed.
  - NOTE: back up the keystore + password securely — losing it means you can never update the app on Play.

## 3. Smoke Testing (Emulator)

- [ ] Journal: create, edit, delete entries.
- [ ] OCD tracker: create, edit, delete events; verify distress slider.
- [ ] Analytics: verify charts render for 7D / 30D / 90D ranges.
- [ ] Export JSON backup, wipe all data, re-import backup — verify data is restored.
- [ ] Export PDF report — verify file saves to device storage.
- [ ] App lock: enable biometric lock, background and reopen the app.
- [ ] Theme toggle: switch between light and dark, restart app, verify it persists.
- [ ] Privacy link in Settings opens `maskedsyntax.com/patterns/privacy`.
- [ ] Wipe all data from Settings — verify entries are gone after restart.

## 4. Play Console Pre-flight

- [ ] Complete the open testing track submission.
  - Preview and confirm the existing open testing release.
  - Send it to Google for review — this is required before IAPs can be created.

- [ ] Set up Play Console Payments profile.
  - `Play Console > Setup > Payments profile`.
  - Add HDFC INR bank account, complete the Indian tax residency form (PAN required).
  - This is a one-time setup covering all apps on the account.

- [ ] Create the three consumable IAP products in Play Console.
  - `Play Console > Monetize > Products > In-app products` (unlocks after first approved release).
  - `com.maskedsyntax.patterns.tip.small` — ₹/$ equivalent of $1.99
  - `com.maskedsyntax.patterns.tip.medium` — ₹/$ equivalent of $4.99
  - `com.maskedsyntax.patterns.tip.large` — ₹/$ equivalent of $9.99
  - Product IDs must match iOS exactly — the Flutter code uses a shared set of constants.

- [ ] Add license testers for IAP sandbox testing.
  - `Play Console > Setup > License testing`.
  - Add real Gmail accounts; those accounts can make test purchases without being charged.

- [ ] Test the tip jar flow on Android with a license tester account.
  - Verify all three tiers load with localized prices.
  - Verify a purchase completes and the thanks dialog appears.
  - Verify cancel is silent.

## 5. Play Console Store Listing & Compliance

- [ ] Complete Google Play Data Safety answers.
  - No data collected, no data shared, users can delete all data from Settings.
  - Privacy policy URL: `https://maskedsyntax.com/patterns/privacy`.

- [ ] Complete Google Play health app declaration.
  - Patterns is for personal reflection/self-tracking; not a regulated medical device.

- [ ] Set content rating via the questionnaire in Play Console.

- [ ] Add support URL and privacy URL to the store listing.

- [ ] Prepare screenshots.
  - At minimum: 2 phone screenshots (required).
  - Recommended: phone + 7-inch tablet + 10-inch tablet.
  - Scenes: welcome, journal editor, OCD tracker, analytics/insights.

- [ ] Review short description and full description in Play Console match the current product.

## 6. Production Release

- [ ] Create a new production release in Play Console.
- [ ] Upload the signed AAB from `flutter build appbundle`.
- [ ] Preview and confirm the release.
- [ ] Send to Google for review.
- [ ] Publish once approved.
