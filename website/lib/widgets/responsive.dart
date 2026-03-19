import 'package:flutter/material.dart';

enum ScreenSize { mobile, tablet, desktop }

class Responsive {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return ScreenSize.mobile;
    if (width < tabletBreakpoint) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  static bool isMobile(BuildContext context) =>
      getScreenSize(context) == ScreenSize.mobile;

  static bool isTablet(BuildContext context) =>
      getScreenSize(context) == ScreenSize.tablet;

  static bool isDesktop(BuildContext context) =>
      getScreenSize(context) == ScreenSize.desktop;

  static double contentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1400) return 1200;
    if (width >= tabletBreakpoint) return width * 0.85;
    if (width >= mobileBreakpoint) return width * 0.9;
    return width * 0.92;
  }

  static EdgeInsets sectionPadding(BuildContext context) {
    final screen = getScreenSize(context);
    switch (screen) {
      case ScreenSize.mobile:
        return const EdgeInsets.symmetric(vertical: 64, horizontal: 20);
      case ScreenSize.tablet:
        return const EdgeInsets.symmetric(vertical: 80, horizontal: 40);
      case ScreenSize.desktop:
        return const EdgeInsets.symmetric(vertical: 120, horizontal: 40);
    }
  }
}

class ContentContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const ContentContainer({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: Responsive.contentWidth(context),
        padding: padding,
        child: child,
      ),
    );
  }
}
