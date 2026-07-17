import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';

import '../app_preferences.dart';
import '../theme/app_theme.dart';
import 'paywall_sheet.dart';

/// Small "PRO" pill shown on locked feature cards. Tint uses [AppTheme.warmYellow]
/// so it reads as a premium accent in both light and dark themes.
class ProLockBadge extends StatelessWidget {
  const ProLockBadge({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = AppTheme.warmYellow;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LineIcons.lock, size: 12, color: accent),
          const SizedBox(width: 4),
          Text(
            'PRO',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Gate for Pro features. Returns true when Pro is unlocked; otherwise opens the
/// paywall and returns false. Use at the tap site of a locked feature:
///
/// ```dart
/// onTap: () {
///   if (requirePro(context, ref)) openFeature();
/// }
/// ```
bool requirePro(BuildContext context, WidgetRef ref) {
  if (ref.read(proProvider)) return true;
  PaywallSheet.show(context);
  return false;
}
