# TODO

## Current Release Gate Snapshot

- [x] Verify current local static checks.
  - `flutter analyze` passes.
  - `flutter test` passes.
- [x] Confirm current platform submission baselines.
  - Android target SDK is explicitly set to 35, matching the current Google Play API 35+ requirement for new apps and updates.
  - Local Xcode is 26.5, matching Apple's current App Store Connect upload baseline of Xcode 26 / iOS 26 SDK or later.
- [x] Verify the public privacy URL.
  - `https://maskedsyntax.com/patterns/privacy` redirects to `https://www.maskedsyntax.com/patterns/privacy` and returns HTTP 200.
- [ ] Produce a signed Android Play artifact.
  - `flutter build appbundle` currently fails because `android/key.properties` is missing.
- [ ] Produce and validate a signed iOS archive through App Store Connect/TestFlight.
- [ ] Complete real-device smoke testing on Android and iOS.
  - Cover journal create/edit/delete, OCD create/delete, analytics refresh, import, export, privacy link, wipe data, app restart, and document provider behavior.
- [ ] Complete store-console submission tasks.
  - Apple App Privacy answers.
  - Google Play Data Safety answers.
  - Google Play health app declaration.
  - Age rating, category, support URL, marketing URL, screenshots, and review notes.

## Mobile Store Submission Blockers

- [ ] Generate and configure the Android platform project.
  - [x] Add the `android/` directory.
  - [x] Set a production-shaped `applicationId`.
  - [x] Configure the base Android manifest and build files.
  - [ ] Configure production release signing.
  - [x] Confirm min/target SDK against current Play requirements.
    - Android target SDK is explicitly set to 35.
  - [x] Add Android launcher icons and adaptive icon assets.

- [ ] Replace the desktop SQLite setup with a mobile-safe database setup.
  - [x] Stop using `sqflite_common_ffi` as the app database path on Android/iOS.
  - [x] Use the normal mobile `sqflite` plugin or a platform-aware database abstraction.
  - [ ] Verify journal, OCD event, import, and export flows on real Android and iOS devices.

- [ ] Replace the iOS placeholder bundle identifier.
  - [x] Change `com.example.patterns` to `com.maskedsyntax.patterns`.
  - [ ] Confirm the final App Store bundle ID with the Apple Developer account.
  - [ ] Confirm the Apple Developer Team ID and provisioning setup.
  - [ ] Validate a real device/archive build, not only the simulator build.

- [ ] Add privacy and health-policy readiness.
  - [ ] Publish a privacy policy URL.
  - [x] Add in-app privacy and safety text.
  - [x] Update the website privacy page with what journal/OCD/distress data is stored, whether it leaves the device, retention, deletion, and backup behavior.
  - [ ] Prepare Apple App Privacy answers in App Store Connect.
  - [ ] Prepare Google Play Data Safety answers in Play Console.
  - [ ] Complete Google Play health app declaration as needed.
  - [x] Add clear non-medical/self-reflection positioning and avoid diagnosis or treatment claims.

## Functional Gaps

- [x] Persist onboarding completion.
  - `_hasStarted` is currently memory-only, so the welcome screen returns after relaunch.

- [x] Persist theme selection.
  - Theme mode currently resets after app restart.

- [x] Finish backup behavior.
  - Removed the "Future" backup option from the shipped settings UI.
  - Decide whether backups are local-only, cloud-based, or manual export/import only.

- [ ] Harden import/export on mobile.
  - [ ] Verify `FilePicker` save/import behavior on Android scoped storage and iOS document providers.
  - [x] Avoid relying on fragile direct file paths where mobile platforms return content/document handles.
    - Mobile import now reads selected backup bytes via `FilePicker` instead of assuming a local path.
    - Export now passes JSON bytes to `FilePicker.saveFile`, which is required for Android/iOS save flows.
  - [x] Add backup schema/version validation.
  - [x] Improve malformed-file errors.
  - [x] Add a safer import preview before destructive overwrite.

- [x] Expose user data controls for OCD entries.
  - [x] Add clear edit actions in the tracker UI.
  - [x] Add clear delete actions in the tracker UI.
  - [x] Make sure sensitive user-entered OCD data can be removed from the app.

