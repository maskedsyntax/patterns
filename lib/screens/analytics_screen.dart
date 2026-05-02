import 'package:animations/animations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';

import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';

enum _Range { seven, thirty, ninety, year }

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  _Range _range = _Range.thirty;
  _Range _previousRange = _Range.thirty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final journalAsync = ref.watch(journalProvider);
    final ocdAsync = ref.watch(ocdProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 116),
          children: [
            FadeSlideIn(child: Text('Insights', style: _screenTitle(theme))),
            const SizedBox(height: 18),
            FadeSlideIn(
              delay: const Duration(milliseconds: 60),
              child: _RangeSelector(
                range: _range,
                onChanged: (range) {
                  if (range == _range) return;
                  setState(() {
                    _previousRange = _range;
                    _range = range;
                  });
                },
              ),
            ),
            const SizedBox(height: 22),
            journalAsync.when(
              data: (journals) => ocdAsync.when(
                data: (ocds) {
                  final filteredJournals = _filterJournals(journals);
                  final filteredOcds = _filterOcds(ocds);
                  final avgDistress = filteredOcds.isEmpty
                      ? 0
                      : filteredOcds
                                .map((entry) => entry.distressLevel)
                                .reduce((a, b) => a + b) /
                            filteredOcds.length;
                  final obsessions = filteredOcds
                      .where((entry) => entry.type == OcdType.obsession)
                      .length;
                  final compulsions = filteredOcds
                      .where((entry) => entry.type == OcdType.compulsion)
                      .length;

                  final goingForward = _range.index >= _previousRange.index;
                  return PageTransitionSwitcher(
                    duration: const Duration(milliseconds: 360),
                    reverse: !goingForward,
                    transitionBuilder: (child, primary, secondary) {
                      return SharedAxisTransition(
                        animation: primary,
                        secondaryAnimation: secondary,
                        transitionType: SharedAxisTransitionType.horizontal,
                        fillColor: Colors.transparent,
                        child: child,
                      );
                    },
                    child: Column(
                      key: ValueKey(_range),
                      children: [
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.25,
                          children: [
                            _SummaryCard(
                              title: 'Journal entries',
                              numericValue: filteredJournals.length.toDouble(),
                              icon: LineIcons.bookOpen,
                            ),
                            _SummaryCard(
                              title: 'OCD events',
                              numericValue: filteredOcds.length.toDouble(),
                              icon: LineIcons.bullseye,
                            ),
                            _SummaryCard(
                              title: 'Average distress',
                              numericValue: avgDistress.toDouble(),
                              fractionDigits: 1,
                              icon: LineIcons.areaChart,
                            ),
                            _SummaryCard(
                              title: 'Most common trigger',
                              value: _commonTrigger(filteredOcds),
                              icon: LineIcons.compass,
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _InsightCard(
                          title: 'Distress trend',
                          child: SizedBox(
                            height: 178,
                            child: _DistressTrend(entries: filteredOcds),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _InsightCard(
                          title: 'Journaling consistency',
                          child: _ConsistencyStrip(
                            entries: filteredJournals,
                            days: _rangeDays,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _InsightCard(
                          title: 'Obsession vs compulsion',
                          child: _RatioBar(
                            obsessions: obsessions,
                            compulsions: compulsions,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _InsightCard(
                          title: 'Trigger patterns',
                          child: Text(
                            _triggerPatternCopy(filteredOcds),
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ],
        ),
      ),
    );
  }

  int get _rangeDays {
    switch (_range) {
      case _Range.seven:
        return 7;
      case _Range.thirty:
        return 30;
      case _Range.ninety:
        return 90;
      case _Range.year:
        return 365;
    }
  }

  DateTime get _cutoff => DateTime.now().subtract(Duration(days: _rangeDays));

  List<JournalEntry> _filterJournals(List<JournalEntry> entries) {
    return entries
        .where((entry) => DateTime.parse(entry.date).isAfter(_cutoff))
        .toList();
  }

  List<OcdEntry> _filterOcds(List<OcdEntry> entries) {
    return entries.where((entry) => entry.datetime.isAfter(_cutoff)).toList();
  }
}

class _RangeSelector extends StatelessWidget {
  final _Range range;
  final ValueChanged<_Range> onChanged;

  const _RangeSelector({required this.range, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: _softDecoration(Theme.of(context), radius: 22),
      child: Row(
        children: [
          _RangeChip(
            label: '7D',
            selected: range == _Range.seven,
            onTap: () => onChanged(_Range.seven),
          ),
          _RangeChip(
            label: '30D',
            selected: range == _Range.thirty,
            onTap: () => onChanged(_Range.thirty),
          ),
          _RangeChip(
            label: '90D',
            selected: range == _Range.ninety,
            onTap: () => onChanged(_Range.ninety),
          ),
          _RangeChip(
            label: 'Year',
            selected: range == _Range.year,
            onTap: () => onChanged(_Range.year),
          ),
        ],
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? theme.colorScheme.onPrimary
                  : AppTheme.textSecondary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String? value;
  final double? numericValue;
  final int fractionDigits;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.icon,
    this.value,
    this.numericValue,
    this.fractionDigits = 0,
  }) : assert(value != null || numericValue != null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueStyle = theme.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w900,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _softDecoration(theme, radius: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 22),
          const Spacer(),
          if (numericValue != null)
            AnimatedCounter(
              value: numericValue!,
              fractionDigits: fractionDigits,
              style: valueStyle,
            )
          else
            Text(
              value!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: valueStyle,
            ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InsightCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _softDecoration(theme, radius: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _DistressTrend extends StatelessWidget {
  final List<OcdEntry> entries;

  const _DistressTrend({required this.entries});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sorted = List<OcdEntry>.from(entries)
      ..sort((a, b) => a.datetime.compareTo(b.datetime));
    final recent = sorted.length > 12
        ? sorted.sublist(sorted.length - 12)
        : sorted;

    if (recent.isEmpty) {
      return Center(
        child: Text(
          'No events in this range',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 10,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(
            color: theme.dividerColor.withValues(alpha: 0.65),
            strokeWidth: 1,
          ),
        ),
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < recent.length; i++)
                FlSpot(i.toDouble(), recent[i].distressLevel.toDouble()),
            ],
            isCurved: true,
            color: AppTheme.warmYellow,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.warmYellow.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsistencyStrip extends StatelessWidget {
  final List<JournalEntry> entries;
  final int days;

  const _ConsistencyStrip({required this.entries, required this.days});

  @override
  Widget build(BuildContext context) {
    final dates = entries.map((entry) => entry.date).toSet();
    final visibleDays = days.clamp(7, 30);

    return Row(
      children: [
        for (var i = visibleDays - 1; i >= 0; i--)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == 0 ? 0 : 4),
              child: Container(
                height: 34,
                decoration: BoxDecoration(
                  color:
                      dates.contains(
                        DateFormat(
                          'yyyy-MM-dd',
                        ).format(DateTime.now().subtract(Duration(days: i))),
                      )
                      ? AppTheme.warmYellow
                      : AppTheme.charcoalInput,
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _RatioBar extends StatelessWidget {
  final int obsessions;
  final int compulsions;

  const _RatioBar({required this.obsessions, required this.compulsions});

  @override
  Widget build(BuildContext context) {
    final total = obsessions + compulsions;
    final obsPercent = total == 0 ? 0.5 : obsessions / total;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Row(
            children: [
              Expanded(
                flex: (obsPercent * 100).round().clamp(1, 99),
                child: Container(height: 14, color: AppTheme.warmYellow),
              ),
              Expanded(
                flex: ((1 - obsPercent) * 100).round().clamp(1, 99),
                child: Container(height: 14, color: AppTheme.softGreen),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              '$obsessions obsessions',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const Spacer(),
            Text(
              '$compulsions compulsions',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}

String _commonTrigger(List<OcdEntry> entries) {
  if (entries.isEmpty) return 'None yet';

  final scores = <String, int>{};
  final displayForms = <String, Map<String, int>>{};

  for (final entry in entries) {
    final tokens = _meaningfulTokens(entry.content);

    for (final token in tokens) {
      _recordTriggerCandidate(
        key: token.stem,
        display: token.original,
        scores: scores,
        displayForms: displayForms,
      );
    }

    for (var i = 0; i < tokens.length - 1; i++) {
      final first = tokens[i];
      final second = tokens[i + 1];
      _recordTriggerCandidate(
        key: '${first.stem} ${second.stem}',
        display: '${first.original} ${second.original}',
        scores: scores,
        displayForms: displayForms,
      );
    }
  }

  if (scores.isEmpty) return 'Not clear';

  final sorted = scores.entries.toList()
    ..sort((a, b) {
      final countCompare = b.value.compareTo(a.value);
      if (countCompare != 0) return countCompare;

      final phraseCompare = b.key
          .split(' ')
          .length
          .compareTo(a.key.split(' ').length);
      if (phraseCompare != 0) return phraseCompare;

      return a.key.compareTo(b.key);
    });

  return _bestDisplayForm(displayForms[sorted.first.key] ?? const {});
}

String commonTriggerForTesting(List<OcdEntry> entries) =>
    _commonTrigger(entries);

String _triggerPatternCopy(List<OcdEntry> entries) {
  if (entries.isEmpty) {
    return 'Patterns will appear here after a few tracked events.';
  }
  final trigger = _commonTrigger(entries);
  if (trigger == 'Not clear') {
    return 'There is not a strong repeated trigger yet.';
  }
  return 'A repeated theme around "$trigger" appears in this range.';
}

const Set<String> _triggerStopWords = {
  'a',
  'an',
  'and',
  'are',
  'as',
  'at',
  'be',
  'because',
  'been',
  'but',
  'by',
  'did',
  'do',
  'does',
  'doing',
  'for',
  'from',
  'had',
  'has',
  'have',
  'having',
  'he',
  'her',
  'here',
  'hers',
  'him',
  'his',
  'i',
  'if',
  'in',
  'into',
  'is',
  'it',
  'its',
  'me',
  'my',
  'of',
  'on',
  'or',
  'our',
  'she',
  'so',
  'than',
  'that',
  'the',
  'their',
  'them',
  'then',
  'there',
  'they',
  'this',
  'to',
  'too',
  'was',
  'we',
  'were',
  'when',
  'where',
  'which',
  'who',
  'will',
  'with',
  'you',
  'your',
  'about',
  'again',
  'always',
  'feel',
  'feeling',
  'felt',
  'just',
  'like',
  'maybe',
  'ocd',
  'really',
  'something',
  'still',
  'thing',
  'things',
  'think',
  'thinking',
  'thought',
  'thoughts',
  'today',
  'very',
};

List<_TriggerToken> _meaningfulTokens(String text) {
  final words = RegExp(
    r"[a-zA-Z][a-zA-Z']*",
  ).allMatches(text.toLowerCase()).map((match) => match.group(0)!);

  return [
    for (final word in words)
      if (_isMeaningfulTriggerWord(word))
        _TriggerToken(original: word, stem: _stemWord(word)),
  ];
}

bool _isMeaningfulTriggerWord(String word) {
  if (word.length < 4) return false;
  if (_triggerStopWords.contains(word)) return false;
  return true;
}

String _stemWord(String word) {
  if (word.length > 5 && word.endsWith('ing')) {
    return _trimDoubleConsonant(word.substring(0, word.length - 3));
  }
  if (word.length > 4 && word.endsWith('ed')) {
    return _trimDoubleConsonant(word.substring(0, word.length - 2));
  }
  if (word.length > 5 && word.endsWith('es')) {
    return word.substring(0, word.length - 2);
  }
  if (word.length > 4 && word.endsWith('s') && !word.endsWith('ss')) {
    return word.substring(0, word.length - 1);
  }
  return word;
}

String _trimDoubleConsonant(String stem) {
  if (stem.length < 2) return stem;

  final last = stem[stem.length - 1];
  final previous = stem[stem.length - 2];
  if (last == previous && !'aeiou'.contains(last)) {
    return stem.substring(0, stem.length - 1);
  }
  return stem;
}

void _recordTriggerCandidate({
  required String key,
  required String display,
  required Map<String, int> scores,
  required Map<String, Map<String, int>> displayForms,
}) {
  scores[key] = (scores[key] ?? 0) + 1;
  final forms = displayForms.putIfAbsent(key, () => {});
  forms[display] = (forms[display] ?? 0) + 1;
}

String _bestDisplayForm(Map<String, int> forms) {
  if (forms.isEmpty) return 'Not clear';
  final sorted = forms.entries.toList()
    ..sort((a, b) {
      final countCompare = b.value.compareTo(a.value);
      if (countCompare != 0) return countCompare;
      return a.key.compareTo(b.key);
    });
  return sorted.first.key;
}

class _TriggerToken {
  final String original;
  final String stem;

  const _TriggerToken({required this.original, required this.stem});
}

TextStyle _screenTitle(ThemeData theme) {
  return TextStyle(
    fontFamily: AppTheme.displayFamily,
    fontSize: 32,
    fontWeight: FontWeight.w500,
    height: 1.08,
    letterSpacing: -0.6,
    color: theme.colorScheme.onSurface,
  );
}

BoxDecoration _softDecoration(ThemeData theme, {required double radius}) {
  return BoxDecoration(
    color: theme.colorScheme.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: theme.dividerColor.withValues(alpha: 0.9)),
  );
}
