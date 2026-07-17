import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../database/db_helper.dart';
import '../services/material_file_store.dart';
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
  /// again. Used by the "Reset entry" action - clearing the text and saving is
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

// Exposure Hierarchy (Pro)
class ExposureHierarchyNotifier extends AsyncNotifier<List<ExposureHierarchy>> {
  @override
  Future<List<ExposureHierarchy>> build() async {
    return await DbHelper.instance.getActiveExposureHierarchies();
  }

  Future<void> addHierarchyWithSteps(
    ExposureHierarchy hierarchy,
    List<ExposureStep> steps,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await DbHelper.instance.insertExposureHierarchyWithSteps(
        hierarchy,
        steps,
      );
      ref.invalidate(exposureStepProvider);
      return await DbHelper.instance.getActiveExposureHierarchies();
    });
  }

  Future<void> archiveHierarchy(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await DbHelper.instance.archiveExposureHierarchy(id);
      return await DbHelper.instance.getActiveExposureHierarchies();
    });
  }
}

final exposureHierarchyProvider =
    AsyncNotifierProvider<ExposureHierarchyNotifier, List<ExposureHierarchy>>(
      () {
        return ExposureHierarchyNotifier();
      },
    );

class ExposureStepNotifier extends AsyncNotifier<List<ExposureStep>> {
  @override
  Future<List<ExposureStep>> build() async {
    return await DbHelper.instance.getExposureSteps();
  }

  Future<void> updateStep(ExposureStep step) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await DbHelper.instance.updateExposureStep(step);
      return await DbHelper.instance.getExposureSteps();
    });
  }
}

final exposureStepProvider =
    AsyncNotifierProvider<ExposureStepNotifier, List<ExposureStep>>(() {
      return ExposureStepNotifier();
    });

// Response Prevention (Pro)
class ResponsePreventionNotifier
    extends AsyncNotifier<List<ResponsePreventionLog>> {
  @override
  Future<List<ResponsePreventionLog>> build() async {
    return await DbHelper.instance.getResponsePreventionLogs();
  }

  Future<void> addLog(ResponsePreventionLog log) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await DbHelper.instance.insertResponsePreventionLog(log);
      return await DbHelper.instance.getResponsePreventionLogs();
    });
  }

  Future<void> deleteLog(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await DbHelper.instance.deleteResponsePreventionLog(id);
      return await DbHelper.instance.getResponsePreventionLogs();
    });
  }
}

final responsePreventionProvider =
    AsyncNotifierProvider<
      ResponsePreventionNotifier,
      List<ResponsePreventionLog>
    >(() {
      return ResponsePreventionNotifier();
    });

// Urge Surfing (Pro)
class UrgeSurfNotifier extends AsyncNotifier<List<UrgeSurfSession>> {
  @override
  Future<List<UrgeSurfSession>> build() async {
    return await DbHelper.instance.getUrgeSurfSessions();
  }

  Future<void> addSession(UrgeSurfSession session) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await DbHelper.instance.insertUrgeSurfSession(session);
      return await DbHelper.instance.getUrgeSurfSessions();
    });
  }
}

final urgeSurfProvider =
    AsyncNotifierProvider<UrgeSurfNotifier, List<UrgeSurfSession>>(() {
      return UrgeSurfNotifier();
    });

// Structured Programs (Pro)
class ProgramEnrollmentNotifier extends AsyncNotifier<List<ProgramEnrollment>> {
  @override
  Future<List<ProgramEnrollment>> build() async {
    return await DbHelper.instance.getProgramEnrollments();
  }

  /// Returns the enrollment id for [programId], creating it if needed.
  Future<int> enroll(String programId) async {
    final existing = state.asData?.value.firstWhere(
      (e) => e.programId == programId,
      orElse: () => ProgramEnrollment(programId: '', createdAt: DateTime.now()),
    );
    if (existing != null && existing.programId == programId) {
      return existing.id!;
    }
    final id = await DbHelper.instance.insertProgramEnrollment(
      ProgramEnrollment(programId: programId, createdAt: DateTime.now()),
    );
    state = await AsyncValue.guard(
      () => DbHelper.instance.getProgramEnrollments(),
    );
    return id;
  }
}

