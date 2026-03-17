import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import '../providers/providers.dart';
import '../models/models.dart';

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
        const SnackBar(content: Text('Entry saved successfully')),
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
                    final isSelected = entry.date == dateStr;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: InkWell(
                        onTap: () => _loadEntryForDate(DateTime.parse(entry.date), entries),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? theme.colorScheme.primary.withOpacity(0.5) : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('MMM d, yyyy').format(DateTime.parse(entry.date)),
                                style: TextStyle(
                                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                entry.content,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withOpacity(isSelected ? 0.8 : 0.4),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
