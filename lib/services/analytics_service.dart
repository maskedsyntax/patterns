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

enum InsightTone { positive, neutral, negative }

class InsightDelta {
  final double value;
  final bool lowerIsBetter;

  const InsightDelta({required this.value, this.lowerIsBetter = false});

  InsightTone get tone {
    if (value.abs() < 0.05) return InsightTone.neutral;
    final improved = lowerIsBetter ? value < 0 : value > 0;
    return improved ? InsightTone.positive : InsightTone.negative;
  }
}

class DashboardPoint {
  final DateTime date;
  final double value;

  const DashboardPoint({required this.date, required this.value});
}

class ThemeInsight {
  final String label;
  final double percent;
  final int count;

  const ThemeInsight({
    required this.label,
    required this.percent,
    required this.count,
  });
}

class RecoveryDashboardSummary {
  final int rangeDays;
  final int recoveryScore;
  final InsightDelta scoreDelta;
  final double averageUrge;
  final InsightDelta urgeDelta;
  final int erpPracticeCount;
  final InsightDelta erpDelta;
  final int consistencyPercent;
  final int activeDays;
  final List<bool> consistencyHeatmap;
  final List<DashboardPoint> scoreTrend;
  final List<DashboardPoint> moodTrend;
  final List<DashboardPoint> urgeTrend;
  final List<DashboardPoint> erpTrend;
  final List<ThemeInsight> topThemes;
  final int thoughts;
  final int compulsions;
  final bool hasAnyData;

