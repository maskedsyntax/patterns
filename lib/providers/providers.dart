import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../database/db_helper.dart';
import '../widgets/rich_journal.dart';

class JournalNotifier extends AsyncNotifier<List<JournalEntry>> {
  @override
  Future<List<JournalEntry>> build() async {
    final entries = await DbHelper.instance.getJournalEntries();
    entries.sort((a, b) => a.date.compareTo(b.date));
    return entries;
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
      final entries = await DbHelper.instance.getJournalEntries();
      entries.sort((a, b) => a.date.compareTo(b.date));
      return entries;
    });
  }

  /// Removes the entry for [date] entirely, freeing the date to be written
  /// again. Used by the "Reset entry" action — clearing the text and saving is
  /// intentionally not allowed (empty entries can't be saved).
  Future<void> deleteEntry(String date) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await DbHelper.instance.deleteJournalEntry(date);
      final entries = await DbHelper.instance.getJournalEntries();
      entries.sort((a, b) => a.date.compareTo(b.date));
      return entries;
    });
  }
}

final journalProvider =
    AsyncNotifierProvider<JournalNotifier, List<JournalEntry>>(() {
      return JournalNotifier();
    });

// Search and Filtering Providers
class JournalSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => "";
  set query(String value) => state = value;
}

final journalSearchQueryProvider =
    NotifierProvider<JournalSearchQueryNotifier, String>(
      JournalSearchQueryNotifier.new,
    );

final filteredJournalProvider = Provider<AsyncValue<List<JournalEntry>>>((ref) {
  final journalAsync = ref.watch(journalProvider);
  final query = ref.watch(journalSearchQueryProvider).toLowerCase();

  return journalAsync.whenData((entries) {
    if (query.isEmpty) return entries;
    return entries.where((entry) {
      return plainTextFromStored(entry.content).toLowerCase().contains(query) ||
          entry.date.contains(query);
    }).toList();
  });
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

  Future<void> updateEntry(OcdEntry entry) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await DbHelper.instance.updateOcdEntry(entry);
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

class OcdHighDistressNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
}

final ocdHighDistressOnlyProvider =
    NotifierProvider<OcdHighDistressNotifier, bool>(
      OcdHighDistressNotifier.new,
    );

final filteredOcdProvider = Provider<AsyncValue<List<OcdEntry>>>((ref) {
  final ocdAsync = ref.watch(ocdProvider);
  final highDistressOnly = ref.watch(ocdHighDistressOnlyProvider);

  return ocdAsync.whenData((entries) {
    if (!highDistressOnly) return entries;
    return entries.where((entry) => entry.distressLevel >= 7).toList();
  });
});

class DelaySessionNotifier extends AsyncNotifier<List<DelaySession>> {
  @override
  Future<List<DelaySession>> build() async {
    return await DbHelper.instance.getDelaySessions();
  }

  Future<void> addSession(DelaySession session) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await DbHelper.instance.insertDelaySession(session);
      return await DbHelper.instance.getDelaySessions();
    });
  }
}

final delaySessionProvider =
    AsyncNotifierProvider<DelaySessionNotifier, List<DelaySession>>(() {
      return DelaySessionNotifier();
    });

class ErpExercisePlanNotifier extends AsyncNotifier<List<ErpExercisePlan>> {
  @override
  Future<List<ErpExercisePlan>> build() async {
    return await DbHelper.instance.getActiveErpExercisePlans();
  }

  Future<void> addPlan(ErpExercisePlan plan) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await DbHelper.instance.insertErpExercisePlan(plan);
      return await DbHelper.instance.getActiveErpExercisePlans();
    });
  }

  Future<void> updatePlan(ErpExercisePlan plan) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await DbHelper.instance.updateErpExercisePlan(plan);
      return await DbHelper.instance.getActiveErpExercisePlans();
    });
  }

  Future<void> archivePlan(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await DbHelper.instance.archiveErpExercisePlan(id);
      return await DbHelper.instance.getActiveErpExercisePlans();
    });
  }
}

final erpExercisePlanProvider =
    AsyncNotifierProvider<ErpExercisePlanNotifier, List<ErpExercisePlan>>(() {
      return ErpExercisePlanNotifier();
    });

class ErpExerciseSessionNotifier
    extends AsyncNotifier<List<ErpExerciseSession>> {
  @override
  Future<List<ErpExerciseSession>> build() async {
    return await DbHelper.instance.getErpExerciseSessions();
  }

  Future<void> addSession(ErpExerciseSession session) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await DbHelper.instance.insertErpExerciseSession(session);
      return await DbHelper.instance.getErpExerciseSessions();
    });
  }
}

final erpExerciseSessionProvider =
    AsyncNotifierProvider<ErpExerciseSessionNotifier, List<ErpExerciseSession>>(
      () {
        return ErpExerciseSessionNotifier();
      },
    );
