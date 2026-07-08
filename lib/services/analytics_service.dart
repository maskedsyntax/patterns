import '../models/models.dart';

enum AnalyticsDateRange { seven, thirty, ninety, year, allTime, custom }

class DateRangeFilter {
  final DateTime? cutoffExclusive;
  final DateTime? startInclusive;
  final DateTime? endInclusive;

  const DateRangeFilter._({
    this.cutoffExclusive,
    this.startInclusive,
    this.endInclusive,
  });

  factory DateRangeFilter.fromPreset(AnalyticsDateRange range) {
    if (range == AnalyticsDateRange.allTime) {
      return const DateRangeFilter._();
    }
    if (range == AnalyticsDateRange.custom) {
      throw ArgumentError('Use DateRangeFilter.custom for custom ranges');
    }
    return DateRangeFilter._(
      cutoffExclusive: DateTime.now().subtract(
        Duration(days: _presetDays(range)),
      ),
    );
  }

  factory DateRangeFilter.custom({
    required DateTime start,
    required DateTime end,
  }) {
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day, 23, 59, 59, 999);
    return DateRangeFilter._(startInclusive: startDay, endInclusive: endDay);
  }

  factory DateRangeFilter.resolve(
    AnalyticsDateRange range, {
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    if (range == AnalyticsDateRange.custom) {
      final start = customStart ?? DateTime.now();
      final end = customEnd ?? DateTime.now();
      return DateRangeFilter.custom(start: start, end: end);
    }
    if (range == AnalyticsDateRange.allTime) {
      return const DateRangeFilter._();
    }
    return DateRangeFilter.fromPreset(range);
  }

  (DateTime start, DateTime end) displayBounds({
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    final now = DateTime.now();
    if (cutoffExclusive != null) {
      return (cutoffExclusive!, now);
    }
    if (startInclusive != null && endInclusive != null) {
      return (startInclusive!, endInclusive!);
    }
    if (customStart != null && customEnd != null) {
      return (
        DateTime(customStart.year, customStart.month, customStart.day),
        DateTime(customEnd.year, customEnd.month, customEnd.day),
      );
    }
    return (DateTime(2000, 1, 1), now);
  }

  bool includesJournalDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    if (cutoffExclusive != null) return date.isAfter(cutoffExclusive!);
    if (startInclusive == null || endInclusive == null) return true;
    final day = DateTime(date.year, date.month, date.day);
    return !day.isBefore(startInclusive!) && !day.isAfter(endInclusive!);
  }

  bool includesOcdDateTime(DateTime datetime) {
    if (cutoffExclusive != null) return datetime.isAfter(cutoffExclusive!);
    if (startInclusive == null || endInclusive == null) return true;
    return !datetime.isBefore(startInclusive!) &&
        !datetime.isAfter(endInclusive!);
  }

  static int presetDaysFor(AnalyticsDateRange range) {
    switch (range) {
      case AnalyticsDateRange.seven:
        return 7;
      case AnalyticsDateRange.thirty:
        return 30;
      case AnalyticsDateRange.ninety:
        return 90;
      case AnalyticsDateRange.year:
        return 365;
      case AnalyticsDateRange.allTime:
        return 30;
      case AnalyticsDateRange.custom:
        return 30;
    }
  }

  static int _presetDays(AnalyticsDateRange range) => presetDaysFor(range);

  int get presetDays => cutoffExclusive == null ? 0 : _presetDaysFromCutoff();

  int _presetDaysFromCutoff() {
    final diff = DateTime.now().difference(cutoffExclusive!).inDays;
    if (diff <= 7) return 7;
    if (diff <= 30) return 30;
    if (diff <= 90) return 90;
    if (diff <= 365) return 365;
    return diff;
  }
}

class AnalyticsSummary {
  final int journalCount;
  final int ocdCount;
  final double averageDistress;
  final int obsessions;
  final int compulsions;
  final String journalingConsistencyNote;

  const AnalyticsSummary({
    required this.journalCount,
    required this.ocdCount,
    required this.averageDistress,
    required this.obsessions,
    required this.compulsions,
    required this.journalingConsistencyNote,
  });
}

class AnalyticsService {
  static List<JournalEntry> filterJournals(
    List<JournalEntry> entries,
    DateRangeFilter filter,
  ) {
    return entries.where((e) => filter.includesJournalDate(e.date)).toList();
  }

  static List<OcdEntry> filterOcds(
    List<OcdEntry> entries,
    DateRangeFilter filter,
  ) {
    return entries
        .where((e) => filter.includesOcdDateTime(e.datetime))
        .toList();
  }

  static double averageDistress(List<OcdEntry> entries) {
    if (entries.isEmpty) return 0;
    return entries.map((e) => e.distressLevel).reduce((a, b) => a + b) /
        entries.length;
  }

  static int obsessionCount(List<OcdEntry> entries) =>
      entries.where((e) => e.type == OcdType.obsession).length;

