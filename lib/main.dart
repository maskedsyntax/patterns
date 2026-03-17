import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'theme/app_theme.dart';
import 'screens/journal_screen.dart';
import 'screens/ocd_tracker_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/settings_screen.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
  
  void toggle() {
    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.dark;
    }
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: PatternsApp(),
    ),
  );
}

class PatternsApp extends ConsumerWidget {
  const PatternsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
      title: 'Patterns',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const JournalScreen(),
    const OcdTrackerScreen(),
    const AnalyticsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentThemeMode = ref.watch(themeModeProvider);
    
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            labelType: NavigationRailLabelType.none,
            leading: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LineIcons.brain, color: Colors.black, size: 28),
                ),
                const SizedBox(height: 40),
              ],
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: IconButton(
                    icon: Icon(
                      currentThemeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
                      size: 20,
                    ),
                    onPressed: () {
                      ref.read(themeModeProvider.notifier).toggle();
                    },
                  ),
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(LineIcons.penNib),
                selectedIcon: Icon(LineIcons.penNib),
                label: Text('Journal'),
              ),
              NavigationRailDestination(
                icon: Icon(LineIcons.list),
                selectedIcon: Icon(LineIcons.list),
                label: Text('OCD Tracker'),
              ),
              NavigationRailDestination(
                icon: Icon(LineIcons.barChart),
                selectedIcon: Icon(LineIcons.barChart),
                label: Text('Analytics'),
              ),
              NavigationRailDestination(
                icon: Icon(LineIcons.cog),
                selectedIcon: Icon(LineIcons.cog),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}
