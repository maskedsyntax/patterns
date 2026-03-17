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

class _OcdTrackerScreenState extends ConsumerState<OcdTrackerScreen> {
  OcdType _selectedType = OcdType.obsession;

  @override
  Widget build(BuildContext context) {
    final ocdAsync = ref.watch(ocdProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OCD Tracker'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              width: 300,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _TypeOption(
                    label: 'Obsessions',
                    isSelected: _selectedType == OcdType.obsession,
                    onTap: () => setState(() => _selectedType = OcdType.obsession),
                    theme: theme,
                  ),
                  _TypeOption(
                    label: 'Compulsions',
                    isSelected: _selectedType == OcdType.compulsion,
                    onTap: () => setState(() => _selectedType = OcdType.compulsion),
                    theme: theme,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _OcdListView(type: _selectedType, entries: ocdAsync),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        label: const Text('Track New'),
        icon: const Icon(LineIcons.plus),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => OcdEntryDialog(initialType: _selectedType),
    );
  }
}

class _TypeOption extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _TypeOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  State<_TypeOption> createState() => _TypeOptionState();
}

class _TypeOptionState extends State<_TypeOption> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: widget.isSelected 
                  ? widget.theme.colorScheme.primary 
                  : (_isHovered ? widget.theme.colorScheme.onSurface.withOpacity(0.05) : Colors.transparent),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: widget.isSelected ? Colors.black : widget.theme.colorScheme.onSurface.withOpacity(_isHovered ? 0.7 : 0.4),
                ),
              ),
            ),
          ),
        ),
      ),
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
                Icon(LineIcons.clipboard, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.1)),
                const SizedBox(height: 16),
                Text(
                  'No entries yet', 
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.3), fontWeight: FontWeight.w500)
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final entry = filtered[index];
            return _OcdCard(entry: entry, type: type, theme: theme);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }
}

class _OcdCard extends StatefulWidget {
  final OcdEntry entry;
  final OcdType type;
  final ThemeData theme;

  const _OcdCard({required this.entry, required this.type, required this.theme});

  @override
  State<_OcdCard> createState() => _OcdCardState();
}

class _OcdCardState extends State<_OcdCard> {
  bool _isHovered = false;

  Color _getDistressColor(int level) {
    if (level < 4) return Colors.greenAccent.withOpacity(0.8);
    if (level < 8) return Colors.orangeAccent.withOpacity(0.8);
    return Colors.redAccent.withOpacity(0.8);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: widget.theme.cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHovered ? widget.theme.colorScheme.primary.withOpacity(0.3) : widget.theme.dividerColor,
              ),
              boxShadow: _isHovered ? [
                BoxShadow(
                  color: widget.theme.colorScheme.primary.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ] : [],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 6,
                      color: _getDistressColor(widget.entry.distressLevel),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  DateFormat('MMM d, h:mm a').format(widget.entry.datetime),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700, 
                                    color: widget.theme.colorScheme.onSurface.withOpacity(0.8),
                                    fontSize: 13,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Distress ${widget.entry.distressLevel}/10',
                                  style: TextStyle(
                                    color: _getDistressColor(widget.entry.distressLevel),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  mouseCursor: SystemMouseCursors.click,
                                  icon: const Icon(LineIcons.trash, size: 18, color: Colors.redAccent),
                                  onPressed: () => ref.read(ocdProvider.notifier).deleteEntry(widget.entry.id!),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.type == OcdType.obsession ? 'OBSESSION' : 'COMPULSION',
                              style: TextStyle(
                                color: widget.theme.colorScheme.primary.withOpacity(0.6),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.entry.content, 
                              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, height: 1.5)
                            ),
                            if (widget.entry.actionTaken != null && widget.entry.actionTaken!.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              Text(
                                'ACTION TAKEN',
                                style: TextStyle(
                                  color: widget.theme.colorScheme.onSurface.withOpacity(0.3),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(widget.entry.actionTaken!, style: const TextStyle(fontSize: 15, height: 1.5)),
                            ],
                            const SizedBox(height: 20),
                            Text(
                              'STRATEGY / RESPONSE',
                              style: TextStyle(
                                color: widget.theme.colorScheme.onSurface.withOpacity(0.3),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.entry.response, 
                              style: GoogleFonts.inter(
                                fontSize: 15, 
                                height: 1.5, 
                                fontStyle: FontStyle.italic,
                                color: widget.theme.colorScheme.onSurface.withOpacity(0.7),
                              )
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
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
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Container(
        width: 550,
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Track OCD Event', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 32),
            SegmentedButton<OcdType>(
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                selectedForegroundColor: theme.colorScheme.primary,
                side: BorderSide(color: theme.dividerColor),
              ),
              segments: const [
                ButtonSegment(value: OcdType.obsession, label: Text('Obsession'), icon: Icon(LineIcons.brain)),
                ButtonSegment(value: OcdType.compulsion, label: Text('Compulsion'), icon: Icon(LineIcons.mouse)),
              ],
              selected: {_type},
              onSelectionChanged: (set) => setState(() => _type = set.first),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: _type == OcdType.obsession ? 'Obsessive Thought' : 'Compulsive Urge',
                hintText: 'Describe the experience...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            if (_type == OcdType.compulsion) ...[
              TextField(
                controller: _actionController,
                decoration: const InputDecoration(
                  labelText: 'Action Taken',
                  hintText: 'What was your response?',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
            ],
            TextField(
              controller: _responseController,
              decoration: const InputDecoration(
                labelText: 'Strategy Used',
                hintText: 'Coping mechanism or therapy response...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Text('Distress Level', style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                const Spacer(),
                Text('${_distressLevel.round()}/10', style: TextStyle(fontWeight: FontWeight.w800, color: theme.colorScheme.primary, fontSize: 18)),
              ],
            ),
            Slider(
              value: _distressLevel,
              min: 0,
              max: 10,
              divisions: 10,
              activeColor: theme.colorScheme.primary,
              onChanged: (val) => setState(() => _distressLevel = val),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context), 
                  child: Text('Cancel', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)))
                ),
                const SizedBox(width: 16),
                ElevatedButton(
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
