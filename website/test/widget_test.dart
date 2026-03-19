import 'package:flutter_test/flutter_test.dart';
import 'package:patterns_website/main.dart';

void main() {
  testWidgets('Website renders', (WidgetTester tester) async {
    await tester.pumpWidget(const PatternsWebsite());
    expect(find.text('Patterns'), findsWidgets);
  });
}
