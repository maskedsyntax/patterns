import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/web_theme.dart';
import '../widgets/responsive.dart';
import '../widgets/animated_on_scroll.dart';

class FeaturesSection extends StatelessWidget {
  final bool isDark;

  const FeaturesSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final screen = Responsive.getScreenSize(context);
    final isMobile = screen == ScreenSize.mobile;
    final textColor = isDark ? WebTheme.darkText : WebTheme.lightText;
    final secondaryText =
        isDark ? WebTheme.darkTextSecondary : WebTheme.lightTextSecondary;
    final accent = isDark ? WebTheme.primaryYellow : WebTheme.primaryGold;

    final features = [
      _FeatureData(
        icon: Icons.edit_note_rounded,
        title: 'Daily Journaling',
        description:
            'A minimalist writing space to record your thoughts. Each entry is tied to a specific date, building a chronological history of your mental well-being.',
      ),
      _FeatureData(
        icon: Icons.track_changes_rounded,
        title: 'OCD Tracking',
        description:
            'Document obsessions and compulsions as they happen. Record the nature of thoughts, actions taken in response, and distress levels on a 0-10 scale.',
      ),
      _FeatureData(
        icon: Icons.insights_rounded,
        title: 'Pattern Analytics',
        description:
            'Visualize trends over time with intuitive charts and heatmaps. Identify patterns that help prepare clear information for professional consultations.',
      ),
      _FeatureData(
        icon: Icons.shield_rounded,
        title: 'Privacy First',
        description:
            'All data stays on your computer. No cloud uploads, no third-party sharing. Your reflections and personal data remain entirely under your control.',
      ),
      _FeatureData(
        icon: Icons.dark_mode_rounded,
        title: 'Dark & Light Modes',
        description:
            'Switch between carefully crafted dark and light themes to match your environment and reduce eye strain during late-night reflections.',
      ),
      _FeatureData(
        icon: Icons.desktop_mac_rounded,
        title: 'Native Desktop',
        description:
            'Built natively for macOS and Linux. Fast startup, minimal resource usage, and a clean interface that feels right at home on your desktop.',
      ),
    ];

    return Container(
      width: double.infinity,
      color: isDark ? WebTheme.darkSurface : WebTheme.lightSurface,
      child: ContentContainer(
        padding: Responsive.sectionPadding(context),
        child: Column(
          children: [
            AnimatedOnScroll(
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border:
                          Border.all(color: accent.withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      'FEATURES',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: accent,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Everything you need.\nNothing you don\'t.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: isMobile ? 32 : 48,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      letterSpacing: -1.5,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 480,
                    child: Text(
                      'Designed to be simple, focused, and respectful of your privacy.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: isMobile ? 15 : 17,
                        color: secondaryText,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isMobile ? 48 : 72),
            // Feature grid
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = isMobile
                    ? 1
                    : screen == ScreenSize.tablet
                        ? 2
                        : 3;
                return Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: features.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final feature = entry.value;
                    final itemWidth = crossAxisCount == 1
                        ? constraints.maxWidth
                        : (constraints.maxWidth - (crossAxisCount - 1) * 24) /
                            crossAxisCount;
                    return AnimatedOnScroll(
                      delay: Duration(milliseconds: idx * 100),
                      child: SizedBox(
                        width: itemWidth,
                        child: _FeatureCard(
                          feature: feature,
                          isDark: isDark,
                          accent: accent,
                          textColor: textColor,
                          secondaryText: secondaryText,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String description;

  _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _FeatureCard extends StatefulWidget {
  final _FeatureData feature;
  final bool isDark;
  final Color accent;
  final Color textColor;
  final Color secondaryText;

  const _FeatureCard({
    required this.feature,
    required this.isDark,
    required this.accent,
    required this.textColor,
    required this.secondaryText,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final border = widget.isDark ? WebTheme.darkBorder : WebTheme.lightBorder;
    final surfaceAlt =
        widget.isDark ? WebTheme.darkSurfaceAlt : WebTheme.lightSurfaceAlt;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: _hovered ? surfaceAlt : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovered
                ? widget.accent.withValues(alpha: 0.2)
                : border.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: widget.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.feature.icon,
                size: 24,
                color: widget.accent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.feature.title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: widget.textColor,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.feature.description,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.6,
                color: widget.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
