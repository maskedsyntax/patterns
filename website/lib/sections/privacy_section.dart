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
    final secondaryText = isDark
        ? WebTheme.darkTextSecondary
        : WebTheme.lightTextSecondary;
    final accent = isDark ? WebTheme.primaryYellow : WebTheme.primaryGold;
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
                child: Icon(Icons.lock_rounded, size: 36, color: accent),
              ),
              const SizedBox(height: 32),
              Text(
                'Your data stays yours.',
                textAlign: TextAlign.center,
                style: GoogleFonts.sourceSerif4(
                  fontSize: isMobile ? 32 : 48,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  letterSpacing: 0,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 560,
                child: Text(
                  'Patterns is completely offline. No accounts, no cloud sync, no telemetry. Everything lives on your machine and nowhere else.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunitoSans(
                    fontSize: isMobile ? 15 : 17,
                    color: secondaryText,
                    height: 1.6,
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 40 : 56),
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
                      description: 'Fully auditable code. Verify it yourself.',
                    ),
                  ];

                  if (isMobile) {
                    return Column(
                      children: points
                          .map(
                            (p) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _PrivacyCard(
                                point: p,
                                isDark: isDark,
                                accent: accent,
                                textColor: textColor,
                                secondaryText: secondaryText,
                                border: border,
                              ),
                            ),
                          )
                          .toList(),
                    );
                  }

                  return Row(
                    children: points
                        .map(
                          (p) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: _PrivacyCard(
                                point: p,
                                isDark: isDark,
                                accent: accent,
                                textColor: textColor,
                                secondaryText: secondaryText,
                                border: border,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
              SizedBox(height: isMobile ? 40 : 56),
              _PolicyDetails(
                isMobile: isMobile,
                textColor: textColor,
                secondaryText: secondaryText,
                border: border,
                accent: accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicyDetails extends StatelessWidget {
  final bool isMobile;
  final Color textColor;
  final Color secondaryText;
  final Color border;
  final Color accent;

  const _PolicyDetails({
    required this.isMobile,
    required this.textColor,
    required this.secondaryText,
    required this.border,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final details = [
      _PolicyBlock(
        title: 'What Patterns stores',
        body:
            'Patterns stores journal entries, OCD event notes, obsession or compulsion category, distress ratings, strategy notes, dates, timestamps, and basic app preferences such as theme and onboarding completion.',
      ),
      _PolicyBlock(
        title: 'Local storage',
        body:
            'Patterns does not currently create accounts, send entries to a server, provide cloud sync, or include third-party analytics. No third-party sharing: Patterns does not sell, share, or send your entries to third parties. Your app data is stored locally on your device.',
      ),
      _PolicyBlock(
        title: 'Export and import',
        body:
            'Manual export creates a JSON backup file in the location you choose. After export, that file may be handled by your device, cloud storage, email, or another document provider. Importing a backup replaces the current local journal and OCD entries in the app.',
      ),
      _PolicyBlock(
        title: 'Health and safety',
        body:
            'Patterns is for personal reflection and self-tracking. It does not diagnose, treat, prevent, or cure any condition, and it is not a replacement for care from a qualified clinician.',
      ),
      _PolicyBlock(
        title: 'Data deletion',
        body:
            'You can delete individual OCD events in the app. Settings also includes a Wipe all data action that deletes local journal entries, OCD events, and app preferences from the device.',
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 22 : 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Privacy policy',
            style: GoogleFonts.sourceSerif4(
              fontSize: isMobile ? 24 : 30,
              fontWeight: FontWeight.w700,
              height: 1.15,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: May 3, 2026',
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              color: secondaryText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ...details.map(
            (detail) => Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: _PolicyDetailBlock(
                detail: detail,
                textColor: textColor,
                secondaryText: secondaryText,
                accent: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyBlock {
  final String title;
  final String body;

  const _PolicyBlock({required this.title, required this.body});
}

class _PolicyDetailBlock extends StatelessWidget {
  final _PolicyBlock detail;
  final Color textColor;
  final Color secondaryText;
  final Color accent;

  const _PolicyDetailBlock({
    required this.detail,
    required this.textColor,
    required this.secondaryText,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.only(top: 9),
          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail.title,
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                detail.body,
                style: GoogleFonts.nunitoSans(
                  fontSize: 14,
                  color: secondaryText,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
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
            style: GoogleFonts.nunitoSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            point.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunitoSans(
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
