import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import '../models/models.dart';
import '../providers/providers.dart';

class OcdTrackerScreen extends ConsumerStatefulWidget {
  const OcdTrackerScreen({super.key});

  @override
  ConsumerState<OcdTrackerScreen> createState() => _OcdTrackerScreenState();
}

class _OcdTrackerScreenState extends ConsumerState<OcdTrackerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final ocdAsync = ref.watch(ocdProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OCD Tracker'),
        bottom: TabBar(
          controller: _tabController,
          dividerColor: Colors.transparent,
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
          tabs: const [
            Tab(text: 'Obsessions'),
            Tab(text: 'Compulsions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OcdListView(type: OcdType.obsession, entries: ocdAsync),
          _OcdListView(type: OcdType.compulsion, entries: ocdAsync),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.colorScheme.primary,
        onPressed: () => _showAddDialog(context),
        label: const Text('Track New', style: TextStyle(color: Colors.black)),
        icon: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => OcdEntryDialog(initialType: OcdType.values[_tabController.index]),
    );
  }
}

class _OcdListView extends ConsumerWidget {
  final OcdType type;
  final AsyncValue<List<OcdEntry>> entries;

  const _OcdListView({required this.type, required this.entries});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return entries.when(
      data: (data) {
        final filtered = data.where((e) => e.type == type).toList();
        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LineIcons.clipboard, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.2)),
                const SizedBox(height: 16),
                Text('No entries yet', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5))),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final entry = filtered[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMM d, h:mm a').format(entry.datetime),
                          style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getDistressColor(entry.distressLevel).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Distress: ${entry.distressLevel}/10',
                            style: TextStyle(
                              color: _getDistressColor(entry.distressLevel),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                          onPressed: () => ref.read(ocdProvider.notifier).deleteEntry(entry.id!),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      type == OcdType.obsession ? 'Obsessive Thought:' : 'Compulsive Urge:',
                      style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(entry.content, style: const TextStyle(fontSize: 16)),
                    if (entry.actionTaken != null && entry.actionTaken!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text('Action Taken:', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(entry.actionTaken!, style: const TextStyle(fontSize: 16)),
                    ],
                    const SizedBox(height: 12),
                    Text('Response/Strategy:', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(entry.response, style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Color _getDistressColor(int level) {
    if (level < 4) return Colors.greenAccent;
    if (level < 8) return Colors.orangeAccent;
    return Colors.redAccent;
  }
}

class OcdEntryDialog extends ConsumerStatefulWidget {
  final OcdType initialType;
  const OcdEntryDialog({super.key, required this.initialType});

  @override
  ConsumerState<OcdEntryDialog> createState() => _OcdEntryDialogState();
}

class _OcdEntryDialogState extends ConsumerState<OcdEntryDialog> {
  late OcdType _type;
  final _contentController = TextEditingController();
  final _actionController = TextEditingController();
  final _responseController = TextEditingController();
  double _distressLevel = 5;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Track OCD Event', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SegmentedButton<OcdType>(
              segments: const [
                ButtonSegment(value: OcdType.obsession, label: Text('Obsession')),
                ButtonSegment(value: OcdType.compulsion, label: Text('Compulsion')),
              ],
              selected: {_type},
              onSelectionChanged: (set) => setState(() => _type = set.first),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: _type == OcdType.obsession ? 'Obsessive Thought' : 'Compulsive Urge',
                hintText: 'What was the thought or urge?',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            if (_type == OcdType.compulsion) ...[
              TextField(
                controller: _actionController,
                decoration: const InputDecoration(
                  labelText: 'Action Taken',
                  hintText: 'What did you do?',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _responseController,
              decoration: const InputDecoration(
                labelText: 'Response / Strategy',
                hintText: 'How did you handle it?',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Text('Distress Level: ${_distressLevel.round()}/10', style: const TextStyle(fontWeight: FontWeight.w600)),
            Slider(
              value: _distressLevel,
              min: 0,
              max: 10,
              divisions: 10,
              onChanged: (val) => setState(() => _distressLevel = val),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: () async {
                    final entry = OcdEntry(
                      type: _type,
                      datetime: DateTime.now(),
                      content: _contentController.text,
                      distressLevel: _distressLevel.round(),
                      response: _responseController.text,
                      actionTaken: _type == OcdType.compulsion ? _actionController.text : null,
                      createdAt: DateTime.now(),
                    );
                    await ref.read(ocdProvider.notifier).addEntry(entry);
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('Save Entry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
