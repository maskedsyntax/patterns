import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:patterns/main.dart';

void main() {
  test('theme mode provider updates and toggles', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.dark);

    container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
    expect(container.read(themeModeProvider), ThemeMode.light);

    container.read(themeModeProvider.notifier).toggle(false);
    expect(container.read(themeModeProvider), ThemeMode.dark);

    container.read(themeModeProvider.notifier).toggle(true);
    expect(container.read(themeModeProvider), ThemeMode.light);
  });
}