final programEnrollmentProvider =
    AsyncNotifierProvider<ProgramEnrollmentNotifier, List<ProgramEnrollment>>(
      () {
        return ProgramEnrollmentNotifier();
      },
    );

class ProgramTaskProgressNotifier
    extends AsyncNotifier<List<ProgramTaskProgress>> {
  @override
  Future<List<ProgramTaskProgress>> build() async {
    return await DbHelper.instance.getProgramTaskProgress();
  }

  Future<void> toggleTask({
    required int enrollmentId,
    required int weekIndex,
    required String taskId,
    required bool completed,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (completed) {
        await DbHelper.instance.insertProgramTaskProgress(
          ProgramTaskProgress(
            enrollmentId: enrollmentId,
            weekIndex: weekIndex,
            taskId: taskId,
            completedAt: DateTime.now(),
          ),
        );
      } else {
        await DbHelper.instance.deleteProgramTaskProgress(
          enrollmentId: enrollmentId,
          weekIndex: weekIndex,
          taskId: taskId,
        );
      }
      return await DbHelper.instance.getProgramTaskProgress();
    });
  }
}

final programTaskProgressProvider =
    AsyncNotifierProvider<
      ProgramTaskProgressNotifier,
      List<ProgramTaskProgress>
    >(() {
      return ProgramTaskProgressNotifier();
    });

// Behavioral Experiments (Pro)
class BehavioralExperimentNotifier
    extends AsyncNotifier<List<BehavioralExperiment>> {
  @override
  Future<List<BehavioralExperiment>> build() async {
    return await DbHelper.instance.getBehavioralExperiments();
  }

  Future<void> add(BehavioralExperiment exp) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await DbHelper.instance.insertBehavioralExperiment(exp);
      return await DbHelper.instance.getBehavioralExperiments();
    });
  }

  Future<void> edit(BehavioralExperiment exp) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await DbHelper.instance.updateBehavioralExperiment(exp);
      return await DbHelper.instance.getBehavioralExperiments();
    });
  }

  Future<void> delete(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await DbHelper.instance.deleteBehavioralExperiment(id);
      return await DbHelper.instance.getBehavioralExperiments();
    });
  }
}

final behavioralExperimentProvider =
    AsyncNotifierProvider<
      BehavioralExperimentNotifier,
      List<BehavioralExperiment>
    >(() {
      return BehavioralExperimentNotifier();
    });

// Exposure Reflection Journal (Pro)
class ExposureReflectionNotifier
    extends AsyncNotifier<List<ExposureReflection>> {
  @override
  Future<List<ExposureReflection>> build() async {
    return await DbHelper.instance.getExposureReflections();
  }

  Future<void> add(ExposureReflection reflection) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await DbHelper.instance.insertExposureReflection(reflection);
      return await DbHelper.instance.getExposureReflections();
    });
  }

  Future<void> delete(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await DbHelper.instance.deleteExposureReflection(id);
      return await DbHelper.instance.getExposureReflections();
    });
  }
}

final exposureReflectionProvider =
    AsyncNotifierProvider<ExposureReflectionNotifier, List<ExposureReflection>>(
      () {
        return ExposureReflectionNotifier();
      },
    );

// Action Planner (Pro)
class ActionPlanNotifier extends AsyncNotifier<List<ActionPlan>> {
  @override
  Future<List<ActionPlan>> build() async {
    return await DbHelper.instance.getActionPlans();
  }

