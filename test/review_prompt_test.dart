import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:patterns/mobile/preferences.dart';
import 'package:patterns/services/review_prompt.dart';

void main() {
  Future<void> initializePrefs() async {
    SharedPreferences.setMockInitialValues({});
    await initMobilePreferences();
  }

  DateTime oldEnoughInstallDate() => DateTime.now().subtract(
    Duration(days: ReviewPromptService.minDaysInstalled + 1),
  );

  test('diagnostics reports missing preferences as ineligible', () {
    mobilePreferences = null;

    final diagnostics = ReviewPromptService.diagnostics();

    expect(diagnostics.eligible, isFalse);
    expect(
      diagnostics.reason,
      RatingPromptIneligibility.preferencesUnavailable,
    );
  });

  test('new installs are not eligible for automatic prompts', () async {
    await initializePrefs();
    await ReviewPromptService.recordSessionStart();
    await ReviewPromptService.recordJournalSaved();
    await ReviewPromptService.recordOcdSaved(2);

    final diagnostics = ReviewPromptService.diagnostics();

    expect(diagnostics.eligible, isFalse);
    expect(diagnostics.reason, RatingPromptIneligibility.tooRecentlyInstalled);
    expect(diagnostics.meaningfulActionCount, 2);
  });

  test(
    'eligible after install age, actions, and active day thresholds',
    () async {
      await initializePrefs();
      await ReviewPromptService.setTestingState(
        firstSeen: oldEnoughInstallDate(),
        meaningfulActionCount: ReviewPromptService.minMeaningfulActions,
        distinctDays: ReviewPromptService.minDistinctDays,
      );

      final diagnostics = ReviewPromptService.diagnostics();

      expect(diagnostics.eligible, isTrue);
      expect(diagnostics.reason, isNull);
    },
  );

  test('decline cooldown suppresses automatic prompts', () async {
    await initializePrefs();
    await ReviewPromptService.setTestingState(
      firstSeen: oldEnoughInstallDate(),
      meaningfulActionCount: ReviewPromptService.minMeaningfulActions,
      distinctDays: ReviewPromptService.minDistinctDays,
      lastDecline: DateTime.now(),
    );

    final diagnostics = ReviewPromptService.diagnostics();

    expect(diagnostics.eligible, isFalse);
    expect(diagnostics.reason, RatingPromptIneligibility.declineCooldown);
  });

  test('recent successful prompt suppresses repeat prompts', () async {
    await initializePrefs();
    await ReviewPromptService.setTestingState(
      firstSeen: oldEnoughInstallDate(),
      meaningfulActionCount: ReviewPromptService.minMeaningfulActions,
      distinctDays: ReviewPromptService.minDistinctDays,
      lastPrompt: DateTime.now(),
    );

    final diagnostics = ReviewPromptService.diagnostics();

    expect(diagnostics.eligible, isFalse);
    expect(diagnostics.reason, RatingPromptIneligibility.promptCooldown);
  });

  test(
    'feedback opt-out and completed rating suppress automatic prompts',
    () async {
      await initializePrefs();
      await ReviewPromptService.setTestingState(
        firstSeen: oldEnoughInstallDate(),
        meaningfulActionCount: ReviewPromptService.minMeaningfulActions,
        distinctDays: ReviewPromptService.minDistinctDays,
        optedOut: true,
      );

      expect(
        ReviewPromptService.diagnostics().reason,
        RatingPromptIneligibility.optedOut,
      );

      await ReviewPromptService.setTestingState(
        firstSeen: oldEnoughInstallDate(),
        meaningfulActionCount: ReviewPromptService.minMeaningfulActions,
        distinctDays: ReviewPromptService.minDistinctDays,
        completed: true,
      );

      expect(
        ReviewPromptService.diagnostics().reason,
        RatingPromptIneligibility.completed,
      );
    },
  );

  test(
    'high distress OCD saves count usage but should not be triggerable',
    () async {
      await initializePrefs();
      await ReviewPromptService.recordOcdSaved(
        ReviewPromptService.maxOcdDistressForTrigger + 1,
      );

      final diagnostics = ReviewPromptService.diagnostics();

      expect(diagnostics.ocdCount, 1);
      expect(diagnostics.meaningfulActionCount, 1);
      expect(ReviewPromptService.maxOcdDistressForTrigger, 4);
    },
  );
}
