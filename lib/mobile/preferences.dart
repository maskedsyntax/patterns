import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences? mobilePreferences;

const appLockPreferenceKey = 'appLockEnabled';

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
