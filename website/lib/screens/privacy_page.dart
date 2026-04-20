import 'package:flutter/material.dart';
import '../sections/privacy_section.dart';
import '../widgets/navbar.dart';
import '../theme/web_theme.dart';

class PrivacyPage extends StatefulWidget {
  final bool isDark;
  final VoidCallback onThemeToggle;

  const PrivacyPage({
    super.key,
    required this.isDark,
    required this.onThemeToggle,
  });

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDark ? WebTheme.darkSurface : WebTheme.lightSurface,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 100),
                PrivacySection(isDark: widget.isDark),
                // Simple footer for the privacy page
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
                    child: Text(
                      '← Back to Home',
                      style: TextStyle(
                        color: widget.isDark ? WebTheme.primaryYellow : WebTheme.primaryGold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Navbar(
              isDark: widget.isDark,
              onThemeToggle: widget.onThemeToggle,
              sectionKeys: const {}, // No scroll keys needed on this page
            ),
          ),
        ],
      ),
    );
  }
}
