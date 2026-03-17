import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/db_helper.dart';
import '../providers/providers.dart';
import '../main.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _exportData(BuildContext context) async {
    try {
      final jsonStr = await DbHelper.instance.exportAll();
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Data',
        fileName: 'patterns_export.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (path != null) {
        final file = File(path);
        await file.writeAsString(jsonStr);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data exported successfully')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Import Data',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonStr = await file.readAsString();
        await DbHelper.instance.importAll(jsonStr);
        // Refresh providers
        ref.invalidate(journalProvider);
        ref.invalidate(ocdProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data imported successfully')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Appearance', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Theme Mode'),
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              onChanged: (mode) {
                if (mode != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(mode);
                }
              },
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
            ),
          ),
          const Divider(height: 48),
          Text('Data Management', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Export Data'),
            subtitle: const Text('Save your journal and OCD entries to a JSON file.'),
            trailing: ElevatedButton(
              onPressed: () => _exportData(context),
              child: const Text('Export'),
            ),
          ),
          ListTile(
            title: const Text('Import Data'),
            subtitle: const Text('Restore your data from a JSON file. This will overwrite existing data.'),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.1),
                foregroundColor: Colors.redAccent,
              ),
              onPressed: () => _importData(context, ref),
              child: const Text('Import'),
            ),
          ),
        ],
      ),
    );
  }
}
