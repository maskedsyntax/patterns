import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:local_auth/local_auth.dart'
    show LocalAuthException, LocalAuthExceptionCode;

import '../models/models.dart';
import '../providers/providers.dart';
import '../services/demo_seed_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import '../widgets/liquid_glass.dart';
import 'biometric_auth.dart';
import 'preferences.dart';
import 'screens/analytics_screen.dart';
import 'screens/compulsion_delay_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/ocd_tracker_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/recovery_hub_screen.dart';
import 'screens/settings_screen.dart';

/// MaterialApp.navigatorKey for the mobile build, so Welcome→Settings can
/// push from a post-frame callback.
final GlobalKey<NavigatorState> mobileRootNavigatorKey =
    GlobalKey<NavigatorState>();

/// Wraps mobile content with a centered max-width frame so it looks reasonable
/// on tablets and landscape phones. Used as MaterialApp.builder on mobile.
class MobileAppFrame extends StatelessWidget {
  final Widget? child;

  const MobileAppFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return _PrivacyScreen(child: _MobileAppFrame(child: child));
  }
}

/// Entry widget for the mobile build. Routes between the welcome screen
/// (first launch) and the home shell.
class MobileShell extends ConsumerStatefulWidget {
  const MobileShell({super.key});

  @override
  ConsumerState<MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends ConsumerState<MobileShell> {
  late bool _hasStarted = mobilePreferences?.getBool('hasStarted') ?? false;
  late bool _hasSeenCurrentRelease =
      !_hasStarted ||
      mobilePreferences?.getString(lastSeenReleaseKey) == currentReleaseId;

  void _startApp() {
    mobilePreferences?.setBool('hasStarted', true);
    mobilePreferences?.setString(lastSeenReleaseKey, currentReleaseId);
    setState(() {
      _hasStarted = true;
      _hasSeenCurrentRelease = true;
    });
  }

  Future<void> _markReleaseSeen({bool showHome = false}) async {
    await mobilePreferences?.setString(lastSeenReleaseKey, currentReleaseId);
    if (showHome) {
      await mobilePreferences?.setString(mobileSelectedTabKey, _Tab.home.name);
    }
    await NotificationService.cancelUpdateAnnouncement();
    if (!mounted) return;
    setState(() => _hasSeenCurrentRelease = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasStarted && !_hasSeenCurrentRelease) {
      return WhatsNewScreen(
        onShowHome: () => _markReleaseSeen(showHome: true),
        onContinue: _markReleaseSeen,
      );
    }
    if (_hasStarted) return const MobileHome();
    return WelcomeScreen(
      onStart: _startApp,
      onImport: () {
        _startApp();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          mobileRootNavigatorKey.currentState?.push(
            MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
          );
        });
      },
    );
  }
}

class WhatsNewScreen extends StatelessWidget {
  final Future<void> Function() onShowHome;
  final Future<void> Function() onContinue;

