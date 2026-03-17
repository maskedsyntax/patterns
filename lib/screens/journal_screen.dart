import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../database/db_helper.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final TextEditingController _controller = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;
  bool _initialLoadDone = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot save an empty entry')),
      );
      return;
    }
    
    setState(() => _isSaving = true);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    await ref.read(journalProvider.notifier).saveEntry(dateStr, _controller.text);
    
    if (mounted) {
      setState(() {
        _isSaving = false;
        _hasUnsavedChanges = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry saved successfully'), behavior: SnackBarBehavior.floating),
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Delete')
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
    final theme = Theme.of(context);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    ref.listen<AsyncValue<List<JournalEntry>>>(journalProvider, (previous, next) {
      if (!_initialLoadDone && next.hasValue) {
        final entries = next.value!;
        final existing = entries.where((e) => e.date == DateFormat('yyyy-MM-dd').format(_selectedDate)).firstOrNull;
        if (existing != null) {
          _controller.text = existing.content;
        }
        _initialLoadDone = true;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('MMMM d, yyyy').format(_selectedDate)),
            Text(
              _hasUnsavedChanges ? 'Unsaved changes' : 'All changes saved',
              style: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.normal,
                color: _hasUnsavedChanges ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving 
              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
              : const Icon(LineIcons.save, size: 18),
            label: const Text('Save'),
          ),
          const SizedBox(width: 12),
          IconButton(
            mouseCursor: SystemMouseCursors.click,
            icon: const Icon(LineIcons.calendar, size: 22),
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
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          Container(
            width: 300,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: theme.dividerColor)),
            ),
            child: journalAsync.when(
              data: (entries) {
                if (!_initialLoadDone) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _loadEntryForDate(_selectedDate, entries);
                      _initialLoadDone = true;
                    }
                  });
                }

                return ListView.builder(
                  itemCount: entries.length + 1,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: OutlinedButton.icon(
                          onPressed: () => _loadEntryForDate(DateTime.now(), entries),
                          icon: const Icon(LineIcons.plus),
                          label: const Text('New Entry Today'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      );
                    }
                    final entry = entries[index - 1];
                    return _JournalTile(
                      entry: entry,
                      isSelected: entry.date == dateStr,
                      onTap: () => _loadEntryForDate(DateTime.parse(entry.date), entries),
                      onDelete: () => _deleteEntry(entry.date),
                      theme: theme,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
          Expanded(
            child: Container(
              color: theme.brightness == Brightness.dark ? const Color(0xFF050505) : Colors.white,
              child: Padding(
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
                    fontSize: 20,
                    height: 1.8,
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Start writing...',
                    hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.2)),
                    filled: false,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
              position: RelativeRect.fromLTRB(offset.dx, offset.dy, offset.dx + 1, offset.dy + 1),
              items: [
                PopupMenuItem(
                  onTap: widget.onDelete,
                  child: const Row(
                    children: [
                      Icon(LineIcons.trash, size: 18, color: Colors.redAccent),
                      SizedBox(width: 12),
                      Text('Delete Entry', style: TextStyle(color: Colors.redAccent)),
                    ],
                  ),
                ),
              ],
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isSelected 
                  ? widget.theme.colorScheme.primary.withOpacity(0.1) 
                  : (_isHovered ? widget.theme.colorScheme.onSurface.withOpacity(0.03) : Colors.transparent),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isSelected 
                    ? widget.theme.colorScheme.primary.withOpacity(0.5) 
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM d, yyyy').format(DateTime.parse(widget.entry.date)),
                  style: TextStyle(
                    color: widget.isSelected ? widget.theme.colorScheme.primary : widget.theme.colorScheme.onSurface,
                    fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.entry.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: widget.theme.colorScheme.onSurface.withOpacity(widget.isSelected ? 0.8 : 0.4),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
