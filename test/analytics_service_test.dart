import 'package:flutter_test/flutter_test.dart';
import 'package:patterns/models/models.dart';
import 'package:patterns/services/analytics_service.dart';

void main() {
  test('export range filter includes custom journal dates inclusively', () {
    final filter = DateRangeFilter.custom(
      start: DateTime(2026, 1, 10),
      end: DateTime(2026, 1, 12),
    );
    final entries = [
      JournalEntry(
        date: '2026-01-09',
        content: 'Before',
        createdAt: DateTime(2026, 1, 9),
        updatedAt: DateTime(2026, 1, 9),
      ),
      JournalEntry(
        date: '2026-01-10',
        content: 'Inside',
        createdAt: DateTime(2026, 1, 10),
        updatedAt: DateTime(2026, 1, 10),
      ),
      JournalEntry(
        date: '2026-01-13',
        content: 'After',
        createdAt: DateTime(2026, 1, 13),
        updatedAt: DateTime(2026, 1, 13),
      ),
    ];

    final filtered = AnalyticsService.filterJournals(entries, filter);
    expect(filtered.map((entry) => entry.date).toList(), ['2026-01-10']);
  });
}