  Future<void> add(ActionPlan plan) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await DbHelper.instance.insertActionPlan(plan);
      return await DbHelper.instance.getActionPlans();
    });
  }

  Future<void> setCompleted(ActionPlan plan, bool completed) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await DbHelper.instance.updateActionPlan(
        plan.copyWith(completed: completed),
      );
      return await DbHelper.instance.getActionPlans();
    });
  }

  Future<void> delete(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await DbHelper.instance.deleteActionPlan(id);
      return await DbHelper.instance.getActionPlans();
    });
  }
}

final actionPlanProvider =
    AsyncNotifierProvider<ActionPlanNotifier, List<ActionPlan>>(() {
      return ActionPlanNotifier();
    });

// Implementation Intentions (Pro)
class ImplementationIntentionNotifier
    extends AsyncNotifier<List<ImplementationIntention>> {
  @override
  Future<List<ImplementationIntention>> build() async {
    return await DbHelper.instance.getImplementationIntentions();
  }

  Future<void> add(ImplementationIntention intention) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await DbHelper.instance.insertImplementationIntention(intention);
      return await DbHelper.instance.getImplementationIntentions();
    });
  }

  Future<void> delete(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await DbHelper.instance.deleteImplementationIntention(id);
      return await DbHelper.instance.getImplementationIntentions();
    });
  }
}

final implementationIntentionProvider =
    AsyncNotifierProvider<
      ImplementationIntentionNotifier,
      List<ImplementationIntention>
    >(() {
      return ImplementationIntentionNotifier();
    });

// Uncertainty Training (Pro)
class UncertaintyLogNotifier extends AsyncNotifier<List<UncertaintyLog>> {
  @override
  Future<List<UncertaintyLog>> build() async {
    return await DbHelper.instance.getUncertaintyLogs();
  }

  Future<void> add(UncertaintyLog log) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await DbHelper.instance.insertUncertaintyLog(log);
      return await DbHelper.instance.getUncertaintyLogs();
    });
  }
}

final uncertaintyLogProvider =
    AsyncNotifierProvider<UncertaintyLogNotifier, List<UncertaintyLog>>(() {
      return UncertaintyLogNotifier();
    });

// Exposure Materials (Pro)
class ExposureMaterialNotifier extends AsyncNotifier<List<ExposureMaterial>> {
  @override
  Future<List<ExposureMaterial>> build() async {
    return await DbHelper.instance.getExposureMaterials();
  }

  /// The material's [ExposureMaterial.fileName] (if any) must already point at a
  /// file copied into the materials dir via `MaterialFileStore.save`.
  Future<void> add(ExposureMaterial material) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await DbHelper.instance.insertExposureMaterial(material);
      return await DbHelper.instance.getExposureMaterials();
    });
  }

  Future<void> delete(ExposureMaterial material) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (material.id != null) {
        await DbHelper.instance.deleteExposureMaterial(material.id!);
      }
      final fileName = material.fileName;
      if (fileName != null) {
        await MaterialFileStore.delete(fileName);
      }
      return await DbHelper.instance.getExposureMaterials();
    });
  }
}

final exposureMaterialProvider =
    AsyncNotifierProvider<ExposureMaterialNotifier, List<ExposureMaterial>>(() {
      return ExposureMaterialNotifier();
    });

// Y-BOCS Self-Check (free)
class YbocsAssessmentNotifier extends AsyncNotifier<List<YbocsAssessment>> {
  @override
  Future<List<YbocsAssessment>> build() async {
    return await DbHelper.instance.getYbocsAssessments();
  }

  Future<void> add(YbocsAssessment assessment) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await DbHelper.instance.insertYbocsAssessment(assessment);
      return await DbHelper.instance.getYbocsAssessments();
    });
  }

  Future<void> delete(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await DbHelper.instance.deleteYbocsAssessment(id);
      return await DbHelper.instance.getYbocsAssessments();
    });
  }
}

final ybocsAssessmentProvider =
    AsyncNotifierProvider<YbocsAssessmentNotifier, List<YbocsAssessment>>(() {
      return YbocsAssessmentNotifier();
    });
