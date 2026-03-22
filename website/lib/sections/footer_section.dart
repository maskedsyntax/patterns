import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/web_theme.dart';
import '../widgets/responsive.dart';

class FooterSection extends StatelessWidget {
  final bool isDark;

  const FooterSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final textColor = isDark ? WebTheme.darkText : WebTheme.lightText;
    final secondaryText =
        isDark ? WebTheme.darkTextSecondary : WebTheme.lightTextSecondary;
    final accent = isDark ? WebTheme.primaryYellow : WebTheme.primaryGold;
    final border = isDark ? WebTheme.darkBorder : WebTheme.lightBorder;
    final surface = isDark ? WebTheme.darkSurface : WebTheme.lightSurface;

    return Container(
      width: double.infinity,
      color: surface,
      child: Column(
        children: [
          Divider(height: 1, color: border.withValues(alpha: 0.5)),
          ContentContainer(
            padding: EdgeInsets.symmetric(
              vertical: isMobile ? 40 : 48,
              horizontal: 0,
            ),
            child: isMobile
                ? Column(
                    children: [
                      _buildBrand(accent, textColor, secondaryText),
                      const SizedBox(height: 32),
                      _buildLinks(secondaryText, accent),
                      const SizedBox(height: 32),
                      _buildCopyright(secondaryText),
                    ],
                  )
                : Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: _buildBrand(
                                  accent, textColor, secondaryText)),
                          _buildLinks(secondaryText, accent),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Divider(
                          height: 1,
                          color: border.withValues(alpha: 0.3)),
                      const SizedBox(height: 24),
                      _buildCopyright(secondaryText),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrand(Color accent, Color textColor, Color secondaryText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/logo.png', width: 28, height: 28),
            ),
            const SizedBox(width: 10),
            Text(
              'Patterns',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Clarity for the mind through\nstructured reflection.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: secondaryText,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLinks(Color secondaryText, Color accent) {
    return Wrap(
      spacing: 24,
      runSpacing: 12,
      children: [
        _FooterLink(
          label: 'GitHub',
          url: 'https://github.com/maskedsyntax/patterns',
          color: secondaryText,
          hoverColor: accent,
        ),
        _FooterLink(
          label: 'Releases',
          url: 'https://github.com/maskedsyntax/patterns/releases',
          color: secondaryText,
          hoverColor: accent,
        ),
        _FooterLink(
          label: 'Issues',
          url: 'https://github.com/maskedsyntax/patterns/issues',
          color: secondaryText,
          hoverColor: accent,
        ),
        _FooterLink(
          label: 'License',
          url: 'https://github.com/maskedsyntax/patterns/blob/master/LICENSE',
          color: secondaryText,
          hoverColor: accent,
        ),
      ],
    );
  }

  Widget _buildCopyright(Color secondaryText) {
    return Text(
      '\u00a9 ${DateTime.now().year} Patterns. MIT License.',
      style: GoogleFonts.inter(fontSize: 13, color: secondaryText),
    );
  }
}

class _FooterLink extends StatefulWidget {
  final String label;
  final String url;
  final Color color;
  final Color hoverColor;

  const _FooterLink({
    required this.label,
    required this.url,
    required this.color,
    required this.hoverColor,
  });

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => launchUrl(Uri.parse(widget.url)),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Text(
            widget.label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _hovered ? widget.hoverColor : widget.color,
            ),
          ),
        ),
      ),
    );
  }
}
