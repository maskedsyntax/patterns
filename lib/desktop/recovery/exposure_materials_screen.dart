import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide MaterialType;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/desktop_chrome.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../services/material_file_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animations.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/recovery_ui.dart';
import '../../widgets/section_intro.dart';

IconData _typeIcon(MaterialType type) {
  switch (type) {
    case MaterialType.script:
      return Icons.notes_rounded;
    case MaterialType.loopTape:
      return Icons.graphic_eq_rounded;
    case MaterialType.image:
      return Icons.image_rounded;
    case MaterialType.link:
      return Icons.link_rounded;
  }
}

String _typeLabel(MaterialType type) {
  switch (type) {
    case MaterialType.script:
      return 'Script';
    case MaterialType.loopTape:
      return 'Loop tape';
    case MaterialType.image:
      return 'Image';
    case MaterialType.link:
      return 'Link';
  }
}

class ExposureMaterialsScreen extends ConsumerWidget {
  /// When set, the library is filtered to this step and new items attach to it.
  final int? linkedStepId;
  final int? linkedHierarchyId;

  const ExposureMaterialsScreen({
    super.key,
    this.linkedStepId,
    this.linkedHierarchyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final materialsAsync = ref.watch(exposureMaterialProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: staggered([
            Row(
              children: [
                const SizedBox.shrink(),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Exposure Materials',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _chooseType(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('New'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Keep your scripts, loop tapes, images, and links here so they are '
              'one tap away during an exposure.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 18),
            const SectionIntro(id: 'exposureMaterials'),
            materialsAsync.when(
              data: (items) {
                final list = linkedStepId == null
                    ? items
                    : items
                          .where((m) => m.linkedStepId == linkedStepId)
                          .toList();
                if (list.isEmpty) {
                  return _EmptyState(onAdd: () => _chooseType(context));
                }
                return Column(
                  children: [
                    for (final m in list) ...[
                      MaterialCard(
                        material: m,
                        onDelete: () => _confirmDelete(context, ref, m),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => Text(
                'Your materials are unavailable right now.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _chooseType(BuildContext context) {
    showDesktopDialog<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.all(14),
          padding: const EdgeInsets.all(12),
          decoration: recoverySoftDecoration(
            Theme.of(sheetContext),
            radius: 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final type in MaterialType.values)
                ListTile(
                  leading: Icon(
                    _typeIcon(type),
                    color: Theme.of(sheetContext).colorScheme.primary,
                  ),
                  title: Text(_typeLabel(type)),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        
                        builder: (_) => ExposureMaterialEditScreen(
                          type: type,
                          linkedStepId: linkedStepId,
                          linkedHierarchyId: linkedHierarchyId,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ExposureMaterial material,
  ) {
    showDesktopDialog<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.all(14),
          padding: const EdgeInsets.all(20),
          decoration: recoverySoftDecoration(
            Theme.of(sheetContext),
            radius: 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delete this material?',
                style: Theme.of(
                  sheetContext,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                'The file (if any) is removed from your device too.',
                style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(sheetContext);
                        await ref
                            .read(exposureMaterialProvider.notifier)
                            .delete(material);
                      },
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: recoverySoftDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.folder_special_rounded,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            'Gather your materials',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Save a script to read, record a loop tape, add an image, or keep a '
            'link, ready for your next exposure.',
            style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAdd,
              child: const Text('Add a material'),
            ),
          ),
        ],
      ),
    );
  }
}

class MaterialCard extends StatelessWidget {
  final ExposureMaterial material;
  final VoidCallback onDelete;

  const MaterialCard({
    super.key,
    required this.material,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: recoverySoftDecoration(theme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _typeIcon(material.type),
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  material.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onDelete,
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _body(context),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    switch (material.type) {
      case MaterialType.script:
        return _ActionButton(
          icon: Icons.menu_book_rounded,
          label: 'Read script',
          onTap: () => _showScript(context),
        );
      case MaterialType.link:
        return _ActionButton(
          icon: Icons.open_in_new_rounded,
          label: material.url ?? 'Open link',
          onTap: () => _openLink(context),
        );
      case MaterialType.image:
        return _ActionButton(
          icon: Icons.visibility_rounded,
          label: 'View image',
          onTap: () => _showImage(context),
        );
      case MaterialType.loopTape:
        return LoopTapePlayer(fileName: material.fileName);
    }
  }

  void _showScript(BuildContext context) {
    showDesktopDialog<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.all(14),
          padding: const EdgeInsets.all(20),
          decoration: recoverySoftDecoration(
            Theme.of(sheetContext),
            radius: 28,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  material.title,
                  style: Theme.of(
                    sheetContext,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Text(
                  material.text ?? '',
                  style: Theme.of(
                    sheetContext,
                  ).textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openLink(BuildContext context) async {
    final url = material.url;
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        showAppSnackBar(
          context,
          'Could not open that link.',
          type: ToastType.error,
        );
      }
    }
  }

  Future<void> _showImage(BuildContext context) async {
    final fileName = material.fileName;
    if (fileName == null) return;
    final file = await MaterialFileStore.resolve(fileName);
    if (!context.mounted) return;
    if (!file.existsSync()) {
      showAppSnackBar(
        context,
        'This image is no longer available.',
        type: ToastType.info,
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black),
          body: Center(child: InteractiveViewer(child: Image.file(file))),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PressScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Play/stop control that loops a stored audio file. Pass either a stored
/// [fileName] (resolved via [MaterialFileStore]) or a direct [absolutePath]
/// (used for the just-recorded preview).
class LoopTapePlayer extends StatefulWidget {
  final String? fileName;
  final String? absolutePath;

  const LoopTapePlayer({super.key, this.fileName, this.absolutePath});

  @override
  State<LoopTapePlayer> createState() => _LoopTapePlayerState();
}

class _LoopTapePlayerState extends State<LoopTapePlayer> {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;
  String? _path;

  @override
  void initState() {
    super.initState();
    _player.setReleaseMode(ReleaseMode.loop);
    _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _playing = state == PlayerState.playing);
    });
    _resolve();
  }

  Future<void> _resolve() async {
    if (widget.absolutePath != null) {
      _path = widget.absolutePath;
      return;
    }
    final name = widget.fileName;
    if (name != null) {
      final file = await MaterialFileStore.resolve(name);
      if (mounted) setState(() => _path = file.existsSync() ? file.path : null);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    final path = _path;
    if (path == null) {
      showAppSnackBar(
        context,
        'This recording is no longer available.',
        type: ToastType.info,
      );
      return;
    }
    if (_playing) {
      await _player.stop();
    } else {
      await _player.play(DeviceFileSource(path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PressScale(
      onTap: _toggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              _playing ? Icons.stop_rounded : Icons.play_arrow_rounded,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Text(
              _playing ? 'Stop' : 'Play loop',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add / edit
// ---------------------------------------------------------------------------

class ExposureMaterialEditScreen extends ConsumerStatefulWidget {
  final MaterialType type;
  final int? linkedStepId;
  final int? linkedHierarchyId;

  const ExposureMaterialEditScreen({
    super.key,
    required this.type,
    this.linkedStepId,
    this.linkedHierarchyId,
  });

  @override
  ConsumerState<ExposureMaterialEditScreen> createState() =>
      _ExposureMaterialEditScreenState();
}

class _ExposureMaterialEditScreenState
    extends ConsumerState<ExposureMaterialEditScreen> {
  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  final _urlController = TextEditingController();

  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  int _elapsed = 0;
  Timer? _timer;
  String? _recordedPath;
  String? _pickedImagePath;
  bool _saving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    _urlController.dispose();
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    final path = result?.files.single.path;
    if (path != null) setState(() => _pickedImagePath = path);
  }

  Future<void> _startRecording() async {
    final allowed = await _recorder.hasPermission();
    if (!allowed) {
      if (mounted) {
        showAppSnackBar(
          context,
          'Microphone access is needed to record a loop tape.',
          type: ToastType.info,
        );
      }
      return;
    }
    final tmp = await getTemporaryDirectory();
    final path = p.join(
      tmp.path,
      'rec_${DateTime.now().microsecondsSinceEpoch}.m4a',
    );
    await _recorder.start(const RecordConfig(), path: path);
    setState(() {
      _isRecording = true;
      _elapsed = 0;
      _recordedPath = null;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed++);
    });
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stop();
    _timer?.cancel();
    setState(() {
      _isRecording = false;
      _recordedPath = path;
    });
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      showAppSnackBar(
        context,
        'Give this material a name to save.',
        type: ToastType.info,
      );
      return;
    }

    String? text;
    String? url;
    String? fileName;

    switch (widget.type) {
      case MaterialType.script:
        text = _textController.text.trim();
        if (text.isEmpty) {
          showAppSnackBar(
            context,
            'Add the script text to save.',
            type: ToastType.info,
          );
          return;
        }
      case MaterialType.link:
        url = _urlController.text.trim();
        if (url.isEmpty) {
          showAppSnackBar(
            context,
            'Paste a link to save.',
            type: ToastType.info,
          );
          return;
        }
      case MaterialType.image:
        if (_pickedImagePath == null) {
          showAppSnackBar(
            context,
            'Pick an image to save.',
            type: ToastType.info,
          );
          return;
        }
      case MaterialType.loopTape:
        if (_recordedPath == null) {
          showAppSnackBar(
            context,
            'Record a loop tape to save.',
            type: ToastType.info,
          );
          return;
        }
    }

    setState(() => _saving = true);
    if (widget.type == MaterialType.image) {
      final ext = p.extension(_pickedImagePath!).replaceFirst('.', '');
      fileName = await MaterialFileStore.save(
        _pickedImagePath!,
        ext.isEmpty ? 'jpg' : ext,
      );
    } else if (widget.type == MaterialType.loopTape) {
      fileName = await MaterialFileStore.save(_recordedPath!, 'm4a');
    }

    await ref
        .read(exposureMaterialProvider.notifier)
        .add(
          ExposureMaterial(
            type: widget.type,
            title: title,
            text: text,
            url: url,
            fileName: fileName,
            linkedStepId: widget.linkedStepId,
            linkedHierarchyId: widget.linkedHierarchyId,
            createdAt: DateTime.now(),
          ),
        );
    if (!mounted) return;
    Navigator.of(context).pop();
    showAppSnackBar(context, 'Material saved.', type: ToastType.success);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
          children: staggered([
            Row(
              children: [
                const SizedBox.shrink(),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'New ${_typeLabel(widget.type).toLowerCase()}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            LabeledField(
              label: 'Title',
              hint: 'A short name you will recognise',
              controller: _titleController,
            ),
            const SizedBox(height: 16),
            ..._typeFields(theme),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save material'),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  List<Widget> _typeFields(ThemeData theme) {
    switch (widget.type) {
      case MaterialType.script:
        return [
          LabeledField(
            label: 'Script',
            hint: 'The text you want to read during the exposure',
            controller: _textController,
            minLines: 5,
          ),
        ];
      case MaterialType.link:
        return [
          LabeledField(
            label: 'Link',
            hint: 'https://…',
            controller: _urlController,
          ),
        ];
      case MaterialType.image:
        return [
          if (_pickedImagePath != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(_pickedImagePath!),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                cacheWidth: 1000,
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image_rounded, size: 18),
              label: Text(
                _pickedImagePath == null ? 'Pick image' : 'Change image',
              ),
            ),
          ),
        ];
      case MaterialType.loopTape:
        return [_recorderPanel(theme)];
    }
  }

  Widget _recorderPanel(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: recoverySoftDecoration(theme, radius: 18),
      child: Column(
        children: [
          if (_isRecording) ...[
            Text(
              'Recording… ${_elapsed}s',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppTheme.mutedRed,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _stopRecording,
                icon: const Icon(Icons.stop_rounded, size: 18),
                label: const Text('Stop'),
              ),
            ),
          ] else if (_recordedPath != null) ...[
            LoopTapePlayer(absolutePath: _recordedPath),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _startRecording,
                icon: const Icon(Icons.fiber_manual_record_rounded, size: 16),
                label: const Text('Re-record'),
              ),
            ),
          ] else ...[
            Text(
              'Record a short clip to replay on a loop.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _startRecording,
                icon: const Icon(Icons.fiber_manual_record_rounded, size: 16),
                label: const Text('Record'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
