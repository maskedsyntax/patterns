import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/web_theme.dart';
import '../widgets/responsive.dart';
import '../widgets/animated_on_scroll.dart';

class DownloadSection extends StatelessWidget {
  final bool isDark;

  const DownloadSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final screen = Responsive.getScreenSize(context);
    final isMobile = screen == ScreenSize.mobile;
    final textColor = isDark ? WebTheme.darkText : WebTheme.lightText;
    final secondaryText =
        isDark ? WebTheme.darkTextSecondary : WebTheme.lightTextSecondary;
    final accent = isDark ? WebTheme.primaryYellow : WebTheme.primaryAmber;
    final border = isDark ? WebTheme.darkBorder : WebTheme.lightBorder;

    return Container(
      width: double.infinity,
      color: isDark ? WebTheme.darkBg : WebTheme.lightBg,
      child: ContentContainer(
        padding: Responsive.sectionPadding(context),
        child: AnimatedOnScroll(
          child: Column(
            children: [
              Text(
                'Ready to start?',
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
                  'Download Patterns for free and take the first step toward understanding your mind better.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: isMobile ? 15 : 17,
                    color: secondaryText,
                    height: 1.6,
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 40 : 56),
              // Download cards
              LayoutBuilder(
                builder: (context, constraints) {
                  final cards = [
                    _DownloadCard(
                      platform: 'macOS',
                      icon: Icons.desktop_mac_rounded,
                      format: '.dmg',
                      description: 'macOS 12 Monterey or later',
                      url:
                          'https://github.com/maskedsyntax/patterns/releases/latest',
                      isDark: isDark,
                      accent: accent,
                      textColor: textColor,
                      secondaryText: secondaryText,
                      border: border,
                    ),
                    _DownloadCard(
                      platform: 'Linux',
                      icon: Icons.terminal_rounded,
                      format: '.deb',
                      description: 'Ubuntu, Debian, and derivatives',
                      url:
                          'https://github.com/maskedsyntax/patterns/releases/latest',
                      isDark: isDark,
                      accent: accent,
                      textColor: textColor,
                      secondaryText: secondaryText,
                      border: border,
                      isBeta: true,
                    ),
                  ];

                  if (isMobile) {
                    return Column(
                      children: cards
                          .map((c) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: c,
                              ))
                          .toList(),
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: cards
                        .map((c) => Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: c,
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 32),
              // Source code link
              GestureDetector(
                onTap: () => launchUrl(
                    Uri.parse('https://github.com/maskedsyntax/patterns')),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Text.rich(
                    TextSpan(
                      text: 'Or build from source on ',
                      style: GoogleFonts.inter(
                          fontSize: 14, color: secondaryText),
                      children: [
                        TextSpan(
                          text: 'GitHub',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: accent,
                            decoration: TextDecoration.underline,
                            decorationColor: accent.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DownloadCard extends StatefulWidget {
  final String platform;
  final IconData icon;
  final String format;
  final String description;
  final String url;
  final bool isDark;
  final Color accent;
  final Color textColor;
  final Color secondaryText;
  final Color border;
  final bool isBeta;

  const _DownloadCard({
    required this.platform,
    required this.icon,
    required this.format,
    required this.description,
    required this.url,
    required this.isDark,
    required this.accent,
    required this.textColor,
    required this.secondaryText,
    required this.border,
    this.isBeta = false,
  });

  @override
  State<_DownloadCard> createState() => _DownloadCardState();
}

class _DownloadCardState extends State<_DownloadCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final surfaceAlt =
        widget.isDark ? WebTheme.darkSurfaceAlt : WebTheme.lightSurfaceAlt;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => launchUrl(Uri.parse(widget.url)),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: _hovered ? surfaceAlt : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered
                  ? widget.accent.withValues(alpha: 0.3)
                  : widget.border.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: [
              Icon(widget.icon, size: 40,
                  color: widget.isBeta
                      ? widget.secondaryText
                      : widget.accent),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.platform,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: widget.textColor,
                    ),
                  ),
                  if (widget.isBeta) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: widget.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: widget.accent.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        'BETA',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: widget.accent,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                widget.description,
                style: GoogleFonts.inter(
                    fontSize: 13, color: widget.secondaryText),
              ),
              const SizedBox(height: 20),
              if (widget.isBeta)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: widget.secondaryText.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Coming Soon',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: widget.secondaryText,
                    ),
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: widget.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.download_rounded,
                          size: 16, color: Colors.black),
                      const SizedBox(width: 8),
                      Text(
                        'Download ${widget.format}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
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
