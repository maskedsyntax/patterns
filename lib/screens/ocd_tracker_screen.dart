import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/window_controls.dart';

class OcdTrackerScreen extends ConsumerStatefulWidget {
  const OcdTrackerScreen({super.key});

  @override
  ConsumerState<OcdTrackerScreen> createState() => _OcdTrackerScreenState();
}

class _OcdTrackerScreenState extends ConsumerState<OcdTrackerScreen> {
  OcdType? _selectedType;
  int? _selectedId;

  @override
  Widget build(BuildContext context) {
    final filteredOcdAsync = ref.watch(filteredOcdProvider);
    final isHighDistressOnly = ref.watch(ocdHighDistressOnlyProvider);
    final theme = Theme.of(context);

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
              'OCD Tracker Workspace',
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
          // 1. Mockup Tracker Header Row
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 24, 40, 20),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OCD Tracker',
                      style: TextStyle(
                        fontFamily: AppTheme.displayFamily,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track your thoughts, urges, and actions.',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                
                // Segments Segmented Capsule Control
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _CustomSegment(
                        label: 'All',
                        isSelected: _selectedType == null,
                        onTap: () => setState(() => _selectedType = null),
                        theme: theme,
                      ),
                      _CustomSegment(
                        label: 'Obsessions',
                        isSelected: _selectedType == OcdType.obsession,
                        onTap: () => setState(() => _selectedType = OcdType.obsession),
                        theme: theme,
                      ),
                      _CustomSegment(
                        label: 'Compulsions',
                        isSelected: _selectedType == OcdType.compulsion,
                        onTap: () => setState(() => _selectedType = OcdType.compulsion),
                        theme: theme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                
                // Distress Filter Button (funnel icon)
                GestureDetector(
                  onTap: () => ref.read(ocdHighDistressOnlyProvider.notifier).toggle(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isHighDistressOnly ? theme.colorScheme.primary.withOpacity(0.15) : theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isHighDistressOnly ? theme.colorScheme.primary : theme.dividerColor,
                      ),
                    ),
                    child: Icon(
                      LineIcons.filter,
                      size: 18,
                      color: isHighDistressOnly ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // + Log entry button
                SizedBox(
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddDialog(context),
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
                      'Log entry',
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
            child: filteredOcdAsync.when(
              data: (data) {
                final filtered = _selectedType == null
                    ? data
                    : data.where((e) => e.type == _selectedType).toList();
                final selected = filtered.where((e) => e.id == _selectedId).firstOrNull ??
                    (filtered.isNotEmpty ? filtered.first : null);
                if (selected != null && selected.id != _selectedId) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _selectedId = selected.id);
                  });
                }
                
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left Panel: Entry List
                    Container(
                      width: 300,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        border: Border(
                          right: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
                        ),
                      ),
                      child: filtered.isEmpty
                          ? Center(
                              child: Text(
                                'No entries',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withOpacity(0.35),
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final entry = filtered[index];
                                final isSelected = entry.id == selected?.id;
                                return _OcdListTile(
                                  entry: entry,
                                  isSelected: isSelected,
                                  onTap: () => setState(() => _selectedId = entry.id),
                                  theme: theme,
                                );
                              },
                            ),
                    ),
                    
                    // Right Panel: Details
                    Expanded(
                      child: Container(
                        color: theme.scaffoldBackgroundColor,
                        child: selected == null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LineIcons.list,
                                      size: 48,
                                      color: theme.colorScheme.onSurface.withOpacity(0.15),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Select an event or track a new one',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(40, 24, 40, 48),
                                child: Center(
                                  child: Container(
                                    constraints: const BoxConstraints(maxWidth: 800),
                                    child: Column(
                                      children: [
                                        _OcdCard(entry: selected, theme: theme),
                                        const SizedBox(height: 16),
                                        // Bottom Strategy tip box
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                          decoration: BoxDecoration(
                                            color: theme.cardTheme.color,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: theme.colorScheme.primary.withOpacity(0.15),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.star_outline_rounded,
                                                color: theme.colorScheme.primary,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  'Great job using your strategy. Small steps build big change.',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: theme.colorScheme.onSurface.withOpacity(0.85),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          OcdEntryDialog(initialType: _selectedType ?? OcdType.obsession),
    );
  }
}

/// Custom segment indicator
class _CustomSegment extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _CustomSegment({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}

/// Custom styled OCD list tile matching the mockup design
class _OcdListTile extends StatefulWidget {
  final OcdEntry entry;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _OcdListTile({
    required this.entry,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  State<_OcdListTile> createState() => _OcdListTileState();
}

class _OcdListTileState extends State<_OcdListTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? widget.theme.colorScheme.primary.withOpacity(0.06)
                  : (_hovered
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.entry.type == OcdType.obsession ? 'Obsession' : 'Compulsion',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: widget.theme.colorScheme.primary.withOpacity(0.9),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${widget.entry.distressLevel}/10',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: widget.theme.colorScheme.onSurface.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  widget.entry.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: widget.theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('MMM d, h:mm a').format(widget.entry.datetime),
                  style: TextStyle(
                    fontSize: 11,
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

/// Upgraded mockup-perfect OCD details Card
class _OcdCard extends StatefulWidget {
  final OcdEntry entry;
  final ThemeData theme;

  const _OcdCard({required this.entry, required this.theme});

  @override
  State<_OcdCard> createState() => _OcdCardState();
}

class _OcdCardState extends State<_OcdCard> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final formattedTime = DateFormat('MMM d, h:mm a').format(widget.entry.datetime);
        
        return Container(
          decoration: BoxDecoration(
            color: widget.theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.theme.dividerColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Date and Delete row
                  Row(
                    children: [
                      Text(
                        formattedTime,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: widget.theme.colorScheme.onSurface.withOpacity(0.55),
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        mouseCursor: SystemMouseCursors.click,
                        icon: const Icon(
                          LineIcons.trash,
                          size: 20,
                          color: Colors.redAccent,
                        ),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Log Entry?'),
                              content: const Text('This will permanently delete this OCD event entry.'),
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
                            ref
                                .read(ocdProvider.notifier)
                                .deleteEntry(widget.entry.id!);
                            if (context.mounted) {
                              showAppSnackBar(
                                context,
                                'Event deleted',
                                type: ToastType.success,
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Compulsion vs Obsession header + Distress level
                  Row(
                    children: [
                      Text(
                        widget.entry.type == OcdType.obsession ? 'OBSESSION' : 'COMPULSION',
                        style: TextStyle(
                          color: widget.theme.colorScheme.primary, // Yellow accent
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Distress ${widget.entry.distressLevel}/10',
                        style: TextStyle(
                          color: const Color(0xFFFF9500), // Orange/gold distress text
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Large urge text
                  Text(
                    widget.entry.content,
                    style: TextStyle(
                      fontFamily: AppTheme.sansFamily,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      height: 1.45,
                      color: widget.theme.colorScheme.onSurface,
                    ),
                  ),
                  
                  // Action taken (Compulsions only)
                  if (widget.entry.actionTaken != null &&
                      widget.entry.actionTaken!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'ACTION TAKEN',
                      style: TextStyle(
                        color: widget.theme.colorScheme.onSurface.withOpacity(0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.entry.actionTaken!,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: widget.theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                  
                  // Strategy/Response
                  const SizedBox(height: 24),
                  Text(
                    'STRATEGY / RESPONSE',
                    style: TextStyle(
                      color: widget.theme.colorScheme.onSurface.withOpacity(0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.entry.response,
                    style: TextStyle(
                      fontFamily: AppTheme.sansFamily,
                      fontSize: 14,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                      color: widget.theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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
            Text(
              'Track OCD Event',
              style: TextStyle(
                fontFamily: AppTheme.sansFamily,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 32),
            SegmentedButton<OcdType>(
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: theme.colorScheme.primary.withOpacity(
                  0.1,
                ),
                selectedForegroundColor: theme.colorScheme.primary,
                side: BorderSide(color: theme.dividerColor),
              ),
              segments: const [
                ButtonSegment(
                  value: OcdType.obsession,
                  label: Text('Obsession'),
                  icon: Icon(LineIcons.brain),
                ),
                ButtonSegment(
                  value: OcdType.compulsion,
                  label: Text('Compulsion'),
                  icon: Icon(LineIcons.mouse),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (set) => setState(() => _type = set.first),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: _type == OcdType.obsession
                    ? 'Obsessive Thought'
                    : 'Compulsive Urge',
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
                Text(
                  'Distress Level',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const Spacer(),
                Text(
                  '${_distressLevel.round()}/10',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                    fontSize: 18,
                  ),
                ),
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
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
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
                      actionTaken: _type == OcdType.compulsion
                          ? _actionController.text
                          : null,
                      createdAt: DateTime.now(),
                    );
                    await ref.read(ocdProvider.notifier).addEntry(entry);
                    if (mounted) {
                      showAppSnackBar(
                        context,
                        'Event saved',
                        type: ToastType.success,
                      );
                      Navigator.pop(context);
                    }
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
