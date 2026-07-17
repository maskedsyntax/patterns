import 'package:flutter_test/flutter_test.dart';

import 'package:patterns/database/db_helper.dart';
import 'package:patterns/models/models.dart';

void main() {
  test('YbocsAssessment round-trips through toMap/fromMap', () {
    final assessment = YbocsAssessment(
      id: 5,
      datetime: DateTime.parse('2026-07-15T10:00:00.000'),
      obsessionScore: 12,
      compulsionScore: 9,
      totalScore: 21,
      severity: YbocsSeverity.moderate,
      itemScores: const [3, 2, 3, 2, 2, 2, 2, 1, 2, 2],
      themes: const ['contamination', 'washing'],
      symptoms: const ['con_dirt', 'wash_hands'],
      createdAt: DateTime.parse('2026-07-15T10:05:00.000'),
    );

    final restored = YbocsAssessment.fromMap(assessment.toMap());

    expect(restored.id, 5);
    expect(restored.datetime, DateTime.parse('2026-07-15T10:00:00.000'));
    expect(restored.obsessionScore, 12);
    expect(restored.compulsionScore, 9);
    expect(restored.totalScore, 21);
    expect(restored.severity, YbocsSeverity.moderate);
    expect(restored.itemScores, const [3, 2, 3, 2, 2, 2, 2, 1, 2, 2]);
    expect(restored.themes, const ['contamination', 'washing']);
    expect(restored.symptoms, const ['con_dirt', 'wash_hands']);
    expect(restored.createdAt, DateTime.parse('2026-07-15T10:05:00.000'));
  });

  test('toMap omits null id and encodes empty lists as empty strings', () {
    final assessment = YbocsAssessment(
      datetime: DateTime.parse('2026-07-15T10:00:00.000'),
      obsessionScore: 0,
      compulsionScore: 0,
      totalScore: 0,
      severity: YbocsSeverity.subclinical,
      itemScores: const [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      themes: const [],
      symptoms: const [],
      createdAt: DateTime.parse('2026-07-15T10:00:00.000'),
    );

    final map = assessment.toMap();
    expect(map.containsKey('id'), false);
    expect(map['severity'], YbocsSeverity.subclinical.index);
    expect(map['themes'], '');
    expect(map['symptoms'], '');

    // Empty strings must decode back to empty lists, not [''].
    final restored = YbocsAssessment.fromMap(map);
    expect(restored.themes, isEmpty);
    expect(restored.symptoms, isEmpty);
  });

  test('ybocsSeverityForScore maps the standard bands', () {
    expect(ybocsSeverityForScore(0), YbocsSeverity.subclinical);
    expect(ybocsSeverityForScore(7), YbocsSeverity.subclinical);
    expect(ybocsSeverityForScore(8), YbocsSeverity.mild);
    expect(ybocsSeverityForScore(15), YbocsSeverity.mild);
    expect(ybocsSeverityForScore(16), YbocsSeverity.moderate);
    expect(ybocsSeverityForScore(23), YbocsSeverity.moderate);
    expect(ybocsSeverityForScore(24), YbocsSeverity.severe);
    expect(ybocsSeverityForScore(31), YbocsSeverity.severe);
    expect(ybocsSeverityForScore(32), YbocsSeverity.extreme);
    expect(ybocsSeverityForScore(40), YbocsSeverity.extreme);
  });

  test('backup preview counts Y-BOCS assessments in a v10 backup', () {
    const backup = '''
{
  "schema_version": 10,
  "journal": [],
  "ocd": [],
  "ybocs_assessments": [
    {
      "datetime": "2026-07-15T10:00:00.000",
      "obsession_score": 12,
      "compulsion_score": 9,
      "total_score": 21,
      "severity": 2,
      "item_scores": "3,2,3,2,2,2,2,1,2,2",
      "themes": "contamination,washing",
      "symptoms": "con_dirt,wash_hands",
      "created_at": "2026-07-15T10:05:00.000"
    }
  ]
}
''';

    final summary = DbHelper.previewBackup(backup);
    expect(summary.ybocsAssessmentCount, 1);
  });

  test('a backup missing ybocs_assessments still restores', () {
    const backup = '''
{
  "schema_version": 9,
  "journal": [],
  "ocd": []
}
''';

    final summary = DbHelper.previewBackup(backup);
    expect(summary.ybocsAssessmentCount, 0);
  });

  test('backup preview rejects an out-of-range total score', () {
    const backup = '''
{
  "schema_version": 10,
  "journal": [],
  "ocd": [],
  "ybocs_assessments": [
    {
      "datetime": "2026-07-15T10:00:00.000",
      "obsession_score": 12,
      "compulsion_score": 9,
      "total_score": 41,
      "severity": 2,
      "item_scores": "3,2,3,2,2,2,2,1,2,2",
      "themes": "",
      "symptoms": "",
      "created_at": "2026-07-15T10:05:00.000"
    }
  ]
}
''';

    expect(() => DbHelper.previewBackup(backup), throwsFormatException);
  });

  test('backup preview rejects an out-of-range item score', () {
    const backup = '''
{
  "schema_version": 10,
  "journal": [],
  "ocd": [],
  "ybocs_assessments": [
    {
      "datetime": "2026-07-15T10:00:00.000",
      "obsession_score": 12,
      "compulsion_score": 9,
      "total_score": 21,
      "severity": 2,
      "item_scores": "3,2,3,2,5,2,2,1,2,2",
      "themes": "",
      "symptoms": "",
      "created_at": "2026-07-15T10:05:00.000"
    }
  ]
}
''';

    expect(() => DbHelper.previewBackup(backup), throwsFormatException);
  });
}
