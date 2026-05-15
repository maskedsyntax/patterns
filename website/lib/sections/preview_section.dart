import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/web_theme.dart';
import '../widgets/responsive.dart';
import '../widgets/animated_on_scroll.dart';

class PreviewSection extends StatelessWidget {
  final bool isDark;

  const PreviewSection({super.key, required this.isDark});

  static const _desktopMockups = [
    'assets/mockups/desktop-1.jpg',
    'assets/mockups/desktop-2.jpg',
    'assets/mockups/desktop-3.jpg',
    'assets/mockups/desktop-4.jpg',
    'assets/mockups/desktop-5.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final screen = Responsive.getScreenSize(context);
    final isMobile = screen == ScreenSize.mobile;
    final textColor = isDark ? WebTheme.darkText : WebTheme.lightText;
    final secondaryText = isDark
        ? WebTheme.darkTextSecondary
        : WebTheme.lightTextSecondary;
    final accent = isDark ? WebTheme.primaryYellow : WebTheme.primaryGold;

    final mobileMockup = _FeatureGraphic(
      width: isMobile ? double.infinity : 620,
      isDark: isDark,
    );
    final desktopMockup = _CyclingMockup(
      assets: _desktopMockups,
      width: isMobile ? double.infinity : 608,
      height: isMobile ? 220 : 380,
      aspectRatio: 1440 / 900,
      isDark: isDark,
    );

    return Container(
      width: double.infinity,
      color: isDark ? WebTheme.darkBg : WebTheme.lightBg,
      child: ContentContainer(
        padding: Responsive.sectionPadding(context),
        child: Column(
          children: [
            AnimatedOnScroll(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: accent.withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      'PREVIEW',
                      style: GoogleFonts.nunitoSans(
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
                    constraints: const BoxConstraints(maxWidth: 540),
                    child: Text(
                      'Real screens from Patterns — at home on mobile and on desktop. The journal, the OCD tracker, the analytics, and the settings.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunitoSans(
                        fontSize: isMobile ? 15 : 17,
                        color: secondaryText,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isMobile ? 56 : 96),
            AnimatedOnScroll(
              delay: const Duration(milliseconds: 100),
              child: _PlatformShowcase(
                eyebrow: 'MOBILE',
                title: 'Pocket-sized reflection',
                description:
                    'Capture obsessions, log distress, and write a quick journal entry — all from your phone. Your entries stay on your device, no accounts and no uploads.',
                mockup: mobileMockup,
                mockupOnLeft: true,
                accent: accent,
                textColor: textColor,
                secondaryText: secondaryText,
                isMobile: isMobile,
              ),
            ),
            SizedBox(height: isMobile ? 56 : 96),
            AnimatedOnScroll(
              delay: const Duration(milliseconds: 200),
              child: _PlatformShowcase(
                eyebrow: 'DESKTOP',
                title: 'Room to think',
                description:
                    'See your patterns at a glance — analytics, history, and a calm writing space with the room a bigger screen gives you. Native on macOS, Windows, and Linux.',
                mockup: desktopMockup,
                mockupOnLeft: false,
                accent: accent,
                textColor: textColor,
                secondaryText: secondaryText,
                isMobile: isMobile,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlatformShowcase extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String description;
  final Widget mockup;
  final bool mockupOnLeft;
  final Color accent;
  final Color textColor;
  final Color secondaryText;
  final bool isMobile;

  const _PlatformShowcase({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.mockup,
    required this.mockupOnLeft,
    required this.accent,
    required this.textColor,
    required this.secondaryText,
    required this.isMobile,
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
            color: accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: accent.withValues(alpha: 0.28)),
          ),
          child: Text(
            eyebrow,
            style: GoogleFonts.nunitoSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: accent,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: GoogleFonts.sourceSerif4(
            fontSize: isMobile ? 28 : 36,
            fontWeight: FontWeight.w700,
            height: 1.15,
            color: textColor,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          description,
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: GoogleFonts.nunitoSans(
            fontSize: 16,
            color: secondaryText,
            height: 1.6,
          ),
        ),
      ],
    );

    if (isMobile) {
      return Column(
        children: [
          mockup,
          const SizedBox(height: 32),
          copy,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: mockupOnLeft
          ? [
              mockup,
              const SizedBox(width: 56),
              Expanded(child: copy),
            ]
          : [
              Expanded(child: copy),
              const SizedBox(width: 56),
              mockup,
            ],
    );
  }
}

class _FeatureGraphic extends StatelessWidget {
  final double width;
  final bool isDark;

  // Native dimensions of feature-graphic.jpg.
  static const _aspect = 1024 / 500;

  const _FeatureGraphic({required this.width, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: _aspect,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.18),
                blurRadius: 40,
                offset: const Offset(0, 20),
                spreadRadius: -8,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/mockups/feature-graphic.jpg',
              fit: BoxFit.cover,
              semanticLabel: 'Patterns mobile preview',
            ),
          ),
        ),
      ),
    );
  }
}

class _CyclingMockup extends StatefulWidget {
  final List<String> assets;
  final double width;
  final double height;
  final double aspectRatio;
  final bool isDark;

  const _CyclingMockup({
    required this.assets,
    required this.width,
    required this.height,
    required this.aspectRatio,
    required this.isDark,
  });

  @override
  State<_CyclingMockup> createState() => _CyclingMockupState();
}

class _CyclingMockupState extends State<_CyclingMockup> {
  int _index = 0;
  Timer? _timer;
  bool _precached = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 3500), (_) {
      if (!mounted) return;
      setState(() => _index = (_index + 1) % widget.assets.length);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Preload every frame so cross-fades don't show a flash while the next
    // image decodes off disk.
    if (!_precached) {
      _precached = true;
      for (final asset in widget.assets) {
        precacheImage(AssetImage(asset), context);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: widget.isDark ? 0.5 : 0.18),
              blurRadius: 40,
              offset: const Offset(0, 20),
              spreadRadius: -8,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: Image.asset(
              widget.assets[_index],
              key: ValueKey(_index),
              fit: BoxFit.cover,
              semanticLabel: 'Patterns desktop screenshot ${_index + 1}',
            ),
          ),
        ),
      ),
    );
  }
}
