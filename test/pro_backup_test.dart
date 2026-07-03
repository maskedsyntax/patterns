import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:patterns/database/db_helper.dart';

/// Verifies the v8 backup schema validates and counts every Pro table, so
/// export/import round-trips cleanly across the full feature set.
void main() {
  String iso = DateTime(2026, 6, 30, 12).toIso8601String();

  Map<String, dynamic> fullBackup() => {
    'schema_version': 9,
    'journal': [],
    'ocd': [],
    'delay_sessions': [],
    'erp_exercise_plans': [],
    'erp_exercise_sessions': [],
    'exposure_hierarchies': [
      {
        'title': 'Door handles',
        'theme': 'Contamination',
        'archived': 0,
        'created_at': iso,
        'updated_at': iso,
      },
    ],
    'exposure_steps': [
      {
        'hierarchy_id': 1,
        'order_index': 0,
        'description': 'Touch the handle once',
        'difficulty': 4,
        'anxiety_rating': 7,
        'status': 2,
        'completed_at': iso,
      },
    ],
    'response_prevention_logs': [
      {
        'datetime': iso,
        'situation': 'Wanted to recheck the lock',
        'outcome': 0,
        'anxiety_level': 6,
        'note': null,
        'linked_step_id': null,
        'created_at': iso,
      },
    ],
    'urge_surf_sessions': [
      {
        'datetime': iso,
        'trigger': 'Urge to wash',
        'initial_urge': 8,
        'peak_urge': 9,
        'final_urge': 3,
        'duration_seconds': 180,
        'note': null,
        'created_at': iso,
      },
    ],
    'program_enrollments': [
      {'program_id': 'delay-4wk', 'created_at': iso},
    ],
    'program_task_progress': [
      {
        'enrollment_id': 1,
        'week_index': 0,
        'task_id': 'w1a',
        'completed_at': iso,
      },
    ],
    'behavioral_experiments': [
      {
        'datetime': iso,
        'fear_prediction': 'The house will flood',
        'confidence': 80,
        'experiment': 'Leave without checking',
        'outcome': 'Nothing happened',
        'learning': 'OCD overestimates risk',
        'status': 1,
        'created_at': iso,
      },
    ],
    'exposure_reflections': [
      {
        'datetime': iso,
        'what_happened': 'Touched the handle',
        'ocd_predicted': 'I would get sick',
        'actually_happened': 'I was fine',
        'what_i_learned': 'Uncertainty is tolerable',
        'do_differently': 'Go sooner',
        'created_at': iso,
      },
    ],
    'action_plans': [
      {
        'situation': 'Urge to google a symptom',
        'planned_action': 'Wait 15 minutes',
        'date': '2026-07-01',
        'notes': null,
        'completed': 0,
        'created_at': iso,
      },
    ],
    'implementation_intentions': [
      {
        'trigger': 'I feel uncertain',
        'response': 'I continue what I was doing',
        'created_at': iso,
      },
    ],
    'uncertainty_log': [
      {
        'datetime': iso,
        'exercise_id': 'maybe',
        'willingness': 7,
        'note': null,
        'created_at': iso,
      },
    ],
    'exposure_materials': [
      {
        'type': 1, // loopTape
        'title': 'My loop tape',
        'text': null,
        'url': null,
        'file_name': 'm_123.m4a',
        'linked_hierarchy_id': 1,
        'linked_step_id': 3,
        'created_at': iso,
      },
    ],
  };

  test('previewBackup accepts a full v8 backup and counts every Pro table', () {
    final summary = DbHelper.previewBackup(jsonEncode(fullBackup()));
    expect(summary.exposureHierarchyCount, 1);
    expect(summary.exposureStepCount, 1);
    expect(summary.responsePreventionCount, 1);
    expect(summary.urgeSurfCount, 1);
    expect(summary.programEnrollmentCount, 1);
    expect(summary.programTaskProgressCount, 1);
    expect(summary.behavioralExperimentCount, 1);
    expect(summary.exposureReflectionCount, 1);
    expect(summary.actionPlanCount, 1);
    expect(summary.implementationIntentionCount, 1);
    expect(summary.uncertaintyLogCount, 1);
    expect(summary.exposureMaterialCount, 1);
  });

  test('an older backup missing the new Pro tables still restores', () {
    final old = {
      'schema_version': 3,
      'journal': [],
      'ocd': [],
    };
    final summary = DbHelper.previewBackup(jsonEncode(old));
    expect(summary.exposureHierarchyCount, 0);
    expect(summary.behavioralExperimentCount, 0);
    expect(summary.uncertaintyLogCount, 0);
  });

  test('a malformed Pro row is rejected', () {
    final bad = fullBackup();
    bad['behavioral_experiments'] = [
      {
        'datetime': iso,
        'fear_prediction': 'x',
        'confidence': 250, // out of range
        'experiment': 'y',
        'outcome': '',
        'learning': '',
        'status': 0,
        'created_at': iso,
      },
    ];
    expect(
      () => DbHelper.previewBackup(jsonEncode(bad)),
      throwsA(isA<FormatException>()),
    );
  });
}
