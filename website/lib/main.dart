import 'package:flutter/material.dart';
import 'theme/web_theme.dart';
import 'widgets/navbar.dart';
import 'sections/hero_section.dart';
import 'sections/features_section.dart';
import 'sections/preview_section.dart';
import 'sections/download_section.dart';
import 'sections/footer_section.dart';
import 'screens/privacy_page.dart';

void main() {
  runApp(const PatternsWebsite());
}

class PatternsWebsite extends StatefulWidget {
  const PatternsWebsite({super.key});

  @override
  State<PatternsWebsite> createState() => _PatternsWebsiteState();
}

class _PatternsWebsiteState extends State<PatternsWebsite> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patterns — Clarity for the mind',
      debugShowCheckedModeBanner: false,
      theme: WebTheme.lightTheme,
      darkTheme: WebTheme.darkTheme,
      themeMode: _themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => _HomePage(
              isDark: _themeMode == ThemeMode.dark,
              onThemeToggle: () {
                setState(() {
                  _themeMode = _themeMode == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
                });
              },
            ),
        '/privacy': (context) => PrivacyPage(
              isDark: _themeMode == ThemeMode.dark,
              onThemeToggle: () {
                setState(() {
                  _themeMode = _themeMode == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
                });
              },
            ),
      },
    );
  }
}

class _HomePage extends StatefulWidget {
  final bool isDark;
  final VoidCallback onThemeToggle;

  const _HomePage({required this.isDark, required this.onThemeToggle});

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  final _scrollController = ScrollController();

  final _heroKey = GlobalKey();
  final _featuresKey = GlobalKey();
  final _previewKey = GlobalKey();
  final _downloadKey = GlobalKey();

  Map<String, GlobalKey> get _sectionKeys => {
        'hero': _heroKey,
        'features': _featuresKey,
        'preview': _previewKey,
        'download': _downloadKey,
      };

  void _scrollToDownload() {
    final ctx = _downloadKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main scrollable content
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
                children: [
                  const SizedBox(height: 68),
                  Container(
                      key: _heroKey,
                      child: HeroSection(
                        isDark: widget.isDark,
                        onDownloadTap: _scrollToDownload,
                      )),
                  Container(
                      key: _featuresKey,
                      child: FeaturesSection(isDark: widget.isDark)),
                  Container(
                      key: _previewKey,
                      child: PreviewSection(isDark: widget.isDark)),
                  Container(
                      key: _downloadKey,
                      child: DownloadSection(isDark: widget.isDark)),
                  FooterSection(isDark: widget.isDark),
                ],
              ),
            ),
          // Fixed navbar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Navbar(
              isDark: widget.isDark,
              onThemeToggle: widget.onThemeToggle,
              sectionKeys: _sectionKeys,
            ),
          ),
        ],
      ),
    );
  }
}
