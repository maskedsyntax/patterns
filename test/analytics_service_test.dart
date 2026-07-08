import 'package:flutter_test/flutter_test.dart';
import 'package:patterns/models/models.dart';
import 'package:patterns/services/analytics_service.dart';

void main() {
  test('export range filter includes custom journal dates inclusively', () {
    final filter = DateRangeFilter.custom(
      start: DateTime(2026, 1, 10),
      end: DateTime(2026, 1, 12),
    );
    final entries = [
      JournalEntry(
        date: '2026-01-09',
        content: 'Before',
        createdAt: DateTime(2026, 1, 9),
        updatedAt: DateTime(2026, 1, 9),
      ),
      JournalEntry(
        date: '2026-01-10',
        content: 'Inside',
        createdAt: DateTime(2026, 1, 10),
        updatedAt: DateTime(2026, 1, 10),
      ),
      JournalEntry(
        date: '2026-01-13',
        content: 'After',
        createdAt: DateTime(2026, 1, 13),
        updatedAt: DateTime(2026, 1, 13),
      ),
    ];

    final filtered = AnalyticsService.filterJournals(entries, filter);
    expect(filtered.map((entry) => entry.date).toList(), ['2026-01-10']);
  });

  group('recovery intelligence dashboard', () {
    final now = DateTime(2026, 7, 8, 12);

    test('calculates score, deltas, consistency, and ERP practice', () {
      final dashboard = AnalyticsService.buildRecoveryDashboard(
        journals: [
          _journal(now, daysAgo: 0, content: 'Resisted checking the lock.'),
          _journal(now, daysAgo: 1, content: 'Felt uncertainty but continued.'),
          _journal(now, daysAgo: 2, content: 'Practiced ERP.'),
        ],
        ocds: [
          _ocd(now, daysAgo: 0, distress: 3, text: 'checking the stove'),
          _ocd(now, daysAgo: 2, distress: 4, text: 'what if doubt'),
          _ocd(now, daysAgo: 8, distress: 9, text: 'checking the door'),
        ],
        delaySessions: [_delay(now, daysAgo: 1)],
        erpSessions: [_erp(now, daysAgo: 0)],
        exposureSteps: [
          _step(now, daysAgo: 2, status: ExposureStepStatus.completed),
        ],
        responsePreventionLogs: [_response(now, daysAgo: 3)],
        urgeSurfSessions: [_surf(now, daysAgo: 4)],
        range: AnalyticsDateRange.seven,
        now: now,
      );

      expect(dashboard.hasAnyData, isTrue);
      expect(dashboard.erpPracticeCount, 5);
      expect(dashboard.activeDays, 5);
      expect(dashboard.consistencyPercent, 71);
      expect(dashboard.consistencyHeatmap.length, 7);
      expect(dashboard.averageUrge, lessThan(5));
      expect(dashboard.urgeDelta.tone, InsightTone.positive);
      expect(dashboard.scoreDelta.tone, InsightTone.positive);
      expect(dashboard.recoveryScore, greaterThan(50));
    });

    test('extracts top themes with local rules', () {
      final dashboard = AnalyticsService.buildRecoveryDashboard(
        journals: [
          _journal(now, daysAgo: 0, content: 'I kept checking the lock.'),
          _journal(now, daysAgo: 1, content: 'Germs and washing felt loud.'),
          _journal(now, daysAgo: 2, content: 'More checking and rechecking.'),
        ],
        ocds: [
          _ocd(now, daysAgo: 0, distress: 4, text: 'contamination germs'),
          _ocd(now, daysAgo: 1, distress: 5, text: 'health symptom worry'),
        ],
        delaySessions: const [],
        erpSessions: const [],
        exposureSteps: const [],
        range: AnalyticsDateRange.seven,
        now: now,
      );

      expect(dashboard.topThemes.first.label, 'Checking');
      expect(
        dashboard.topThemes.map((theme) => theme.label),
        containsAll(['Contamination', 'Health']),
      );
    });

    test('returns neutral empty dashboard state', () {
      final dashboard = AnalyticsService.buildRecoveryDashboard(
        journals: const [],
        ocds: const [],
        delaySessions: const [],
        erpSessions: const [],
        exposureSteps: const [],
        range: AnalyticsDateRange.thirty,
        now: now,
      );

      expect(dashboard.hasAnyData, isFalse);
      expect(dashboard.recoveryScore, 13);
      expect(dashboard.averageUrge, 0);
      expect(dashboard.consistencyPercent, 0);
      expect(dashboard.topThemes, isEmpty);
    });
  });
}

JournalEntry _journal(
  DateTime now, {
  required int daysAgo,
  required String content,
}) {
  final date = now.subtract(Duration(days: daysAgo));
  final key =
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  return JournalEntry(
    date: key,
    content: content,
    createdAt: date,
    updatedAt: date,
  );
}

OcdEntry _ocd(
  DateTime now, {
  required int daysAgo,
  required int distress,
  required String text,
}) {
  final date = now.subtract(Duration(days: daysAgo));
  return OcdEntry(
    type: OcdType.obsession,
    datetime: date,
    content: text,
    distressLevel: distress,
    response: 'I noticed the urge.',
    createdAt: date,
  );
}

DelaySession _delay(DateTime now, {required int daysAgo}) {
  final date = now.subtract(Duration(days: daysAgo));
  return DelaySession(
    compulsion: 'checking',
    plannedSeconds: 300,
    actualSeconds: 300,
    completed: true,
    urgeBefore: 8,
    urgeAfter: 3,
    outcome: DelayOutcome.resisted,
    createdAt: date,
  );
}

ErpExerciseSession _erp(DateTime now, {required int daysAgo}) {
  final date = now.subtract(Duration(days: daysAgo));
  return ErpExerciseSession(
    exerciseId: 'checking',
    exerciseTitle: 'Delay checking',
    triggerOrExposure: 'Leave without checking',
    fearPrediction: 'Something bad will happen',
    preventionCommitment: 'No rechecking',
    plannedSeconds: 600,
    actualSeconds: 600,
    completed: true,
    anxietyBefore: 7,
    anxietyAfter: 3,
    outcome: DelayOutcome.resisted,
    whatHappened: 'Nothing urgent happened.',
    learning: 'The urge dropped.',
    createdAt: date,
  );
}

ExposureStep _step(
  DateTime now, {
  required int daysAgo,
  required ExposureStepStatus status,
}) {
  final date = now.subtract(Duration(days: daysAgo));
  return ExposureStep(
    orderIndex: 0,
    description: 'Touch handle',
    difficulty: 5,
    anxietyRating: 6,
    status: status,
    completedAt: status == ExposureStepStatus.completed ? date : null,
  );
}

ResponsePreventionLog _response(DateTime now, {required int daysAgo}) {
  final date = now.subtract(Duration(days: daysAgo));
  return ResponsePreventionLog(
    datetime: date,
    situation: 'Wanted reassurance',
    outcome: ResponseOutcome.resisted,
    anxietyLevel: 4,
    createdAt: date,
  );
}

UrgeSurfSession _surf(DateTime now, {required int daysAgo}) {
  final date = now.subtract(Duration(days: daysAgo));
  return UrgeSurfSession(
    datetime: date,
    trigger: 'Checking urge',
    initialUrge: 7,
    peakUrge: 8,
    finalUrge: 3,
    durationSeconds: 420,
    createdAt: date,
  );
}
