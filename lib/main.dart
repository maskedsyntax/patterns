import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show FlutterQuillLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_preferences.dart';
import 'desktop/onboarding.dart';
import 'desktop/shell.dart';
import 'mobile/main_shell.dart';
import 'services/notification_service.dart';
import 'services/pro_service.dart';
import 'services/review_prompt.dart';
import 'services/tip_jar.dart';
import 'theme/app_theme.dart';
import 'widgets/app_snack_bar.dart';
import 'widgets/platform.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  await initAppPreferences();

  if (!kIsDesktop) {
    await ReviewPromptService.recordSessionStart();
    await NotificationService.init();
    // Re-arm the saved reminder so it survives app updates and reinstalls of
    // the schedule (the OS clears pending notifications on app upgrade).
    if (appPreferences?.getBool(reminderEnabledKey) ?? false) {
      await NotificationService.scheduleDailyReminder(
        TimeOfDay(
          hour:
              appPreferences?.getInt(reminderHourKey) ??
              NotificationService.defaultHour,
          minute:
              appPreferences?.getInt(reminderMinuteKey) ??
              NotificationService.defaultMinute,
        ),
      );
    }
    final hasStarted = appPreferences?.getBool(hasStartedKey) ?? false;
    final releaseSeen =
        appPreferences?.getString(lastSeenReleaseKey) == currentReleaseId;
    final releaseScheduled =
        appPreferences?.getString(releaseAnnouncementScheduledKey) ==
        currentReleaseId;
    final canUseExistingReminderPermission =
        appPreferences?.getBool(reminderEnabledKey) ?? false;
    if (hasStarted &&
        !releaseSeen &&
        !releaseScheduled &&
        canUseExistingReminderPermission) {
      await NotificationService.scheduleUpdateAnnouncement(
        DateTime.now().add(const Duration(hours: 6)),
      );
      await appPreferences?.setString(
        releaseAnnouncementScheduledKey,
        currentReleaseId,
      );
    }
  } else {
    // Desktop: notifications (macOS) + review session for later settings/polish.
    await ReviewPromptService.recordSessionStart();
    await NotificationService.init();
    if (appPreferences?.getBool(reminderEnabledKey) ?? false) {
      await NotificationService.scheduleDailyReminder(
        TimeOfDay(
          hour:
              appPreferences?.getInt(reminderHourKey) ??
              NotificationService.defaultHour,
          minute:
              appPreferences?.getInt(reminderMinuteKey) ??
              NotificationService.defaultMinute,
        ),
      );
    }
  }

  TipJarService.init();
  ProService.init();

  runApp(const ProviderScope(child: PatternsApp()));
}

class PatternsApp extends ConsumerWidget {
  const PatternsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Patterns',
      debugShowCheckedModeBanner: false,
      // Dark-only app. A single dark theme is supplied and the mode is pinned,
      // so the OS appearance setting and any legacy saved preference are ignored.
      theme: kIsDesktop ? AppTheme.darkTheme : AppTheme.mobileDarkTheme,
      themeMode: ThemeMode.dark,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      localizationsDelegates: const [
        FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      navigatorKey: kIsDesktop ? desktopRootNavigatorKey : mobileRootNavigatorKey,
      builder: kIsDesktop
          ? null
          : (context, child) => MobileAppFrame(child: child),
      home: kIsDesktop ? const DesktopRoot() : const MobileShell(),
    );
  }
}
