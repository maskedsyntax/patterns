import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patterns/widgets/rich_journal.dart';

void main() {
  group('rich_journal storage helpers', () {
    test('plain document round-trips through stored form', () {
      final doc = Document()..insert(0, 'a calm note');
      final stored = storedFromDocument(doc);
      final back = documentFromStored(stored);
      expect(back.toPlainText().trim(), 'a calm note');
    });

    test('legacy plain-text content is upgraded, not lost', () {
      // Entries written before rich text are bare strings, not Delta JSON.
      const legacy = 'written the old way';
      final doc = documentFromStored(legacy);
      expect(doc.toPlainText().trim(), 'written the old way');
      expect(plainTextFromStored(legacy), 'written the old way');
    });

    test('empty content yields an empty document', () {
      final doc = documentFromStored('');
      expect(doc.toPlainText().trim(), '');
    });

    test('bold/italic attributes survive a stored round-trip as runs', () {
      final doc = Document()..insert(0, 'plain bold end');
      // Format the word "bold" (offset 6, length 4).
      doc.format(6, 4, Attribute.bold);
      final stored = storedFromDocument(doc);

      final runs = richRunsFromStored(stored);
      final boldRun = runs.firstWhere((r) => r.text.contains('bold'));
      expect(boldRun.bold, isTrue);
      // Plain text extraction ignores styling.
      expect(plainTextFromStored(stored), 'plain bold end');
    });

    test('bullet list lines are prefixed with a bullet in read-only runs', () {
      final doc = Document()..insert(0, 'milk\neggs\nbread');
      // Make all three lines a bullet list (newlines at 4, 9, and the doc end).
      doc.format(0, 15, Attribute.ul);
      final stored = storedFromDocument(doc);

      final text = richRunsFromStored(stored).map((r) => r.text).join();
      expect(text.contains('•'), isTrue);
      expect(text, contains('milk'));
      expect(text, contains('eggs'));
      // Plain-text extraction stays clean (no bullet glyphs) for search.
      expect(plainTextFromStored(stored), 'milk\neggs\nbread');
    });

    test('richRunsFromStored falls back to a single run for legacy text', () {
      final runs = richRunsFromStored('legacy line');
      expect(runs.length, 1);
      expect(runs.first.text, 'legacy line');
      expect(runs.first.bold, isFalse);
    });

    test('malformed JSON is treated as plain text, not an error', () {
      const broken = '{not valid delta';
      expect(plainTextFromStored(broken), '{not valid delta');
      expect(documentFromStored(broken).toPlainText().trim(), '{not valid delta');
    });
  });
}
