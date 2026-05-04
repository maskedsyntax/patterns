import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../database/db_helper.dart';
import '../widgets/window_controls.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;
  bool _initialLoadDone = false;
  bool _isFocusMode = false;

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot save an empty entry'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    await ref
        .read(journalProvider.notifier)
        .saveEntry(dateStr, _controller.text);

    if (mounted) {
      setState(() {
        _isSaving = false;
        _hasUnsavedChanges = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entry saved successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _loadEntryForDate(DateTime date, List<JournalEntry> entries) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final existing = entries.where((e) => e.date == dateStr).firstOrNull;

    setState(() {
      _selectedDate = date;
      _controller.text = existing?.content ?? '';
      _hasUnsavedChanges = false;
    });
  }

  Future<void> _deleteEntry(String date) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: const Text('This will permanently remove this journal entry.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DbHelper.instance.deleteJournalEntry(date);
      ref.invalidate(journalProvider);
      if (date == DateFormat('yyyy-MM-dd').format(_selectedDate)) {
        _controller.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final journalAsync = ref.watch(journalProvider);
    final filteredJournalAsync = ref.watch(filteredJournalProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    ref.listen<AsyncValue<List<JournalEntry>>>(journalProvider, (
      previous,
      next,
    ) {
      if (!_initialLoadDone && next.hasValue) {
        _loadEntryForDate(_selectedDate, next.value!);
        _initialLoadDone = true;
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.white,
              border: Border(
                bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
              ),
            ),
            child: AppBar(
              toolbarHeight: 48,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  _isFocusMode ? LineIcons.compress : LineIcons.expand,
                  size: 20,
                ),
                tooltip: _isFocusMode ? 'Exit Focus Mode' : 'Enter Focus Mode',
                onPressed: () => setState(() => _isFocusMode = !_isFocusMode),
              ),
              titleSpacing: 0,
              title: Stack(
                alignment: Alignment.center,
                children: [
                  if (!_isFocusMode)
                    Center(
                      child: Container(
                        height: 30,
                        width: 250,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) =>
                              ref
                                      .read(journalSearchQueryProvider.notifier)
                                      .query =
                                  value,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search journals...',
                            prefixIcon: Icon(
                              LineIcons.search,
                              size: 16,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.4,
                              ),
                            ),
                            contentPadding: EdgeInsets.zero,
                            fillColor: theme.colorScheme.onSurface.withOpacity(
                              0.05,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat('MMMM d, yyyy').format(_selectedDate),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          _hasUnsavedChanges ? 'Unsaved' : 'Saved',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: _hasUnsavedChanges
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                const SizedBox(width: 12),
                SizedBox(
                  height: 28,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(LineIcons.save, size: 14),
                    label: const Text('Save', style: TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  mouseCursor: SystemMouseCursors.click,
                  icon: Icon(
                    LineIcons.calendar,
                    size: 18,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      _loadEntryForDate(picked, journalAsync.value ?? []);
                    }
                  },
                ),
                const SizedBox(width: 4),
                const WindowControls(),
              ],
            ),
          ),
        ),
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _isFocusMode ? 0 : 280,
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.surface
                    : theme.scaffoldBackgroundColor,
                border: Border(
                  right: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: SizedBox(
                  width: 280,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _loadEntryForDate(
                              DateTime.now(),
                              journalAsync.value ?? [],
                            ),
                            icon: const Icon(LineIcons.plus, size: 16),
                            label: const Text('Today'),
                          ),
                        ),
                      ),
                      Expanded(
                        child: filteredJournalAsync.when(
                          data: (entries) {
                            if (!_initialLoadDone && journalAsync.hasValue) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  _loadEntryForDate(
                                    _selectedDate,
                                    journalAsync.value!,
                                  );
                                  _initialLoadDone = true;
                                }
                              });
                            }

                            return ListView.builder(
                              itemCount: entries.length,
                              padding: const EdgeInsets.only(bottom: 8),
                              itemBuilder: (context, index) {
                                final entry = entries[index];
                                return _JournalTile(
                                  entry: entry,
                                  isSelected: entry.date == dateStr,
                                  onTap: () => _loadEntryForDate(
                                    DateTime.parse(entry.date),
                                    journalAsync.value ?? [],
                                  ),
                                  onDelete: () => _deleteEntry(entry.date),
                                  theme: theme,
                                );
                              },
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, s) => Center(child: Text('Error: $e')),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: isDark ? Colors.black : Colors.white,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  padding: const EdgeInsets.fromLTRB(48, 48, 48, 0),
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    expands: true,
                    onChanged: (value) {
                      if (!_hasUnsavedChanges) {
                        setState(() => _hasUnsavedChanges = true);
                      }
                    },
                    style: GoogleFonts.inter(
                      fontSize: 19,
                      height: 1.7,
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Start writing...',
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.1),
                      ),
                      filled: false,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JournalTile extends StatefulWidget {
  final JournalEntry entry;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ThemeData theme;

  const _JournalTile({
    required this.entry,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
    required this.theme,
  });

  @override
  State<_JournalTile> createState() => _JournalTileState();
}

class _JournalTileState extends State<_JournalTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          onSecondaryTapDown: (details) {
            final offset = details.globalPosition;
            showMenu(
              context: context,
              position: RelativeRect.fromLTRB(
                offset.dx,
                offset.dy,
                offset.dx + 1,
                offset.dy + 1,
              ),
              items: [
                PopupMenuItem(
                  onTap: widget.onDelete,
                  child: const Row(
                    children: [
                      Icon(LineIcons.trash, size: 18, color: Colors.redAccent),
                      SizedBox(width: 12),
                      Text(
                        'Delete Entry',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.isSelected
                    ? widget.theme.colorScheme.primary.withOpacity(0.5)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? widget.theme.colorScheme.primary.withOpacity(
                        isDark ? 0.15 : 0.1,
                      )
                    : (_isHovered
                          ? widget.theme.colorScheme.onSurface.withOpacity(0.05)
                          : Colors.transparent),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat(
                      'MMM d, yyyy',
                    ).format(DateTime.parse(widget.entry.date)),
                    style: TextStyle(
                      color: widget.isSelected
                          ? (isDark
                                ? widget.theme.colorScheme.primary
                                : Colors.black)
                          : widget.theme.colorScheme.onSurface.withOpacity(0.8),
                      fontWeight: widget.isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.entry.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: widget.theme.colorScheme.onSurface.withOpacity(
                        widget.isSelected ? 0.6 : 0.3,
                      ),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
