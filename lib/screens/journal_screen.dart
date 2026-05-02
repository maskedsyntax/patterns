import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';

import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';

class TodayScreen extends ConsumerStatefulWidget {
  final VoidCallback onJournal;
  final VoidCallback onTrack;
  final VoidCallback onSettings;

  const TodayScreen({
    super.key,
    required this.onJournal,
    required this.onTrack,
    required this.onSettings,
  });

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final journalAsync = ref.watch(journalProvider);
    final ocdAsync = ref.watch(ocdProvider);
    final dateLabel = DateFormat('EEEE, MMMM d').format(DateTime.now());
    final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final hasJournalToday =
        journalAsync.asData?.value.any((entry) => entry.date == todayKey) ??
        false;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 116),
          children: staggered([
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Today', style: _screenTitle(theme)),
                      const SizedBox(height: 5),
                      Text(dateLabel, style: _muted(theme, 15)),
                    ],
                  ),
                ),
                _RoundIconButton(
                  icon: LineIcons.cog,
                  onTap: widget.onSettings,
                  semanticLabel: 'Settings',
                ),
              ],
            ),
            const SizedBox(height: 28),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    LineIcons.feather,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    hasJournalToday
                        ? 'You showed up today.'
                        : 'A quiet note for today.',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    hasJournalToday
                        ? 'Let the rest of the day be lighter. You do not need to solve every thought.'
                        : 'You do not have to solve the pattern right now. Just notice one thing gently.',
                    style: _muted(
                      theme,
                      16,
                    ).copyWith(height: 1.55, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: LineIcons.penNib,
                    title: 'Write\nJournal',
                    onTap: widget.onJournal,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _ActionCard(
                    icon: LineIcons.bullseye,
                    title: 'Track OCD\nEvent',
                    onTap: widget.onTrack,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'Recent Activity',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            journalAsync.when(
              data: (entries) => _RecentRow(
                icon: LineIcons.bookOpen,
                title: 'Last journal entry',
                value: entries.isEmpty
                    ? 'No entries yet'
                    : DateFormat(
                        'MMM d',
                      ).format(DateTime.parse(entries.last.date)),
              ),
              loading: () => const _RecentSkeleton(),
              error: (error, stackTrace) => const _RecentRow(
                icon: LineIcons.bookOpen,
                title: 'Last journal entry',
                value: 'Unavailable',
              ),
            ),
            const SizedBox(height: 10),
            ocdAsync.when(
              data: (entries) => _RecentRow(
                icon: LineIcons.bullseye,
                title: 'Last OCD event',
                value: entries.isEmpty
                    ? 'No events yet'
                    : DateFormat(
                        'MMM d, h:mm a',
                      ).format(entries.first.datetime),
              ),
              loading: () => const _RecentSkeleton(),
              error: (error, stackTrace) => const _RecentRow(
                icon: LineIcons.bullseye,
                title: 'Last OCD event',
                value: 'Unavailable',
              ),
            ),
            const SizedBox(height: 10),
            journalAsync.when(
              data: (entries) => _RecentRow(
                icon: LineIcons.calendarCheck,
                title: 'Consistency',
                value: _streakLabel(entries),
              ),
              loading: () => const _RecentSkeleton(),
              error: (error, stackTrace) => const _RecentRow(
                icon: LineIcons.calendarCheck,
                title: 'Consistency',
                value: 'Unavailable',
              ),
            ),
          ]),
        ),
      ),
    );
  }

  String _streakLabel(List<JournalEntry> entries) {
    if (entries.isEmpty) return 'Start with one entry';
    final dates = entries.map((e) => e.date).toSet();
    var cursor = DateTime.now();
    var streak = 0;
    while (dates.contains(DateFormat('yyyy-MM-dd').format(cursor))) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    if (streak == 0) return 'Last entry saved';
    if (streak == 1) return '1 day streak';
    return '$streak day streak';
  }
}

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = ref.read(journalSearchQueryProvider);
    if (_searchController.text.isNotEmpty) _isSearching = true;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _enterSearch() {
    setState(() => _isSearching = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  void _exitSearch() {
    _searchFocus.unfocus();
    _searchController.clear();
    ref.read(journalSearchQueryProvider.notifier).query = '';
    setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entriesAsync = ref.watch(filteredJournalProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: _isSearching
                    ? _InlineSearchBar(
                        key: const ValueKey('search'),
                        controller: _searchController,
                        focusNode: _searchFocus,
                        onChanged: (value) => ref
                            .read(journalSearchQueryProvider.notifier)
                            .query = value,
                        onCancel: _exitSearch,
                      )
                    : Row(
                        key: const ValueKey('header'),
                        children: [
                          Expanded(
                            child: Text('Journal', style: _screenTitle(theme)),
                          ),
                          _RoundIconButton(
                            icon: LineIcons.search,
                            semanticLabel: 'Search journal',
                            onTap: _enterSearch,
                          ),
                          const SizedBox(width: 10),
                          _RoundIconButton(
                            icon: LineIcons.calendar,
                            semanticLabel: 'Choose date',
                            onTap: () => _pickDate(context),
                          ),
                        ],
                      ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: _isSearching
                  ? const SizedBox.shrink()
                  : SizedBox(
                      height: 52,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final date = DateTime.now().subtract(
                            Duration(days: index),
                          );
                          return _DatePill(
                            date: date,
                            isToday: index == 0,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    JournalEntryEditor(date: date),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 8),
                        itemCount: 10,
                      ),
                    ),
            ),
            Expanded(
              child: entriesAsync.when(
                data: (entries) {
                  final sorted = List<JournalEntry>.from(entries)
                    ..sort((a, b) => b.date.compareTo(a.date));
                  final query = ref.watch(journalSearchQueryProvider);
                  final children = <Widget>[
                    if (!_isSearching) ...[
                      _TodayEntryCard(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                JournalEntryEditor(date: DateTime.now()),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (sorted.isEmpty)
                      _EmptyState(
                        icon: _isSearching && query.isNotEmpty
                            ? LineIcons.search
                            : LineIcons.penNib,
                        title: _isSearching && query.isNotEmpty
                            ? 'No matches'
                            : 'No journal entries yet',
                        body: _isSearching && query.isNotEmpty
                            ? 'Nothing matches "$query".'
                            : 'A few quiet lines are enough to begin.',
                      )
                    else
                      ...sorted.map(
                        (entry) => _JournalListCard(entry: entry),
                      ),
                  ];
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 116),
                    children: staggered(
                      children,
                      stagger: const Duration(milliseconds: 40),
                      duration: const Duration(milliseconds: 380),
                      offset: 12,
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _DatePickerSheet(initialDate: DateTime.now()),
    );
    if (picked == null || !context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => JournalEntryEditor(date: picked)),
    );
  }
}

class _InlineSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onCancel;

  const _InlineSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onCancel,
  });

  @override
  State<_InlineSearchBar> createState() => _InlineSearchBarState();
}

class _InlineSearchBarState extends State<_InlineSearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    super.dispose();
  }

  void _onControllerChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            decoration: _softDecoration(theme, radius: 18),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Icon(
                  LineIcons.search,
                  size: 18,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    onChanged: widget.onChanged,
                    textInputAction: TextInputAction.search,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      hintText: 'Search entries',
                      hintStyle: TextStyle(
                        color: AppTheme.textSecondary.withValues(alpha: 0.7),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (widget.controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      widget.controller.clear();
                      widget.onChanged('');
                    },
                    child: Icon(
                      Icons.cancel,
                      size: 18,
                      color: AppTheme.textSecondary.withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        TextButton(
          onPressed: widget.onCancel,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: theme.colorScheme.primary,
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class JournalEntryEditor extends ConsumerStatefulWidget {
  final DateTime date;

  const JournalEntryEditor({super.key, required this.date});

  @override
  ConsumerState<JournalEntryEditor> createState() => _JournalEntryEditorState();
}

class _JournalEntryEditorState extends ConsumerState<JournalEntryEditor> {
  final TextEditingController _controller = TextEditingController();
  bool _loaded = false;
  bool _saving = false;
  bool _saved = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(journalProvider);
    final theme = Theme.of(context);
    final dateKey = DateFormat('yyyy-MM-dd').format(widget.date);

    entriesAsync.whenData((entries) {
      if (_loaded) return;
      final existing = entries
          .where((entry) => entry.date == dateKey)
          .firstOrNull;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _controller.text = existing?.content ?? '';
        setState(() {
          _loaded = true;
          _saved = true;
        });
      });
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(LineIcons.angleLeft),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('MMMM d, yyyy').format(widget.date),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 240),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                            opacity: animation,
                            child: SizeTransition(
                              sizeFactor: animation,
                              axisAlignment: -1,
                              child: child,
                            ),
                          ),
                          child: Text(
                            _saving
                                ? 'Saving...'
                                : (_saved ? 'Saved' : 'Unsaved'),
                            key: ValueKey(
                              _saving ? 'saving' : (_saved ? 'saved' : 'unsaved'),
                            ),
                            style: _muted(theme, 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _saving ? null : _save,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                child: TextField(
                  controller: _controller,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  autofocus: true,
                  onChanged: (_) => setState(() => _saved = false),
                  style: TextStyle(
                    fontFamily: AppTheme.sansFamily,
                    fontSize: 19,
                    height: 1.65,
                    letterSpacing: -0.1,
                    color: theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Start writing...',
                    hintStyle: TextStyle(
                      color: AppTheme.textSecondary.withValues(alpha: 0.5),
                    ),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_controller.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final dateKey = DateFormat('yyyy-MM-dd').format(widget.date);
    await ref
        .read(journalProvider.notifier)
        .saveEntry(dateKey, _controller.text.trim());
    if (!mounted) return;
    setState(() {
      _saving = false;
      _saved = true;
    });
  }
}

class _JournalListCard extends StatelessWidget {
  final JournalEntry entry;

  const _JournalListCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateTime.parse(entry.date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _Card(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => JournalEntryEditor(date: date),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('MMMM d').format(date),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              entry.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _muted(theme, 14).copyWith(height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayEntryCard extends StatelessWidget {
  final VoidCallback onTap;

  const _TodayEntryCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _Card(
      onTap: onTap,
      child: Row(
        children: [
          Icon(LineIcons.penNib, color: theme.colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Today entry',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Icon(LineIcons.angleRight, color: AppTheme.textSecondary),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _Card(
      onTap: onTap,
      child: SizedBox(
        height: 124,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 26),
            const Spacer(),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _RecentRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _softDecoration(theme, radius: 20),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(value, style: _muted(theme, 13)),
        ],
      ),
    );
  }
}

class _RecentSkeleton extends StatelessWidget {
  const _RecentSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _RecentRow(
      icon: LineIcons.circle,
      title: 'Loading',
      value: '...',
    );
  }
}

class _DatePill extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final VoidCallback onTap;

  const _DatePill({
    required this.date,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    final weekday = DateFormat('EEE').format(date);
    final dayLabel = DateFormat('MMM dd').format(date);

    return Center(
      child: PressScale(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: accent.withValues(alpha: 0.45),
              width: 1,
            ),
          ),
          child: isToday
              ? Text(
                  'Today',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: accent,
                    letterSpacing: -0.1,
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      weekday,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.5,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      dayLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.1,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _DatePickerSheet extends StatefulWidget {
  final DateTime initialDate;

  const _DatePickerSheet({required this.initialDate});

  @override
  State<_DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<_DatePickerSheet> {
  late DateTime _date = widget.initialDate;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;

    return _BottomPanel(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose date',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              CalendarDatePicker(
                initialDate: _date,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                onDateChanged: (date) => _date = date,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, _date),
                  child: const Text('Open entry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String semanticLabel;

  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: semanticLabel,
      child: PressScale(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: _softDecoration(theme, radius: 18),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _Card({required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.all(20),
      decoration: _softDecoration(Theme.of(context), radius: 24),
      child: child,
    );

    if (onTap == null) return content;
    return PressScale(onTap: onTap, child: content);
  }
}

class _BottomPanel extends StatelessWidget {
  final Widget child;

  const _BottomPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: child,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 42),
      child: Column(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary.withValues(alpha: 0.75),
            size: 38,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(body, textAlign: TextAlign.center, style: _muted(theme, 14)),
        ],
      ),
    );
  }
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

TextStyle _muted(ThemeData theme, double size) {
  return TextStyle(color: AppTheme.textSecondary, fontSize: size);
}

BoxDecoration _softDecoration(ThemeData theme, {required double radius}) {
  return BoxDecoration(
    color: theme.colorScheme.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: theme.dividerColor.withValues(alpha: 0.9)),
  );
}
