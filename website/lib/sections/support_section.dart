import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/web_theme.dart';
import '../utils/analytics_service.dart';
import '../widgets/animated_on_scroll.dart';
import '../widgets/responsive.dart';

class SupportSection extends StatelessWidget {
  final bool isDark;

  const SupportSection({super.key, required this.isDark});

  static const String _sponsorsUrl = 'https://github.com/sponsors/maskedsyntax';

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final textColor = isDark ? WebTheme.darkText : WebTheme.lightText;
    final secondaryText = isDark
        ? WebTheme.darkTextSecondary
        : WebTheme.lightTextSecondary;
    final accent = isDark ? WebTheme.primaryYellow : WebTheme.primaryGold;
    final border = isDark ? WebTheme.darkBorder : WebTheme.lightBorder;
    final surface = isDark ? WebTheme.darkSurfaceAlt : WebTheme.lightSurface;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 56 : 88,
        horizontal: 0,
      ),
      child: ContentContainer(
        child: AnimatedOnScroll(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 620),
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 32 : 40,
                horizontal: isMobile ? 24 : 40,
              ),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: border.withValues(alpha: 0.6)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withValues(alpha: 0.14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.favorite_rounded,
                      color: accent,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Support Patterns',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunitoSans(
                      fontSize: isMobile ? 24 : 30,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Patterns is open source, independent, and ad-free. '
                    'If it has helped you, a small sponsorship keeps development going.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 15,
                      color: secondaryText,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _SponsorButton(
                    isDark: isDark,
                    onTap: () {
                      AnalyticsService.logEvent(
                        'sponsor_click',
                        parameters: const {'source': 'support_section'},
                      );
                      launchUrl(Uri.parse(_sponsorsUrl));
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SponsorButton extends StatefulWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _SponsorButton({required this.isDark, required this.onTap});

  @override
  State<_SponsorButton> createState() => _SponsorButtonState();
}

class _SponsorButtonState extends State<_SponsorButton> {
  bool _hovered = false;

  static const Color _sponsorPink = Color(0xFFEA4AAA);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: _hovered
                ? _sponsorPink
                : _sponsorPink.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FaIcon(
                FontAwesomeIcons.heart,
                size: 14,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Text(
                'Sponsor on GitHub',
                style: GoogleFonts.nunitoSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
