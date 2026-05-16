import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../mobile/preferences.dart';
import '../theme/app_theme.dart';

enum ReviewTrigger { journalSaved, ocdLowDistress, analyticsLinger, manual }

/// Lightweight in-app rating prompts.
///
/// Trigger sites call `recordSessionStart` / `recordJournalSaved` /
/// `recordOcdSaved` to feed engagement counters, then call
/// `maybeRequestReview` at a designated "happy moment." The soft pre-prompt
/// filters out unhappy users (routing them to email feedback) before the
/// native store sheet is invoked, protecting the public rating.
class ReviewPromptService {
  static const _kFirstSeen = 'rating_first_seen_ts';
  static const _kJournalCount = 'rating_journal_count';
  static const _kOcdCount = 'rating_ocd_count';
  static const _kDistinctDays = 'rating_distinct_days';
  static const _kLastDayKey = 'rating_last_day_key';
  static const _kLastPromptTs = 'rating_last_prompt_ts';
  static const _kLastDeclineTs = 'rating_last_decline_ts';
  static const _kOptedOut = 'rating_opted_out';
  static const _kCompleted = 'rating_completed';

  static const _minDaysInstalled = 7;
  static const _minJournalEntries = 5;
  static const _minDistinctDays = 3;
  static const maxOcdDistressForTrigger = 4;
  static const _reprompAfterShowDays = 90;
  static const _reprompAfterDeclineDays = 30;

  static const _iosAppStoreId = '6762611172';
  static const _supportEmail = 'aftaab@aftaab.dev';

  static bool _inFlight = false;

  static bool get _isMobile {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid;
  }

  static Future<void> recordSessionStart() async {
    final prefs = mobilePreferences;
    if (prefs == null) return;
    final now = DateTime.now();
    if (!prefs.containsKey(_kFirstSeen)) {
      await prefs.setInt(_kFirstSeen, now.millisecondsSinceEpoch);
    }
    final todayKey = _dayKey(now);
    if (prefs.getString(_kLastDayKey) != todayKey) {
      final count = (prefs.getInt(_kDistinctDays) ?? 0) + 1;
      await prefs.setInt(_kDistinctDays, count);
      await prefs.setString(_kLastDayKey, todayKey);
    }
  }

  static Future<void> recordJournalSaved() async {
    final prefs = mobilePreferences;
    if (prefs == null) return;
    await prefs.setInt(_kJournalCount, (prefs.getInt(_kJournalCount) ?? 0) + 1);
  }

  static Future<void> recordOcdSaved(int distress) async {
    final prefs = mobilePreferences;
    if (prefs == null) return;
    await prefs.setInt(_kOcdCount, (prefs.getInt(_kOcdCount) ?? 0) + 1);
  }

  static bool _isEligible() {
    final prefs = mobilePreferences;
    if (prefs == null) return false;
    if (prefs.getBool(_kOptedOut) ?? false) return false;
    if (prefs.getBool(_kCompleted) ?? false) return false;

    final firstSeen = prefs.getInt(_kFirstSeen);
    if (firstSeen == null) return false;
    final now = DateTime.now();
    final daysInstalled = now
        .difference(DateTime.fromMillisecondsSinceEpoch(firstSeen))
        .inDays;
    if (daysInstalled < _minDaysInstalled) return false;

    if ((prefs.getInt(_kJournalCount) ?? 0) < _minJournalEntries) return false;
    if ((prefs.getInt(_kDistinctDays) ?? 0) < _minDistinctDays) return false;

    final lastPrompt = prefs.getInt(_kLastPromptTs);
    if (lastPrompt != null) {
      final since = now
          .difference(DateTime.fromMillisecondsSinceEpoch(lastPrompt))
          .inDays;
      if (since < _reprompAfterShowDays) return false;
    }
    final lastDecline = prefs.getInt(_kLastDeclineTs);
    if (lastDecline != null) {
      final since = now
          .difference(DateTime.fromMillisecondsSinceEpoch(lastDecline))
          .inDays;
      if (since < _reprompAfterDeclineDays) return false;
    }
    return true;
  }

  /// Eligibility-gated prompt for "happy moment" triggers.
  static Future<void> maybeRequestReview(
    BuildContext context, {
    required ReviewTrigger trigger,
  }) async {
    if (!_isMobile) return;
    if (_inFlight) return;
    if (!_isEligible()) return;
    _inFlight = true;
    try {
      // Brief delay so the closing screen / save toast settles first.
      await Future.delayed(const Duration(milliseconds: 600));
      if (!context.mounted) return;
      await _showSoftPrompt(context, manual: false);
    } finally {
      _inFlight = false;
    }
  }

  /// Manual entry from Settings — skips eligibility and cooldowns.
  static Future<void> requestReviewManually(BuildContext context) async {
    if (_inFlight) return;
    _inFlight = true;
    try {
      await _showSoftPrompt(context, manual: true);
    } finally {
      _inFlight = false;
    }
  }

  static Future<void> _showSoftPrompt(
    BuildContext context, {
    required bool manual,
  }) async {
    final prefs = mobilePreferences;
    if (!manual) {
      await prefs?.setInt(
        _kLastPromptTs,
        DateTime.now().millisecondsSinceEpoch,
      );
    }
    if (!context.mounted) return;

    final choice = await showDialog<_PromptChoice>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => const _SoftPromptDialog(),
    );

    switch (choice) {
      case null:
      case _PromptChoice.later:
        if (!manual) {
          await prefs?.setInt(
            _kLastDeclineTs,
            DateTime.now().millisecondsSinceEpoch,
          );
        }
      case _PromptChoice.yes:
        await _launchNativeReviewSheet();
        await prefs?.setBool(_kCompleted, true);
      case _PromptChoice.feedback:
        if (!manual) await prefs?.setBool(_kOptedOut, true);
        await _sendFeedbackEmail();
    }
  }

  static Future<void> _launchNativeReviewSheet() async {
    if (!_isMobile) return;
    final review = InAppReview.instance;
    try {
      if (await review.isAvailable()) {
        await review.requestReview();
        return;
      }
    } catch (_) {/* fall through to store listing */}
    try {
      await review.openStoreListing(appStoreId: _iosAppStoreId);
    } catch (_) {/* nothing we can do */}
  }

  static Future<void> _sendFeedbackEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: {
        'subject': 'Patterns feedback',
        'body': 'Hi,\n\nMy feedback about Patterns:\n\n',
      },
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {/* user can copy the address from the privacy page */}
  }

  static String _dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

enum _PromptChoice { yes, feedback, later }

class _SoftPromptDialog extends StatelessWidget {
  const _SoftPromptDialog();

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
                LineIcons.feather,
                color: theme.colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Is Patterns helping you?',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontFamily: AppTheme.displayFamily,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your honest read shapes what we build next. '
              'No pressure — pick whatever fits.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pop(_PromptChoice.yes),
                child: const Text('Yes, it helps'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () =>
                    Navigator.of(context).pop(_PromptChoice.feedback),
                child: const Text('Not really — share feedback'),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(_PromptChoice.later),
                child: Text(
                  'Maybe later',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
