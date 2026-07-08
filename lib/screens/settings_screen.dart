import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../database/db_helper.dart';
import '../providers/providers.dart';
import '../services/tip_jar.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/tip_jar_sheet.dart';
import '../widgets/window_controls.dart';
import '../widgets/export_report_sheet.dart';
import '../widgets/platform.dart';

const String _githubSponsorsUrl = 'https://github.com/sponsors/maskedsyntax';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _exportData(BuildContext context) async {
    try {
      final jsonStr = await DbHelper.instance.exportAll();
      await Future.delayed(const Duration(milliseconds: 100));

      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Patterns Data',
        fileName: 'patterns_backup.json',
        type: FileType.any,
      );

      if (path != null) {
        String finalPath = path;
        if (!finalPath.toLowerCase().endsWith('.json')) {
          finalPath += '.json';
        }

        final file = File(finalPath);
        await file.writeAsString(jsonStr);

        if (context.mounted) {
          showAppSnackBar(context, 'Data exported', type: ToastType.success);
        }
      }
    } catch (e) {
      debugPrint('Export Error: $e');
      if (context.mounted) {
        showAppSnackBar(
          context,
          'Export failed. Please try again.',
          type: ToastType.error,
        );
      }
    }
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data?'),
        content: const Text(
          'This will overwrite all your current entries. This action cannot be undone.',
        ),
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
            child: const Text('Import & Overwrite'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select Patterns Backup',
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonStr = await file.readAsString();
        await DbHelper.instance.importAll(jsonStr);
        ref.invalidate(journalProvider);
        ref.invalidate(ocdProvider);
        if (context.mounted) {
          showAppSnackBar(context, 'Data imported', type: ToastType.success);
        }
      }
    } catch (e) {
      debugPrint('Import Error: $e');
      if (context.mounted) {
        showAppSnackBar(
          context,
          'Import failed. The backup may be invalid.',
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border(
              bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
            ),
          ),
          child: AppBar(
            toolbarHeight: 48,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Settings',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            actions: const [WindowControls()],
          ),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
            children: [
              Text(
                'Data Management',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              _SettingsItem(
                title: 'Export Data',
                subtitle: 'Save your records to a local JSON file',
                icon: LineIcons.download,
                onTap: () => _exportData(context),
                trailing: Icon(
                  LineIcons.angleRight,
                  size: 18,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
                theme: theme,
              ),
              if (isPdfExportSupported)
                _SettingsItem(
                  title: 'Export report (PDF)',
                  subtitle:
                      'Save journal, OCD log, and insights for a date range',
                  icon: LineIcons.fileExport,
                  onTap: () => ExportReportSheet.show(context),
                  trailing: Icon(
                    LineIcons.angleRight,
                    size: 18,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  theme: theme,
                ),
              _SettingsItem(
                title: 'Import Data',
                subtitle: 'Restore entries from a JSON file',
                icon: LineIcons.upload,
                onTap: () => _importData(context, ref),
                trailing: Icon(
                  LineIcons.angleRight,
                  size: 18,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
                isDestructive: true,
                theme: theme,
              ),
              const SizedBox(height: 48),
              Text(
                'Support',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              if (TipJarService.isPlatformSupported)
                _SettingsItem(
                  title: 'Support Patterns',
                  subtitle: 'Leave a small tip to keep development going',
                  icon: LineIcons.heart,
                  onTap: () => TipJarSheet.show(context),
                  trailing: Icon(
                    LineIcons.angleRight,
                    size: 18,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  theme: theme,
                )
              else
                _SettingsItem(
                  title: 'Sponsor on GitHub',
                  subtitle: 'Support development through GitHub Sponsors',
                  icon: LineIcons.heart,
                  onTap: () => launchUrl(
                    Uri.parse(_githubSponsorsUrl),
                    mode: LaunchMode.externalApplication,
                  ),
                  trailing: Icon(
                    LineIcons.alternateExternalLink,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  theme: theme,
                ),
              const SizedBox(height: 64),
              Center(
                child: Column(
                  children: [
                    Text(
                      'Patterns v1.0.0',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.2),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Clarity for the mind through structured reflection.',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.2),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
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
  final ThemeData theme;

  const _SettingsItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.theme,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
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
                  color:
                      (isDestructive
                              ? Colors.redAccent
                              : theme.colorScheme.primary)
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isDestructive
                      ? Colors.redAccent
                      : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
