import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/web_theme.dart';
import '../widgets/responsive.dart';

class HeroSection extends StatelessWidget {
  final bool isDark;
  final VoidCallback onDownloadTap;

  const HeroSection({
    super.key,
    required this.isDark,
    required this.onDownloadTap,
  });

  @override
  Widget build(BuildContext context) {
    final screen = Responsive.getScreenSize(context);
    final isMobile = screen == ScreenSize.mobile;
    final textColor = isDark ? WebTheme.darkText : WebTheme.lightText;
    final secondaryText =
        isDark ? WebTheme.darkTextSecondary : WebTheme.lightTextSecondary;
    final accent = isDark ? WebTheme.primaryYellow : WebTheme.primaryAmber;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0A0A0A),
                  Color(0xFF0D0D00),
                  Color(0xFF0A0A0A),
                ],
              )
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFAFAFA),
                  Color(0xFFFFFDF0),
                  Color(0xFFFAFAFA),
                ],
              ),
      ),
      child: ContentContainer(
        padding: EdgeInsets.only(
          top: isMobile ? 100 : 140,
          bottom: isMobile ? 80 : 120,
        ),
        child: Column(
          children: [
            // Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: accent.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Open Source & Privacy-First',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: accent,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Headline
            Text(
              'Clarity for\nthe mind.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: isMobile
                    ? 48
                    : screen == ScreenSize.tablet
                        ? 64
                        : 80,
                fontWeight: FontWeight.w800,
                height: 1.05,
                letterSpacing: -3,
                color: textColor,
              ),
            ),
            const SizedBox(height: 24),
            // Sub-headline
            SizedBox(
              width: isMobile ? double.infinity : 560,
              child: Text(
                'A focused desktop app for daily journaling and tracking obsessive-compulsive patterns through structured reflection.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 16 : 19,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                  color: secondaryText,
                ),
              ),
            ),
            const SizedBox(height: 48),
            // CTA buttons
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                _PrimaryButton(
                  label: 'Download for Free',
                  icon: Icons.download_rounded,
                  onTap: onDownloadTap,
                  accent: accent,
                ),
                _SecondaryButton(
                  label: 'View on GitHub',
                  icon: Icons.code_rounded,
                  onTap: () {},
                  isDark: isDark,
                  accent: accent,
                ),
              ],
            ),
            SizedBox(height: isMobile ? 60 : 80),
            // App preview mockup
            _AppPreview(isDark: isDark, screenWidth: screenWidth, isMobile: isMobile),
          ],
        ),
      ),
    );
  }
}

class _AppPreview extends StatelessWidget {
  final bool isDark;
  final double screenWidth;
  final bool isMobile;

  const _AppPreview({
    required this.isDark,
    required this.screenWidth,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? WebTheme.darkSurface : WebTheme.lightSurface;
    final border = isDark ? WebTheme.darkBorder : WebTheme.lightBorder;
    final accent = isDark ? WebTheme.primaryYellow : WebTheme.primaryAmber;
    final text = isDark ? WebTheme.darkText : WebTheme.lightText;
    final textSec = isDark ? WebTheme.darkTextSecondary : WebTheme.lightTextSecondary;
    final surfaceAlt = isDark ? WebTheme.darkSurfaceAlt : WebTheme.lightSurfaceAlt;

    return Container(
      constraints: const BoxConstraints(maxWidth: 960),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 60,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          // Window chrome
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: surfaceAlt,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(bottom: BorderSide(color: border)),
            ),
            child: Row(
              children: [
                _dot(const Color(0xFFFF5F57)),
                const SizedBox(width: 8),
                _dot(const Color(0xFFFFBD2E)),
                const SizedBox(width: 8),
                _dot(const Color(0xFF27C93F)),
                const Spacer(),
                Text(
                  'Patterns',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: textSec,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 52),
              ],
            ),
          ),
          // App content mockup
          SizedBox(
            height: isMobile ? 240 : 420,
            child: Row(
              children: [
                // Sidebar
                Container(
                  width: isMobile ? 48 : 64,
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: border)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _sidebarIcon(accent, true),
                      const SizedBox(height: 12),
                      _sidebarIcon(textSec.withValues(alpha: 0.3), false),
                      const SizedBox(height: 12),
                      _sidebarIcon(textSec.withValues(alpha: 0.3), false),
                      const SizedBox(height: 12),
                      _sidebarIcon(textSec.withValues(alpha: 0.3), false),
                    ],
                  ),
                ),
                // Entry list
                if (!isMobile)
                  Container(
                    width: 220,
                    decoration: BoxDecoration(
                      color: surfaceAlt,
                      border: Border(right: BorderSide(color: border)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.add, size: 14, color: accent),
                              const SizedBox(width: 6),
                              Text(
                                'New Entry',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _entryItem('March 19, 2026', 'A moment of clarity...', true, accent, text, textSec, border),
                        const SizedBox(height: 8),
                        _entryItem('March 18, 2026', 'Practiced mindfulness...', false, accent, text, textSec, border),
                        const SizedBox(height: 8),
                        _entryItem('March 17, 2026', 'Reflected on progress...', false, accent, text, textSec, border),
                      ],
                    ),
                  ),
                // Main editor
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 16 : 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'March 19, 2026',
                          style: GoogleFonts.inter(
                            fontSize: isMobile ? 12 : 14,
                            fontWeight: FontWeight.w500,
                            color: textSec,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'A moment of clarity',
                          style: GoogleFonts.inter(
                            fontSize: isMobile ? 18 : 24,
                            fontWeight: FontWeight.w700,
                            color: text,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Today I noticed a pattern in my thinking that I hadn\'t seen before. The structured reflection helped me identify triggers and responses more clearly...',
                          style: GoogleFonts.inter(
                            fontSize: isMobile ? 13 : 15,
                            height: 1.7,
                            color: textSec,
                          ),
                        ),
                        const Spacer(),
                        // Fake cursor line
                        Row(
                          children: [
                            Container(
                              width: 2,
                              height: 18,
                              color: accent,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color color) => Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _sidebarIcon(Color color, bool active) => Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          active ? Icons.edit_note : Icons.circle_outlined,
          size: 16,
          color: color,
        ),
      );

  Widget _entryItem(String date, String preview, bool active, Color accent,
      Color text, Color textSec, Color border) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: active ? accent.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: active ? Border.all(color: accent.withValues(alpha: 0.2)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: active ? accent : textSec,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            preview,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: textSec,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color accent;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.accent,
  });

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            decoration: BoxDecoration(
              color: _hovered ? widget.accent : widget.accent.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: widget.accent.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 18, color: Colors.black),
                const SizedBox(width: 10),
                Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
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

class _SecondaryButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final Color accent;

  const _SecondaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isDark,
    required this.accent,
  });

  @override
  State<_SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<_SecondaryButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final border = widget.isDark ? WebTheme.darkBorder : WebTheme.lightBorder;
    final textColor = widget.isDark ? WebTheme.darkText : WebTheme.lightText;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            decoration: BoxDecoration(
              color: _hovered
                  ? (widget.isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.03))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 18, color: textColor.withValues(alpha: 0.7)),
                const SizedBox(width: 10),
                Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor.withValues(alpha: 0.8),
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
