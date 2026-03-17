import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:window_manager/window_manager.dart';
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
  
  void toggle(bool currentlyDark) {
    if (currentlyDark) {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.dark;
    }
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    minimumSize: Size(1000, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

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
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Row(
        children: [
          // UNIFIED SIDEBAR (Navigation Part)
          Container(
            width: 72,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface, // Shared background with the list
              border: Border(right: BorderSide(color: theme.dividerColor.withOpacity(0.5))),
            ),
            child: Column(
              children: [
                const SizedBox(height: 48, child: DragToMoveArea(child: SizedBox.expand())),
                _PatternsLogo(theme: theme),
                const SizedBox(height: 48),
                _NavIcon(
                  icon: LineIcons.penNib,
                  isSelected: _selectedIndex == 0,
                  onTap: () => setState(() => _selectedIndex = 0),
                  theme: theme,
                  tooltip: 'Journal',
                ),
                _NavIcon(
                  icon: LineIcons.list,
                  isSelected: _selectedIndex == 1,
                  onTap: () => setState(() => _selectedIndex = 1),
                  theme: theme,
                  tooltip: 'OCD Tracker',
                ),
                _NavIcon(
                  icon: LineIcons.barChart,
                  isSelected: _selectedIndex == 2,
                  onTap: () => setState(() => _selectedIndex = 2),
                  theme: theme,
                  tooltip: 'Analytics',
                ),
                _NavIcon(
                  icon: LineIcons.cog,
                  isSelected: _selectedIndex == 3,
                  onTap: () => setState(() => _selectedIndex = 3),
                  theme: theme,
                  tooltip: 'Settings',
                ),
                const Spacer(),
                IconButton(
                  mouseCursor: SystemMouseCursors.click,
                  icon: Icon(
                    isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                    size: 20,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  onPressed: () {
                    ref.read(themeModeProvider.notifier).toggle(isDark);
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          
          // MAIN CONTENT (which will include its own contextual sidebar)
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

class _PatternsLogo extends StatelessWidget {
  final ThemeData theme;
  const _PatternsLogo({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(
        painter: LogoPainter(),
      ),
    );
  }
}

class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromLTWH(size.width * 0.25, size.height * 0.25, size.width * 0.5, size.height * 0.5),
      0, 4.5, false, paint
    );
    
    canvas.drawArc(
      Rect.fromLTWH(size.width * 0.35, size.height * 0.35, size.width * 0.3, size.height * 0.3),
      3, 4.5, false, paint
    );

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 1.5, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _NavIcon extends StatefulWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;
  final String tooltip;

  const _NavIcon({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.theme,
    required this.tooltip,
  });

  @override
  State<_NavIcon> createState() => _NavIconState();
}

class _NavIconState extends State<_NavIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Tooltip(
        message: widget.tooltip,
        preferBelow: false,
        margin: const EdgeInsets.only(left: 60),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: widget.isSelected 
                    ? widget.theme.colorScheme.primary.withOpacity(0.15) 
                    : (_isHovered ? widget.theme.colorScheme.onSurface.withOpacity(0.05) : Colors.transparent),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                widget.icon,
                color: widget.isSelected 
                    ? widget.theme.colorScheme.primary 
                    : widget.theme.colorScheme.onSurface.withOpacity(_isHovered ? 0.7 : 0.3),
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
