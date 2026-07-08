import 'package:flutter/foundation.dart';

import '../database/db_helper.dart';
import '../models/models.dart';

/// Debug-only sample data for making the analytics dashboard feel alive in a
/// fresh simulator. This never runs in release builds and never writes over an
/// existing local dataset.
class DemoSeedService {
  static bool _started = false;

  static Future<bool> seedIfNeeded() async {
    if (!kDebugMode || _started) return false;
    _started = true;

    final db = DbHelper.instance;
    final hasData =
        (await db.getJournalEntries()).isNotEmpty ||
        (await db.getOcdEntries()).isNotEmpty ||
        (await db.getDelaySessions()).isNotEmpty ||
        (await db.getErpExerciseSessions()).isNotEmpty ||
        (await db.getExposureSteps()).isNotEmpty ||
        (await db.getResponsePreventionLogs()).isNotEmpty ||
        (await db.getUrgeSurfSessions()).isNotEmpty;
    if (hasData) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 9);

    for (var i = 59; i >= 0; i--) {
      if (_journalDays.contains(i)) {
        await db.upsertJournalEntry(_journal(today, i));
      }
    }

    for (var i = 58; i >= 0; i -= 2) {
      await db.insertOcdEntry(_ocd(today, i));
    }
    for (final day in [27, 24, 21, 18, 15, 12, 9, 6, 4, 2, 1]) {
      await db.insertDelaySession(_delay(today, day));
    }

    final checkingPlanId = await db.insertErpExercisePlan(
      _plan(
        today,
        exerciseId: 'delay_checking',
        title: 'Delay checking',
        exposure: 'Leave the apartment after checking the door once.',
        commitment: 'No rechecking for the planned window.',
      ),
    );
    final contaminationPlanId = await db.insertErpExercisePlan(
      _plan(
        today,
        exerciseId: 'contamination_response_prevention',
        title: 'Sit with contamination doubt',
        exposure: 'Touch a shared surface and wait before washing.',
        commitment: 'Let uncertainty be present without resetting.',
      ),
    );

    for (final day in [25, 22, 19, 16, 13, 10, 7, 5, 3, 0]) {
      await db.insertErpExerciseSession(
        _erp(today, day, checkingPlanId, 'Delay checking'),
      );
    }
    for (final day in [26, 20, 14, 8, 2]) {
      await db.insertErpExerciseSession(
        _erp(
          today,
          day,
          contaminationPlanId,
          'Sit with contamination doubt',
          contamination: true,
        ),
      );
    }

    await db.insertExposureHierarchyWithSteps(
      ExposureHierarchy(
        title: 'Checking ladder',
        theme: 'Checking',
        createdAt: today.subtract(const Duration(days: 35)),
        updatedAt: today,
      ),
      [
        _exposureStep(today, 0, 'Check the front door once', 3, 4, 24),
        _exposureStep(today, 1, 'Leave home without a photo', 5, 6, 17),
        _exposureStep(today, 2, 'Go to bed without one last recheck', 6, 7, 9),
        _exposureStep(today, 3, 'Let a lock doubt pass for one hour', 8, 8, 1),
      ],
    );

    for (final day in [23, 18, 11, 6, 3, 1]) {
      await db.insertResponsePreventionLog(_response(today, day));
    }
    for (final day in [28, 21, 15, 10, 4, 0]) {
      await db.insertUrgeSurfSession(_surf(today, day));
    }

