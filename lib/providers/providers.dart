import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../database/db_helper.dart';

class JournalNotifier extends AsyncNotifier<List<JournalEntry>> {
  @override
  Future<List<JournalEntry>> build() async {
    return await DbHelper.instance.getJournalEntries();
  }

  Future<void> saveEntry(String date, String content) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final entry = JournalEntry(
        date: date,
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await DbHelper.instance.upsertJournalEntry(entry);
      return await DbHelper.instance.getJournalEntries();
    });
  }
}

final journalProvider = AsyncNotifierProvider<JournalNotifier, List<JournalEntry>>(() {
  return JournalNotifier();
});

class OcdNotifier extends AsyncNotifier<List<OcdEntry>> {
  @override
  Future<List<OcdEntry>> build() async {
    return await DbHelper.instance.getOcdEntries();
  }

  Future<void> addEntry(OcdEntry entry) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await DbHelper.instance.insertOcdEntry(entry);
      return await DbHelper.instance.getOcdEntries();
    });
  }

  Future<void> deleteEntry(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await DbHelper.instance.deleteOcdEntry(id);
      return await DbHelper.instance.getOcdEntries();
    });
  }
}

final ocdProvider = AsyncNotifierProvider<OcdNotifier, List<OcdEntry>>(() {
  return OcdNotifier();
});
