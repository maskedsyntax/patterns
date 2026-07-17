import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';

import '../app_preferences.dart';
import '../screens/analytics_screen.dart';
import '../screens/journal_screen.dart';
import '../screens/ocd_tracker_screen.dart';
import '../screens/settings_screen.dart';
import 'home_screen.dart';
import 'recovery/recovery_hub_screen.dart';

/// Root navigator key for the desktop build (review prompts, timer completions).
final GlobalKey<NavigatorState> desktopRootNavigatorKey =
    GlobalKey<NavigatorState>();

enum DesktopTab { home, journal, track, recovery, insights, settings }

/// Desktop app shell: icon sidebar + main content.
class DesktopShell extends ConsumerStatefulWidget {
  const DesktopShell({super.key, this.initialTab});

  final DesktopTab? initialTab;

  @override
  ConsumerState<DesktopShell> createState() => DesktopShellState();
}

class DesktopShellState extends ConsumerState<DesktopShell> {
  late DesktopTab _selectedTab = widget.initialTab ?? _savedTab();

  void selectTab(DesktopTab tab) {
    if (tab == _selectedTab) return;
    appPreferences?.setString(desktopSelectedTabKey, tab.name);
    setState(() => _selectedTab = tab);
  }

  DesktopTab _savedTab() {
    final saved = appPreferences?.getString(desktopSelectedTabKey);
    return DesktopTab.values.firstWhere(
      (tab) => tab.name == saved,
      orElse: () => DesktopTab.home,
    );
  }

  Widget _pageFor(DesktopTab tab) {
    return switch (tab) {
      DesktopTab.home => DesktopHomeScreen(
        onOpenJournal: () => selectTab(DesktopTab.journal),
        onOpenTrack: () => selectTab(DesktopTab.track),
        onOpenRecovery: () => selectTab(DesktopTab.recovery),
        onOpenInsights: () => selectTab(DesktopTab.insights),
        onOpenSettings: () => selectTab(DesktopTab.settings),
      ),
      DesktopTab.journal => const JournalScreen(),
      DesktopTab.track => const OcdTrackerScreen(),
      DesktopTab.recovery => const RecoveryHubScreen(),
      DesktopTab.insights => const AnalyticsScreen(),
      DesktopTab.settings => const SettingsScreen(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 220,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                right: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Text(
                    'PATTERNS',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.8,
                      color: theme.colorScheme.onSurface.withOpacity(0.9),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _NavTile(
                  icon: LineIcons.home,
                  label: 'Home',
                  isSelected: _selectedTab == DesktopTab.home,
                  onTap: () => selectTab(DesktopTab.home),
                  theme: theme,
                ),
                _NavTile(
                  icon: LineIcons.penNib,
                  label: 'Journal',
                  isSelected: _selectedTab == DesktopTab.journal,
                  onTap: () => selectTab(DesktopTab.journal),
                  theme: theme,
                ),
                _NavTile(
                  icon: LineIcons.list,
                  label: 'Tracker',
                  isSelected: _selectedTab == DesktopTab.track,
                  onTap: () => selectTab(DesktopTab.track),
                  theme: theme,
                ),
                _NavTile(
                  icon: Icons.self_improvement_rounded,
                  label: 'Recovery',
                  isSelected: _selectedTab == DesktopTab.recovery,
                  onTap: () => selectTab(DesktopTab.recovery),
                  theme: theme,
                ),
                _NavTile(
                  icon: LineIcons.barChart,
                  label: 'Insights',
                  isSelected: _selectedTab == DesktopTab.insights,
                  onTap: () => selectTab(DesktopTab.insights),
                  theme: theme,
                ),
                const Spacer(),
                _NavTile(
                  icon: LineIcons.cog,
                  label: 'Settings',
                  isSelected: _selectedTab == DesktopTab.settings,
                  onTap: () => selectTab(DesktopTab.settings),
                  theme: theme,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: KeyedSubtree(
                key: ValueKey(_selectedTab.name),
                child: _pageFor(_selectedTab),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: widget.isSelected
                  ? LinearGradient(
                      colors: [
                        widget.theme.colorScheme.primary.withOpacity(0.16),
                        widget.theme.colorScheme.primary.withOpacity(0.08),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              color: !widget.isSelected && _isHovered
                  ? widget.theme.colorScheme.onSurface.withOpacity(0.05)
                  : (widget.isSelected ? null : Colors.transparent),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  color: widget.isSelected
                      ? widget.theme.colorScheme.primary
                      : widget.theme.colorScheme.onSurface.withOpacity(
                          _isHovered ? 0.8 : 0.5,
                        ),
                  size: 20,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 14,
                      color: widget.isSelected
                          ? widget.theme.colorScheme.onSurface
                          : widget.theme.colorScheme.onSurface.withOpacity(
                              _isHovered ? 0.9 : 0.6,
                            ),
                    ),
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
