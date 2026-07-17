import 'dart:io' show Platform;

import 'package:flutter/foundation.dart'
    show debugPrint, kDebugMode, kIsWeb, visibleForTesting;
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_preferences.dart';
import '../theme/app_theme.dart';

enum ReviewTrigger {
  journalSaved,
  ocdLowDistress,
  urgeCompleted,
  erpCompleted,
  analyticsLinger,
  manual,
}

enum RatingPromptIneligibility {
  preferencesUnavailable,
  optedOut,
  completed,
  missingFirstSeen,
  tooRecentlyInstalled,
  notEnoughMeaningfulActions,
  notEnoughDistinctDays,
  promptCooldown,
  declineCooldown,
}

class RatingPromptDiagnostics {
  final DateTime? firstSeen;
  final int daysInstalled;
  final int journalCount;
  final int ocdCount;
  final int meaningfulActionCount;
  final int distinctDays;
  final DateTime? lastPrompt;
  final DateTime? lastDecline;
  final bool optedOut;
  final bool completed;
  final bool eligible;
  final RatingPromptIneligibility? reason;

  const RatingPromptDiagnostics({
    required this.firstSeen,
    required this.daysInstalled,
    required this.journalCount,
    required this.ocdCount,
    required this.meaningfulActionCount,
    required this.distinctDays,
    required this.lastPrompt,
    required this.lastDecline,
    required this.optedOut,
    required this.completed,
    required this.eligible,
    required this.reason,
  });
}

/// Lightweight in-app rating prompts.
///
/// Trigger sites record meaningful actions, then call `maybeRequestReview` at a
/// designated "happy moment." The soft pre-prompt filters out unhappy users
/// (routing them to email feedback) before the native store sheet is invoked.
class ReviewPromptService {
  static const _kFirstSeen = 'rating_first_seen_ts';
  static const _kJournalCount = 'rating_journal_count';
  static const _kOcdCount = 'rating_ocd_count';
  static const _kMeaningfulActionCount = 'rating_meaningful_action_count';
  static const _kDistinctDays = 'rating_distinct_days';
  static const _kLastDayKey = 'rating_last_day_key';
  static const _kLastPromptTs = 'rating_last_prompt_ts';
  static const _kLastDeclineTs = 'rating_last_decline_ts';
  static const _kOptedOut = 'rating_opted_out';
  static const _kCompleted = 'rating_completed';

  static const _minDaysInstalled = 2;
  static const _minMeaningfulActions = 2;
  static const _minDistinctDays = 2;
  static const maxOcdDistressForTrigger = 4;
  static const _reprompAfterShowDays = 90;
  static const _reprompAfterDeclineDays = 14;

  static const _iosAppStoreId = '6762611172';
  static const _androidPackage = 'com.maskedsyntax.patterns';
  static const _supportEmail = 'aftaab@aftaab.dev';

  static bool _inFlight = false;

  @visibleForTesting
  static const minDaysInstalled = _minDaysInstalled;

  @visibleForTesting
  static const minMeaningfulActions = _minMeaningfulActions;

