import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

void showAppSnackBar(
  BuildContext context,
  String message, {
  ScaffoldMessengerState? messenger,
}) {
  (messenger ?? ScaffoldMessenger.of(context)).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: AppTheme.textPrimary),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppTheme.charcoalInput,
    ),
  );
}
