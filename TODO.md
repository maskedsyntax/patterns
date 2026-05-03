# TODO

## Mobile Store Submission Blockers

- [ ] Generate and configure the Android platform project.
  - [x] Add the `android/` directory.
  - [x] Set a production-shaped `applicationId`.
  - [x] Configure the base Android manifest and build files.
  - [ ] Configure production release signing.
  - [x] Confirm min/target SDK against current Play requirements.
    - Android target SDK is explicitly set to 35.
  - [ ] Add Android launcher icons and adaptive icon assets.

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
  - [ ] Avoid relying on fragile direct file paths where mobile platforms return content/document handles.
  - [x] Add backup schema/version validation.
  - [x] Improve malformed-file errors.
  - [ ] Consider a safer import preview before destructive overwrite.

- [ ] Expose user data controls for OCD entries.
  - [ ] Add clear edit actions in the tracker UI.
  - [x] Add clear delete actions in the tracker UI.
  - [x] Make sure sensitive user-entered OCD data can be removed from the app.

- [ ] Add app-level privacy protection if desired for launch quality.
  - Consider passcode or biometric lock.
  - Consider privacy screen behavior when the app is backgrounded.

## Store Assets And Metadata

- [ ] Replace default/template launcher icons with final production icons.
- [x] Customize the iOS launch screen.
  - The launch storyboard is themed and unsigned archive validation no longer reports the default launch image warning.
- [ ] Prepare App Store and Play Store screenshots.
- [ ] Prepare support URL, marketing URL, privacy URL, age rating, and app category.
- [ ] Update README and public-facing copy to describe the mobile product accurately.
- [x] Add data deletion and data retention language to the website privacy page and in-app privacy copy.

## Dependency And Build Hygiene

- [ ] Remove unused or desktop-only dependencies from the mobile app.
  - [x] Remove `window_manager`.
  - [x] Remove `flutter_quill`.
  - [x] Remove `flutter_markdown_plus`.
  - [x] Remove `flutter_heatmap_calendar`.
  - [x] Remove unused `package_info_plus`.

- [ ] Audit native plugin privacy declarations.
  - [ ] Account for `file_picker`, `path_provider`, `shared_preferences`, `sqflite`, `url_launcher`, and transitive native plugins.
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