  @visibleForTesting
  static const minDistinctDays = _minDistinctDays;

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
    await _recordMeaningfulAction();
  }

  static Future<void> recordOcdSaved(int distress) async {
    final prefs = mobilePreferences;
    if (prefs == null) return;
    await prefs.setInt(_kOcdCount, (prefs.getInt(_kOcdCount) ?? 0) + 1);
    await _recordMeaningfulAction();
  }

  static Future<void> recordUrgePracticeCompleted() async {
    await _recordMeaningfulAction();
  }

  static Future<void> recordErpPracticeCompleted() async {
    await _recordMeaningfulAction();
  }

  static Future<void> _recordMeaningfulAction() async {
    final prefs = mobilePreferences;
    if (prefs == null) return;
    await prefs.setInt(
      _kMeaningfulActionCount,
      (prefs.getInt(_kMeaningfulActionCount) ?? 0) + 1,
    );
  }

  static RatingPromptDiagnostics diagnostics() {
    final prefs = mobilePreferences;
    final now = DateTime.now();
    if (prefs == null) {
      return RatingPromptDiagnostics(
        firstSeen: null,
        daysInstalled: 0,
        journalCount: 0,
        ocdCount: 0,
        meaningfulActionCount: 0,
        distinctDays: 0,
        lastPrompt: null,
        lastDecline: null,
        optedOut: false,
        completed: false,
        eligible: false,
        reason: RatingPromptIneligibility.preferencesUnavailable,
      );
    }
    return _diagnosticsForPrefs(prefs, now);
  }

  @visibleForTesting
  static bool isEligibleForTesting() => diagnostics().eligible;

  @visibleForTesting
  static Future<void> setTestingState({
    DateTime? firstSeen,
    int journalCount = 0,
    int ocdCount = 0,
    int? meaningfulActionCount,
    int distinctDays = 0,
    DateTime? lastPrompt,
    DateTime? lastDecline,
    bool optedOut = false,
    bool completed = false,
  }) async {
    final prefs = mobilePreferences;
    if (prefs == null) return;
    for (final key in [
      _kFirstSeen,
      _kJournalCount,
      _kOcdCount,
      _kMeaningfulActionCount,
      _kDistinctDays,
      _kLastDayKey,
      _kLastPromptTs,
      _kLastDeclineTs,
      _kOptedOut,
      _kCompleted,
    ]) {
      await prefs.remove(key);
    }
    if (firstSeen != null) {
      await prefs.setInt(_kFirstSeen, firstSeen.millisecondsSinceEpoch);
    }
    await prefs.setInt(_kJournalCount, journalCount);
    await prefs.setInt(_kOcdCount, ocdCount);
    if (meaningfulActionCount != null) {
      await prefs.setInt(_kMeaningfulActionCount, meaningfulActionCount);
    }
    await prefs.setInt(_kDistinctDays, distinctDays);
    if (lastPrompt != null) {
      await prefs.setInt(_kLastPromptTs, lastPrompt.millisecondsSinceEpoch);
    }
    if (lastDecline != null) {
      await prefs.setInt(_kLastDeclineTs, lastDecline.millisecondsSinceEpoch);
    }
    await prefs.setBool(_kOptedOut, optedOut);
    await prefs.setBool(_kCompleted, completed);
  }

  static RatingPromptDiagnostics _diagnosticsForPrefs(
    dynamic prefs,
    DateTime now,
  ) {
    final firstSeenMs = prefs.getInt(_kFirstSeen) as int?;
    final firstSeen = firstSeenMs == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(firstSeenMs);
    final daysInstalled = firstSeen == null
        ? 0
        : now.difference(firstSeen).inDays;
    final journalCount = prefs.getInt(_kJournalCount) as int? ?? 0;
    final ocdCount = prefs.getInt(_kOcdCount) as int? ?? 0;
    final meaningfulActionCount =
        prefs.getInt(_kMeaningfulActionCount) as int? ??
        journalCount + ocdCount;
    final distinctDays = prefs.getInt(_kDistinctDays) as int? ?? 0;
    final lastPromptMs = prefs.getInt(_kLastPromptTs) as int?;
    final lastDeclineMs = prefs.getInt(_kLastDeclineTs) as int?;
    final lastPrompt = lastPromptMs == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(lastPromptMs);
    final lastDecline = lastDeclineMs == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(lastDeclineMs);
    final optedOut = prefs.getBool(_kOptedOut) as bool? ?? false;
    final completed = prefs.getBool(_kCompleted) as bool? ?? false;

    RatingPromptIneligibility? reason;
    if (optedOut) {
      reason = RatingPromptIneligibility.optedOut;
    } else if (completed) {
      reason = RatingPromptIneligibility.completed;
    } else if (firstSeen == null) {
      reason = RatingPromptIneligibility.missingFirstSeen;
    } else if (daysInstalled < _minDaysInstalled) {
      reason = RatingPromptIneligibility.tooRecentlyInstalled;
    } else if (meaningfulActionCount < _minMeaningfulActions) {
      reason = RatingPromptIneligibility.notEnoughMeaningfulActions;
    } else if (distinctDays < _minDistinctDays) {
      reason = RatingPromptIneligibility.notEnoughDistinctDays;
    } else if (lastPrompt != null &&
        now.difference(lastPrompt).inDays < _reprompAfterShowDays) {
      reason = RatingPromptIneligibility.promptCooldown;
    } else if (lastDecline != null &&
        now.difference(lastDecline).inDays < _reprompAfterDeclineDays) {
      reason = RatingPromptIneligibility.declineCooldown;
    }

    return RatingPromptDiagnostics(
      firstSeen: firstSeen,
      daysInstalled: daysInstalled,
      journalCount: journalCount,
      ocdCount: ocdCount,
      meaningfulActionCount: meaningfulActionCount,
      distinctDays: distinctDays,
      lastPrompt: lastPrompt,
      lastDecline: lastDecline,
      optedOut: optedOut,
      completed: completed,
      eligible: reason == null,
      reason: reason,
    );
  }

  static bool _isEligible(ReviewTrigger trigger) {
    final diagnostics = ReviewPromptService.diagnostics();
    if (!diagnostics.eligible) {
      _debugLog(trigger, diagnostics);
      return false;
    }
    return true;
  }

  static void _debugLog(
    ReviewTrigger trigger,
    RatingPromptDiagnostics diagnostics,
  ) {
    if (!kDebugMode) return;
    debugPrint(
      'Review prompt skipped for ${trigger.name}: '
      '${diagnostics.reason?.name ?? 'eligible'} '
      '(daysInstalled=${diagnostics.daysInstalled}, '
      'meaningfulActions=${diagnostics.meaningfulActionCount}, '
      'distinctDays=${diagnostics.distinctDays}, '
      'lastPrompt=${diagnostics.lastPrompt}, '
      'lastDecline=${diagnostics.lastDecline}, '
      'optedOut=${diagnostics.optedOut}, '
      'completed=${diagnostics.completed})',
    );
  }

  /// Eligibility-gated prompt for "happy moment" triggers.
  static Future<void> maybeRequestReview(
    BuildContext context, {
    required ReviewTrigger trigger,
  }) async {
    if (!_isMobile) return;
    if (_inFlight) return;
    if (!_isEligible(trigger)) return;
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

  /// Manual entry from Settings - skips eligibility and cooldowns.
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
        // Manual taps go straight to the store listing - the native in-app
        // review sheet is rate-limited and frequently no-ops silently, which
        // looks broken when the user explicitly asked to rate. The automatic
        // "happy moment" path still prefers the in-app sheet.
        await _launchReview(preferStoreListing: manual);
        if (manual) {
          await prefs?.setBool(_kCompleted, true);
        } else {
          await prefs?.setInt(
            _kLastPromptTs,
            DateTime.now().millisecondsSinceEpoch,
          );
        }
      case _PromptChoice.feedback:
        if (!manual) await prefs?.setBool(_kOptedOut, true);
        await _sendFeedbackEmail();
    }
  }

  /// Routes the user to a place they can rate the app.
  ///
  /// When [preferStoreListing] is false we first try the native in-app review
  /// sheet (the right UX for an automatic "happy moment"). When true - or when
  /// the in-app sheet is unavailable - we open the store listing directly, with
  /// a plain URL launch as the final fallback so the user always lands
  /// somewhere.
  static Future<void> _launchReview({required bool preferStoreListing}) async {
    if (!_isMobile) return;
    final review = InAppReview.instance;
    if (!preferStoreListing) {
      try {
        if (await review.isAvailable()) {
          await review.requestReview();
          return;
        }
      } catch (_) {
        /* fall through to store listing */
      }
    }
    try {
      await review.openStoreListing(appStoreId: _iosAppStoreId);
      return;
    } catch (_) {
      /* fall through to direct URL */
    }
    await _openStoreUrl();
  }

  static Future<void> _openStoreUrl() async {
    final uri = Platform.isAndroid
        ? Uri.parse(
            'https://play.google.com/store/apps/details?id=$_androidPackage',
          )
        : Uri.parse(
            'https://apps.apple.com/app/id$_iosAppStoreId?action=write-review',
          );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      /* nothing we can do */
    }
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
    } catch (_) {
      /* user can copy the address from the privacy page */
    }
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
    final surface = AppTheme.charcoalCard;

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
              'No pressure. Pick whatever fits.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(_PromptChoice.yes),
                child: const Text('Yes, it helps'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () =>
                    Navigator.of(context).pop(_PromptChoice.feedback),
                child: const Text('Not really, feedback'),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(_PromptChoice.later),
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
