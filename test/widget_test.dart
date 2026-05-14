import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:patterns/database/db_helper.dart';
import 'package:patterns/main.dart';
import 'package:patterns/models/models.dart';
import 'package:patterns/screens/analytics_screen.dart';

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

  test('trigger analysis filters stop words and detects bigrams', () {
    final entries = [
      _ocdEntry('I felt really worried about checking locks today'),
      _ocdEntry('The thought was about checked locks again'),
      _ocdEntry('Just checking locks before bed'),
    ];

    expect(commonTriggerForTesting(entries), 'checking locks');
  });

  test('trigger analysis groups simple word suffixes', () {
    final entries = [
      _ocdEntry('Washing hands felt very urgent'),
      _ocdEntry('Washed hands after touching the sink'),
      _ocdEntry('Washes hands when anxious'),
      _ocdEntry('Washing hands before leaving'),
    ];

    expect(commonTriggerForTesting(entries), 'washing hands');
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

OcdEntry _ocdEntry(String content) {
  return OcdEntry(
    type: OcdType.obsession,
    datetime: DateTime(2026, 1, 1),
    content: content,
    distressLevel: 5,
    response: '',
    createdAt: DateTime(2026, 1, 1),
  );
}
