import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

import '../theme/app_theme.dart';

class TipThanksDialog extends StatelessWidget {
  const TipThanksDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const TipThanksDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? AppTheme.charcoalCard : theme.colorScheme.surface;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.14),
              ),
              alignment: Alignment.center,
              child: Icon(
                LineIcons.heart,
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Thank you',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontFamily: AppTheme.displayFamily,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your support means a lot. Patterns stays ad-free and independent because of people like you.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Glad to help'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
