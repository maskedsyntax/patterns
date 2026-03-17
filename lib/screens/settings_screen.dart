import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data exported successfully'), behavior: SnackBarBehavior.floating),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), behavior: SnackBarBehavior.floating),
        );
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
        ref.invalidate(journalProvider);
        ref.invalidate(ocdProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data imported successfully'), behavior: SnackBarBehavior.floating),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e'), behavior: SnackBarBehavior.floating),
        );
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
      body: Center(
        child: Container(
          maxWidth: 800,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
            children: [
              Text('Appearance', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 24),
              _SettingsItem(
                title: 'Theme Mode',
                subtitle: 'Choose your preferred visual style',
                icon: LineIcons.palette,
                trailing: DropdownButtonHideUnderline(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: DropdownButton<ThemeMode>(
                      value: themeMode,
                      style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w600),
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
                ),
              ),
              const SizedBox(height: 48),
              Text('Data Management', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 24),
              _SettingsItem(
                title: 'Export Data',
                subtitle: 'Save your records to a local JSON file',
                icon: LineIcons.download,
                onTap: () => _exportData(context),
                trailing: const Icon(LineIcons.angleRight, size: 18),
              ),
              _SettingsItem(
                title: 'Import Data',
                subtitle: 'Restore entries from a JSON file (overwrites existing)',
                icon: LineIcons.upload,
                onTap: () => _importData(context, ref),
                trailing: const Icon(LineIcons.angleRight, size: 18),
                isDestructive: true,
              ),
              const SizedBox(height: 64),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Patterns v1.0.0',
                      style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.2), fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Clarity for the mind through structured reflection.',
                      style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.2), fontSize: 11, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SettingsItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isDestructive ? Colors.redAccent : theme.colorScheme.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: isDestructive ? Colors.redAccent : theme.colorScheme.primary),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle, 
                      style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 13)
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
