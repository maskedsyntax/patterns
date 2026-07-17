import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/pro_service.dart';

/// Shared preferences used by both mobile and desktop.
///
/// Historically named [mobilePreferences]; the alias is kept so existing
/// call sites continue to compile while the rest of the app migrates.
SharedPreferences? appPreferences;

/// Legacy alias for [appPreferences]. Prefer [appPreferences] in new code.
SharedPreferences? get mobilePreferences => appPreferences;
set mobilePreferences(SharedPreferences? value) => appPreferences = value;

const appLockPreferenceKey = 'appLockEnabled';
const mobileSelectedTabKey = 'mobileSelectedTab';
const desktopSelectedTabKey = 'desktopSelectedTab';
const reminderEnabledKey = 'reminderEnabled';
const reminderHourKey = 'reminderHour';
const reminderMinuteKey = 'reminderMinute';
const proUnlockedKey = 'proUnlocked';
const lastSeenReleaseKey = 'lastSeenReleaseId';
const releaseAnnouncementScheduledKey = 'releaseAnnouncementScheduledId';
const currentReleaseId = 'patterns_1_6_home_cockpit';
const hasStartedKey = 'hasStarted';

/// One-time flag for the first-run spotlight tour of the bottom tabs. Uses the
/// same `sectionSeen_` convention as [SectionIntro] so a single "replay" reset
/// pattern covers both.
const tabTourSeenKey = 'sectionSeen_tabTour';

Future<void> initAppPreferences() async {
  appPreferences = await SharedPreferences.getInstance();
}

/// Legacy name used by the mobile entry path.
Future<void> initMobilePreferences() => initAppPreferences();

Future<void> clearLocalPreferences() async {
  await appPreferences?.clear();
}

class AppLockNotifier extends Notifier<bool> {
  @override
  bool build() => appPreferences?.getBool(appLockPreferenceKey) ?? false;

  Future<void> setEnabled(bool enabled) async {
    await appPreferences?.setBool(appLockPreferenceKey, enabled);
    state = enabled;
  }
}

final appLockEnabledProvider = NotifierProvider<AppLockNotifier, bool>(
  AppLockNotifier.new,
);

/// Whether "Patterns Pro" is unlocked. Backed by the persisted flag that
/// [ProService] writes on a successful purchase or restore. Subscribes to the
/// purchase event stream so any unlock flips Pro gating app-wide immediately.
class ProNotifier extends Notifier<bool> {
  StreamSubscription<ProEvent>? _sub;

  @override
  bool build() {
    _sub = ProService.events.listen((event) {
      if (event is ProSuccess) state = true;
    });
    ref.onDispose(() => _sub?.cancel());
    return ProService.isUnlocked;
  }

  /// Re-reads the persisted flag (e.g. after launch-time restore completes).
  void refresh() => state = ProService.isUnlocked;
}

final proProvider = NotifierProvider<ProNotifier, bool>(ProNotifier.new);

/// Daily reminder preference (on/off + time of day). Persistence only - the
/// Settings screen owns the OS permission + scheduling side effects.
class ReminderSettings {
  final bool enabled;
  final int hour;
  final int minute;

  const ReminderSettings({
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  ReminderSettings copyWith({bool? enabled, int? hour, int? minute}) =>
      ReminderSettings(
        enabled: enabled ?? this.enabled,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
      );
}

class ReminderNotifier extends Notifier<ReminderSettings> {
  @override
  ReminderSettings build() => ReminderSettings(
    enabled: appPreferences?.getBool(reminderEnabledKey) ?? false,
    hour: appPreferences?.getInt(reminderHourKey) ?? 20,
    minute: appPreferences?.getInt(reminderMinuteKey) ?? 0,
  );

  Future<void> setEnabled(bool enabled) async {
    await appPreferences?.setBool(reminderEnabledKey, enabled);
    state = state.copyWith(enabled: enabled);
  }

  Future<void> setTime(int hour, int minute) async {
    await appPreferences?.setInt(reminderHourKey, hour);
    await appPreferences?.setInt(reminderMinuteKey, minute);
    state = state.copyWith(hour: hour, minute: minute);
  }
}

final reminderProvider = NotifierProvider<ReminderNotifier, ReminderSettings>(
  ReminderNotifier.new,
);
