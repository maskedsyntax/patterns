import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'marketing_animations/marketing_animations.dart';
import 'theme/app_theme.dart';

/// Temporary entrypoint for recording Meta / YouTube ad animations.
///
/// Usage:
/// ```bash
/// flutter run -t lib/main_marketing.dart --dart-define=AD_INDEX=1
/// ```
///
/// [AD_INDEX] selects which ad to render (1–10). Defaults to 1.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Strip OS chrome (status bar, nav bar, clocks, battery) for clean capture.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);

  final adIndex = _parseAdIndex(
    const String.fromEnvironment('AD_INDEX', defaultValue: '1'),
  );

  runApp(MarketingAdApp(adIndex: adIndex));
}

int _parseAdIndex(String raw) {
  final parsed = int.tryParse(raw.trim());
  if (parsed == null || parsed < 1 || parsed > 24) {
    debugPrint(
      'main_marketing: invalid AD_INDEX="$raw" — falling back to 1 '
      '(valid range: 1–24)',
    );
    return 1;
  }
  return parsed;
}

class MarketingAdApp extends StatelessWidget {
  final int adIndex;

  const MarketingAdApp({super.key, required this.adIndex});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patterns Ads · $adIndex',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.mobileDarkTheme,
      themeMode: ThemeMode.dark,
      home: MarketingAdHost(adIndex: adIndex),
    );
  }
}

/// Full-bleed host that maps [adIndex] → the matching self-playing ad widget.
class MarketingAdHost extends StatelessWidget {
  final int adIndex;

  const MarketingAdHost({super.key, required this.adIndex});

  static Widget widgetForIndex(int index) {
    switch (index) {
      case 1:
        return const AdAnimation1();
      case 2:
        return const AdAnimation2();
      case 3:
        return const AdAnimation3();
      case 4:
        return const AdAnimation4();
      case 5:
        return const AdAnimation5();
      case 6:
        return const AdAnimation6();
      case 7:
        return const AdAnimation7();
      case 8:
        return const AdAnimation8();
      case 9:
        return const AdAnimation9();
      case 10:
        return const AdAnimation10();
      case 11:
        return const AdAnimation11();
      case 12:
        return const AdAnimation12();
      case 13:
        return const AdAnimation13();
      case 14:
        return const AdAnimation14();
      case 15:
        return const AdAnimation15();
      case 16:
        return const AdAnimation16();
      case 17:
        return const AdAnimation17();
      case 18:
        return const AdAnimation18();
      case 19:
        return const AdAnimation19();
      case 20:
        return const AdAnimation20();
      case 21:
        return const AdAnimation21();
      case 22:
        return const AdAnimation22();
      case 23:
        return const AdAnimation23();
      case 24:
        return const AdAnimation24();
      default:
        return const AdAnimation1();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(child: widgetForIndex(adIndex)),
    );
  }
}