  const RecoveryDashboardSummary({
    required this.rangeDays,
    required this.recoveryScore,
    required this.scoreDelta,
    required this.averageUrge,
    required this.urgeDelta,
    required this.erpPracticeCount,
    required this.erpDelta,
    required this.consistencyPercent,
    required this.activeDays,
    required this.consistencyHeatmap,
    required this.scoreTrend,
    required this.moodTrend,
    required this.urgeTrend,
    required this.erpTrend,
    required this.topThemes,
    required this.thoughts,
    required this.compulsions,
    required this.hasAnyData,
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

  static RecoveryDashboardSummary buildRecoveryDashboard({
    required List<JournalEntry> journals,
    required List<OcdEntry> ocds,
    required List<DelaySession> delaySessions,
    required List<ErpExerciseSession> erpSessions,
    required List<ExposureStep> exposureSteps,
    List<ResponsePreventionLog> responsePreventionLogs = const [],
    List<UrgeSurfSession> urgeSurfSessions = const [],
    AnalyticsDateRange range = AnalyticsDateRange.thirty,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();
    final rangeDays = DateRangeFilter.presetDaysFor(range).clamp(7, 365);
    final currentStart = _startOfDay(
      today.subtract(Duration(days: rangeDays - 1)),
    );
    final currentEnd = _endOfDay(today);
    final previousStart = _startOfDay(
      currentStart.subtract(Duration(days: rangeDays)),
    );
    final previousEnd = _endOfDay(
      currentStart.subtract(const Duration(days: 1)),
    );

    final current = _DashboardPeriodData.build(
      journals: journals,
      ocds: ocds,
      delaySessions: delaySessions,
      erpSessions: erpSessions,
      exposureSteps: exposureSteps,
      responsePreventionLogs: responsePreventionLogs,
      urgeSurfSessions: urgeSurfSessions,
      start: currentStart,
      end: currentEnd,
      days: rangeDays,
    );
    final previous = _DashboardPeriodData.build(
      journals: journals,
      ocds: ocds,
      delaySessions: delaySessions,
      erpSessions: erpSessions,
      exposureSteps: exposureSteps,
      responsePreventionLogs: responsePreventionLogs,
      urgeSurfSessions: urgeSurfSessions,
      start: previousStart,
      end: previousEnd,
      days: rangeDays,
    );

    return RecoveryDashboardSummary(
      rangeDays: rangeDays,
      recoveryScore: current.recoveryScore,
      scoreDelta: InsightDelta(
        value: current.recoveryScore - previous.recoveryScore.toDouble(),
      ),
      averageUrge: current.averageUrge,
      urgeDelta: InsightDelta(
        value: current.averageUrge - previous.averageUrge,
        lowerIsBetter: true,
      ),
      erpPracticeCount: current.erpPracticeCount,
      erpDelta: InsightDelta(
        value: current.erpPracticeCount - previous.erpPracticeCount.toDouble(),
      ),
      consistencyPercent: current.consistencyPercent,
      activeDays: current.activeDays.length,
      consistencyHeatmap: current.consistencyHeatmap,
      scoreTrend: current.scoreTrend,
      moodTrend: current.moodTrend,
      urgeTrend: current.urgeTrend,
      erpTrend: current.erpTrend,
      topThemes: _topThemes(journals: current.journals, ocds: current.ocds),
      thoughts: current.ocds.where((e) => e.type == OcdType.obsession).length,
      compulsions: current.ocds
          .where((e) => e.type == OcdType.compulsion)
          .length,
      hasAnyData: current.hasAnyData,
    );
  }

  static DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime _endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static bool _inRange(DateTime date, DateTime start, DateTime end) {
    return !date.isBefore(start) && !date.isAfter(end);
  }

  static List<ThemeInsight> _topThemes({
    required List<JournalEntry> journals,
    required List<OcdEntry> ocds,
  }) {
    final counts = <String, int>{};
    var categorized = 0;
    var uncategorized = 0;

    void classify(String text) {
      final themes = _classifyThemes(text);
      if (themes.isEmpty) {
        uncategorized++;
        return;
      }
      categorized++;
      for (final theme in themes) {
        counts[theme] = (counts[theme] ?? 0) + 1;
      }
    }

    for (final entry in journals) {
      classify(entry.content);
    }
    for (final entry in ocds) {
      classify('${entry.content} ${entry.response} ${entry.actionTaken ?? ''}');
    }

    if (counts.isEmpty && uncategorized > 0) {
      return [
        ThemeInsight(label: 'Uncategorized', percent: 1, count: uncategorized),
      ];
    }

    final denominator = categorized == 0 ? 1 : categorized;
    final themes =
        counts.entries
            .map(
              (entry) => ThemeInsight(
                label: entry.key,
                percent: entry.value / denominator,
                count: entry.value,
              ),
            )
            .toList()
          ..sort((a, b) => b.count.compareTo(a.count));
    return themes.take(4).toList();
  }

  static List<String> _classifyThemes(String text) {
    final normalized = text.toLowerCase();
    final matches = <String>[];
    for (final entry in _themeRules.entries) {
      if (entry.value.any((keyword) => normalized.contains(keyword))) {
        matches.add(entry.key);
      }
    }
    return matches;
  }

  static const Map<String, List<String>> _themeRules = {
    'Contamination': [
      'contamination',
      'contaminated',
      'dirty',
      'germs',
      'germ',
      'wash',
      'clean',
      'hygiene',
      'infect',
    ],
    'Harm': [
      'harm',
      'hurt',
      'violent',
      'attack',
      'kill',
      'knife',
      'danger',
      'injure',
    ],
    'Checking': [
      'check',
      'checking',
      'lock',
      'stove',
      'door',
      'switch',
      'recheck',
    ],
    'Reassurance': [
      'reassurance',
      'reassure',
      'ask again',
      'asked',
      'confirm',
      'certainty',
    ],
    'Health': [
      'health',
      'illness',
      'symptom',
      'disease',
      'doctor',
      'cancer',
      'heart',
      'medical',
    ],
    'Relationship': [
      'relationship',
      'partner',
      'love',
      'break up',
      'cheat',
      'dating',
      'marriage',
    ],
    'Symmetry': [
      'symmetry',
      'even',
      'order',
      'arrange',
      'aligned',
      'just right',
      'perfect',
    ],
    'Moral': [
      'moral',
      'religious',
      'sin',
      'blasphemy',
      'guilt',
      'confess',
      'wrong person',
    ],
    'Rumination': [
      'ruminate',
      'rumination',
      'analyze',
      'mental review',
      'figure out',
      'replay',
      'solve',
    ],
    'Uncertainty': [
      'uncertain',
      'uncertainty',
      'what if',
      'doubt',
      'maybe',
      'not sure',
      'unknown',
    ],
  };

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

class _DashboardPeriodData {
  final List<JournalEntry> journals;
  final List<OcdEntry> ocds;
  final Set<String> activeDays;
  final int erpPracticeCount;
  final double averageUrge;
  final int consistencyPercent;
  final int recoveryScore;
  final List<bool> consistencyHeatmap;
  final List<DashboardPoint> scoreTrend;
  final List<DashboardPoint> moodTrend;
  final List<DashboardPoint> urgeTrend;
  final List<DashboardPoint> erpTrend;

  bool get hasAnyData =>
      journals.isNotEmpty || ocds.isNotEmpty || erpPracticeCount > 0;

  const _DashboardPeriodData({
    required this.journals,
    required this.ocds,
    required this.activeDays,
    required this.erpPracticeCount,
    required this.averageUrge,
    required this.consistencyPercent,
    required this.recoveryScore,
    required this.consistencyHeatmap,
    required this.scoreTrend,
    required this.moodTrend,
    required this.urgeTrend,
    required this.erpTrend,
  });

  factory _DashboardPeriodData.build({
    required List<JournalEntry> journals,
    required List<OcdEntry> ocds,
    required List<DelaySession> delaySessions,
    required List<ErpExerciseSession> erpSessions,
    required List<ExposureStep> exposureSteps,
    required List<ResponsePreventionLog> responsePreventionLogs,
    required List<UrgeSurfSession> urgeSurfSessions,
    required DateTime start,
    required DateTime end,
    required int days,
    bool includeTrends = true,
  }) {
    final periodJournals = journals.where((entry) {
      return AnalyticsService._inRange(DateTime.parse(entry.date), start, end);
    }).toList();
    final periodOcds = ocds.where((entry) {
      return AnalyticsService._inRange(entry.datetime, start, end);
    }).toList();
    final periodDelays = delaySessions.where((entry) {
      return AnalyticsService._inRange(entry.createdAt, start, end);
    }).toList();
    final periodErp = erpSessions.where((entry) {
      return AnalyticsService._inRange(entry.createdAt, start, end);
    }).toList();
    final periodSteps = exposureSteps.where((step) {
      return step.status == ExposureStepStatus.completed &&
          step.completedAt != null &&
          AnalyticsService._inRange(step.completedAt!, start, end);
    }).toList();
    final periodResponses = responsePreventionLogs.where((entry) {
      return AnalyticsService._inRange(entry.createdAt, start, end);
    }).toList();
    final periodSurfs = urgeSurfSessions.where((entry) {
      return AnalyticsService._inRange(entry.createdAt, start, end);
    }).toList();

    final activeDays = <String>{};
    for (final entry in periodJournals) {
      activeDays.add(entry.date);
    }
    for (final entry in periodOcds) {
      activeDays.add(AnalyticsService._dateKey(entry.datetime));
    }
    for (final entry in periodDelays) {
      activeDays.add(AnalyticsService._dateKey(entry.createdAt));
    }
    for (final entry in periodErp) {
      activeDays.add(AnalyticsService._dateKey(entry.createdAt));
    }
    for (final entry in periodSteps) {
      activeDays.add(AnalyticsService._dateKey(entry.completedAt!));
    }
    for (final entry in periodResponses) {
      activeDays.add(AnalyticsService._dateKey(entry.createdAt));
    }
    for (final entry in periodSurfs) {
      activeDays.add(AnalyticsService._dateKey(entry.createdAt));
    }

    final erpPracticeCount =
        periodDelays.length +
        periodErp.length +
        periodSteps.length +
        periodResponses.length +
        periodSurfs.length;
    final urgeValues = <int>[
      for (final entry in periodOcds) entry.distressLevel,
      for (final entry in periodDelays) entry.urgeAfter,
      for (final entry in periodErp) entry.anxietyAfter,
      for (final entry in periodResponses) entry.anxietyLevel,
      for (final entry in periodSurfs) entry.finalUrge,
    ];
    final averageUrge = urgeValues.isEmpty
        ? 0.0
        : urgeValues.reduce((a, b) => a + b) / urgeValues.length;
    final consistencyPercent = ((activeDays.length / days) * 100).round().clamp(
      0,
      100,
    );
    final journalScore = ((periodJournals.length / days) * 100).clamp(0, 100);
    final erpScore = ((erpPracticeCount / (days / 3).ceil()) * 100).clamp(
      0,
      100,
    );
    final urgeScore = urgeValues.isEmpty
        ? 50.0
        : ((10 - averageUrge) / 10 * 100).clamp(0, 100);
    final recoveryScore =
        (consistencyPercent * 0.30 +
                erpScore * 0.30 +
                urgeScore * 0.25 +
                journalScore * 0.15)
            .round()
            .clamp(0, 100);

    final heatmapDays = days < 30 ? days : 30;
    final consistencyHeatmap = <bool>[
      for (var i = heatmapDays - 1; i >= 0; i--)
        activeDays.contains(
          AnalyticsService._dateKey(end.subtract(Duration(days: i))),
        ),
    ];

    final bucketCount = days <= 7 ? days : 7;
    final scoreTrend = <DashboardPoint>[];
    final moodTrend = <DashboardPoint>[];
    final urgeTrend = <DashboardPoint>[];
    final erpTrend = <DashboardPoint>[];
    if (includeTrends) {
      for (var bucket = 0; bucket < bucketCount; bucket++) {
        final bucketStart = AnalyticsService._startOfDay(
          start.add(Duration(days: (days * bucket / bucketCount).floor())),
        );
        final bucketEnd = AnalyticsService._endOfDay(
          start.add(
            Duration(days: (days * (bucket + 1) / bucketCount).floor() - 1),
          ),
        );
        final bucketData = _DashboardPeriodData._bucket(
          journals: periodJournals,
          ocds: periodOcds,
          delaySessions: periodDelays,
          erpSessions: periodErp,
          exposureSteps: periodSteps,
          responsePreventionLogs: periodResponses,
          urgeSurfSessions: periodSurfs,
          start: bucketStart,
          end: bucketEnd,
        );
        scoreTrend.add(
          DashboardPoint(
            date: bucketEnd,
            value: bucketData.recoveryScore.toDouble(),
          ),
        );
        moodTrend.add(DashboardPoint(date: bucketEnd, value: bucketData.mood));
        urgeTrend.add(
          DashboardPoint(date: bucketEnd, value: bucketData.averageUrge),
        );
        erpTrend.add(
          DashboardPoint(
            date: bucketEnd,
            value: bucketData.erpPracticeCount.toDouble(),
          ),
        );
      }
    }

    return _DashboardPeriodData(
      journals: periodJournals,
      ocds: periodOcds,
      activeDays: activeDays,
      erpPracticeCount: erpPracticeCount,
      averageUrge: averageUrge,
      consistencyPercent: consistencyPercent,
      recoveryScore: recoveryScore,
      consistencyHeatmap: consistencyHeatmap,
      scoreTrend: scoreTrend,
      moodTrend: moodTrend,
      urgeTrend: urgeTrend,
      erpTrend: erpTrend,
    );
  }

  factory _DashboardPeriodData._bucket({
    required List<JournalEntry> journals,
    required List<OcdEntry> ocds,
    required List<DelaySession> delaySessions,
    required List<ErpExerciseSession> erpSessions,
    required List<ExposureStep> exposureSteps,
    required List<ResponsePreventionLog> responsePreventionLogs,
    required List<UrgeSurfSession> urgeSurfSessions,
    required DateTime start,
    required DateTime end,
  }) {
    return _DashboardPeriodData.build(
      journals: journals,
      ocds: ocds,
      delaySessions: delaySessions,
      erpSessions: erpSessions,
      exposureSteps: exposureSteps,
      responsePreventionLogs: responsePreventionLogs,
      urgeSurfSessions: urgeSurfSessions,
      start: start,
      end: end,
      days: end.difference(start).inDays + 1,
      includeTrends: false,
    );
  }

  double get mood {
    if (ocds.isEmpty) return journals.isEmpty ? 5 : 6;
    return (10 - averageUrge).clamp(0, 10);
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
