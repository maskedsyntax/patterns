/// Mobile-facing re-export of shared app preferences.
///
/// Preference keys, init, and Riverpod notifiers live in [app_preferences]
/// so desktop can use them without importing mobile UI. This file keeps
/// existing `import '../preferences.dart'` / `mobile/preferences.dart` paths
/// working with no behavior change.
library;

export '../app_preferences.dart';
