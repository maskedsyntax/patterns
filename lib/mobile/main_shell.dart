import 'dart:math' as math;

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:local_auth/local_auth.dart' show LocalAuthException, LocalAuthExceptionCode;

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import '../widgets/liquid_glass.dart';
import 'biometric_auth.dart';
import 'preferences.dart';
import 'screens/analytics_screen.dart';
import 'screens/compulsion_delay_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/ocd_tracker_screen.dart';
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

  void _startApp() {
    mobilePreferences?.setBool('hasStarted', true);
    setState(() => _hasStarted = true);
  }

  @override
  Widget build(BuildContext context) {
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
      // biometric prompt or an app-switcher peek — don't auto-re-prompt;
      // let the user tap the Unlock button.
      final shouldReauth = _didBackground;
      setState(() {
        _lifecycleCovered = false;
        _didBackground = false;
      });
      if (shouldReauth &&
          _locked &&
          ref.read(appLockEnabledProvider)) {
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
      // don't re-prompt here — that re-prompt was the trigger for the
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
          setState(() => _errorMessage =
              'Too many attempts. Try again in a moment.');
          break;
        case LocalAuthExceptionCode.biometricLockout:
          setState(() => _errorMessage =
              'Biometric authentication is locked. Unlock your device with your passcode to reset it.');
          break;
        case LocalAuthExceptionCode.noBiometricsEnrolled:
        case LocalAuthExceptionCode.noCredentialsSet:
        case LocalAuthExceptionCode.noBiometricHardware:
        case LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable:
          // App lock isn't usable on this device anymore — turn it off so the
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
          setState(() => _errorMessage =
              'Could not unlock Patterns. Try again.');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage =
            'Could not unlock Patterns. Try again.');
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
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onStart;
  final VoidCallback onImport;

  const WelcomeScreen({
    super.key,
    required this.onStart,
    required this.onImport,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            children: [
              const Spacer(),
              FadeSlideIn(
                duration: const Duration(milliseconds: 600),
                offset: 22,
                child: Container(
                  width: 164,
                  height: 164,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.surface,
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, _) {
                      final t = Curves.easeInOut.transform(_pulse.value);
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 104 + t * 8,
                            height: 104 + t * 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.24 + t * 0.18,
                                ),
                                width: 2,
                              ),
                            ),
                          ),
                          Container(
                            width: 58 + t * 6,
                            height: 58 + t * 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.14 + t * 0.10,
                              ),
                            ),
                          ),
                          Icon(
                            LineIcons.feather,
                            color: theme.colorScheme.primary,
                            size: 34,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 48),
              FadeSlideIn(
                delay: const Duration(milliseconds: 180),
                child: Text(
                  'Understand your patterns.\nOne entry at a time.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTheme.displayFamily,
                    fontWeight: FontWeight.w500,
                    fontSize: 32,
                    height: 1.12,
                    letterSpacing: -0.6,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              FadeSlideIn(
                delay: const Duration(milliseconds: 280),
                child: Text(
                  'Track intrusive thoughts, compulsions, distress, and daily reflections in a calm private space.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.55,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              FadeSlideIn(
                delay: const Duration(milliseconds: 340),
                child: Text(
                  'Patterns is for personal reflection and self-tracking. It does not diagnose, treat, or replace care from a qualified clinician.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.45,
                  ),
                ),
              ),
              const Spacer(),
              FadeSlideIn(
                delay: const Duration(milliseconds: 420),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onStart,
                    child: const Text('Start journaling'),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FadeSlideIn(
                delay: const Duration(milliseconds: 520),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: widget.onImport,
                    child: const Text('Import existing data'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _Tab { home, journal, track, insights }

class MobileHome extends ConsumerStatefulWidget {
  const MobileHome({super.key});

  @override
  ConsumerState<MobileHome> createState() => _MobileHomeState();
}

class _MobileHomeState extends ConsumerState<MobileHome> {
  _Tab _selectedTab = _Tab.home;

  @override
  Widget build(BuildContext context) {
    final today = TodayScreen(
      onJournal: () => _openJournalEditor(context),
      onTrack: () => _openOcdFlow(context),
      onDelay: () => _openDelayFlow(context),
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
      _Tab.insights: const AnalyticsScreen(),
    };

    final showFab =
        _selectedTab == _Tab.home ||
        _selectedTab == _Tab.journal ||
        _selectedTab == _Tab.track;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: PageTransitionSwitcher(
              duration: const Duration(milliseconds: 320),
              reverse: false,
              transitionBuilder: (child, primary, secondary) {
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
                  setState(() => _selectedTab = tab);
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
                duration: const Duration(milliseconds: 320),
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
      ),
    );
  }
}

class _FloatingTabBar extends StatefulWidget {
  final _Tab selectedTab;
  final ValueChanged<_Tab> onSelected;

  const _FloatingTabBar({required this.selectedTab, required this.onSelected});

  @override
  State<_FloatingTabBar> createState() => _FloatingTabBarState();
}

class _FloatingTabBarState extends State<_FloatingTabBar>
    with SingleTickerProviderStateMixin {
  static const _tabs = _Tab.values;

  late final AnimationController _slide = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 440),
  )..value = 1;
  late int _fromIndex = _tabs.indexOf(widget.selectedTab);
  late int _toIndex = _fromIndex;

  @override
  void didUpdateWidget(_FloatingTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedTab != widget.selectedTab) {
      _fromIndex = _toIndex;
      _toIndex = _tabs.indexOf(widget.selectedTab);
      _slide.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _slide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LiquidGlass(
      borderRadius: 30,
      shadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.10),
          blurRadius: 26,
          offset: const Offset(0, 14),
        ),
      ],
      child: SizedBox(
        height: 68,
        child: LayoutBuilder(
          builder: (context, constraints) {
            const inset = 6.0;
            const indicatorH = 52.0;
            final itemWidth = constraints.maxWidth / _tabs.length;
            final indicatorW = itemWidth - inset * 2;

            return AnimatedBuilder(
              animation: _slide,
              builder: (context, _) {
                // Springy position with a subtle overshoot.
                final t = Curves.easeOutBack.transform(_slide.value);
                final pos = _fromIndex + (_toIndex - _fromIndex) * t;
                final left = pos * itemWidth + inset;
                // Squash-and-stretch: widen mid-transit, settle back to 1 — the
                // "liquid" feel.
                final pulse = math.sin(math.pi * _slide.value.clamp(0.0, 1.0));
                final stretchX = 1 + pulse * 0.16;
                final squashY = 1 - pulse * 0.06;

                return Stack(
                  children: [
                    Positioned(
                      left: left,
                      top: (68 - indicatorH) / 2,
                      width: indicatorW,
                      height: indicatorH,
                      child: Transform.scale(
                        scaleX: stretchX,
                        scaleY: squashY,
                        child: _GlassIndicator(isDark: isDark),
                      ),
                    ),
                    Row(
                      children: [
                        _TabItem(
                          icon: LineIcons.home,
                          label: 'Home',
                          active: widget.selectedTab == _Tab.home,
                          onTap: () => widget.onSelected(_Tab.home),
                        ),
                        _TabItem(
                          icon: LineIcons.bookOpen,
                          label: 'Journal',
                          active: widget.selectedTab == _Tab.journal,
                          onTap: () => widget.onSelected(_Tab.journal),
                        ),
                        _TabItem(
                          icon: LineIcons.bullseye,
                          label: 'Track',
                          active: widget.selectedTab == _Tab.track,
                          onTap: () => widget.onSelected(_Tab.track),
                        ),
                        _TabItem(
                          icon: LineIcons.barChart,
                          label: 'Insights',
                          active: widget.selectedTab == _Tab.insights,
                          onTap: () => widget.onSelected(_Tab.insights),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// The glassy capsule behind the active tab — a brighter glass pane with a top
/// specular highlight and a soft accent glow.
class _GlassIndicator extends StatelessWidget {
  final bool isDark;

  const _GlassIndicator({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primary.withValues(alpha: isDark ? 0.30 : 0.34),
            primary.withValues(alpha: isDark ? 0.12 : 0.16),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.22 : 0.40),
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
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

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inactiveColor = theme.brightness == Brightness.dark
        ? AppTheme.textSecondary
        : AppTheme.lightTextPrimary.withValues(alpha: 0.72);
    final color = active ? theme.colorScheme.primary : inactiveColor;

    return Expanded(
      child: PressScale(
        scale: 0.94,
        onTap: onTap,
        child: Center(
          child: AnimatedScale(
            scale: active ? 1.05 : 1.0,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: active ? 1 : 0),
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  builder: (context, t, _) {
                    return Icon(
                      icon,
                      size: 22 + (t * 1.5),
                      color: Color.lerp(inactiveColor, color, t),
                    );
                  },
                ),
                const SizedBox(height: 5),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  ),
                  child: Text(label),
                ),
              ],
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

  const _ActionSheet({
    required this.onJournal,
    required this.onOcd,
    required this.onDelay,
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
              child: Text(
                'What do you want to add?',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FadeSlideIn(
              delay: const Duration(milliseconds: 70),
              child: _SheetAction(
                icon: LineIcons.penNib,
                title: 'Journal Entry',
                onTap: onJournal,
              ),
            ),
            const SizedBox(height: 10),
            FadeSlideIn(
              delay: const Duration(milliseconds: 140),
              child: _SheetAction(
                icon: LineIcons.bullseye,
                title: 'OCD Event',
                onTap: onOcd,
              ),
            ),
            const SizedBox(height: 10),
            FadeSlideIn(
              delay: const Duration(milliseconds: 210),
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
