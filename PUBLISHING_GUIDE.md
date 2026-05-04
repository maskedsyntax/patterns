# Publishing Guide — Patterns

This guide outlines the final steps and metadata required to publish **Patterns** to the Apple App Store and Google Play Store.

## 1. Store Metadata

### App Information
- **Name:** Patterns
- **Subtitle (iOS):** Clarity for the mind
- **Short Description (Android):** Daily journaling and OCD tracking through structured reflection.
- **Category:** Health & Fitness or Medical (Reflection/Self-Tracking)
- **Primary Language:** English

### Descriptions
**Full Description:**
Patterns is a focused application designed for daily journaling and tracking obsessive-compulsive patterns. It provides a clean, private, and minimal space to record your thoughts, behaviors, and emotional trends.

Key Features:
- Daily Journaling: Minimalist writing space for chronological reflection.
- OCD Tracking: Structure tools to document obsessions, compulsions, and distress levels (0-10).
- Local-First Privacy: All data stays on your device. No cloud, no tracking, no third-party sharing.
- Structured Insights: Visualize your distress trends and consistency over time.

Note: Patterns is for personal reflection and self-tracking. It does not diagnose, treat, or replace care from a qualified clinician.

**Keywords (iOS):**
journal, ocd tracker, mental health, reflection, thought tracker, compulsions, distress, privacy, minimalist

## 2. Privacy Policy
- **URL:** [https://maskedsyntax.com/patterns/privacy](https://maskedsyntax.com/patterns/privacy)
- **Data Collection:** The app does not collect any data. All data is stored locally on the user's device.
- **Data Deletion:** Users can delete individual entries or use the "Wipe all data" button in Settings to clear all local storage.

## 3. Screenshots Checklist
Prepare screenshots for:
- iPhone (6.7" and 6.5")
- iPad (12.9" 6th Gen and 2nd Gen)
- Android Phone (at least 2)
- Android Tablet (7-inch and 10-inch)

**Scenes to capture:**
1. Welcome Screen (Calm onboarding)
2. Home (Today's overview)
3. Journal Editor (Clean writing space)
4. OCD Entry Flow (Structured tracking)
5. Insights Screen (Trend charts)

## 4. Release Signing (Android)

To build a release APK/AAB for Google Play:
1. Create a keystore: `keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
2. Create `android/key.properties` (do NOT commit this):
   ```properties
   storePassword=<your-password>
   keyPassword=<your-password>
   keyAlias=upload
   storeFile=<path-to-keystore>
   ```
3. Update `android/app/build.gradle.kts` to use the signing configuration.

## 5. Final Verification
1. Run `flutter analyze`
2. Run `flutter test`
3. Build artifacts:
   - Android: `flutter build appbundle`
   - iOS: `flutter build ipa`
