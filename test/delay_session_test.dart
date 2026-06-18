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
