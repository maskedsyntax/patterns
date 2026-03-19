import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/web_theme.dart';
import '../widgets/responsive.dart';
import '../widgets/animated_on_scroll.dart';

class PrivacySection extends StatelessWidget {
  final bool isDark;

  const PrivacySection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final screen = Responsive.getScreenSize(context);
    final isMobile = screen == ScreenSize.mobile;
    final textColor = isDark ? WebTheme.darkText : WebTheme.lightText;
    final secondaryText =
        isDark ? WebTheme.darkTextSecondary : WebTheme.lightTextSecondary;
    final accent = isDark ? WebTheme.primaryYellow : WebTheme.primaryAmber;
    final surface = isDark ? WebTheme.darkSurface : WebTheme.lightSurface;
    final border = isDark ? WebTheme.darkBorder : WebTheme.lightBorder;

    return Container(
      width: double.infinity,
      color: surface,
      child: ContentContainer(
        padding: Responsive.sectionPadding(context),
        child: AnimatedOnScroll(
          child: Column(
            children: [
              // Large lock icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.lock_rounded,
                  size: 36,
                  color: accent,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Your data stays yours.',
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
                width: 560,
                child: Text(
                  'Patterns is completely offline. No accounts, no cloud sync, no telemetry. Everything lives on your machine and nowhere else.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 15 : 17,
                    color: secondaryText,
                    height: 1.6,
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 40 : 56),
              // Privacy points
              LayoutBuilder(
                builder: (context, constraints) {
                  final points = [
                    _PrivacyPoint(
                      icon: Icons.cloud_off_rounded,
                      title: 'No Cloud',
                      description: 'Zero data leaves your device. Ever.',
                    ),
                    _PrivacyPoint(
                      icon: Icons.visibility_off_rounded,
                      title: 'No Tracking',
                      description: 'No analytics, no telemetry, no cookies.',
                    ),
                    _PrivacyPoint(
                      icon: Icons.code_rounded,
                      title: 'Open Source',
                      description:
                          'Fully auditable code. Verify it yourself.',
                    ),
                  ];

                  if (isMobile) {
                    return Column(
                      children: points
                          .map((p) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _PrivacyCard(
                                  point: p,
                                  isDark: isDark,
                                  accent: accent,
                                  textColor: textColor,
                                  secondaryText: secondaryText,
                                  border: border,
                                ),
                              ))
                          .toList(),
                    );
                  }

                  return Row(
                    children: points
                        .map((p) => Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: _PrivacyCard(
                                  point: p,
                                  isDark: isDark,
                                  accent: accent,
                                  textColor: textColor,
                                  secondaryText: secondaryText,
                                  border: border,
                                ),
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrivacyPoint {
  final IconData icon;
  final String title;
  final String description;

  _PrivacyPoint({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _PrivacyCard extends StatelessWidget {
  final _PrivacyPoint point;
  final bool isDark;
  final Color accent;
  final Color textColor;
  final Color secondaryText;
  final Color border;

  const _PrivacyCard({
    required this.point,
    required this.isDark,
    required this.accent,
    required this.textColor,
    required this.secondaryText,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(point.icon, size: 28, color: accent),
          const SizedBox(height: 16),
          Text(
            point.title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            point.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: secondaryText,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
