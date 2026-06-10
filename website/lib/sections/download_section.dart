import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../theme/web_theme.dart';
import '../widgets/responsive.dart';
import '../widgets/animated_on_scroll.dart';
import '../utils/analytics_service.dart';

class DownloadSection extends StatefulWidget {
  final bool isDark;

  const DownloadSection({super.key, required this.isDark});

  @override
  State<DownloadSection> createState() => _DownloadSectionState();
}

class _DownloadSectionState extends State<DownloadSection> {
  // Mac App Store listing for the desktop Patterns build.
  static const _macAppStoreUrl =
      'https://apps.apple.com/us/app/patterns-ocd-journaling/id6762611172?mt=12';

  static const _iosAppStoreUrl =
      'https://apps.apple.com/us/app/patterns-ocd-journaling/id6762611172';

  static const String? _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.maskedsyntax.patterns';

  String? _linuxUrl;
  String? _windowsUrl;
  String? _version;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchReleaseAssets();
  }

  Future<void> _fetchReleaseAssets() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.github.com/repos/maskedsyntax/patterns/releases/latest',
        ),
        headers: {'Accept': 'application/vnd.github+json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tagName = data['tag_name'] as String?;
        final assets = data['assets'] as List;
        for (final asset in assets) {
          final name = asset['name'] as String;
          final url = asset['browser_download_url'] as String;
          if (name.endsWith('.deb')) _linuxUrl = url;
          if (name.endsWith('.exe')) _windowsUrl = url;
        }
        _version = tagName;
      }
    } catch (_) {
      // Fallback handled by the GitHub releases link.
    }
    if (mounted) setState(() => _loading = false);
  }

  void _open(String url, String platform) {
    AnalyticsService.logDownload(platform, _version ?? 'unknown');
    launchUrl(Uri.parse(url), webOnlyWindowName: '_blank');
  }

  void _comingSoon(String platform) {
    AnalyticsService.logEvent(
      'download_coming_soon_click',
      parameters: {'platform': platform},
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = Responsive.getScreenSize(context);
    final isMobile = screen == ScreenSize.mobile;
    final textColor = widget.isDark ? WebTheme.darkText : WebTheme.lightText;
    final secondaryText = widget.isDark
        ? WebTheme.darkTextSecondary
        : WebTheme.lightTextSecondary;
    final accent = widget.isDark
        ? WebTheme.primaryYellow
        : WebTheme.primaryGold;
    final border = widget.isDark ? WebTheme.darkBorder : WebTheme.lightBorder;
    final surfaceAlt = widget.isDark
        ? WebTheme.darkSurfaceAlt
        : WebTheme.lightSurfaceAlt;

    return Container(
      width: double.infinity,
      color: widget.isDark ? WebTheme.darkBg : WebTheme.lightBg,
      child: ContentContainer(
        padding: Responsive.sectionPadding(context),
        child: AnimatedOnScroll(
          child: Column(
            children: [
              Text(
                'Download Patterns',
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
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Text(
                  'A calm, local-first space for journaling and OCD self-tracking — available where you reflect.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunitoSans(
                    fontSize: isMobile ? 15 : 17,
                    color: secondaryText,
                    height: 1.6,
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 40 : 56),
              _MobileHero(
                isDark: widget.isDark,
                isMobile: isMobile,
                accent: accent,
                textColor: textColor,
                secondaryText: secondaryText,
                border: border,
                surfaceAlt: surfaceAlt,
                iosUrl: _iosAppStoreUrl,
                playUrl: _playStoreUrl,
                onIosTap: () => _open(_iosAppStoreUrl, 'iOS'),
                onPlayTap: () => _playStoreUrl == null
                    ? _comingSoon('Android')
                    : _open(_playStoreUrl!, 'Android'),
              ),
              SizedBox(height: isMobile ? 56 : 80),
              _OtherDownloadsHeader(
                textColor: textColor,
                secondaryText: secondaryText,
                isMobile: isMobile,
              ),
              SizedBox(height: isMobile ? 24 : 32),
              _OtherPlatforms(
                isMobile: isMobile,
                isDark: widget.isDark,
                accent: accent,
                textColor: textColor,
                secondaryText: secondaryText,
                border: border,
                surfaceAlt: surfaceAlt,
                loading: _loading,
                linuxUrl: _linuxUrl,
                windowsUrl: _windowsUrl,
                onMac: () => _open(_macAppStoreUrl, 'macOS'),
                onWindows: () => _open(
                  _windowsUrl ??
                      'https://github.com/maskedsyntax/patterns/releases/latest',
                  'Windows',
                ),
                onLinux: () => _open(
                  _linuxUrl ??
                      'https://github.com/maskedsyntax/patterns/releases/latest',
                  'Linux',
                ),
              ),
              if (_version != null) ...[
                const SizedBox(height: 20),
                Text(
                  'Latest desktop release: $_version',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12,
                    color: secondaryText,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SelectionContainer.disabled(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      AnalyticsService.logGitHubClick();
                      launchUrl(
                        Uri.parse('https://github.com/maskedsyntax/patterns'),
                      );
                    },
                    child: Text.rich(
                      TextSpan(
                        text: 'Or build from source on ',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 14,
                          color: secondaryText,
                        ),
                        children: [
                          TextSpan(
                            text: 'GitHub',
                            style: GoogleFonts.nunitoSans(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileHero extends StatelessWidget {
  final bool isDark;
  final bool isMobile;
  final Color accent;
  final Color textColor;
  final Color secondaryText;
  final Color border;
  final Color surfaceAlt;
  final String? iosUrl;
  final String? playUrl;
  final VoidCallback onIosTap;
  final VoidCallback onPlayTap;

  const _MobileHero({
    required this.isDark,
    required this.isMobile,
    required this.accent,
    required this.textColor,
    required this.secondaryText,
    required this.border,
    required this.surfaceAlt,
    required this.iosUrl,
    required this.playUrl,
    required this.onIosTap,
    required this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    final copy = Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: accent.withValues(alpha: 0.25)),
          ),
          child: Text(
            'Mobile',
            style: GoogleFonts.nunitoSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: accent,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'On your phone',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: GoogleFonts.sourceSerif4(
            fontSize: isMobile ? 28 : 36,
            fontWeight: FontWeight.w700,
            height: 1.1,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Track obsessions, log distress, and journal in a calm private space. Your entries stay on your device — no accounts, no uploads.',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: GoogleFonts.nunitoSans(
            fontSize: 15,
            color: secondaryText,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.start,
          spacing: 12,
          runSpacing: 12,
          children: [
            _StoreBadge(
              storeName: 'App Store',
              prefix: 'Download on the',
              icon: FontAwesomeIcons.apple,
              comingSoon: iosUrl == null,
              onTap: onIosTap,
            ),
            _StoreBadge(
              storeName: 'Google Play',
              prefix: 'Get it on',
              icon: FontAwesomeIcons.googlePlay,
              comingSoon: playUrl == null,
              onTap: onPlayTap,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Requires iOS 14 or later · Android 8 or later',
          style: GoogleFonts.nunitoSans(
            fontSize: 12,
            color: secondaryText,
            height: 1.5,
          ),
        ),
      ],
    );

    final phone = _PhoneIllustration(
      isDark: isDark,
      accent: accent,
      border: border,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 28 : 40),
      decoration: BoxDecoration(
        color: surfaceAlt,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border.withValues(alpha: 0.5)),
      ),
      child: isMobile
          ? Column(children: [phone, const SizedBox(height: 28), copy])
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: copy),
                const SizedBox(width: 40),
                phone,
              ],
            ),
    );
  }
}

class _PhoneIllustration extends StatelessWidget {
  final bool isDark;
  final Color accent;
  final Color border;

  const _PhoneIllustration({
    required this.isDark,
    required this.accent,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    // Aspect ratio matches the underlying mockup (1284x2778) so the image
    // fills the frame without distortion.
    const height = 320.0;
    final width = height * (1284 / 2778);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/mockups/frame-1.jpg',
          fit: BoxFit.cover,
          semanticLabel: 'Patterns home screen on iPhone',
        ),
      ),
    );
  }
}

class _StoreBadge extends StatefulWidget {
  final String storeName;
  final String prefix;
  final FaIconData icon;
  final bool comingSoon;
  final VoidCallback onTap;

  const _StoreBadge({
    required this.storeName,
    required this.prefix,
    required this.icon,
    required this.comingSoon,
    required this.onTap,
  });

  @override
  State<_StoreBadge> createState() => _StoreBadgeState();
}

class _StoreBadgeState extends State<_StoreBadge> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final showComingSoon = widget.comingSoon;
    final opacity = showComingSoon ? 0.72 : 1.0;

    return SelectionContainer.disabled(
      child: Tooltip(
        message: showComingSoon
            ? '${widget.storeName} — coming soon'
            : 'Open ${widget.storeName}',
        child: MouseRegion(
          cursor: showComingSoon
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: Opacity(
              opacity: opacity,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _hovered && !showComingSoon
                            ? Colors.white.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(widget.icon, size: 24, color: Colors.white),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.prefix,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.8),
                                height: 1.0,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.storeName,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (showComingSoon)
                    Positioned(
                      top: -8,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: WebTheme.primaryYellow,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'Coming soon',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
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

class _OtherDownloadsHeader extends StatelessWidget {
  final Color textColor;
  final Color secondaryText;
  final bool isMobile;

  const _OtherDownloadsHeader({
    required this.textColor,
    required this.secondaryText,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Other download options',
          style: GoogleFonts.sourceSerif4(
            fontSize: isMobile ? 22 : 28,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Patterns runs natively on every desktop you use.',
          style: GoogleFonts.nunitoSans(
            fontSize: 14,
            color: secondaryText,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _OtherPlatforms extends StatelessWidget {
  final bool isMobile;
  final bool isDark;
  final Color accent;
  final Color textColor;
  final Color secondaryText;
  final Color border;
  final Color surfaceAlt;
  final bool loading;
  final String? linuxUrl;
  final String? windowsUrl;
  final VoidCallback onMac;
  final VoidCallback onWindows;
  final VoidCallback onLinux;

  const _OtherPlatforms({
    required this.isMobile,
    required this.isDark,
    required this.accent,
    required this.textColor,
    required this.secondaryText,
    required this.border,
    required this.surfaceAlt,
    required this.loading,
    required this.linuxUrl,
    required this.windowsUrl,
    required this.onMac,
    required this.onWindows,
    required this.onLinux,
  });

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      _DesktopCard(
        platform: 'macOS',
        icon: FontAwesomeIcons.apple,
        requirements: 'macOS 12 Monterey or later',
        actionLabel: 'Open in App Store',
        actionIcon: Icons.open_in_new_rounded,
        onTap: onMac,
        isDark: isDark,
        accent: accent,
        textColor: textColor,
        secondaryText: secondaryText,
        border: border,
        surfaceAlt: surfaceAlt,
      ),
      _DesktopCard(
        platform: 'Windows',
        icon: FontAwesomeIcons.windows,
        requirements: 'Windows 10 or later',
        actionLabel: loading ? 'Loading…' : 'Download .exe',
        actionIcon: Icons.download_rounded,
        onTap: onWindows,
        isDark: isDark,
        accent: accent,
        textColor: textColor,
        secondaryText: secondaryText,
        border: border,
        surfaceAlt: surfaceAlt,
        busy: loading,
      ),
      _DesktopCard(
        platform: 'Linux',
        icon: FontAwesomeIcons.linux,
        requirements: 'Ubuntu, Debian, and derivatives',
        actionLabel: loading ? 'Loading…' : 'Download .deb',
        actionIcon: Icons.download_rounded,
        onTap: onLinux,
        isDark: isDark,
        accent: accent,
        textColor: textColor,
        secondaryText: secondaryText,
        border: border,
        surfaceAlt: surfaceAlt,
        busy: loading,
      ),
    ];

    if (isMobile) {
      return Column(
        children: cards
            .map(
              (c) =>
                  Padding(padding: const EdgeInsets.only(bottom: 12), child: c),
            )
            .toList(),
      );
    }

    // IntrinsicHeight gives the Row a bounded height equal to the tallest
    // child, which lets CrossAxisAlignment.stretch make every card the same
    // height. Without it the Row inherits the scroll view's infinite height
    // and the stretch constraint blows up at layout time.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: cards
            .map(
              (c) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: c,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _DesktopCard extends StatefulWidget {
  final String platform;
  final FaIconData icon;
  final String requirements;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback onTap;
  final bool isDark;
  final Color accent;
  final Color textColor;
  final Color secondaryText;
  final Color border;
  final Color surfaceAlt;
  final bool busy;

  const _DesktopCard({
    required this.platform,
    required this.icon,
    required this.requirements,
    required this.actionLabel,
    required this.actionIcon,
    required this.onTap,
    required this.isDark,
    required this.accent,
    required this.textColor,
    required this.secondaryText,
    required this.border,
    required this.surfaceAlt,
    this.busy = false,
  });

  @override
  State<_DesktopCard> createState() => _DesktopCardState();
}

class _DesktopCardState extends State<_DesktopCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return SelectionContainer.disabled(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _hovered ? widget.surfaceAlt : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _hovered
                    ? widget.accent.withValues(alpha: 0.35)
                    : widget.border.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(widget.icon, size: 28, color: widget.accent),
                const SizedBox(height: 16),
                Text(
                  widget.platform,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: widget.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.requirements,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 13,
                    color: widget.secondaryText,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    if (widget.busy)
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: widget.accent,
                        ),
                      )
                    else
                      Icon(widget.actionIcon, size: 14, color: widget.accent),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.actionLabel,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: widget.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
