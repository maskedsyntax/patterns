import 'package:flutter_test/flutter_test.dart';

import 'package:patterns/database/db_helper.dart';
import 'package:patterns/models/models.dart';

void main() {
  test('DelaySession round-trips through toMap/fromMap', () {
    final session = DelaySession(
      id: 7,
      compulsion: 'Checking the lock',
      plannedSeconds: 300,
      actualSeconds: 180,
      completed: false,
      urgeBefore: 8,
      urgeAfter: 4,
      outcome: DelayOutcome.delayed,
      note: 'It eased off after a while.',
      createdAt: DateTime.parse('2026-06-18T09:41:00.000'),
    );

    final restored = DelaySession.fromMap(session.toMap());

    expect(restored.id, 7);
    expect(restored.compulsion, 'Checking the lock');
    expect(restored.plannedSeconds, 300);
    expect(restored.actualSeconds, 180);
    expect(restored.completed, false);
    expect(restored.urgeBefore, 8);
    expect(restored.urgeAfter, 4);
    expect(restored.outcome, DelayOutcome.delayed);
    expect(restored.note, 'It eased off after a while.');
    expect(restored.createdAt, DateTime.parse('2026-06-18T09:41:00.000'));
  });

  test('ErpExerciseSession round-trips through toMap/fromMap', () {
    final session = ErpExerciseSession(
      id: 11,
      planId: 3,
      exerciseId: 'delay_checking',
      exerciseTitle: 'Delay Checking',
      triggerOrExposure: 'Leave the front door after checking once',
      fearPrediction: 'I will feel unsafe all afternoon',
      preventionCommitment: 'No rechecking the lock',
      plannedSeconds: 300,
      actualSeconds: 240,
      completed: false,
      anxietyBefore: 7,
      anxietyAfter: 4,
      outcome: DelayOutcome.delayed,
      whatHappened: 'The anxiety dropped after a few minutes',
      learning: 'The feeling can shift without checking again',
      note: 'The urge was still there, but quieter.',
      createdAt: DateTime.parse('2026-06-25T12:30:00.000'),
    );

    final restored = ErpExerciseSession.fromMap(session.toMap());

    expect(restored.id, 11);
    expect(restored.planId, 3);
    expect(restored.exerciseId, 'delay_checking');
    expect(restored.exerciseTitle, 'Delay Checking');
    expect(
      restored.triggerOrExposure,
      'Leave the front door after checking once',
    );
    expect(restored.fearPrediction, 'I will feel unsafe all afternoon');
    expect(restored.preventionCommitment, 'No rechecking the lock');
    expect(restored.plannedSeconds, 300);
    expect(restored.actualSeconds, 240);
    expect(restored.completed, false);
    expect(restored.anxietyBefore, 7);
    expect(restored.anxietyAfter, 4);
    expect(restored.outcome, DelayOutcome.delayed);
    expect(restored.whatHappened, 'The anxiety dropped after a few minutes');
    expect(restored.learning, 'The feeling can shift without checking again');
    expect(restored.note, 'The urge was still there, but quieter.');
    expect(restored.createdAt, DateTime.parse('2026-06-25T12:30:00.000'));
  });

  test('ErpExercisePlan round-trips through toMap/fromMap', () {
    final plan = ErpExercisePlan(
      id: 3,
      exerciseId: 'delay_checking',
      exerciseTitle: 'Delay Checking',
      triggerOrExposure: 'Leave after checking once',
      fearPrediction: 'I will feel unsafe',
      preventionCommitment: 'No rechecking',
      defaultSeconds: 300,
      archived: true,
      createdAt: DateTime.parse('2026-06-25T12:30:00.000'),
      updatedAt: DateTime.parse('2026-06-25T12:45:00.000'),
    );

    final restored = ErpExercisePlan.fromMap(plan.toMap());

    expect(restored.id, 3);
    expect(restored.exerciseId, 'delay_checking');
    expect(restored.exerciseTitle, 'Delay Checking');
    expect(restored.triggerOrExposure, 'Leave after checking once');
    expect(restored.fearPrediction, 'I will feel unsafe');
    expect(restored.preventionCommitment, 'No rechecking');
    expect(restored.defaultSeconds, 300);
    expect(restored.archived, true);
    expect(restored.createdAt, DateTime.parse('2026-06-25T12:30:00.000'));
    expect(restored.updatedAt, DateTime.parse('2026-06-25T12:45:00.000'));
  });

  test('toMap encodes completed as 0/1 and omits null id', () {
    final session = DelaySession(
      compulsion: 'Washing',
      plannedSeconds: 60,
      actualSeconds: 60,
      completed: true,
      urgeBefore: 6,
      urgeAfter: 6,
      outcome: DelayOutcome.resisted,
      createdAt: DateTime.parse('2026-06-18T09:41:00.000'),
    );

    final map = session.toMap();
    expect(map.containsKey('id'), false);
    expect(map['completed'], 1);
    expect(map['note'], isNull);
    expect(map['outcome'], DelayOutcome.resisted.index);
  });

  test('backup preview counts delay sessions in a v2 backup', () {
    const backup = '''
{
  "schema_version": 2,
  "journal": [],
  "ocd": [],
  "delay_sessions": [
    {
      "compulsion": "Checking",
      "planned_seconds": 300,
      "actual_seconds": 300,
      "completed": 1,
      "urge_before": 8,
      "urge_after": 3,
      "outcome": 0,
      "note": null,
      "created_at": "2026-06-18T09:41:00.000"
    }
  ]
}
''';

    final summary = DbHelper.previewBackup(backup);
    expect(summary.delaySessionCount, 1);
  });

  test('backup preview counts ERP exercise sessions in a v3 backup', () {
    const backup = '''
{
  "schema_version": 3,
  "journal": [],
  "ocd": [],
  "delay_sessions": [],
  "erp_exercise_plans": [
    {
      "id": 3,
      "exercise_id": "delay_checking",
      "exercise_title": "Delay Checking",
      "trigger_or_exposure": "Leave after checking once",
      "fear_prediction": "I will feel unsafe",
      "prevention_commitment": "No rechecking",
      "default_seconds": 300,
      "archived": 0,
      "created_at": "2026-06-25T12:30:00.000",
      "updated_at": "2026-06-25T12:30:00.000"
    }
  ],
  "erp_exercise_sessions": [
    {
      "plan_id": 3,
      "exercise_id": "delay_checking",
      "exercise_title": "Delay Checking",
      "trigger_or_exposure": "Leave after checking once",
      "fear_prediction": "I will feel unsafe",
      "prevention_commitment": "No rechecking",
      "planned_seconds": 300,
      "actual_seconds": 300,
      "completed": 1,
      "anxiety_before": 7,
      "anxiety_after": 4,
      "outcome": 0,
      "what_happened": "Nothing urgent happened",
      "learning": "I can leave the question alone",
      "note": null,
      "created_at": "2026-06-25T12:30:00.000"
    }
  ]
}
''';

    final summary = DbHelper.previewBackup(backup);
    expect(summary.erpExercisePlanCount, 1);
    expect(summary.erpExerciseSessionCount, 1);
  });

  test('a v1 backup (no delay_sessions) still restores', () {
    const backup = '''
{
  "schema_version": 1,
  "journal": [],
  "ocd": []
}
''';

    final summary = DbHelper.previewBackup(backup);
    expect(summary.delaySessionCount, 0);
    expect(summary.erpExercisePlanCount, 0);
    expect(summary.erpExerciseSessionCount, 0);
  });

  test('a malformed schema_version is a FormatException, not a TypeError', () {
    const backup = '''
{
  "schema_version": "2",
  "journal": [],
  "ocd": []
}
''';

    expect(() => DbHelper.previewBackup(backup), throwsFormatException);
  });

  test('a backup newer than we understand is rejected', () {
    const backup = '''
{
  "schema_version": 99,
  "journal": [],
  "ocd": []
}
''';

    expect(() => DbHelper.previewBackup(backup), throwsFormatException);
  });

  test('backup preview rejects out-of-range urge levels', () {
    const backup = '''
{
  "schema_version": 2,
  "journal": [],
  "ocd": [],
  "delay_sessions": [
    {
      "compulsion": "Checking",
      "planned_seconds": 300,
      "actual_seconds": 300,
      "completed": 1,
      "urge_before": 8,
      "urge_after": 11,
      "outcome": 0,
      "created_at": "2026-06-18T09:41:00.000"
    }
  ]
}
''';

    expect(() => DbHelper.previewBackup(backup), throwsFormatException);
  });

  test('backup preview rejects out-of-range ERP anxiety levels', () {
    const backup = '''
{
  "schema_version": 3,
  "journal": [],
  "ocd": [],
  "delay_sessions": [],
  "erp_exercise_plans": [],
  "erp_exercise_sessions": [
    {
      "exercise_id": "delay_checking",
      "exercise_title": "Delay Checking",
      "trigger_or_exposure": "Leave after checking once",
      "fear_prediction": "I will feel unsafe",
      "prevention_commitment": "No rechecking",
      "planned_seconds": 300,
      "actual_seconds": 300,
      "completed": 1,
      "anxiety_before": 7,
      "anxiety_after": 12,
      "outcome": 0,
      "what_happened": "Nothing urgent happened",
      "learning": "I can leave the question alone",
      "created_at": "2026-06-25T12:30:00.000"
    }
  ]
}
''';

    expect(() => DbHelper.previewBackup(backup), throwsFormatException);
  });

  test('backup preview rejects ERP sessions missing structured fields', () {
    const backup = '''
{
  "schema_version": 3,
  "journal": [],
  "ocd": [],
  "delay_sessions": [],
  "erp_exercise_plans": [],
  "erp_exercise_sessions": [
    {
      "exercise_id": "delay_checking",
      "exercise_title": "Delay Checking",
      "planned_seconds": 300,
      "actual_seconds": 300,
      "completed": 1,
      "anxiety_before": 7,
      "anxiety_after": 4,
      "outcome": 0,
      "created_at": "2026-06-25T12:30:00.000"
    }
  ]
}
''';

    expect(() => DbHelper.previewBackup(backup), throwsFormatException);
  });

  test('backup preview rejects malformed ERP plans', () {
    const backup = '''
{
  "schema_version": 3,
  "journal": [],
  "ocd": [],
  "delay_sessions": [],
  "erp_exercise_plans": [
    {
      "exercise_id": "delay_checking",
      "exercise_title": "Delay Checking",
      "trigger_or_exposure": "Leave after checking once",
      "fear_prediction": "I will feel unsafe",
      "prevention_commitment": "No rechecking",
      "default_seconds": 300,
      "archived": 4,
      "created_at": "2026-06-25T12:30:00.000",
      "updated_at": "2026-06-25T12:30:00.000"
    }
  ],
  "erp_exercise_sessions": []
}
''';

    expect(() => DbHelper.previewBackup(backup), throwsFormatException);
  });

  test('backup preview rejects out-of-range outcome', () {
    const backup = '''
{
  "schema_version": 2,
  "journal": [],
  "ocd": [],
  "delay_sessions": [
    {
      "compulsion": "Checking",
      "planned_seconds": 300,
      "actual_seconds": 300,
      "completed": 1,
      "urge_before": 8,
      "urge_after": 3,
      "outcome": 9,
      "created_at": "2026-06-18T09:41:00.000"
    }
  ]
}
''';

    expect(() => DbHelper.previewBackup(backup), throwsFormatException);
  });
}
