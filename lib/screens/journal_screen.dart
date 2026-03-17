import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:window_manager/window_manager.dart';
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
  final TextEditingController _searchController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;
  bool _initialLoadDone = false;
  bool _isPreviewMode = true;
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
        const SnackBar(content: Text('Cannot save an empty entry'), behavior: SnackBarBehavior.floating),
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
        _isPreviewMode = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry saved successfully'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _loadEntryForDate(DateTime date, List<JournalEntry> entries, {bool forceEdit = false}) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final existing = entries.where((e) => e.date == dateStr).firstOrNull;
    
    setState(() {
      _selectedDate = date;
      _controller.text = existing?.content ?? '';
      _hasUnsavedChanges = false;
      _isPreviewMode = (existing == null || forceEdit) ? false : true;
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
        _isPreviewMode = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final journalAsync = ref.watch(journalProvider);
    final filteredJournalAsync = ref.watch(filteredJournalProvider);
    final theme = Theme.of(context);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    ref.listen<AsyncValue<List<JournalEntry>>>(journalProvider, (previous, next) {
      if (!_initialLoadDone && next.hasValue) {
        final entries = next.value!;
        final existing = entries.where((e) => e.date == DateFormat('yyyy-MM-dd').format(_selectedDate)).firstOrNull;
        if (existing != null) {
          _controller.text = existing.content;
          _isPreviewMode = true;
        } else {
          _isPreviewMode = false;
        }
        _initialLoadDone = true;
      }
    });

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: DragToMoveArea(
          child: Container(
            decoration: BoxDecoration(
              color: theme.appBarTheme.backgroundColor,
              border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5))),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(_isFocusMode ? LineIcons.expand : LineIcons.compress, size: 20),
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
                        height: 34,
                        width: 250,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => ref.read(journalSearchQueryProvider.notifier).query = value,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Search journals...',
                            prefixIcon: const Icon(LineIcons.search, size: 16),
                            contentPadding: EdgeInsets.zero,
                            fillColor: theme.colorScheme.onSurface.withOpacity(0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
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
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)
                        ),
                        Text(
                          _hasUnsavedChanges ? 'Unsaved changes' : 'Saved',
                          style: TextStyle(
                            fontSize: 10, 
                            fontWeight: FontWeight.w500,
                            color: _hasUnsavedChanges ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                Container(
                  height: 30,
                  width: 70,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Row(
                    children: [
                      _ModeToggle(
                        icon: LineIcons.edit,
                        isSelected: !_isPreviewMode,
                        onTap: () => setState(() => _isPreviewMode = false),
                        theme: theme,
                      ),
                      _ModeToggle(
                        icon: LineIcons.eye,
                        isSelected: _isPreviewMode,
                        onTap: () => setState(() => _isPreviewMode = true),
                        theme: theme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  height: 32,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving 
                      ? SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary))
                      : const Icon(LineIcons.save, size: 16),
                    label: const Text('Save', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  mouseCursor: SystemMouseCursors.click,
                  icon: const Icon(LineIcons.calendar, size: 20),
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
          ),
        ),
      ),
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _isFocusMode ? 0 : 280,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(right: BorderSide(color: theme.dividerColor.withOpacity(0.5))),
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
                          onPressed: () => _loadEntryForDate(DateTime.now(), journalAsync.value ?? [], forceEdit: true),
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
                                _loadEntryForDate(_selectedDate, journalAsync.value!);
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
                                onTap: () => _loadEntryForDate(DateTime.parse(entry.date), journalAsync.value ?? []),
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
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: theme.scaffoldBackgroundColor,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: _isPreviewMode 
                    ? Markdown(
                        data: _controller.text.isEmpty ? '*No content to preview*' : _controller.text,
                        padding: const EdgeInsets.all(48),
                        extensionSet: md.ExtensionSet.gitHubFlavored,
                        styleSheet: MarkdownStyleSheet(
                          p: GoogleFonts.inter(fontSize: 18, height: 1.8, color: theme.colorScheme.onSurface.withOpacity(0.8)),
                          h1: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: theme.colorScheme.primary),
                          h2: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface),
                          blockquote: const TextStyle(color: Colors.grey),
                          blockquoteDecoration: BoxDecoration(
                            border: Border(left: BorderSide(color: theme.colorScheme.primary, width: 4)),
                          ),
                        ),
                      )
                    : Padding(
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
                            hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.1)),
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
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _ModeToggle({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Icon(
                icon, 
                size: 16, 
                color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withOpacity(0.3)
              ),
            ),
          ),
        ),
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
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.isSelected 
                  ? widget.theme.colorScheme.primary.withOpacity(0.1) 
                  : (_isHovered ? widget.theme.colorScheme.onSurface.withOpacity(0.03) : Colors.transparent),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM d, yyyy').format(DateTime.parse(widget.entry.date)),
                  style: TextStyle(
                    color: widget.isSelected ? widget.theme.colorScheme.primary : widget.theme.colorScheme.onSurface.withOpacity(0.8),
                    fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.entry.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: widget.theme.colorScheme.onSurface.withOpacity(widget.isSelected ? 0.6 : 0.3),
                    fontSize: 12,
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
