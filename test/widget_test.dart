import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:patterns/database/db_helper.dart';
import 'package:patterns/main.dart';

void main() {
  test('theme mode provider updates and toggles', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.system);

    container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
    expect(container.read(themeModeProvider), ThemeMode.light);

    container.read(themeModeProvider.notifier).toggle(false);
    expect(container.read(themeModeProvider), ThemeMode.dark);

    container.read(themeModeProvider.notifier).toggle(true);
    expect(container.read(themeModeProvider), ThemeMode.light);
  });

  test('backup preview validates schema and returns record counts', () {
    const backup = '''
{
  "schema_version": 1,
  "journal": [
    {
      "date": "2026-01-01",
      "content": "Entry",
      "created_at": "2026-01-01T10:00:00.000",
      "updated_at": "2026-01-01T10:00:00.000"
    }
  ],
  "ocd": [
    {
      "type": 0,
      "datetime": "2026-01-01T10:00:00.000",
      "content": "Trigger",
      "distress_level": 5,
      "response": "Pause",
      "action_taken": null,
      "created_at": "2026-01-01T10:00:00.000"
    }
  ]
}
''';

    final summary = DbHelper.previewBackup(backup);

    expect(summary.journalCount, 1);
    expect(summary.ocdCount, 1);
  });

  test('backup preview rejects invalid distress levels', () {
    const backup = '''
{
  "schema_version": 1,
  "journal": [],
  "ocd": [
    {
      "type": 0,
      "datetime": "2026-01-01T10:00:00.000",
      "content": "Trigger",
      "distress_level": 11,
      "response": "Pause",
      "created_at": "2026-01-01T10:00:00.000"
    }
  ]
}
''';

    expect(() => DbHelper.previewBackup(backup), throwsFormatException);
  });
}
