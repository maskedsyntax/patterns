import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/pro_service.dart';

SharedPreferences? mobilePreferences;

const appLockPreferenceKey = 'appLockEnabled';
const reminderEnabledKey = 'reminderEnabled';
const reminderHourKey = 'reminderHour';
const reminderMinuteKey = 'reminderMinute';
const proUnlockedKey = 'proUnlocked';

Future<void> initMobilePreferences() async {
  mobilePreferences = await SharedPreferences.getInstance();
}

Future<void> clearLocalPreferences() async {
  await mobilePreferences?.clear();
}

class AppLockNotifier extends Notifier<bool> {
  @override
  bool build() => mobilePreferences?.getBool(appLockPreferenceKey) ?? false;

  Future<void> setEnabled(bool enabled) async {
    await mobilePreferences?.setBool(appLockPreferenceKey, enabled);
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

/// Daily reminder preference (on/off + time of day). Persistence only — the
/// Settings screen owns the OS permission + scheduling side effects, mirroring
/// how the app-lock toggle works.
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
    enabled: mobilePreferences?.getBool(reminderEnabledKey) ?? false,
    hour: mobilePreferences?.getInt(reminderHourKey) ?? 20,
    minute: mobilePreferences?.getInt(reminderMinuteKey) ?? 0,
  );

  Future<void> setEnabled(bool enabled) async {
    await mobilePreferences?.setBool(reminderEnabledKey, enabled);
    state = state.copyWith(enabled: enabled);
  }

  Future<void> setTime(int hour, int minute) async {
    await mobilePreferences?.setInt(reminderHourKey, hour);
    await mobilePreferences?.setInt(reminderMinuteKey, minute);
    state = state.copyWith(hour: hour, minute: minute);
  }
}

final reminderProvider = NotifierProvider<ReminderNotifier, ReminderSettings>(
  ReminderNotifier.new,
);