  static int compulsionCount(List<OcdEntry> entries) =>
      entries.where((e) => e.type == OcdType.compulsion).length;

  static String journalingConsistencyNote(
    List<JournalEntry> journals, {
    required int rangeDays,
  }) {
    if (journals.isEmpty) {
      return 'No journal entries in this range.';
    }
    final visibleDays = rangeDays.clamp(7, 30);
    final dates = journals.map((e) => e.date).toSet();
    var loggedDays = 0;
    for (var i = 0; i < visibleDays; i++) {
      final key = _dateKey(DateTime.now().subtract(Duration(days: i)));
      if (dates.contains(key)) loggedDays++;
    }
    return 'Journaled on $loggedDays of the last $visibleDays days.';
  }

  static AnalyticsSummary buildSummary({
    required List<JournalEntry> journals,
    required List<OcdEntry> ocds,
    required DateRangeFilter filter,
    AnalyticsDateRange range = AnalyticsDateRange.thirty,
  }) {
    final rangeDays =
        range == AnalyticsDateRange.custom && filter.startInclusive != null
        ? filter.endInclusive!
              .difference(filter.startInclusive!)
              .inDays
              .clamp(7, 30)
        : DateRangeFilter.presetDaysFor(range);

    return AnalyticsSummary(
      journalCount: journals.length,
      ocdCount: ocds.length,
      averageDistress: averageDistress(ocds),
      obsessions: obsessionCount(ocds),
      compulsions: compulsionCount(ocds),
      journalingConsistencyNote: journalingConsistencyNote(
        journals,
        rangeDays: filter.presetDays > 0 ? filter.presetDays : rangeDays,
      ),
    );
  }

  static String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Effort-focused recovery metrics aggregated across every ERP tool. Pure and
  /// testable - pass `now` to pin "today" in tests.
  static RecoveryMetrics buildRecoveryMetrics({
    required List<DelaySession> delaySessions,
    required List<ErpExerciseSession> erpSessions,
    required List<ExposureStep> exposureSteps,
    List<ResponsePreventionLog> responsePreventionLogs = const [],
    List<UrgeSurfSession> urgeSurfSessions = const [],
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();

    // Every day on which the user practised something (a delay, an ERP session,
    // completing an exposure step, a response-prevention log, or an urge surf).
    final activeDays = <String>{};
    for (final d in delaySessions) {
      activeDays.add(_dateKey(d.createdAt));
    }
    for (final e in erpSessions) {
      activeDays.add(_dateKey(e.createdAt));
    }
    for (final s in exposureSteps) {
      if (s.status == ExposureStepStatus.completed && s.completedAt != null) {
        activeDays.add(_dateKey(s.completedAt!));
      }
    }
    for (final r in responsePreventionLogs) {
      activeDays.add(_dateKey(r.createdAt));
    }
    for (final u in urgeSurfSessions) {
      activeDays.add(_dateKey(u.createdAt));
    }

    // Streak: consecutive active days. Anchored to today, but if today has no
    // practice yet we anchor to yesterday so a streak isn't lost mid-day.
    var streak = 0;
    var cursor = activeDays.contains(_dateKey(today))
        ? today
        : today.subtract(const Duration(days: 1));
    while (activeDays.contains(_dateKey(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    final exposuresCompleted = exposureSteps
        .where((s) => s.status == ExposureStepStatus.completed)
        .length;
    final sessionsPracticed =
        delaySessions.length + erpSessions.length + urgeSurfSessions.length;

    // Average urge drop across delay sessions (before→after) and urge surfs
    // (initial→final).
    final drops = <int>[
      for (final d in delaySessions) d.urgeBefore - d.urgeAfter,
      for (final u in urgeSurfSessions) u.initialUrge - u.finalUrge,
    ];
    final avgUrgeReduction = drops.isEmpty
        ? 0.0
        : drops.reduce((a, b) => a + b) / drops.length;

    final weekly = <bool>[
      for (var i = 6; i >= 0; i--)
        activeDays.contains(_dateKey(today.subtract(Duration(days: i)))),
    ];

    return RecoveryMetrics(
      practiceStreakDays: streak,
      exposuresCompleted: exposuresCompleted,
      sessionsPracticed: sessionsPracticed,
      avgUrgeReduction: avgUrgeReduction,
      weeklyActivity: weekly,
      hasAnyData: activeDays.isNotEmpty,
    );
  }
}

class RecoveryMetrics {
  final int practiceStreakDays;
  final int exposuresCompleted;
  final int sessionsPracticed;
  final double avgUrgeReduction;
  final List<bool> weeklyActivity; // length 7, oldest → today
  final bool hasAnyData;

  const RecoveryMetrics({
    required this.practiceStreakDays,
    required this.exposuresCompleted,
    required this.sessionsPracticed,
    required this.avgUrgeReduction,
    required this.weeklyActivity,
    required this.hasAnyData,
  });
}