    return true;
  }

  static JournalEntry _journal(DateTime today, int daysAgo) {
    final date = today.subtract(Duration(days: daysAgo));
    final theme = _themes[daysAgo % _themes.length];
    final improving = daysAgo < 30;
    return JournalEntry(
      date: _dateKey(date),
      content: improving
          ? 'I noticed the $theme thought show up today and practiced letting uncertainty be there. The urge was real, but I delayed the compulsion and came back to what mattered. Checking felt less sticky after a few minutes.'
          : 'The $theme fear felt loud today. I kept looking for certainty and noticed how reassurance only helped for a moment. I want to practice response prevention next time instead of trying to solve the doubt.',
      createdAt: date,
      updatedAt: date.add(const Duration(minutes: 12)),
    );
  }

  static OcdEntry _ocd(DateTime today, int daysAgo) {
    final date = today.subtract(Duration(days: daysAgo, hours: -2));
    final recent = daysAgo < 30;
    final theme = _themes[daysAgo % _themes.length];
    final distress = recent
        ? [5, 4, 6, 3, 4, 5][daysAgo % 6]
        : [8, 7, 9, 8, 6, 7][daysAgo % 6];
    final type = daysAgo % 3 == 0 ? OcdType.compulsion : OcdType.obsession;
    return OcdEntry(
      type: type,
      datetime: date,
      content: switch (theme) {
        'contamination' => 'What if my hands are contaminated with germs?',
        'checking' => 'What if the door lock or stove is not safe?',
        'harm' => 'What if I somehow harm someone by being careless?',
        'health' => 'What if this symptom means a serious health problem?',
        'uncertainty' => 'What if I never get certainty and stay stuck?',
        _ => 'What if this relationship doubt means something important?',
      },
      distressLevel: distress,
      response: recent
          ? 'Labeled it as OCD, allowed the doubt, and returned to the day.'
          : 'Asked for reassurance and mentally reviewed it for a while.',
      actionTaken: type == OcdType.compulsion
          ? (recent ? 'Delayed checking for 15 minutes' : 'Checked repeatedly')
          : null,
      createdAt: date,
    );
  }

  static DelaySession _delay(DateTime today, int daysAgo) {
    final date = today.subtract(Duration(days: daysAgo, hours: -5));
    final before = [7, 8, 6, 7, 5][daysAgo % 5];
    final after = (before - [2, 3, 2, 4, 1][daysAgo % 5]).clamp(1, 9);
    return DelaySession(
      compulsion: daysAgo % 2 == 0
          ? 'Checking the lock'
          : 'Seeking reassurance',
      plannedSeconds: 900,
      actualSeconds: daysAgo % 4 == 0 ? 720 : 900,
      completed: daysAgo % 4 != 0,
      urgeBefore: before,
      urgeAfter: after,
      outcome: daysAgo % 4 == 0 ? DelayOutcome.delayed : DelayOutcome.resisted,
      note: 'The urge rose, peaked, and softened when I stopped feeding it.',
      createdAt: date,
    );
  }

  static ErpExercisePlan _plan(
    DateTime today, {
    required String exerciseId,
    required String title,
    required String exposure,
    required String commitment,
  }) {
    final created = today.subtract(const Duration(days: 40));
    return ErpExercisePlan(
      exerciseId: exerciseId,
      exerciseTitle: title,
      triggerOrExposure: exposure,
      fearPrediction: 'Anxiety will stay high unless I do the compulsion.',
      preventionCommitment: commitment,
      defaultSeconds: 900,
      createdAt: created,
      updatedAt: today,
    );
  }

  static ErpExerciseSession _erp(
    DateTime today,
    int daysAgo,
    int planId,
    String title, {
    bool contamination = false,
  }) {
    final date = today.subtract(Duration(days: daysAgo, hours: -7));
    final before = contamination ? 7 : 6;
    final after = daysAgo < 10 ? 3 : 4;
    return ErpExerciseSession(
      planId: planId,
      exerciseId: contamination
          ? 'contamination_response_prevention'
          : 'delay_checking',
      exerciseTitle: title,
      triggerOrExposure: contamination
          ? 'Touched a shared surface and waited before washing.'
          : 'Left after checking once and resisted rechecking.',
      fearPrediction: 'I will feel unsafe until I neutralize the feeling.',
      preventionCommitment: 'No reassurance, no extra checking, no reset.',
      plannedSeconds: 900,
      actualSeconds: 900,
      completed: true,
      anxietyBefore: before,
      anxietyAfter: after,
      outcome: DelayOutcome.resisted,
      whatHappened: 'The anxiety moved around, then dropped without a ritual.',
      learning: 'The feeling can change without certainty.',
      note: 'Good practice session.',
      createdAt: date,
    );
  }

  static ExposureStep _exposureStep(
    DateTime today,
    int index,
    String description,
    int difficulty,
    int anxiety,
    int completedDaysAgo,
  ) {
    return ExposureStep(
      orderIndex: index,
      description: description,
      difficulty: difficulty,
      anxietyRating: anxiety,
      status: ExposureStepStatus.completed,
      completedAt: today.subtract(Duration(days: completedDaysAgo)),
    );
  }

  static ResponsePreventionLog _response(DateTime today, int daysAgo) {
    final date = today.subtract(Duration(days: daysAgo, hours: -4));
    return ResponsePreventionLog(
      datetime: date,
      situation: 'Wanted reassurance about a checking doubt.',
      outcome: daysAgo % 3 == 0
          ? ResponseOutcome.delayed
          : ResponseOutcome.resisted,
      anxietyLevel: [5, 4, 6, 3][daysAgo % 4],
      note: 'Let the uncertainty sit without trying to close the loop.',
      createdAt: date,
    );
  }

  static UrgeSurfSession _surf(DateTime today, int daysAgo) {
    final date = today.subtract(Duration(days: daysAgo, hours: -6));
    final initial = [6, 7, 5, 8][daysAgo % 4];
    return UrgeSurfSession(
      datetime: date,
      trigger: 'Urge to check until it feels just right.',
      initialUrge: initial,
      peakUrge: (initial + 1).clamp(0, 10),
      finalUrge: (initial - 3).clamp(1, 9),
      durationSeconds: 720,
      note: 'The wave passed more quickly than expected.',
      createdAt: date,
    );
  }

  static String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static const _journalDays = {
    59,
    57,
    55,
    52,
    49,
    46,
    43,
    40,
    37,
    34,
    31,
    29,
    28,
    27,
    25,
    24,
    22,
    21,
    20,
    18,
    17,
    15,
    14,
    13,
    11,
    10,
    8,
    7,
    6,
    4,
    3,
    2,
    1,
    0,
  };

  static const _themes = [
    'checking',
    'contamination',
    'harm',
    'health',
    'uncertainty',
    'relationship',
  ];
}
