import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_preferences.dart';
import '../database/db_helper.dart';
import '../desktop/biometric_auth.dart';
import '../providers/providers.dart';
import '../services/material_file_store.dart';
import '../services/notification_service.dart';
import '../services/pro_service.dart';
import '../services/review_prompt.dart';
import '../services/tip_jar.dart';
import '../widgets/app_snack_bar.dart';
import '../widgets/export_report_sheet.dart';
import '../widgets/paywall_sheet.dart';
import '../widgets/platform.dart';
import '../widgets/tip_jar_sheet.dart';
import '../widgets/window_controls.dart';

const String _githubSponsorsUrl = 'https://github.com/sponsors/maskedsyntax';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

enum _SettingsCategory { data, reminders, privacy, pro, support }

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  _SettingsCategory _category = _SettingsCategory.data;

  Future<void> _exportData(BuildContext context) async {
    try {
      final bytes = await DbHelper.instance.exportBundle();
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Patterns Data',
        fileName: 'patterns_backup.zip',
        type: FileType.custom,
        allowedExtensions: ['zip'],
        bytes: bytes,
      );
      if (path == null) return;
      // On some platforms, saveFile writes bytes; on others we write the path.
      if (path.isNotEmpty && !File(path).existsSync()) {
        await File(path).writeAsBytes(bytes);
      } else if (path.isNotEmpty) {
        // If the picker already wrote, or path exists empty, ensure content.
        final file = File(path);
        if (await file.length() == 0) {
          await file.writeAsBytes(bytes);
        }
      }
      if (context.mounted) {
        showAppSnackBar(context, 'Data exported', type: ToastType.success);
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
        type: FileType.custom,
        allowedExtensions: ['zip', 'json'],
        withData: true,
      );
      if (result == null || result.files.single.path == null) return;

      final file = result.files.single;
      final Uint8List bytes =
          file.bytes ?? await File(file.path!).readAsBytes();
      final path = file.path!.toLowerCase();
      if (path.endsWith('.zip')) {
        await DbHelper.instance.importBundle(bytes);
      } else {
        await DbHelper.instance.importAll(utf8.decode(bytes));
      }
      _invalidateAll(ref);
      if (context.mounted) {
        showAppSnackBar(context, 'Data imported', type: ToastType.success);
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

  void _invalidateAll(WidgetRef ref) {
    ref
      ..invalidate(journalProvider)
      ..invalidate(ocdProvider)
      ..invalidate(delaySessionProvider)
      ..invalidate(erpExercisePlanProvider)
      ..invalidate(erpExerciseSessionProvider)
      ..invalidate(exposureHierarchyProvider)
      ..invalidate(exposureStepProvider)
      ..invalidate(responsePreventionProvider)
      ..invalidate(urgeSurfProvider)
      ..invalidate(programEnrollmentProvider)
      ..invalidate(programTaskProgressProvider)
      ..invalidate(behavioralExperimentProvider)
      ..invalidate(exposureReflectionProvider)
      ..invalidate(actionPlanProvider)
      ..invalidate(implementationIntentionProvider)
      ..invalidate(uncertaintyLogProvider)
      ..invalidate(exposureMaterialProvider)
      ..invalidate(ybocsAssessmentProvider);
  }

  Future<void> _setReminderEnabled(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    if (!enabled) {
      await NotificationService.cancelReminder();
      await ref.read(reminderProvider.notifier).setEnabled(false);
      if (context.mounted) {
        showAppSnackBar(context, 'Daily reminder turned off');
      }
      return;
    }
    final granted = await NotificationService.requestPermission();
    if (!granted) {
      if (context.mounted) {
        showAppSnackBar(
          context,
          'Allow notifications in system settings to get reminders.',
          type: ToastType.error,
        );
      }
      return;
    }
    final settings = ref.read(reminderProvider);
    await NotificationService.scheduleDailyReminder(
      TimeOfDay(hour: settings.hour, minute: settings.minute),
    );
    await ref.read(reminderProvider.notifier).setEnabled(true);
    if (context.mounted) {
      showAppSnackBar(context, 'Daily reminder is on', type: ToastType.success);
    }
  }

  Future<void> _pickReminderTime(BuildContext context, WidgetRef ref) async {
    final settings = ref.read(reminderProvider);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: settings.hour, minute: settings.minute),
    );
    if (picked == null) return;
    await ref.read(reminderProvider.notifier).setTime(picked.hour, picked.minute);
    if (ref.read(reminderProvider).enabled) {
      await NotificationService.scheduleDailyReminder(picked);
    }
  }

  Future<void> _setAppLock(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    final auth = ref.read(biometricAuthenticatorProvider);
    if (enabled) {
      final supported = await auth.isDeviceSupported();
      if (!supported) {
        if (context.mounted) {
          showAppSnackBar(
            context,
            'This device does not support app lock.',
            type: ToastType.error,
          );
        }
        return;
      }
      final ok = await auth.authenticate(
        reason: 'Confirm to enable app lock for Patterns',
      );
      if (!ok) return;
      await ref.read(appLockEnabledProvider.notifier).setEnabled(true);
      if (context.mounted) {
        showAppSnackBar(context, 'App lock enabled', type: ToastType.success);
      }
    } else {
      final ok = await auth.authenticate(
        reason: 'Confirm to disable app lock for Patterns',
      );
      if (!ok) return;
      await ref.read(appLockEnabledProvider.notifier).setEnabled(false);
      if (context.mounted) {
        showAppSnackBar(context, 'App lock disabled');
      }
    }
  }

  Future<void> _confirmWipe(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wipe all data?'),
        content: const Text(
          'This deletes local entries and resets Preferences on this device. This cannot be undone.',
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
            child: const Text('Wipe'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await DbHelper.instance.clearAll();
      await MaterialFileStore.deleteAll();
      await clearLocalPreferences();
      await initAppPreferences();
      _invalidateAll(ref);
      if (context.mounted) {
        showAppSnackBar(context, 'Local data wiped', type: ToastType.success);
      }
    } catch (e) {
      if (context.mounted) {
        showAppSnackBar(context, 'Wipe failed', type: ToastType.error);
      }
    }
  }

  void _showPrivacy(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy & safety'),
        content: const SingleChildScrollView(
          child: Text(
            'Patterns stores your journal, OCD log, and recovery practice data locally on this device.\n\n'
            'Nothing is uploaded to our servers. Backups you export stay under your control.\n\n'
            'Patterns is a self-help companion, not a diagnosis or a replacement for professional care.',
            style: TextStyle(height: 1.45),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => launchUrl(
              Uri.parse('https://maskedsyntax.com/patterns/privacy'),
              mode: LaunchMode.externalApplication,
            ),
            child: const Text('View full Privacy Policy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reminder = ref.watch(reminderProvider);
    final appLockEnabled = ref.watch(appLockEnabledProvider);
    final isPro = ref.watch(proProvider);

    final categories = <(_SettingsCategory, String, IconData)>[
      (_SettingsCategory.data, 'Data', LineIcons.database),
      if (NotificationService.isSupported)
        (_SettingsCategory.reminders, 'Reminders', LineIcons.bell),
      (_SettingsCategory.privacy, 'Privacy', LineIcons.userShield),
      if (ProService.isPlatformSupported)
        (_SettingsCategory.pro, 'Patterns Pro', LineIcons.crown),
      (_SettingsCategory.support, 'Support', LineIcons.heart),
    ];
    if (!categories.any((c) => c.$1 == _category)) {
      _category = categories.first.$1;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
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
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 220,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  right: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                children: [
                  for (final (cat, label, icon) in categories)
                    _CategoryTile(
                      label: label,
                      icon: icon,
                      selected: _category == cat,
                      onTap: () => setState(() => _category = cat),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(36, 28, 48, 48),
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: switch (_category) {
                    _SettingsCategory.data => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle('Data Management', theme),
                        const SizedBox(height: 16),
                        _SettingsItem(
                          title: 'Export Data',
                          subtitle:
                              'Save a zip backup including exposure materials',
                          icon: LineIcons.download,
                          onTap: () => _exportData(context),
                          theme: theme,
                        ),
                        if (isPdfExportSupported)
                          _SettingsItem(
                            title: 'Export report (PDF)',
                            subtitle:
                                'Save journal, OCD log, and insights for a date range',
                            icon: LineIcons.fileExport,
                            onTap: () => ExportReportSheet.show(context),
                            theme: theme,
                          ),
                        _SettingsItem(
                          title: 'Import Data',
                          subtitle: 'Restore from a zip or JSON backup',
                          icon: LineIcons.upload,
                          onTap: () => _importData(context, ref),
                          isDestructive: true,
                          theme: theme,
                        ),
                      ],
                    ),
                    _SettingsCategory.reminders => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle('Reminders', theme),
                        const SizedBox(height: 16),
                        _SettingsSwitchItem(
                          title: 'Daily reminder',
                          subtitle: reminder.enabled
                              ? 'Scheduled for ${TimeOfDay(hour: reminder.hour, minute: reminder.minute).format(context)}'
                              : 'A gentle daily check-in nudge',
                          icon: LineIcons.bell,
                          value: reminder.enabled,
                          onChanged: (v) =>
                              _setReminderEnabled(context, ref, v),
                          theme: theme,
                        ),
                        if (reminder.enabled)
                          _SettingsItem(
                            title: 'Reminder time',
                            subtitle: TimeOfDay(
                              hour: reminder.hour,
                              minute: reminder.minute,
                            ).format(context),
                            icon: LineIcons.clock,
                            onTap: () => _pickReminderTime(context, ref),
                            theme: theme,
                          ),
                      ],
                    ),
                    _SettingsCategory.privacy => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle('Privacy', theme),
                        const SizedBox(height: 16),
                        _SettingsItem(
                          title: 'Privacy & safety',
                          subtitle: 'How your local data is handled',
                          icon: LineIcons.userShield,
                          onTap: () => _showPrivacy(context),
                          theme: theme,
                        ),
                        _SettingsSwitchItem(
                          title: 'App lock',
                          subtitle:
                              'Require device unlock when Patterns reopens',
                          icon: LineIcons.lock,
                          value: appLockEnabled,
                          onChanged: (v) => _setAppLock(context, ref, v),
                          theme: theme,
                        ),
                        _SettingsItem(
                          title: 'Wipe all data',
                          subtitle:
                              'Delete local entries and reset preferences',
                          icon: LineIcons.trash,
                          onTap: () => _confirmWipe(context, ref),
                          isDestructive: true,
                          theme: theme,
                        ),
                      ],
                    ),
                    _SettingsCategory.pro => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle('Patterns Pro', theme),
                        const SizedBox(height: 16),
                        if (isPro)
                          _SettingsItem(
                            title: 'Patterns Pro is active',
                            subtitle:
                                'Every recovery tool is unlocked. Thank you',
                            icon: LineIcons.crown,
                            onTap: () => showAppSnackBar(
                              context,
                              'Patterns Pro is active on this device.',
                            ),
                            theme: theme,
                          )
                        else
                          _SettingsItem(
                            title: 'Unlock Patterns Pro',
                            subtitle:
                                'One-time unlock for all recovery tools',
                            icon: LineIcons.crown,
                            onTap: () => PaywallSheet.show(context),
                            theme: theme,
                          ),
                        _SettingsItem(
                          title: 'Restore purchases',
                          subtitle: 'Re-apply a previous Patterns Pro unlock',
                          icon: LineIcons.syncIcon,
                          onTap: () {
                            ProService.restore();
                            showAppSnackBar(context, 'Restoring purchases…');
                          },
                          theme: theme,
                        ),
                      ],
                    ),
                    _SettingsCategory.support => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle('Support', theme),
                        const SizedBox(height: 16),
                        _SettingsItem(
                          title: 'Rate Patterns',
                          subtitle: 'Tell the store what you think',
                          icon: LineIcons.star,
                          onTap: () => ReviewPromptService
                              .requestReviewManually(context),
                          theme: theme,
                        ),
                        if (TipJarService.isPlatformSupported)
                          _SettingsItem(
                            title: 'Support Patterns',
                            subtitle:
                                'Leave a small tip to keep development going',
                            icon: LineIcons.heart,
                            onTap: () => TipJarSheet.show(context),
                            theme: theme,
                          )
                        else
                          _SettingsItem(
                            title: 'Sponsor on GitHub',
                            subtitle:
                                'Support development through GitHub Sponsors',
                            icon: LineIcons.heart,
                            onTap: () => launchUrl(
                              Uri.parse(_githubSponsorsUrl),
                              mode: LaunchMode.externalApplication,
                            ),
                            theme: theme,
                          ),
                      ],
                    ),
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: widget.selected
                  ? theme.colorScheme.primary.withOpacity(0.14)
                  : _hovered
                  ? theme.colorScheme.onSurface.withOpacity(0.05)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 18,
                  color: widget.selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: theme.colorScheme.onSurface,
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

// Keep helper widgets below; old build method removed.

class _SectionTitle extends StatelessWidget {
  final String text;
  final ThemeData theme;
  const _SectionTitle(this.text, this.theme);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface,
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDestructive;
  final ThemeData theme;

  const _SettingsItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.theme,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
              Icon(
                LineIcons.angleRight,
                size: 18,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSwitchItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final ThemeData theme;

  const _SettingsSwitchItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: theme.colorScheme.primary),
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
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
