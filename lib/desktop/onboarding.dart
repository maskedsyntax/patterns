import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';

import '../app_preferences.dart';
import '../providers/providers.dart';
import '../services/demo_seed_service.dart';
import '../services/notification_service.dart';
import '../services/pro_service.dart';
import '../theme/app_theme.dart';
import '../widgets/paywall_sheet.dart';
import 'privacy_gate.dart';
import 'shell.dart';

/// Desktop entry: welcome → what's new → shell, with app-lock gate.
class DesktopRoot extends ConsumerStatefulWidget {
  const DesktopRoot({super.key});

  @override
  ConsumerState<DesktopRoot> createState() => _DesktopRootState();
}

class _DesktopRootState extends ConsumerState<DesktopRoot> {
  late bool _hasStarted = appPreferences?.getBool(hasStartedKey) ?? false;
  late bool _hasSeenCurrentRelease =
      !_hasStarted ||
      appPreferences?.getString(lastSeenReleaseKey) == currentReleaseId;

  late bool _openSettingsAfterStart = false;

  void _startApp({bool openSettings = false}) {
    appPreferences?.setBool(hasStartedKey, true);
    appPreferences?.setString(lastSeenReleaseKey, currentReleaseId);
    setState(() {
      _hasStarted = true;
      _hasSeenCurrentRelease = true;
      _openSettingsAfterStart = openSettings;
    });
  }

  Future<void> _markReleaseSeen({bool showHome = false}) async {
    await appPreferences?.setString(lastSeenReleaseKey, currentReleaseId);
    if (showHome) {
      await appPreferences?.setString(
        desktopSelectedTabKey,
        DesktopTab.home.name,
      );
    }
    await NotificationService.cancelUpdateAnnouncement();
    if (!mounted) return;
    setState(() => _hasSeenCurrentRelease = true);
  }

  @override
  Widget build(BuildContext context) {
    late final Widget body;
    if (_hasStarted && !_hasSeenCurrentRelease) {
      body = DesktopWhatsNewScreen(
        onShowHome: () => _markReleaseSeen(showHome: true),
        onContinue: _markReleaseSeen,
      );
    } else if (_hasStarted) {
      body = _DesktopShellHost(
        initialTab: _openSettingsAfterStart ? DesktopTab.settings : null,
      );
    } else {
      body = DesktopWelcomeScreen(
        onStart: () => _startApp(),
        onImport: () => _startApp(openSettings: true),
      );
    }

    return DesktopPrivacyGate(child: body);
  }
}

class _DesktopShellHost extends ConsumerStatefulWidget {
  const _DesktopShellHost({this.initialTab});

  final DesktopTab? initialTab;

  @override
  ConsumerState<_DesktopShellHost> createState() => _DesktopShellHostState();
}

class _DesktopShellHostState extends ConsumerState<_DesktopShellHost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _seedDemoData());
  }

  Future<void> _seedDemoData() async {
    final seeded = await DemoSeedService.seedIfNeeded();
    if (!mounted || !seeded) return;
    ref
      ..invalidate(journalProvider)
      ..invalidate(ocdProvider)
      ..invalidate(delaySessionProvider)
      ..invalidate(erpExercisePlanProvider)
      ..invalidate(erpExerciseSessionProvider)
      ..invalidate(exposureHierarchyProvider)
      ..invalidate(exposureStepProvider)
      ..invalidate(responsePreventionProvider)
      ..invalidate(urgeSurfProvider);
  }

  @override
  Widget build(BuildContext context) =>
      DesktopShell(initialTab: widget.initialTab);
}

class DesktopWelcomeScreen extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onImport;

  const DesktopWelcomeScreen({
    super.key,
    required this.onStart,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Container(
            margin: const EdgeInsets.all(40),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.cardTheme.color ?? theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patterns',
                  style: TextStyle(
                    fontFamily: AppTheme.displayFamily,
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'A private companion for journaling, OCD tracking, and ERP practice — on your desktop.',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.55),
                    fontSize: 16,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onStart,
                    child: const Text('Get started'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      onImport();
                    },
                    child: const Text('I have a backup to import'),
                  ),
                ),
                if (ProService.isPlatformSupported) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => PaywallSheet.show(context),
                      child: const Text('Unlock Patterns Pro'),
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                Text(
                  'Private by design. Not a diagnosis or replacement for care.',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.35),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DesktopWhatsNewScreen extends StatelessWidget {
  final Future<void> Function() onShowHome;
  final Future<void> Function() onContinue;

  const DesktopWhatsNewScreen({
    super.key,
    required this.onShowHome,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: AppTheme.warmYellow,
                  size: 40,
                ),
                const SizedBox(height: 20),
                Text(
                  'Patterns got a major upgrade',
                  style: TextStyle(
                    fontFamily: AppTheme.displayFamily,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Desktop now includes Home, Recovery Hub with ERP tools, richer Insights, reminders, and app lock — matching the mobile companion.',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.55),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 28),
                _Bullet(
                  icon: LineIcons.home,
                  text: 'Home cockpit with streak and next practice',
                ),
                _Bullet(
                  icon: Icons.self_improvement_rounded,
                  text: 'Full Recovery Hub with free and Pro tools',
                ),
                _Bullet(
                  icon: LineIcons.barChart,
                  text: 'Insights: Overview, Thoughts, Urges, ERP',
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => onShowHome(),
                    child: const Text('Show me Home'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => onContinue(),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Bullet({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.75),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
