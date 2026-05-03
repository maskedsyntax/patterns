import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences? mobilePreferences;

Future<void> initMobilePreferences() async {
  mobilePreferences = await SharedPreferences.getInstance();
}

Future<void> clearLocalPreferences() async {
  await mobilePreferences?.clear();
}
