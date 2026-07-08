import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:patterns/mobile/screens/onboarding_screen.dart';
import 'package:patterns/theme/app_theme.dart';

void main() {
  testWidgets('onboarding renders first launch welcome copy', (tester) async {
    await _pumpOnboarding(
      tester,
      const WelcomeScreen(onStart: _noop, onImport: _noop),
    );

    expect(find.text('Understand your patterns.'), findsOneWidget);
    expect(find.textContaining('A calm private space'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('onboarding final step explains free and pro paths', (
    tester,
  ) async {
    await _pumpOnboarding(
      tester,
      const WelcomeScreen(onStart: _noop, onImport: _noop),
    );

    await _goToFinalStep(tester);

    expect(find.text('Start simple. Go deeper with Pro.'), findsOneWidget);
    expect(find.text('Start free'), findsOneWidget);
    expect(find.text('Unlock Pro'), findsOneWidget);
    expect(find.textContaining('One-time unlock'), findsOneWidget);
  });

  testWidgets('Start free calls onStart from final step', (tester) async {
    var started = false;
    await _pumpOnboarding(
      tester,
      WelcomeScreen(onStart: () => started = true, onImport: _noop),
    );

    await _goToFinalStep(tester);
    await tester.tap(find.text('Start free'));
    await tester.pump();

    expect(started, isTrue);
  });

  testWidgets('import existing data remains available as quiet action', (
    tester,
  ) async {
    var imported = false;
    await _pumpOnboarding(
      tester,
      WelcomeScreen(onStart: _noop, onImport: () => imported = true),
    );

    await tester.tap(find.text('Import existing data'));
    await tester.pump();

    expect(imported, isTrue);
  });

  testWidgets('Unlock Pro opens paywall from final step', (tester) async {
    await _pumpOnboarding(
      tester,
      const WelcomeScreen(onStart: _noop, onImport: _noop),
    );

    await _goToFinalStep(tester);
    await tester.tap(find.text('Unlock Pro'));
    await tester.pump();

    expect(find.text('Patterns Pro'), findsOneWidget);
  });

  testWidgets('onboarding text uses fixed light-on-dark colors', (
    tester,
  ) async {
    // The screen is hard-coded dark. Its text must use the fixed light color
    // rather than theme-derived colors so it stays readable on the dark
    // background (the app is dark-only, but this guards the intent).
    await _pumpOnboarding(
      tester,
      const WelcomeScreen(onStart: _noop, onImport: _noop),
    );

    final title = tester.widget<Text>(find.text('Understand your patterns.'));
    expect(title.style?.color, AppTheme.textPrimary);

    final point = tester.widget<Text>(
      find.text('Private local-first reflection'),
    );
    expect(point.style?.color, AppTheme.textPrimary);
  });
}

Widget _host(Widget child) {
  return MaterialApp(
    theme: AppTheme.mobileDarkTheme,
    home: child,
  );
}

Future<void> _pumpOnboarding(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(_host(child));
  await tester.pumpAndSettle();
}

Future<void> _goToFinalStep(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
  }
}

void _noop() {}
