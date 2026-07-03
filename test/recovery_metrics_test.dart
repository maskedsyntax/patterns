import 'package:flutter_test/flutter_test.dart';
import 'package:patterns/models/models.dart';
import 'package:patterns/services/analytics_service.dart';

DelaySession _delay(DateTime when, {int before = 8, int after = 3}) {
  return DelaySession(
    compulsion: 'c',
    plannedSeconds: 300,
    actualSeconds: 300,
    completed: true,
    urgeBefore: before,
    urgeAfter: after,
    outcome: DelayOutcome.resisted,
    createdAt: when,
  );
}

ExposureStep _step(ExposureStepStatus status, {DateTime? completedAt}) {
  return ExposureStep(
    hierarchyId: 1,
    orderIndex: 0,
    description: 'd',
    difficulty: 3,
    anxietyRating: 5,
    status: status,
    completedAt: completedAt,
  );
}

void main() {
  group('buildRecoveryMetrics', () {
    test('empty input has no data and zeroed metrics', () {
      final m = AnalyticsService.buildRecoveryMetrics(
        delaySessions: const [],
        erpSessions: const [],
        exposureSteps: const [],
        now: DateTime(2026, 6, 29),
      );
      expect(m.hasAnyData, false);
      expect(m.practiceStreakDays, 0);
      expect(m.exposuresCompleted, 0);
      expect(m.sessionsPracticed, 0);
      expect(m.avgUrgeReduction, 0);
      expect(m.weeklyActivity.length, 7);
      expect(m.weeklyActivity.every((d) => d == false), true);
    });

    test('counts a 3-day consecutive streak ending today', () {
      final today = DateTime(2026, 6, 29, 12);
      final m = AnalyticsService.buildRecoveryMetrics(
        delaySessions: [
          _delay(today),
          _delay(today.subtract(const Duration(days: 1))),
          _delay(today.subtract(const Duration(days: 2))),
          // gap on day 3, then an older one that must not extend the streak
          _delay(today.subtract(const Duration(days: 5))),
        ],
        erpSessions: const [],
        exposureSteps: const [],
        now: today,
      );
      expect(m.practiceStreakDays, 3);
      expect(m.sessionsPracticed, 4);
      expect(m.hasAnyData, true);
    });

    test('streak survives if today has no practice but yesterday did', () {
      final today = DateTime(2026, 6, 29, 9);
      final m = AnalyticsService.buildRecoveryMetrics(
        delaySessions: [
          _delay(today.subtract(const Duration(days: 1))),
          _delay(today.subtract(const Duration(days: 2))),
        ],
        erpSessions: const [],
        exposureSteps: const [],
        now: today,
      );
      expect(m.practiceStreakDays, 2);
    });

    test('exposures completed and avg urge reduction', () {
      final today = DateTime(2026, 6, 29);
      final m = AnalyticsService.buildRecoveryMetrics(
        delaySessions: [
          _delay(today, before: 9, after: 4), // drop 5
          _delay(today, before: 6, after: 5), // drop 1
        ],
        erpSessions: const [],
        exposureSteps: [
          _step(ExposureStepStatus.completed, completedAt: today),
          _step(ExposureStepStatus.inProgress),
          _step(ExposureStepStatus.notStarted),
        ],
        now: today,
      );
      expect(m.exposuresCompleted, 1);
      expect(m.avgUrgeReduction, closeTo(3.0, 0.0001));
    });
  });
}
