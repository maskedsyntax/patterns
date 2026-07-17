import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:patterns/models/models.dart';
import 'package:patterns/providers/providers.dart';
import 'package:patterns/mobile/screens/ybocs_content.dart';
import 'package:patterns/mobile/screens/ybocs_screen.dart';
import 'package:patterns/theme/app_theme.dart';

/// In-memory stand-in for the DB-backed notifier so the flow can run headless.
class _FakeYbocsNotifier extends YbocsAssessmentNotifier {
  final List<YbocsAssessment> _store = [];

  @override
  Future<List<YbocsAssessment>> build() async => _store;

  @override
  Future<void> add(YbocsAssessment assessment) async {
    _store.insert(0, assessment);
    state = AsyncData(List.of(_store));
  }

  @override
  Future<void> delete(int id) async {
    _store.removeWhere((a) => a.id == id);
    state = AsyncData(List.of(_store));
  }
}

void main() {
  testWidgets('walks intro → checklist → severity → results and saves', (
    tester,
  ) async {
    final fake = _FakeYbocsNotifier();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [ybocsAssessmentProvider.overrideWith(() => fake)],
        child: MaterialApp(
          theme: AppTheme.mobileDarkTheme,
          home: const YbocsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Intro
    expect(find.text('OCD Self-Check'), findsOneWidget);
    await tester.tap(find.text('Begin'));
    await tester.pumpAndSettle();

    // Checklist — tick the first symptom, then continue.
    expect(find.text('What feels familiar?'), findsOneWidget);
    await tester.tap(find.text(ybocsCategories.first.items.first.label));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Continue'));
    await tester.pumpAndSettle();

    // Severity — answer all 10 questions.
    for (var i = 0; i < ybocsSeverityQuestions.length; i++) {
      expect(
        find.text('Question ${i + 1} of ${ybocsSeverityQuestions.length}'),
        findsOneWidget,
      );
      // Pick the third option (score 2) on every question.
      await tester.tap(find.text(ybocsSeverityQuestions[i].options[2]));
      await tester.pumpAndSettle();
      await tester.tap(find.text(i == 9 ? 'See results' : 'Next'));
      await tester.pumpAndSettle();
    }

    // Results — 10 items × 2 points = 20 → Moderate band.
    expect(find.text('Your results'), findsOneWidget);
    expect(find.text('20'), findsOneWidget);
    expect(find.text('Moderate'), findsWidgets);

    // Save persists exactly one assessment through the notifier.
    await tester.tap(find.text('Save to my history'));
    await tester.pumpAndSettle();
    final saved = await fake.build();
    expect(saved.length, 1);
    expect(saved.first.totalScore, 20);
    expect(saved.first.severity, YbocsSeverity.moderate);
    expect(saved.first.symptoms, contains(ybocsCategories.first.items.first.id));
  });
}
