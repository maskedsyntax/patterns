import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/web_theme.dart';
import '../widgets/responsive.dart';
import '../widgets/animated_on_scroll.dart';

class PreviewSection extends StatefulWidget {
  final bool isDark;

  const PreviewSection({super.key, required this.isDark});

  @override
  State<PreviewSection> createState() => _PreviewSectionState();
}

class _PreviewSectionState extends State<PreviewSection> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final screen = Responsive.getScreenSize(context);
    final isMobile = screen == ScreenSize.mobile;
    final textColor = widget.isDark ? WebTheme.darkText : WebTheme.lightText;
    final secondaryText = widget.isDark
        ? WebTheme.darkTextSecondary
        : WebTheme.lightTextSecondary;
    final accent =
        widget.isDark ? WebTheme.primaryYellow : WebTheme.primaryAmber;

    final tabs = ['Journal', 'OCD Tracker', 'Analytics'];

    return Container(
      width: double.infinity,
      color: widget.isDark ? WebTheme.darkBg : WebTheme.lightBg,
      child: ContentContainer(
        padding: Responsive.sectionPadding(context),
        child: Column(
          children: [
            AnimatedOnScroll(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border:
                          Border.all(color: accent.withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      'PREVIEW',
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
                    'See it in action',
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
                    width: 500,
                    child: Text(
                      'Three focused screens designed to help you track, reflect, and understand your patterns.',
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
            SizedBox(height: isMobile ? 32 : 48),
            // Tab switcher
            AnimatedOnScroll(
              delay: const Duration(milliseconds: 150),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? WebTheme.darkSurfaceAlt
                      : WebTheme.lightSurfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (widget.isDark
                            ? WebTheme.darkBorder
                            : WebTheme.lightBorder)
                        .withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: tabs.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final label = entry.value;
                    final isActive = idx == _selectedTab;
                    return InkWell(
                      onTap: () => setState(() => _selectedTab = idx),
                      mouseCursor: SystemMouseCursors.click,
                      borderRadius: BorderRadius.circular(8),
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 16 : 24,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? accent
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          label,
                          style: GoogleFonts.inter(
                            fontSize: isMobile ? 13 : 14,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w500,
                            color: isActive
                                ? Colors.black
                                : secondaryText,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: isMobile ? 32 : 48),
            // Preview content
            AnimatedOnScroll(
              delay: const Duration(milliseconds: 300),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _PreviewMockup(
                  key: ValueKey(_selectedTab),
                  tabIndex: _selectedTab,
                  isDark: widget.isDark,
                  isMobile: isMobile,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewMockup extends StatelessWidget {
  final int tabIndex;
  final bool isDark;
  final bool isMobile;

  const _PreviewMockup({
    super.key,
    required this.tabIndex,
    required this.isDark,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? WebTheme.darkSurface : WebTheme.lightSurface;
    final border = isDark ? WebTheme.darkBorder : WebTheme.lightBorder;
    final accent = isDark ? WebTheme.primaryYellow : WebTheme.primaryAmber;
    final text = isDark ? WebTheme.darkText : WebTheme.lightText;
    final textSec =
        isDark ? WebTheme.darkTextSecondary : WebTheme.lightTextSecondary;
    final surfaceAlt =
        isDark ? WebTheme.darkSurfaceAlt : WebTheme.lightSurfaceAlt;

    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          height: isMobile ? 300 : 460,
          child: _buildContent(accent, text, textSec, surfaceAlt, border),
        ),
      ),
    );
  }

  Widget _buildContent(
      Color accent, Color text, Color textSec, Color surfaceAlt, Color border) {
    switch (tabIndex) {
      case 0:
        return _journalPreview(accent, text, textSec, surfaceAlt, border);
      case 1:
        return _ocdPreview(accent, text, textSec, surfaceAlt, border);
      case 2:
        return _analyticsPreview(accent, text, textSec, surfaceAlt, border);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _journalPreview(
      Color accent, Color text, Color textSec, Color surfaceAlt, Color border) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 20 : 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 16, color: accent),
              const SizedBox(width: 8),
              Text(
                'Wednesday, March 19',
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textSec),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Saved',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Noticing the small wins',
            style: GoogleFonts.inter(
              fontSize: isMobile ? 20 : 28,
              fontWeight: FontWeight.w700,
              color: text,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Today was a good day. I caught myself spiraling into a compulsive checking pattern but managed to pause, breathe, and redirect my attention. The structured tracking from yesterday helped me recognize the trigger earlier than usual.\n\nSmall victories matter. Each time I choose a different response, it gets a little easier.',
            style: GoogleFonts.inter(
              fontSize: isMobile ? 14 : 16,
              height: 1.7,
              color: textSec,
            ),
            maxLines: isMobile ? 6 : 10,
            overflow: TextOverflow.fade,
          ),
        ],
      ),
    );
  }

  Widget _ocdPreview(
      Color accent, Color text, Color textSec, Color surfaceAlt, Color border) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 20 : 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recent Entries',
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 18 : 22,
                  fontWeight: FontWeight.w700,
                  color: text,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, size: 14, color: Colors.black),
                    const SizedBox(width: 4),
                    Text(
                      'Track New',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                _ocdEntry('Checking (Door locks)', 'Obsession', 6, accent, text,
                    textSec, surfaceAlt, border, '2:30 PM'),
                const SizedBox(height: 12),
                _ocdEntry('Hand washing', 'Compulsion', 4, accent, text, textSec,
                    surfaceAlt, border, '11:15 AM'),
                if (!isMobile) ...[
                  const SizedBox(height: 12),
                  _ocdEntry('Intrusive thought', 'Obsession', 7, accent, text,
                      textSec, surfaceAlt, border, '9:00 AM'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ocdEntry(String title, String type, int distress, Color accent,
      Color text, Color textSec, Color surfaceAlt, Color border, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: text),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        type,
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: accent),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: textSec),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Distress meter
          Column(
            children: [
              Text(
                '$distress',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
              Text(
                '/10',
                style: GoogleFonts.inter(
                    fontSize: 11, color: textSec),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _analyticsPreview(
      Color accent, Color text, Color textSec, Color surfaceAlt, Color border) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 20 : 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Patterns',
            style: GoogleFonts.inter(
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.w700,
              color: text,
            ),
          ),
          const SizedBox(height: 16),
          // Stats row
          Row(
            children: [
              _statCard('Entries', '47', accent, text, textSec, surfaceAlt, border),
              const SizedBox(width: 12),
              _statCard('Avg Distress', '4.2', accent, text, textSec, surfaceAlt, border),
              const SizedBox(width: 12),
              _statCard('Streak', '12d', accent, text, textSec, surfaceAlt, border),
            ],
          ),
          const SizedBox(height: 16),
          // Chart mockup
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border.withValues(alpha: 0.5)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Distress Levels — Last 7 Days',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textSec,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final maxBarHeight = constraints.maxHeight - 24;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [6, 4, 7, 5, 3, 4, 2]
                              .map((val) => Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '$val',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: accent,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Container(
                                            height: (val / 10) * maxBarHeight,
                                            decoration: BoxDecoration(
                                              color: accent
                                                  .withValues(alpha: 0.7),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ))
                              .toList(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                        .map((d) => Expanded(
                              child: Text(
                                d,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                    fontSize: 10, color: textSec),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color accent, Color text,
      Color textSec, Color surfaceAlt, Color border) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: isMobile ? 18 : 24,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                  fontSize: 12, color: textSec),
            ),
          ],
        ),
      ),
    );
  }
}