- [x] Add app-level privacy protection if desired for launch quality.
  - [x] Add optional device passcode/biometric app lock.
  - [x] Add privacy screen behavior when the app is backgrounded.

## Store Assets And Metadata

- [x] Replace default/template launcher icons with final production icons.
  - Generated Android adaptive icons and refreshed iOS/macOS launcher icons from `assets/logo.png`.
- [x] Customize the iOS launch screen.
  - The launch storyboard is themed and unsigned archive validation no longer reports the default launch image warning.
- [ ] Prepare App Store and Play Store screenshots.
- [ ] Prepare support URL, marketing URL, privacy URL, age rating, and app category.
- [x] Update README and public-facing copy to describe the mobile product accurately.
- [x] Add data deletion and data retention language to the website privacy page and in-app privacy copy.

## Dependency And Build Hygiene

- [ ] Remove unused or desktop-only dependencies from the mobile app.
  - [x] Remove `window_manager`.
  - [x] Remove `flutter_quill`.
  - [x] Remove `flutter_markdown_plus`.
  - [x] Remove `flutter_heatmap_calendar`.
  - [x] Remove unused `package_info_plus`.

- [x] Audit native plugin privacy declarations.
  - [x] Account for `file_picker`, `path_provider`, `shared_preferences`, `sqflite`, `url_launcher`, `local_auth`, and transitive native plugins.
    - iOS pods include privacy resources for `file_picker`, `shared_preferences_foundation`, `sqflite_darwin`, `url_launcher_ios`, and `local_auth_darwin`.
    - `shared_preferences_foundation` declares UserDefaults required-reason API usage.
    - `file_picker` pulls `DKImagePickerController`, `DKPhotoGallery`, `SDWebImage`, and `SwiftyGif`; those pods include privacy manifests in the installed pod sources.
  - [x] Remove unused plugins before preparing store privacy answers.

- [ ] Add release verification.
  - [x] Run `flutter analyze`.
  - [x] Run tests.
  - [x] Build Android debug artifact.
  - [x] Build iOS simulator app.
  - [x] Build Android release-format app bundle.
  - [x] Build unsigned iOS archive.
  - [ ] Configure production Android signing.
  - [ ] Build signed Android release artifact.
  - [ ] Build signed iOS archive.
  - Smoke test on real Android and iOS devices.

## Desktop Animation Parity

- [ ] Implement mobile-quality animations in the desktop app.
  - [ ] Staggered list entrance effects (`FadeSlideIn`) for all list views.
  - [ ] Pulse animations for the welcome/onboarding experience.
  - [ ] Tactile "Press Scaling" feedback (`PressScale`) for interactive cards and buttons.
  - [ ] Smooth icon morphing/scaling in primary action buttons using `AnimatedSwitcher`.
  - [ ] Interpolated "Animated Counters" for insights and analytics values.
  - [ ] Fluid navigation transitions (Fade-through and Shared Axis) for tab switching and filtering.
  - [ ] Smooth indicator animations for navigation elements.
  - [ ] Contextual FAB animations (slide/fade) based on scroll or screen state.
  - [ ] Animated search bar transitions (expand/collapse).
  - [ ] Responsive transitions for the entry editor (Saving/Saved states).

## Support Us / Tip Jar IAP

### Pre-flight (App Store Connect)

- [x] Sign Paid Apps Agreement (active May 19, 2026).
- [x] Add banking (HDFC, INR account, USD royalty conversion).
- [x] Submit tax forms (W-8BEN + U.S. Certificate of Foreign Status of Beneficial Owner).
- [x] Enroll in Apple Small Business Program (15% commission from next quarter).
- [x] Create three consumable in-app purchases in App Store Connect.
  - `com.maskedsyntax.patterns.tip.small` — $1.99 — "Small Tip" / "A small thank you for the team"
  - `com.maskedsyntax.patterns.tip.medium` — $4.99 — "Medium Tip" / "A generous thank you for the team"
  - `com.maskedsyntax.patterns.tip.large` — $9.99 — "Large Tip" / "An incredibly generous show of support"
- [ ] Create at least two sandbox tester accounts (US + India regions) under Users and Access > Sandbox > Test Accounts.

### Flutter implementation