  const WhatsNewScreen({
    super.key,
    required this.onShowHome,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF090A09), AppTheme.deepCharcoal],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
            children: [
              FadeSlideIn(
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF20201D), Color(0xFF141413)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0xFF39362F)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 30,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.warmYellow.withValues(alpha: 0.16),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppTheme.warmYellow,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Patterns got a major upgrade',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontFamily: AppTheme.displayFamily,
                          fontSize: 35,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.8,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Your Home now brings recovery score, daily practice, quick actions, and progress into one calm place.',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 15,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              FadeSlideIn(
                delay: const Duration(milliseconds: 80),
                child: const _WhatsNewFeatureList(),
              ),
              const SizedBox(height: 22),
              FadeSlideIn(
                delay: const Duration(milliseconds: 140),
                child: FilledButton(
                  onPressed: () {
                    onShowHome();
                  },
                  child: const Text('Show me the new Home'),
                ),
              ),
              const SizedBox(height: 10),
              FadeSlideIn(
                delay: const Duration(milliseconds: 180),
                child: TextButton(
                  onPressed: () {
                    onContinue();
                  },
                  child: const Text('Continue to Patterns'),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Notifications are only used if you already opted in. You can change reminders any time in Settings.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WhatsNewFeatureList extends StatelessWidget {
  const _WhatsNewFeatureList();

  static const _features = [
    _WhatsNewFeature(
      icon: LineIcons.lineChart,
      title: 'Recovery score on Home',
      body: 'See progress without digging through analytics.',
    ),
    _WhatsNewFeature(
      icon: LineIcons.clock,
      title: 'Continue your practice',
      body: 'Jump back into ERP and delay tools faster.',
    ),
    _WhatsNewFeature(
      icon: LineIcons.layerGroup,
      title: 'Exposure tools are closer',
      body: 'Find hierarchy, materials, and uncertainty practice from Home.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _features.length; i++) ...[
          _WhatsNewFeatureTile(feature: _features[i]),
          if (i != _features.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _WhatsNewFeature {
  final IconData icon;
  final String title;
  final String body;

  const _WhatsNewFeature({
    required this.icon,
    required this.title,
    required this.body,
  });
}

class _WhatsNewFeatureTile extends StatelessWidget {
  final _WhatsNewFeature feature;

  const _WhatsNewFeatureTile({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181817),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF34322D)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppTheme.warmYellow.withValues(alpha: 0.14),
            ),
            child: Icon(feature.icon, color: AppTheme.warmYellow, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  feature.body,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12.5,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileAppFrame extends StatelessWidget {
  final Widget? child;

  const _MobileAppFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _PrivacyScreen extends ConsumerStatefulWidget {
  final Widget child;

  const _PrivacyScreen({required this.child});

  @override
  ConsumerState<_PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends ConsumerState<_PrivacyScreen>
    with WidgetsBindingObserver {
  bool _lifecycleCovered = false;
  bool _didBackground = false;
  bool _locked = mobilePreferences?.getBool(appLockPreferenceKey) ?? false;
  bool _authInProgress = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_locked) _authenticate();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // While the biometric prompt is up, the OS transitions the app through
    // `inactive` (iOS) and `paused` (Android). Reacting to those the same
    // way we'd react to a real backgrounding sets _locked back to true and
    // re-fires _authenticate(), creating an infinite prompt loop. Ignore
    // lifecycle changes while auth is in flight.
    if (_authInProgress) return;

    if (state == AppLifecycleState.resumed) {
      // `_didBackground` is only set by a real `paused` (the prompt-induced
      // paused is filtered above), so it's our marker for "the user actually
      // backgrounded the app." If it's false, we're returning from the
      // biometric prompt or an app-switcher peek - don't auto-re-prompt;
      // let the user tap the Unlock button.
      final shouldReauth = _didBackground;
      setState(() {
        _lifecycleCovered = false;
        _didBackground = false;
      });
      if (shouldReauth && _locked && ref.read(appLockEnabledProvider)) {
        _authenticate();
      }
      return;
    }

    // Cover the screen for any non-resumed state so the user's content is
    // hidden in the app switcher / system overlay regardless of which exact
    // lifecycle state the OS chose.
    setState(() {
      _lifecycleCovered = true;
      // Only a full `paused` counts as a real backgrounding for the relock
      // decision. `inactive` and `hidden` are transient (system prompts,
      // app switcher peek, predictive back) and shouldn't force a re-auth.
      if (state == AppLifecycleState.paused) {
        _didBackground = true;
        if (ref.read(appLockEnabledProvider)) _locked = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(appLockEnabledProvider, (_, enabled) {
      // The Settings toggle authenticates before flipping this provider, so
      // don't re-prompt here - that re-prompt was the trigger for the
      // historical loop. We just clear the cover when the user disables.
      if (!enabled) setState(() => _locked = false);
    });
    final covered = _lifecycleCovered || _locked;

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !covered,
            child: AnimatedOpacity(
              opacity: covered ? 1 : 0,
              duration: const Duration(milliseconds: 120),
              child: _PrivacyCover(
                showUnlock: _locked && !_lifecycleCovered,
                unlockBusy: _authInProgress,
                onUnlock: _authenticate,
                message: _lifecycleCovered ? null : _errorMessage,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _authenticate() async {
    if (_authInProgress || !mounted || !ref.read(appLockEnabledProvider)) {
      return;
    }
    setState(() {
      _authInProgress = true;
      _errorMessage = null;
    });
    try {
      final auth = ref.read(biometricAuthenticatorProvider);
      final supported = await auth.isDeviceSupported();
      if (!supported) {
        await ref.read(appLockEnabledProvider.notifier).setEnabled(false);
        if (mounted) setState(() => _locked = false);
        return;
      }
      // local_auth 3.x returns true only on success; everything else (including
      // user cancellation) is signalled via LocalAuthException.
      await auth.authenticate(reason: 'Unlock Patterns to continue.');
      if (!mounted) return;
      setState(() => _locked = false);
    } on LocalAuthException catch (e) {
      if (!mounted) return;
      switch (e.code) {
        case LocalAuthExceptionCode.userCanceled:
        case LocalAuthExceptionCode.systemCanceled:
        case LocalAuthExceptionCode.timeout:
        case LocalAuthExceptionCode.userRequestedFallback:
          // Recoverable, no-fault outcomes. Leave the cover up with the
          // Unlock button so the user can retry on their own.
          break;
        case LocalAuthExceptionCode.temporaryLockout:
          setState(
            () => _errorMessage = 'Too many attempts. Try again in a moment.',
          );
          break;
        case LocalAuthExceptionCode.biometricLockout:
          setState(
            () => _errorMessage =
                'Biometric authentication is locked. Unlock your device with your passcode to reset it.',
          );
          break;
        case LocalAuthExceptionCode.noBiometricsEnrolled:
        case LocalAuthExceptionCode.noCredentialsSet:
        case LocalAuthExceptionCode.noBiometricHardware:
        case LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable:
          // App lock isn't usable on this device anymore - turn it off so the
          // user isn't trapped behind a cover they can never satisfy.
          await ref.read(appLockEnabledProvider.notifier).setEnabled(false);
          if (mounted) {
            setState(() {
              _locked = false;
              _errorMessage =
                  'Biometric authentication is unavailable. App lock has been turned off.';
            });
          }
          break;
        default:
          setState(
            () => _errorMessage = 'Could not unlock Patterns. Try again.',
          );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'Could not unlock Patterns. Try again.');
      }
    } finally {
      // Defer clearing the in-progress flag until after the next frame. The
      // `resumed` event that fires when the biometric prompt closes is
      // queued during auth and would otherwise sneak past the guard and
      // re-enter _authenticate(), restarting the loop.
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _authInProgress = false);
        });
      }
    }
  }
}

class _PrivacyCover extends StatelessWidget {
  final bool showUnlock;
  final bool unlockBusy;
  final VoidCallback onUnlock;
  final String? message;

  const _PrivacyCover({
    required this.showUnlock,
    required this.unlockBusy,
    required this.onUnlock,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: 'Patterns privacy screen',
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surface,
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Icon(
                  LineIcons.lock,
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
              ),
            ),
            if (showUnlock) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: unlockBusy ? null : onUnlock,
                child: Text(unlockBusy ? 'Unlocking...' : 'Unlock'),
              ),
            ],
            if (message != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _Tab { home, journal, track, erp, insights }

class MobileHome extends ConsumerStatefulWidget {
  const MobileHome({super.key});

  @override
  ConsumerState<MobileHome> createState() => _MobileHomeState();
}

class _MobileHomeState extends ConsumerState<MobileHome> {
  late _Tab _selectedTab = _savedTab();

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
  Widget build(BuildContext context) {
    final today = TodayScreen(
      onJournal: () => _openJournalEditor(context),
      onTrack: () => _openOcdFlow(context),
      onDelay: () => _openDelayFlow(context),
      onErp: _openErpTab,
      onInsights: _openInsightsTab,
      onSettings: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen())),
    );
    final pages = {
      _Tab.home: today,
      _Tab.journal: const JournalScreen(),
      _Tab.track: OcdTrackerScreen(
        onAdd: () => _openOcdFlow(context),
        onDelay: () => _openDelayFlow(context),
      ),
      _Tab.erp: const RecoveryHubScreen(),
      _Tab.insights: const AnalyticsScreen(),
    };

    final showFab = _selectedTab == _Tab.journal || _selectedTab == _Tab.track;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: PageTransitionSwitcher(
              duration: AppMotion.medium,
              reverse: false,
              transitionBuilder: (child, primary, secondary) {
                if (motionDisabled(context)) return child;
                return FadeThroughTransition(
                  animation: primary,
                  secondaryAnimation: secondary,
                  fillColor: Colors.transparent,
                  child: child,
                );
              },
              child: KeyedSubtree(
                key: ValueKey(_selectedTab.name),
                child: pages[_selectedTab]!,
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 8,
            child: SafeArea(
              minimum: EdgeInsets.zero,
              child: _FloatingTabBar(
                selectedTab: _selectedTab,
                onSelected: (tab) {
                  if (tab == _selectedTab) return;
                  _selectTab(tab);
                },
              ),
            ),
          ),
          Positioned(
            right: 28,
            bottom: 92,
            child: SafeArea(
              minimum: EdgeInsets.zero,
              child: AnimatedSlide(
                offset: showFab ? Offset.zero : const Offset(0, 1.6),
                duration: AppMotion.medium,
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: showFab ? 1 : 0,
                  duration: const Duration(milliseconds: 220),
                  child: IgnorePointer(
                    ignoring: !showFab,
                    child: _FloatingPenButton(
                      icon: _selectedTab == _Tab.track
                          ? Icons.add_rounded
                          : LineIcons.penNib,
                      semanticLabel: _selectedTab == _Tab.track
                          ? 'Track OCD event'
                          : 'Add entry',
                      onTap: switch (_selectedTab) {
                        _Tab.journal => () => _openJournalEditor(context),
                        _Tab.track => () => _openOcdFlow(context),
                        _ => () => _showAddSheet(context),
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openJournalEditor(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JournalEntryEditor(date: DateTime.now()),
      ),
    );
  }

  void _openOcdFlow(
    BuildContext context, {
    OcdType initialType = OcdType.obsession,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => OcdEventFlow(initialType: initialType),
      ),
    );
  }

  void _openDelayFlow(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => const CompulsionDelayFlow(),
      ),
    );
  }

  void _openErpTab() {
    if (_selectedTab == _Tab.erp) return;
    _selectTab(_Tab.erp);
  }

  void _openInsightsTab() {
    if (_selectedTab == _Tab.insights) return;
    _selectTab(_Tab.insights);
  }

  void _selectTab(_Tab tab) {
    mobilePreferences?.setString(mobileSelectedTabKey, tab.name);
    setState(() => _selectedTab = tab);
  }

  _Tab _savedTab() {
    final saved = mobilePreferences?.getString(mobileSelectedTabKey);
    return _Tab.values.firstWhere(
      (tab) => tab.name == saved,
      orElse: () => _Tab.home,
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ActionSheet(
        onJournal: () {
          Navigator.pop(context);
          _openJournalEditor(context);
        },
        onOcd: () {
          Navigator.pop(context);
          _openOcdFlow(context);
        },
        onDelay: () {
          Navigator.pop(context);
          _openDelayFlow(context);
        },
        onErp: () {
          Navigator.pop(context);
          _openErpTab();
        },
      ),
    );
  }
}

class _FloatingTabBar extends StatelessWidget {
  final _Tab selectedTab;
  final ValueChanged<_Tab> onSelected;

  const _FloatingTabBar({required this.selectedTab, required this.onSelected});

  static const _items = [
    _DockTabSpec(tab: _Tab.home, icon: LineIcons.home, label: 'Home'),
    _DockTabSpec(tab: _Tab.journal, icon: LineIcons.bookOpen, label: 'Journal'),
    _DockTabSpec(tab: _Tab.track, icon: LineIcons.bullseye, label: 'Track'),
    _DockTabSpec(
      tab: _Tab.erp,
      icon: Icons.self_improvement_rounded,
      label: 'Recovery',
    ),
    _DockTabSpec(
      tab: _Tab.insights,
      icon: LineIcons.barChart,
      label: 'Insights',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LiquidGlass(
      borderRadius: 28,
      tint: isDark ? AppTheme.charcoalCard : AppTheme.mobileLightBg,
      opacity: isDark ? 0.58 : 0.88,
      blurSigma: isDark ? 22 : 20,
      saturation: isDark ? 1.25 : 1.12,
      shadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.16),
          blurRadius: isDark ? 30 : 24,
          offset: const Offset(0, 14),
        ),
      ],
      child: SizedBox(
        height: 74,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Row(
            children: [
              for (final item in _items)
                _SegmentTabItem(
                  spec: item,
                  active: selectedTab == item.tab,
                  onTap: () => onSelected(item.tab),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingPenButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String semanticLabel;

  const _FloatingPenButton({
    required this.onTap,
    this.icon = LineIcons.penNib,
    this.semanticLabel = 'Add entry',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: semanticLabel,
      child: PressScale(
        onTap: onTap,
        scale: 0.9,
        child: LiquidGlass(
          circle: true,
          tint: theme.colorScheme.primary,
          blurSigma: 18,
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          child: SizedBox(
            width: 52,
            height: 52,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: Icon(
                  icon,
                  key: ValueKey(icon.codePoint),
                  color: theme.colorScheme.onPrimary,
                  size: 26,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockTabSpec {
  final _Tab tab;
  final IconData icon;
  final String label;

  const _DockTabSpec({
    required this.tab,
    required this.icon,
    required this.label,
  });
}

class _SegmentTabItem extends StatelessWidget {
  final _DockTabSpec spec;
  final bool active;
  final VoidCallback onTap;

  const _SegmentTabItem({
    required this.spec,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final inactiveColor = isDark
        ? AppTheme.textSecondary
        : AppTheme.lightTextPrimary.withValues(alpha: 0.86);
    final activeColor = theme.colorScheme.primary;
    final activeBackground = activeColor.withValues(
      alpha: isDark ? 0.14 : 0.13,
    );

    return Expanded(
      child: Tooltip(
        message: spec.label,
        child: Semantics(
          button: true,
          selected: active,
          label: spec.label,
          child: PressScale(
            scale: 0.96,
            onTap: onTap,
            child: SizedBox.expand(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 5, 4, 5),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        decoration: BoxDecoration(
                          color: active ? activeBackground : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: active
                              ? Border.all(
                                  color: activeColor.withValues(
                                    alpha: isDark ? 0.10 : 0.16,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    top: 0,
                    left: active ? 18 : 28,
                    right: active ? 18 : 28,
                    height: 3,
                    child: AnimatedOpacity(
                      opacity: active ? 1 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: activeColor,
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 9, 4, 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedScale(
                            scale: active ? 1.05 : 1,
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            child: Icon(
                              spec.icon,
                              size: 23,
                              color: active ? activeColor : inactiveColor,
                            ),
                          ),
                          const SizedBox(height: 5),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              style: TextStyle(
                                color: active ? activeColor : inactiveColor,
                                fontSize: 10.5,
                                fontWeight: active
                                    ? FontWeight.w900
                                    : FontWeight.w700,
                              ),
                              child: Text(
                                spec.label,
                                maxLines: 1,
                                softWrap: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionSheet extends StatelessWidget {
  final VoidCallback onJournal;
  final VoidCallback onOcd;
  final VoidCallback onDelay;
  final VoidCallback onErp;

  const _ActionSheet({
    required this.onJournal,
    required this.onOcd,
    required this.onDelay,
    required this.onErp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LiquidGlass(
          borderRadius: 28,
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.30),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                FadeSlideIn(
                  duration: AppMotion.medium,
                  offset: AppMotion.smallOffset,
                  child: Text(
                    'What do you want to add?',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 40),
                  duration: AppMotion.medium,
                  offset: AppMotion.smallOffset,
                  child: _SheetAction(
                    icon: LineIcons.penNib,
                    title: 'Journal Entry',
                    onTap: onJournal,
                  ),
                ),
                const SizedBox(height: 10),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 80),
                  duration: AppMotion.medium,
                  offset: AppMotion.smallOffset,
                  child: _SheetAction(
                    icon: LineIcons.bullseye,
                    title: 'OCD Event',
                    onTap: onOcd,
                  ),
                ),
                const SizedBox(height: 10),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 120),
                  duration: AppMotion.medium,
                  offset: AppMotion.smallOffset,
                  child: _SheetAction(
                    icon: Icons.self_improvement_rounded,
                    title: 'Guided ERP',
                    onTap: onErp,
                  ),
                ),
                const SizedBox(height: 10),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 160),
                  duration: AppMotion.medium,
                  offset: AppMotion.smallOffset,
                  child: _SheetAction(
                    icon: LineIcons.hourglassHalf,
                    title: 'Pause an Urge',
                    onTap: onDelay,
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

class _SheetAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SheetAction({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fill = isDark ? AppTheme.charcoalInput : AppTheme.mobileLightBg;
    final textColor = isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary;

    return PressScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 14),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
