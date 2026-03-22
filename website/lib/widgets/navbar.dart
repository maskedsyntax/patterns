import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/web_theme.dart';
import 'responsive.dart';

class Navbar extends StatefulWidget {
  final bool isDark;
  final VoidCallback onThemeToggle;
  final Map<String, GlobalKey> sectionKeys;

  const Navbar({
    super.key,
    required this.isDark,
    required this.onThemeToggle,
    required this.sectionKeys,
  });

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  bool _mobileMenuOpen = false;

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
    setState(() => _mobileMenuOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isDark = widget.isDark;
    final bg = isDark ? WebTheme.darkBg : WebTheme.lightBg;
    final textColor = isDark ? WebTheme.darkText : WebTheme.lightText;
    final accent = isDark ? WebTheme.primaryYellow : WebTheme.primaryGold;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: bg.withValues(alpha: 0.92),
          child: ContentContainer(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  // Logo
                  InkWell(
                    onTap: () {
                      if (widget.sectionKeys['hero'] != null) {
                        _scrollTo(widget.sectionKeys['hero']!);
                      }
                    },
                    mouseCursor: SystemMouseCursors.click,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset('assets/logo.png',
                              width: 36, height: 36),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Patterns',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (!isMobile) ...[
                    _NavLink(
                      label: 'Features',
                      onTap: () => _scrollTo(widget.sectionKeys['features']!),
                      color: textColor,
                    ),
                    const SizedBox(width: 32),
                    _NavLink(
                      label: 'Preview',
                      onTap: () => _scrollTo(widget.sectionKeys['preview']!),
                      color: textColor,
                    ),
                    const SizedBox(width: 32),
                    _NavLink(
                      label: 'Privacy',
                      onTap: () => _scrollTo(widget.sectionKeys['privacy']!),
                      color: textColor,
                    ),
                    const SizedBox(width: 32),
                    _NavLink(
                      label: 'Download',
                      onTap: () => _scrollTo(widget.sectionKeys['download']!),
                      color: textColor,
                    ),
                    const SizedBox(width: 24),
                    IconButton(
                      onPressed: widget.onThemeToggle,
                      mouseCursor: SystemMouseCursors.click,
                      icon: Icon(
                        isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        size: 20,
                        color: textColor.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 16),
                    _GithubButton(accent: accent),
                  ] else ...[
                    IconButton(
                      onPressed: widget.onThemeToggle,
                      mouseCursor: SystemMouseCursors.click,
                      icon: Icon(
                        isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        size: 20,
                        color: textColor.withValues(alpha: 0.7),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          setState(() => _mobileMenuOpen = !_mobileMenuOpen),
                      mouseCursor: SystemMouseCursors.click,
                      icon: Icon(
                        _mobileMenuOpen ? Icons.close : Icons.menu,
                        color: textColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        // Mobile menu
        if (_mobileMenuOpen && isMobile)
          Container(
            width: double.infinity,
            color: bg.withValues(alpha: 0.98),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MobileNavLink(
                  label: 'Features',
                  onTap: () => _scrollTo(widget.sectionKeys['features']!),
                  color: textColor,
                ),
                _MobileNavLink(
                  label: 'Preview',
                  onTap: () => _scrollTo(widget.sectionKeys['preview']!),
                  color: textColor,
                ),
                _MobileNavLink(
                  label: 'Privacy',
                  onTap: () => _scrollTo(widget.sectionKeys['privacy']!),
                  color: textColor,
                ),
                _MobileNavLink(
                  label: 'Download',
                  onTap: () => _scrollTo(widget.sectionKeys['download']!),
                  color: textColor,
                ),
                const SizedBox(height: 12),
                _GithubButton(
                    accent:
                        isDark ? WebTheme.primaryYellow : WebTheme.primaryGold),
              ],
            ),
          ),
      ],
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _NavLink(
      {required this.label, required this.onTap, required this.color});

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
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
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _hovered
                  ? widget.color
                  : widget.color.withValues(alpha: 0.65),
            ),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}

class _MobileNavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _MobileNavLink(
      {required this.label, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      mouseCursor: SystemMouseCursors.click,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: color.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}

class _GithubButton extends StatefulWidget {
  final Color accent;
  const _GithubButton({required this.accent});

  @override
  State<_GithubButton> createState() => _GithubButtonState();
}

class _GithubButtonState extends State<_GithubButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => launchUrl(
            Uri.parse('https://github.com/maskedsyntax/patterns')),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: _hovered
                  ? widget.accent
                  : widget.accent.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, size: 16, color: Colors.black),
                const SizedBox(width: 6),
                Text(
                  'Star on GitHub',
                  style: GoogleFonts.inter(
                    fontSize: 14,
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
