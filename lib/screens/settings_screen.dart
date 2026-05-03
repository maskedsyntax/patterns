import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';

import '../database/db_helper.dart';
import '../main.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/animations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: staggered([
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LineIcons.angleLeft),
                ),
                Expanded(child: Text('Settings', style: _screenTitle(theme))),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              'Theme',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: _softDecoration(theme, radius: 22),
              child: Row(
                children: [
                  _ThemeChoice(
                    label: 'System',
                    selected: themeMode == ThemeMode.system,
                    onTap: () => ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(ThemeMode.system),
                  ),
                  _ThemeChoice(
                    label: 'Dark',
                    selected: themeMode == ThemeMode.dark,
                    onTap: () => ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(ThemeMode.dark),
                  ),
                  _ThemeChoice(
                    label: 'Light',
                    selected: themeMode == ThemeMode.light,
                    onTap: () => ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(ThemeMode.light),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Data',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            _SettingsItem(
              icon: LineIcons.download,
              title: 'Export data',
              subtitle: 'Save your records to a local JSON file',
              onTap: () => _exportData(context),
            ),
            const SizedBox(height: 10),
            _SettingsItem(
              icon: LineIcons.upload,
              title: 'Import data',
              subtitle: 'Restore entries from a JSON file',
              onTap: () => _confirmImport(context, ref),
            ),
            const SizedBox(height: 28),
            Text(
              'Privacy',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            _SettingsItem(
              icon: LineIcons.lock,
              title: 'Privacy & safety',
              subtitle: 'How your local data is handled',
              onTap: () => _showPrivacySheet(context),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final jsonStr = await DbHelper.instance.exportAll();
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Patterns Data',
        fileName: 'patterns_backup.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (path == null) return;
      final finalPath = path.toLowerCase().endsWith('.json')
          ? path
          : '$path.json';
      await File(finalPath).writeAsString(jsonStr);
      if (context.mounted) _showMessage(context, 'Data exported');
    } catch (error) {
      if (context.mounted) _showMessage(context, 'Export failed');
    }
  }

  void _confirmImport(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _BottomPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Import data?',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              'This will overwrite your current entries.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _importData(context, ref);
                },
                child: const Text('Import & overwrite'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select Patterns Backup',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.single.path == null) return;
      final jsonStr = await File(result.files.single.path!).readAsString();
      await DbHelper.instance.importAll(jsonStr);
      ref.invalidate(journalProvider);
      ref.invalidate(ocdProvider);
      if (context.mounted) _showMessage(context, 'Data imported');
    } on FormatException {
      if (context.mounted) _showMessage(context, 'Backup file is not valid');
    } catch (error) {
      if (context.mounted) _showMessage(context, 'Import failed');
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.charcoalInput,
      ),
    );
  }

  void _showPrivacySheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _BottomPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy & safety',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              'Patterns stores journal entries, OCD events, distress ratings, and reflections on this device. Manual export creates a JSON file wherever you choose to save it.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
            ),
            const SizedBox(height: 12),
            Text(
              'Patterns is for personal reflection and self-tracking. It does not diagnose, treat, or replace care from a qualified clinician.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeChoice extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? theme.colorScheme.onPrimary
                  : AppTheme.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PressScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: _softDecoration(theme, radius: 22),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(LineIcons.angleRight, color: AppTheme.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  final Widget child;

  const _BottomPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: child,
      ),
    );
  }
}

TextStyle _screenTitle(ThemeData theme) {
  return TextStyle(
    fontFamily: AppTheme.displayFamily,
    fontSize: 32,
    fontWeight: FontWeight.w500,
    height: 1.08,
    letterSpacing: -0.6,
    color: theme.colorScheme.onSurface,
  );
}

BoxDecoration _softDecoration(ThemeData theme, {required double radius}) {
  return BoxDecoration(
    color: theme.colorScheme.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: theme.dividerColor.withValues(alpha: 0.9)),
  );
}
