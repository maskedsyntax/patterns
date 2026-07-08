import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

import '../theme/app_theme.dart';

/// Semantic flavour of a toast. Controls only the leading icon and its tint -
/// the card itself stays calm and neutral to match the app's aesthetic.
enum ToastType { neutral, success, error, info }

/// Global messenger so toasts survive navigation (e.g. shown right after a
/// full-screen flow pops). Wired into [MaterialApp.scaffoldMessengerKey].
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void showAppSnackBar(
  BuildContext context,
  String message, {
  ToastType type = ToastType.neutral,
  ScaffoldMessengerState? messenger,
}) {
  final state =
      messenger ??
      rootScaffoldMessengerKey.currentState ??
      ScaffoldMessenger.of(context);
  // Prefer the live app context so the toast adopts the current theme
  // (light/dark, mobile/desktop) even when [context] has been disposed.
  final theme = Theme.of(rootScaffoldMessengerKey.currentContext ?? context);

  state
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.zero,
        duration: type == ToastType.error
            ? const Duration(seconds: 4)
            : const Duration(milliseconds: 2800),
        content: _ToastCard(message: message, type: type, theme: theme),
      ),
    );
}

class _ToastCard extends StatelessWidget {
  final String message;
  final ToastType type;
  final ThemeData theme;

  const _ToastCard({
    required this.message,
    required this.type,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final accent = _accent(type);
    final icon = _icon(type);

    return Container(
      padding: EdgeInsets.fromLTRB(icon == null ? 16 : 12, 12, 16, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: accent!.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accent, size: 17),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: AppTheme.sansFamily,
                color: theme.colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Color? _accent(ToastType type) {
    switch (type) {
      case ToastType.success:
        return AppTheme.softGreen;
      case ToastType.error:
        return AppTheme.mutedRed;
      case ToastType.info:
        return AppTheme.warmYellow;
      case ToastType.neutral:
        return null;
    }
  }

  static IconData? _icon(ToastType type) {
    switch (type) {
      case ToastType.success:
        return LineIcons.check;
      case ToastType.error:
        return LineIcons.exclamationTriangle;
      case ToastType.info:
        return LineIcons.infoCircle;
      case ToastType.neutral:
        return null;
    }
  }
}
