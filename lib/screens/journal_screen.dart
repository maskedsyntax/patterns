import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final TextEditingController _controller = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  Timer? _debounce;
  bool _isSaving = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 1), () {
      _save();
    });
  }

  Future<void> _save() async {
    if (_controller.text.isEmpty) return;
    setState(() => _isSaving = true);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    await ref.read(journalProvider.notifier).saveEntry(dateStr, _controller.text);
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final journalAsync = ref.watch(journalProvider);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('MMMM d, yyyy').format(_selectedDate)),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, size: 20),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
                // Load existing content for the new date
                final entries = journalAsync.value ?? [];
                final existing = entries.where((e) => e.date == DateFormat('yyyy-MM-dd').format(picked)).firstOrNull;
                _controller.text = existing?.content ?? '';
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          Container(
            width: 280,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: theme.dividerColor)),
            ),
            child: journalAsync.when(
              data: (entries) {
                return ListView.builder(
                  itemCount: entries.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ListTile(
                        leading: Icon(Icons.add, color: theme.colorScheme.primary),
                        title: const Text('New Journal Entry'),
                        onTap: () {
                          setState(() {
                            _selectedDate = DateTime.now();
                            _controller.clear();
                          });
                        },
                      );
                    }
                    final entry = entries[index - 1];
                    final isSelected = entry.date == dateStr;
                    return ListTile(
                      selected: isSelected,
                      selectedTileColor: theme.colorScheme.primary.withOpacity(0.05),
                      title: Text(
                        DateFormat('MMM d, yyyy').format(DateTime.parse(entry.date)),
                        style: TextStyle(
                          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        entry.content,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedDate = DateTime.parse(entry.date);
                          _controller.text = entry.content;
                        });
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                onChanged: (_) => _onChanged(),
                style: GoogleFonts.inter(
                  fontSize: 18,
                  height: 1.6,
                  color: theme.colorScheme.onSurface,
                ),
                decoration: const InputDecoration(
                  hintText: 'Write your thoughts...',
                  filled: false,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
