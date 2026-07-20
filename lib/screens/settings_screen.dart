import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_preferences.dart';
import '../database/db_helper.dart';
import '../desktop/biometric_auth.dart';
import '../providers/providers.dart';
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
import '../theme/app_theme.dart';

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
      if (path.isNotEmpty && !File(path).existsSync()) {
        await File(path).writeAsBytes(bytes);
      } else if (path.isNotEmpty) {
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
        dialogTitle: 'Select Backup File',
        type: FileType.custom,
        allowedExtensions: ['zip', 'json'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) throw Exception('No file data available');

      await DbHelper.instance.importBundle(bytes);
      ref.invalidate(journalProvider);
      ref.invalidate(ocdProvider);
      ref.invalidate(delaySessionProvider);
      ref.invalidate(erpExerciseSessionProvider);
      ref.invalidate(exposureStepProvider);
      ref.invalidate(responsePreventionProvider);
      ref.invalidate(urgeSurfProvider);

      if (context.mounted) {
        showAppSnackBar(context, 'Backup restored successfully', type: ToastType.success);
      }
    } catch (e) {
      debugPrint('Import Error: $e');
      if (context.mounted) {
        showAppSnackBar(
          context,
          'Restore failed. Make sure the file is a valid Patterns backup.',
          type: ToastType.error,
        );
      }
    }
  }

  Future<void> _setReminderEnabled(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    try {
      if (enabled) {
        final granted = await NotificationService.requestPermission();
        if (!granted) {
          if (context.mounted) {
            showAppSnackBar(
              context,
              'Notification permission denied. Please check your OS settings.',
              type: ToastType.error,
            );
          }
          return;
        }
        final current = ref.read(reminderProvider);
        await ref.read(reminderProvider.notifier).setEnabled(true);
        await NotificationService.scheduleDailyReminder(
          TimeOfDay(hour: current.hour, minute: current.minute),
        );
      } else {
        await ref.read(reminderProvider.notifier).setEnabled(false);
        await NotificationService.cancelReminder();
      }
    } catch (e) {
      debugPrint('Reminder toggle failed: $e');
    }
  }

  Future<void> _pickReminderTime(BuildContext context, WidgetRef ref) async {
    final current = ref.read(reminderProvider);
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
    );
    if (selected == null) return;

    try {
      await ref.read(reminderProvider.notifier).setTime(selected.hour, selected.minute);
      if (ref.read(reminderProvider).enabled) {
        await NotificationService.scheduleDailyReminder(selected);
      }
      if (context.mounted) {
        showAppSnackBar(context, 'Reminder time updated', type: ToastType.success);
      }
    } catch (e) {
      debugPrint('Reminder time update failed: $e');
    }
  }

  Future<void> _setAppLock(BuildContext context, WidgetRef ref, bool enabled) async {
    try {
      if (enabled) {
        final authenticator = ref.read(biometricAuthenticatorProvider);
        final available = await authenticator.isDeviceSupported();
        if (!available) {
          if (context.mounted) {
            showAppSnackBar(
              context,
              'App Lock is not available on this device or has not been configured.',
              type: ToastType.error,
            );
          }
          return;
        }
        final authenticated = await authenticator.authenticate(
          reason: 'Confirm identity to enable App Lock',
        );
        if (!authenticated) return;
      }
      await ref.read(appLockEnabledProvider.notifier).setEnabled(enabled);
    } catch (e) {
      debugPrint('App lock toggle failed: $e');
    }
  }

  Future<void> _confirmWipe(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wipe All Local Data?'),
        content: const Text(
          'This will permanently delete all your journal entries, exposures, '
          'tracker logs, and reset preferences. This action cannot be undone.',
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
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await DbHelper.instance.clearAll();
      await clearLocalPreferences();
      ref.invalidate(journalProvider);
      ref.invalidate(ocdProvider);
      ref.invalidate(delaySessionProvider);
      ref.invalidate(erpExerciseSessionProvider);
      ref.invalidate(exposureStepProvider);
      ref.invalidate(responsePreventionProvider);
      ref.invalidate(urgeSurfProvider);

      if (context.mounted) {
        showAppSnackBar(context, 'All local data has been wiped.', type: ToastType.success);
      }
    } catch (e) {
      debugPrint('Wipe failed: $e');
    }
  }

  void _showPrivacy(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy & Safety'),
        content: const Text(
          'Patterns is a local-first application. Your entries, logs, '
          'exposures, and settings are stored locally on your device\'s SQLite database. '
          'No analytical trackers are included, and no data is transmitted to remote servers.',
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
        (_SettingsCategory.pro, 'Patterns Desktop Pro', Icons.verified_user_rounded),
      (_SettingsCategory.support, 'Support', Icons.help_outline_rounded),
    ];
    if (!categories.any((c) => c.$1 == _category)) {
      _category = categories.first.$1;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border(
              bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
            ),
          ),
          child: AppBar(
            toolbarHeight: 60,
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Settings',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            actions: const [WindowControls()],
          ),
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Sidebar Inside Settings
          SizedBox(
            width: 240,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  right: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
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

          // Detail Pane Area
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(40, 32, 48, 48),
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Settings Page Title
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontFamily: AppTheme.displayFamily,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage your data and preferences.',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.55),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Switched category widgets
                      switch (_category) {
                        _SettingsCategory.data => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SettingsGroup(
                              title: 'Data Management',
                              children: [
                                _SettingsListRow(
                                  title: 'Export Data',
                                  subtitle: 'Save a zip backup including exposures and journals',
                                  icon: Icons.download_rounded,
                                  onTap: () => _exportData(context),
                                ),
                                Divider(height: 1, color: Colors.white.withOpacity(0.04), indent: 20, endIndent: 20),
                                if (isPdfExportSupported) ...[
                                  _SettingsListRow(
                                    title: 'Export Report (PDF)',
                                    subtitle: 'Save journal, OCD log, and insights for a date range',
                                    icon: Icons.description_rounded,
                                    onTap: () => ExportReportSheet.show(context),
                                  ),
                                  Divider(height: 1, color: Colors.white.withOpacity(0.04), indent: 20, endIndent: 20),
                                ],
                                _SettingsListRow(
                                  title: 'Import Data',
                                  subtitle: 'Restore from a zip or JSON backup',
                                  icon: Icons.upload_rounded,
                                  onTap: () => _importData(context, ref),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20, left: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    size: 15,
                                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'All data stays on your device unless you choose to export.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        _SettingsCategory.reminders => _SettingsGroup(
                          title: 'Reminders',
                          children: [
                            _SettingsSwitchRow(
                              title: 'Daily reminder',
                              subtitle: reminder.enabled
                                  ? 'Scheduled for ${TimeOfDay(hour: reminder.hour, minute: reminder.minute).format(context)}'
                                  : 'A gentle daily check-in nudge',
                              icon: LineIcons.bell,
                              value: reminder.enabled,
                              onChanged: (v) => _setReminderEnabled(context, ref, v),
                            ),
                            if (reminder.enabled) ...[
                              Divider(height: 1, color: Colors.white.withOpacity(0.04), indent: 20, endIndent: 20),
                              _SettingsListRow(
                                title: 'Reminder time',
                                subtitle: TimeOfDay(
                                  hour: reminder.hour,
                                  minute: reminder.minute,
                                ).format(context),
                                icon: LineIcons.clock,
                                onTap: () => _pickReminderTime(context, ref),
                              ),
                            ],
                          ],
                        ),
                        _SettingsCategory.privacy => _SettingsGroup(
                          title: 'Privacy & Security',
                          children: [
                            _SettingsListRow(
                              title: 'Privacy & safety',
                              subtitle: 'How your local data is handled',
                              icon: LineIcons.userShield,
                              onTap: () => _showPrivacy(context),
                            ),
                            Divider(height: 1, color: Colors.white.withOpacity(0.04), indent: 20, endIndent: 20),
                            _SettingsSwitchRow(
                              title: 'App lock',
                              subtitle: 'Require device unlock when Patterns reopens',
                              icon: LineIcons.lock,
                              value: appLockEnabled,
                              onChanged: (v) => _setAppLock(context, ref, v),
                            ),
                            Divider(height: 1, color: Colors.white.withOpacity(0.04), indent: 20, endIndent: 20),
                            _SettingsListRow(
                              title: 'Wipe all data',
                              subtitle: 'Delete local entries and reset preferences',
                              icon: LineIcons.trash,
                              isDestructive: true,
                              onTap: () => _confirmWipe(context, ref),
                            ),
                          ],
                        ),
                        _SettingsCategory.pro => _SettingsGroup(
                          title: 'Patterns Desktop Pro',
                          children: [
                            if (isPro)
                              _SettingsListRow(
                                title: 'Patterns Desktop Pro is active',
                                subtitle: 'Every desktop recovery tool is unlocked. Thank you',
                                icon: LineIcons.crown,
                                onTap: () => showAppSnackBar(
                                  context,
                                  'Patterns Desktop Pro is active on this device.',
                                ),
                              )
                            else
                              _SettingsListRow(
                                title: 'Unlock Patterns Desktop Pro',
                                subtitle: 'One-time unlock for all desktop recovery tools',
                                icon: LineIcons.unlock,
                                onTap: () => PaywallSheet.show(context),
                              ),
                            Divider(height: 1, color: Colors.white.withOpacity(0.04), indent: 20, endIndent: 20),
                            _SettingsListRow(
                              title: 'Restore purchases',
                              subtitle: 'Re-apply a previous Patterns Desktop Pro unlock',
                              icon: LineIcons.syncIcon,
                              onTap: () {
                                ProService.restore();
                                showAppSnackBar(context, 'Restoring purchases…');
                              },
                            ),
                          ],
                        ),
                        _SettingsCategory.support => _SettingsGroup(
                          title: 'Support & Sponsorship',
                          children: [
                            _SettingsListRow(
                              title: 'Rate Patterns',
                              subtitle: 'Tell the store what you think',
                              icon: LineIcons.star,
                              onTap: () => ReviewPromptService.requestReviewManually(context),
                            ),
                            Divider(height: 1, color: Colors.white.withOpacity(0.04), indent: 20, endIndent: 20),
                            if (TipJarService.isPlatformSupported)
                              _SettingsListRow(
                                title: 'Support Patterns',
                                subtitle: 'Leave a small tip to keep development going',
                                icon: LineIcons.heart,
                                onTap: () => TipJarSheet.show(context),
                              )
                            else
                              _SettingsListRow(
                                title: 'Sponsor on GitHub',
                                subtitle: 'Support development through GitHub Sponsors',
                                icon: LineIcons.heart,
                                onTap: () => launchUrl(
                                  Uri.parse(_githubSponsorsUrl),
                                  mode: LaunchMode.externalApplication,
                                ),
                              ),
                          ],
                        ),
                      },
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Selected category item in the Settings sidebar
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
      padding: const EdgeInsets.only(bottom: 6),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: widget.selected
                  ? theme.colorScheme.primary.withOpacity(0.08)
                  : _hovered
                      ? theme.colorScheme.onSurface.withOpacity(0.04)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: widget.selected
                  ? Border.all(color: theme.colorScheme.primary.withOpacity(0.3), width: 1.2)
                  : Border.all(color: Colors.transparent, width: 1.2),
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 20,
                  color: widget.selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    maxLines: 2,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: widget.selected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
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

/// Grouped card container matching the high-fidelity mockups
class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.55),
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

/// Grouped settings row (interactive list tile)
class _SettingsListRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsListRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = isDestructive ? Colors.redAccent : theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.dividerColor),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LineIcons.angleRight,
              size: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grouped settings row (switch toggle)
class _SettingsSwitchRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: theme.dividerColor),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
