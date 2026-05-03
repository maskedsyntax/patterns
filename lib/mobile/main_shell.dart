import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';
import 'preferences.dart';
import 'screens/analytics_screen.dart';
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
    return _MobileAppFrame(child: child);
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
  late bool _hasStarted =
      mobilePreferences?.getBool('hasStarted') ?? false;

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
            MaterialPageRoute<void>(
              builder: (_) => const SettingsScreen(),
            ),
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
      onSettings: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen())),
    );
    final pages = {
      _Tab.home: today,
      _Tab.journal: const JournalScreen(),
      _Tab.track: OcdTrackerScreen(onAdd: () => _openOcdFlow(context)),
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
      ),
    );
  }
}

class _FloatingTabBar extends StatelessWidget {
  final _Tab selectedTab;
  final ValueChanged<_Tab> onSelected;

  const _FloatingTabBar({required this.selectedTab, required this.onSelected});

  static const _tabs = _Tab.values;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final gradientColors = isDark
        ? [
            Colors.white.withValues(alpha: 0.10),
            theme.colorScheme.surface.withValues(alpha: 0.44),
            Colors.black.withValues(alpha: 0.10),
          ]
        : [
            Colors.white.withValues(alpha: 0.32),
            Colors.white.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.10),
          ];
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.55);

    final selectedIndex = _tabs.indexOf(selectedTab);

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.08),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.04),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const indicatorInset = 6.0;
              final itemWidth = constraints.maxWidth / _tabs.length;
              final indicatorWidth = itemWidth - indicatorInset * 2;
              final indicatorLeft = selectedIndex * itemWidth + indicatorInset;
              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 360),
                    curve: Curves.easeOutCubic,
                    left: indicatorLeft,
                    top: (68 - 52) / 2,
                    width: indicatorWidth,
                    height: 52,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: isDark ? 0.14 : 0.18,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.22,
                          ),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _TabItem(
                        icon: LineIcons.home,
                        label: 'Home',
                        active: selectedTab == _Tab.home,
                        onTap: () => onSelected(_Tab.home),
                      ),
                      _TabItem(
                        icon: LineIcons.bookOpen,
                        label: 'Journal',
                        active: selectedTab == _Tab.journal,
                        onTap: () => onSelected(_Tab.journal),
                      ),
                      _TabItem(
                        icon: LineIcons.bullseye,
                        label: 'Track',
                        active: selectedTab == _Tab.track,
                        onTap: () => onSelected(_Tab.track),
                      ),
                      _TabItem(
                        icon: LineIcons.barChart,
                        label: 'Insights',
                        active: selectedTab == _Tab.insights,
                        onTap: () => onSelected(_Tab.insights),
                      ),
                    ],
                  ),
                ],
              );
            },
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
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.55),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.24),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
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

  const _ActionSheet({required this.onJournal, required this.onOcd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: theme.dividerColor),
        ),
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
          ],
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
    final fill = isDark ? AppTheme.charcoalInput : AppTheme.lightBg;
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
