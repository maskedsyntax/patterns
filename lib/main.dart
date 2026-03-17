import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'theme/app_theme.dart';
import 'screens/journal_screen.dart';
import 'screens/ocd_tracker_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: PatternsApp(),
    ),
  );
}

class PatternsApp extends StatelessWidget {
  const PatternsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patterns',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const JournalScreen(),
    const OcdTrackerScreen(),
    const Center(child: Text('Analytics coming soon')),
    const Center(child: Text('Settings coming soon')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            labelType: NavigationRailLabelType.none,
            backgroundColor: AppTheme.backgroundColor,
            indicatorColor: AppTheme.accentColor.withOpacity(0.1),
            selectedIconTheme: const IconThemeData(color: AppTheme.accentColor),
            unselectedIconTheme: IconThemeData(color: AppTheme.textSecondary.withOpacity(0.5)),
            leading: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LineIcons.brain, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 40),
              ],
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
