import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:local_auth/local_auth.dart'
    show LocalAuthException, LocalAuthExceptionCode;

import '../models/models.dart';
import '../providers/providers.dart';
import '../services/analytics_service.dart';
import '../services/demo_seed_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import '../widgets/liquid_glass.dart';
import 'biometric_auth.dart';
import 'preferences.dart';
import 'screens/analytics_screen.dart';
import 'screens/compulsion_delay_screen.dart';
import 'screens/erp_exercises_screen.dart';
import 'screens/exposure_hierarchy_screen.dart';
import 'screens/exposure_reflection_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/ocd_tracker_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/recovery_hub_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/ybocs_screen.dart';
import 'widgets/pro_gate.dart';
import 'widgets/section_intro.dart';
import 'widgets/spotlight_tour.dart';

/// MaterialApp.navigatorKey for the mobile build, so Welcome→Settings can
/// push from a post-frame callback.
final GlobalKey<NavigatorState> mobileRootNavigatorKey =
    GlobalKey<NavigatorState>();

/// Bumped to request a replay of the spotlight tab tour (e.g. from Settings).
/// The mobile home listens and re-runs the tour when this changes.
class TourRequestNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void request() => state++;
}

final tourRequestProvider = NotifierProvider<TourRequestNotifier, int>(
  TourRequestNotifier.new,
);

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

  // True only for the session where the user just finished onboarding, so the
  // spotlight tour runs for genuinely new users and not on every cold start or
  // for existing users upgrading into this release.
  bool _justStarted = false;

  void _startApp() {
    mobilePreferences?.setBool('hasStarted', true);
    mobilePreferences?.setString(lastSeenReleaseKey, currentReleaseId);
    setState(() {
      _hasStarted = true;
      _hasSeenCurrentRelease = true;
      _justStarted = true;
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
    if (_hasStarted) return MobileHome(showTour: _justStarted);
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
                        'Today now shows one clear next step, and Recovery groups every tool by where you are in your work.',
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
                  child: const Text('Show me the new Today'),
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
      icon: LineIcons.checkCircle,
      title: 'One clear next step',
      body: 'Today suggests the single best thing to do right now.',
    ),
    _WhatsNewFeature(
      icon: LineIcons.layerGroup,
      title: 'Recovery, grouped by stage',
      body: 'Assess, Plan, Practice, and Review — tools where you expect them.',
    ),
    _WhatsNewFeature(
      icon: LineIcons.heart,
      title: 'Help right now, up top',
      body: 'Grounding tools stay one tap away when a moment gets hard.',
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
  final bool showTour;

  const MobileHome({super.key, this.showTour = false});

  @override
  ConsumerState<MobileHome> createState() => _MobileHomeState();
}

class _MobileHomeState extends ConsumerState<MobileHome> {
  late _Tab _selectedTab = _savedTab();

  // Stable keys the spotlight tour measures — one per tab. The concluding step
  // is centered (target-less), so it needs no key.
  final Map<_Tab, GlobalKey> _tabKeys = {
    for (final tab in _Tab.values) tab: GlobalKey(),
  };
  bool _tourRunning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _seedDemoData();
      if (widget.showTour) _startTour();
    });
  }

  void _startTour({bool force = false}) {
    if (_tourRunning) return;
    if (!force && (mobilePreferences?.getBool(tabTourSeenKey) ?? false)) return;
    _selectTab(_Tab.home);
    // Let any in-flight transition settle (a Settings pop on replay, or the
    // Home mounting on first run) before measuring/showing the spotlight.
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted || _tourRunning) return;
      _tourRunning = true;
      showSpotlightTour(
        context,
        steps: _buildTourSteps(),
        onFinish: () {
          _tourRunning = false;
          mobilePreferences?.setBool(tabTourSeenKey, true);
        },
        onFinaleCta: () => _openNextStep(RecoveryStep.selfCheck),
      );
    });
  }

  List<TourStep> _buildTourSteps() {
    TourStep tab(_Tab t, String id) {
      final intro = sectionIntros[id]!;
      return TourStep(
        targetKey: _tabKeys[t]!,
        title: intro.title,
        points: intro.points,
        onShow: () => _selectTab(t),
      );
    }

    return [
      tab(_Tab.home, 'today'),
      tab(_Tab.journal, 'journal'),
      tab(_Tab.track, 'track'),
      tab(_Tab.erp, 'recoveryHub'),
      tab(_Tab.insights, 'insights'),
      TourStep(
        title: "You're all set",
        points: const [
          'Start with a quick self-check — it sets your baseline and unlocks your recovery score.',
        ],
        ctaLabel: 'Take self-check',
        onShow: () => _selectTab(_Tab.home),
      ),
    ];
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
    // Replay requests (from Settings) re-run the tour on the live app.
    ref.listen<int>(tourRequestProvider, (_, _) => _startTour(force: true));

    final today = TodayScreen(
      onJournal: () => _openJournalEditor(context),
      onTrack: () => _openOcdFlow(context),
      onDelay: () => _openDelayFlow(context),
      onErp: _openErpTab,
      onInsights: _openInsightsTab,
      onNextStep: _openNextStep,
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
                tabKeys: _tabKeys,
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

  /// Deep-links the Today screen's "Your next step" card straight to the right
  /// tool. Pro-only steps are only ever recommended to Pro users (see
  /// [AnalyticsService.buildNextStep]); the requirePro guards are defensive.
  void _openNextStep(RecoveryStep step) {
    switch (step) {
      case RecoveryStep.selfCheck:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (_) => const YbocsScreen(),
          ),
        );
      case RecoveryStep.buildHierarchy:
        if (!requirePro(context, ref)) return;
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const ExposureHierarchyScreen(),
          ),
        );
      case RecoveryStep.dailyPractice:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const ErpExercisesScreen(showBack: true),
          ),
        );
      case RecoveryStep.reflect:
        if (!requirePro(context, ref)) return;
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const ExposureReflectionScreen(),
          ),
        );
      case RecoveryStep.journal:
        _openJournalEditor(context);
    }
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
  final Map<_Tab, GlobalKey> tabKeys;
  final ValueChanged<_Tab> onSelected;

  const _FloatingTabBar({
    required this.selectedTab,
    required this.tabKeys,
    required this.onSelected,
  });

  static const _items = [
    _DockTabSpec(tab: _Tab.home, icon: LineIcons.home, label: 'Today'),
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
    return LiquidGlass(
      borderRadius: 28,
      tint: AppTheme.charcoalCard,
      opacity: 0.58,
      blurSigma: 22,
      saturation: 1.25,
      shadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.30),
          blurRadius: 30,
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
                  measureKey: tabKeys[item.tab],
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
  final GlobalKey? measureKey;
  final VoidCallback onTap;

  const _SegmentTabItem({
    required this.spec,
    required this.active,
    required this.measureKey,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inactiveColor = AppTheme.textSecondary;
    final activeColor = theme.colorScheme.primary;
    final activeBackground = activeColor.withValues(alpha: 0.14);

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
              key: measureKey,
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
                                  color: activeColor.withValues(alpha: 0.10),
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
    final fill = AppTheme.charcoalInput;
    final textColor = AppTheme.textPrimary;

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
