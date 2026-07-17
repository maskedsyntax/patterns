import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../database/db_helper.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/rich_journal.dart';
import '../widgets/window_controls.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final QuillController _controller = QuillController.basic();
  final FocusNode _editorFocus = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;
  bool _initialLoadDone = false;
  bool _isEditing = false;
  String _savedSnapshot = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onDocumentChanged);
  }

  void _onDocumentChanged() {
    final dirty = storedFromDocument(_controller.document) != _savedSnapshot;
    if (dirty != _hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = dirty);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onDocumentChanged);
    _controller.dispose();
    _editorFocus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_controller.document.toPlainText().trim().isEmpty) {
      showAppSnackBar(
        context,
        'Nothing to save yet. Add a line whenever you feel ready.',
        type: ToastType.info,
      );
      return;
    }

    setState(() => _isSaving = true);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    await ref
        .read(journalProvider.notifier)
        .saveEntry(dateStr, storedFromDocument(_controller.document));

    if (mounted) {
      _savedSnapshot = storedFromDocument(_controller.document);
      setState(() {
        _isSaving = false;
        _hasUnsavedChanges = false;
      });
      showAppSnackBar(context, 'Entry saved', type: ToastType.success);
    }
  }

  void _loadEntryForDate(DateTime date, List<JournalEntry> entries) {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final existing = entries.where((e) => e.date == dateStr).firstOrNull;

    _controller.document = documentFromStored(existing?.content ?? '');
    _controller.moveCursorToEnd();
    _savedSnapshot = storedFromDocument(_controller.document);
    setState(() {
      _selectedDate = date;
      _hasUnsavedChanges = false;
      _isEditing = existing == null; // Go directly to edit mode if entry doesn't exist
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
        _controller.document = Document();
        _savedSnapshot = storedFromDocument(_controller.document);
        setState(() {
          _isEditing = false;
        });
      }
    }
  }

  // Simple keyword-based theme detection for journal entries
  String? _detectTheme(String content) {
    final text = content.toLowerCase();
    if (text.contains('contamination') || text.contains('wash') || text.contains('germs') || text.contains('dirt') || text.contains('clean')) {
      return 'Contamination';
    }
    if (text.contains('uncertain') || text.contains('doubt') || text.contains('reassurance') || text.contains('certainty') || text.contains('solve')) {
      return 'Uncertainty';
    }
    if (text.contains('check') || text.contains('lock') || text.contains('door') || text.contains('stove')) {
      return 'Checking';
    }
    if (text.contains('relationship') || text.contains('love') || text.contains('partner')) {
      return 'Relationship';
    }
    if (text.contains('health') || text.contains('illness') || text.contains('cancer') || text.contains('sick') || text.contains('die')) {
      return 'Health';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final journalAsync = ref.watch(journalProvider);
    final filteredJournalAsync = ref.watch(filteredJournalProvider);
    final theme = Theme.of(context);
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
            color: theme.scaffoldBackgroundColor,
            border: Border(
              bottom: BorderSide(color: theme.dividerColor.withOpacity(0.3)),
            ),
          ),
          child: AppBar(
            toolbarHeight: 48,
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              'Journal Workspace',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            actions: const [WindowControls()],
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. Mockup Journal Header Row
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 24, 40, 20),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Journal',
                      style: TextStyle(
                        fontFamily: AppTheme.displayFamily,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your space to reflect and release.',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                
                // Search journals...
                Container(
                  width: 240,
                  height: 36,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) =>
                        ref.read(journalSearchQueryProvider.notifier).query = value,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search journals...',
                      prefixIcon: Icon(
                        LineIcons.search,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                      contentPadding: EdgeInsets.zero,
                      fillColor: theme.cardTheme.color,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(color: theme.dividerColor, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(color: theme.dividerColor, width: 1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // + New entry button
                SizedBox(
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _controller.document = Document();
                      _savedSnapshot = storedFromDocument(_controller.document);
                      setState(() {
                        _selectedDate = DateTime.now();
                        _isEditing = true;
                        _hasUnsavedChanges = false;
                      });
                      _editorFocus.requestFocus();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary, // Yellow
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    icon: const Icon(LineIcons.plus, size: 16, color: Colors.black),
                    label: const Text(
                      'New entry',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 2. Split View Area
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Panel: Journal Entry List
                Container(
                  width: 300,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(
                      right: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
                    ),
                  ),
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

                      // Group entries into "Today" and "Earlier"
                      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
                      final todayEntries = entries.where((e) => e.date == todayStr).toList();
                      final earlierEntries = entries.where((e) => e.date != todayStr).toList();

                      return ListView(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: [
                          if (todayEntries.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                              child: Text(
                                'Today',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary, // Yellow
                                ),
                              ),
                            ),
                            for (final entry in todayEntries)
                              _JournalTile(
                                entry: entry,
                                isSelected: entry.date == dateStr,
                                onTap: () {
                                  _loadEntryForDate(
                                    DateTime.parse(entry.date),
                                    journalAsync.value ?? [],
                                  );
                                },
                                onDelete: () => _deleteEntry(entry.date),
                                theme: theme,
                              ),
                          ],
                          if (earlierEntries.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 16,
                                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Earlier',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            for (final entry in earlierEntries)
                              _JournalTile(
                                entry: entry,
                                isSelected: entry.date == dateStr,
                                onTap: () {
                                  _loadEntryForDate(
                                    DateTime.parse(entry.date),
                                    journalAsync.value ?? [],
                                  );
                                },
                                onDelete: () => _deleteEntry(entry.date),
                                theme: theme,
                              ),
                          ],
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Center(child: Text('Error: $e')),
                  ),
                ),
                
                // Right Pane: Editor / Viewer
                Expanded(
                  child: Container(
                    color: theme.scaffoldBackgroundColor,
                    child: _isEditing 
                      ? _buildEditView(theme, journalAsync.value ?? [])
                      : _buildReadView(theme, journalAsync.value ?? []),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build the details reader panel
  Widget _buildReadView(ThemeData theme, List<JournalEntry> entries) {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final existing = entries.where((e) => e.date == dateStr).firstOrNull;

    if (existing == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LineIcons.penNib,
              size: 48,
              color: theme.colorScheme.onSurface.withOpacity(0.15),
            ),
            const SizedBox(height: 16),
            Text(
              'No entry for this date.',
              style: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() => _isEditing = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('Create Entry'),
            ),
          ],
        ),
      );
    }

    final plainText = documentFromStored(existing.content).toPlainText().trim();
    final themeDetected = _detectTheme(plainText);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top action row in details panel
        Padding(
          padding: const EdgeInsets.fromLTRB(48, 36, 48, 20),
          child: Row(
            children: [
              Text(
                '${DateFormat('MMMM d, yyyy').format(DateTime.parse(existing.date))} at ${DateFormat('h:mm a').format(existing.createdAt)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_horiz,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteEntry(existing.date);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(LineIcons.trash, size: 18, color: Colors.redAccent),
                        const SizedBox(width: 12),
                        const Text('Delete Entry', style: TextStyle(color: Colors.redAccent)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Journal content body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: QuillEditor.basic(
                  controller: QuillController(
                    document: documentFromStored(existing.content),
                    selection: const TextSelection.collapsed(offset: 0),
                    readOnly: true,
                  ),
                  config: QuillEditorConfig(
                    expands: false,
                    customStyles: _desktopEditorStyles(theme),
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Bottom toolbar: Theme Chip (left), Action buttons (right)
        Padding(
          padding: const EdgeInsets.fromLTRB(48, 20, 48, 36),
          child: Row(
            children: [
              if (themeDetected != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        themeDetected,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              
              // Edit button
              OutlinedButton(
                onPressed: () {
                  _loadEntryForDate(DateTime.parse(existing.date), entries);
                  setState(() => _isEditing = true);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.dividerColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(
                  'Edit',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Delete button (icon style)
              IconButton(
                onPressed: () => _deleteEntry(existing.date),
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: theme.dividerColor),
                  ),
                  padding: const EdgeInsets.all(10),
                ),
                icon: Icon(
                  LineIcons.trash,
                  size: 20,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Build the details editor panel
  Widget _buildEditView(ThemeData theme, List<JournalEntry> entries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Editor Header
        Padding(
          padding: const EdgeInsets.fromLTRB(48, 36, 48, 20),
          child: Row(
            children: [
              Text(
                'Editing: ${DateFormat('MMMM d, yyyy').format(_selectedDate)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              Text(
                _hasUnsavedChanges ? 'Unsaved changes' : 'Saved',
                style: TextStyle(
                  fontSize: 12,
                  color: _hasUnsavedChanges 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
        
        // Format Toolbar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: JournalFormatToolbar(controller: _controller),
        ),
        const SizedBox(height: 12),
        
        // Editor input
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: QuillEditor.basic(
                  controller: _controller,
                  focusNode: _editorFocus,
                  config: QuillEditorConfig(
                    expands: true,
                    placeholder: 'Start writing...',
                    customStyles: _desktopEditorStyles(theme),
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Action row: Save / Cancel
        Padding(
          padding: const EdgeInsets.fromLTRB(48, 20, 48, 36),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: () {
                  _loadEntryForDate(_selectedDate, entries);
                  setState(() => _isEditing = false);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.dividerColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isSaving ? null : () async {
                  await _save();
                  setState(() => _isEditing = false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: _isSaving 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Text('Save Entry'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  DefaultStyles _desktopEditorStyles(ThemeData theme) {
    final base = TextStyle(
      fontFamily: AppTheme.sansFamily,
      fontSize: 18,
      height: 1.7,
      color: theme.colorScheme.onSurface,
      fontWeight: FontWeight.w400,
    );
    return DefaultStyles(
      paragraph: DefaultTextBlockStyle(
        base,
        const HorizontalSpacing(0, 0),
        const VerticalSpacing(0, 0),
        const VerticalSpacing(0, 0),
        null,
      ),
      placeHolder: DefaultTextBlockStyle(
        base.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.15)),
        const HorizontalSpacing(0, 0),
        const VerticalSpacing(0, 0),
        const VerticalSpacing(0, 0),
        null,
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
    final dateObj = DateTime.tryParse(widget.entry.date) ?? widget.entry.createdAt;
    final dateStr = DateFormat('MMMM d, yyyy').format(dateObj);
    final timeStr = DateFormat('h:mm a').format(widget.entry.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? widget.theme.colorScheme.primary.withOpacity(0.06)
                  : (_isHovered
                      ? widget.theme.colorScheme.onSurface.withOpacity(0.04)
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isSelected
                    ? widget.theme.colorScheme.primary.withOpacity(0.35)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: TextStyle(
                    color: widget.isSelected
                        ? widget.theme.colorScheme.primary
                        : widget.theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text.rich(
                  richPreviewSpan(
                    widget.entry.content,
                    TextStyle(
                      color: widget.theme.colorScheme.onSurface.withOpacity(
                        widget.isSelected ? 0.65 : 0.35,
                      ),
                      fontSize: 11.5,
                    ),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: widget.theme.colorScheme.onSurface.withOpacity(0.4),
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