- [x] Add `in_app_purchase: ^3.2.0` to `pubspec.yaml`.
- [x] Create `lib/services/tip_jar.dart`.
  - Wrap `InAppPurchase.instance` with availability check, product query, purchase initiation, and `purchaseStream` listener.
  - Hardcode the three product IDs as constants.
  - Always call `completePurchase()` on `PurchaseStatus.purchased` to avoid stuck transactions.
  - Subscription is initialized at app startup via `TipJarService.init()` from `main.dart` so pending purchases from a previous session are completed.
- [x] Create `lib/widgets/tip_jar_sheet.dart`.
  - Three tip rows showing live localized prices from `ProductDetails.price` (never hardcode currency strings).
  - Loading state while products are fetched, error state with retry, disabled state during in-flight purchase.
- [x] Create `lib/widgets/tip_thanks_dialog.dart` for the post-purchase confirmation.
- [x] Add a "Support Patterns" tile to `lib/screens/settings_screen.dart` and `lib/mobile/screens/settings_screen.dart`.
  - macOS desktop uses the IAP tip jar; Windows and Linux desktop show a "Sponsor on GitHub" tile that opens the GitHub Sponsors page in the browser.
- [x] Wire GitHub Sponsors for Windows and Linux.
  - GitHub Sponsors profile live at https://github.com/sponsors/maskedsyntax.
  - Added `.github/FUNDING.yml` so the repo page shows a Sponsor button.
  - Added a Sponsor badge to the README badges row.
- [x] Verify `com.apple.security.network.client` is enabled in `macos/Runner/Release.entitlements` and `DebugProfile.entitlements`.
  - Debug already had it; added to Release for IAP traffic in Mac App Store builds.

### Sandbox testing

- [ ] Sign a test device into a sandbox tester account (Settings > App Store > Sandbox Account).
- [ ] Verify the tip sheet opens and all three products load with localized prices.
- [ ] Verify successful purchase flow for each tier.
- [ ] Verify multiple tips in a row succeed (consumable behavior).
- [ ] Verify cancel and Touch ID denial paths are silent (no error noise).
- [ ] Verify network-failure handling.
- [ ] Verify the tile is hidden when `InAppPurchase.isAvailable` returns false.
- [ ] Verify INR prices display correctly when signed into an India sandbox tester.

### App Store review submission

- [ ] Capture review screenshots of the live tip sheet (one per IAP or one combined image).
- [ ] Fill the Review Information section on each of the three IAPs in App Store Connect (screenshot + review notes).
- [ ] Bump app version to 1.1.4 in `pubspec.yaml`.
- [ ] Attach all three IAPs to the new app version in App Store Connect.
- [ ] Upload build, submit for review.

### Google Play (deferred until Android launch)

- [ ] Complete Google Play payments profile (bank + tax info) when ready to ship on Android.
- [ ] Create matching consumable products in Play Console using the same product IDs.
- [ ] Re-test the same Flutter flow on Android using a Play Console license tester.

## Submission & Compliance Gaps

- [x] Add Semantics labels to all interactive cards for VoiceOver/TalkBack support.
- [x] Add a direct link to the external Privacy Policy URL in the Settings privacy sheet.
- [x] Explicitly state "No Third-Party Sharing" in the privacy text.
- [x] Confirm Android targetSdkVersion is set to 34 or higher.
  - Android target SDK is explicitly set to 35.
- [x] Replace default iOS Launch Screen storyboard with a themed version.
- [x] Add a "Wipe All Data" button in Settings (Compliance: Apple 5.1.1).
- [x] Move/Duplicate medical disclaimer to the Welcome Screen (Compliance: Health Policy).
- [x] Add unencrypted data warning to the Export flow.
- [x] Verify iOS Info.plist usage descriptions for FilePicker.
  - FilePicker uses document picker flows; no protected-resource usage string is needed for the current import/export behavior.
  - Enabled opening documents in place for iOS document handling.
- [ ] Audit for iPad-specific screenshots and UI scaling.
  - [x] Constrain the app shell to a phone-like readable width on large screens.
  - [ ] Capture App Store iPad screenshots after final visual assets are ready.
- [ ] Complete Google Play "Health App" declaration.
  - Play Console task; cannot be completed in code.
