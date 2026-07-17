import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:local_auth/local_auth.dart'
    show LocalAuthException, LocalAuthExceptionCode;
import 'package:url_launcher/url_launcher.dart';

import '../../database/db_helper.dart';
import '../../providers/providers.dart';
import '../../services/material_file_store.dart';
import '../../services/notification_service.dart';
import '../../services/pro_service.dart';
import '../../services/pro_pairing_service.dart';
import '../../services/review_prompt.dart';
import '../../services/tip_jar.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animations.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/export_report_sheet.dart';
import '../../widgets/paywall_sheet.dart';
import '../../widgets/platform.dart';
import '../../widgets/tip_jar_sheet.dart';
import '../biometric_auth.dart';
import '../main_shell.dart' show tourRequestProvider;
import '../preferences.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appLockEnabled = ref.watch(appLockEnabledProvider);
    final reminder = ref.watch(reminderProvider);

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
              onTap: () => _confirmExport(context),
            ),
            if (isPdfExportSupported) ...[
              const SizedBox(height: 10),
              _SettingsItem(
                icon: LineIcons.fileExport,
                title: 'Export report (PDF)',
                subtitle:
                    'Save journal, OCD log, and insights for a date range',
                onTap: () => ExportReportSheet.show(context),
              ),
            ],
            const SizedBox(height: 10),
            _SettingsItem(
              icon: LineIcons.upload,
              title: 'Import data',
              subtitle: 'Restore entries from a JSON file',
              onTap: () => _confirmImport(context, ref),
            ),
            if (NotificationService.isSupported) ...[
              const SizedBox(height: 28),
              Text(
                'Reminders',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              _SettingsSwitchItem(
                icon: LineIcons.bell,
                title: 'Daily reminder',
                subtitle: reminder.enabled
                    ? 'A gentle nudge at '
                          '${TimeOfDay(hour: reminder.hour, minute: reminder.minute).format(context)}'
                    : 'A gentle nudge to check in each day',
                value: reminder.enabled,
                onChanged: (value) => _setReminderEnabled(context, ref, value),
              ),
              if (reminder.enabled) ...[
                const SizedBox(height: 10),
                _SettingsItem(
                  icon: LineIcons.clock,
                  title: 'Reminder time',
                  subtitle: TimeOfDay(
                    hour: reminder.hour,
                    minute: reminder.minute,
                  ).format(context),
                  onTap: () => _pickReminderTime(context, ref),
                ),
              ],
            ],
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
            const SizedBox(height: 10),
            _SettingsSwitchItem(
              icon: LineIcons.userLock,
              title: 'App lock',
              subtitle: 'Require device unlock when Patterns reopens',
              value: appLockEnabled,
              onChanged: (value) => _setAppLock(context, ref, value),
            ),
            const SizedBox(height: 10),
            _SettingsItem(
              icon: LineIcons.alternateTrash,
              title: 'Wipe all data',
              subtitle: 'Delete local entries and reset app preferences',
              onTap: () => _confirmWipeData(context, ref),
            ),
            if (ProService.isPlatformSupported) ...[
              const SizedBox(height: 28),
              Text(
                'Patterns Pro',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              if (ref.watch(proProvider)) ...[
                _SettingsItem(
                  icon: LineIcons.checkCircle,
                  title: 'Patterns Pro is active',
                  subtitle: 'Every recovery tool is unlocked. Thank you',
                  onTap: () => showAppSnackBar(
                    context,
                    'Patterns Pro is active on this device.',
                    type: ToastType.success,
                  ),
                ),
                const SizedBox(height: 10),
                _SettingsItem(
                  icon: LineIcons.desktop,
                  title: 'Link Desktop App',
                  subtitle: 'Display your offline code to link with desktop',
                  onTap: () => _showDesktopLinkingDialog(context),
                ),
              ]
              else
                _SettingsItem(
                  icon: LineIcons.unlock,
                  title: 'Unlock Patterns Pro',
                  subtitle: 'One-time unlock for all recovery tools',
                  onTap: () => PaywallSheet.show(context),
                ),
              const SizedBox(height: 10),
              _SettingsItem(
                icon: LineIcons.syncIcon,
                title: 'Restore purchases',
                subtitle: 'Re-apply a previous Patterns Pro unlock',
                onTap: () {
                  ProService.restore();
                  showAppSnackBar(
                    context,
                    'Restoring your purchases…',
                    type: ToastType.info,
                  );
                },
              ),
            ],
            const SizedBox(height: 28),
            Text(
              'Help',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            _SettingsItem(
              icon: LineIcons.compass,
              title: 'Replay the app tour',
              subtitle: 'Walk through what each tab does again',
              onTap: () {
                mobilePreferences?.setBool(tabTourSeenKey, false);
                final container = ProviderScope.containerOf(
                  context,
                  listen: false,
                );
                Navigator.of(context).pop();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  container.read(tourRequestProvider.notifier).request();
                });
              },
            ),
            const SizedBox(height: 10),
            _SettingsItem(
              icon: LineIcons.lightbulb,
              title: 'Show the welcome screens',
              subtitle: 'See the intro again next time you open Patterns',
              onTap: () {
                mobilePreferences?.setBool(hasStartedKey, false);
                showAppSnackBar(
                  context,
                  'The welcome screens will show next time you open Patterns.',
                  type: ToastType.info,
                );
              },
            ),
            const SizedBox(height: 28),
            Text(
              'Feedback',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            _SettingsItem(
              icon: LineIcons.star,
              title: 'Rate Patterns',
              subtitle: 'Tell the store what you think',
              onTap: () => ReviewPromptService.requestReviewManually(context),
            ),
            if (TipJarService.isPlatformSupported) ...[
              const SizedBox(height: 10),
              _SettingsItem(
                icon: LineIcons.heart,
                title: 'Support Patterns',
                subtitle: 'Leave a small tip to keep development going',
                onTap: () => TipJarSheet.show(context),
              ),
            ],
          ], maxSteps: 6),
        ),
      ),
    );
  }

  void _showDesktopLinkingDialog(BuildContext context) {
    final otp = ProPairingService.generateOfflineOTP();
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: theme.dividerColor),
          ),
          title: Row(
            children: [
              Icon(Icons.desktop_mac_rounded, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 12),
              const Text('Link Desktop App'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'To link your Patterns Pro purchase with the desktop app:',
                style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.7)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Option 1: Scan QR Code',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                'Open the Paywall sheet on desktop, choose "Scan QR Code", and scan it with your phone\'s built-in system camera app.',
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.55), height: 1.3),
              ),
              const SizedBox(height: 16),
              const Text(
                'Option 2: Enter Offline Code',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                'On desktop, choose "Enter Code" and type in this code:',
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.55), height: 1.3),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Text(
                  '${otp.substring(0, 3)} ${otp.substring(3)}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This code expires in 5 minutes.',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _confirmExport(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _BottomPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export data?',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              'The backup is a readable JSON file and is not encrypted by Patterns. Save it somewhere private.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _exportData(context);
                },
                child: const Text('Export JSON backup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
      if (context.mounted) _showMessage(context, 'Data exported');
    } catch (error) {
      if (context.mounted) {
        _showMessage(context, 'Export failed', type: ToastType.error);
      }
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
              'Choose a JSON backup. Patterns will show what it contains before replacing current entries.',
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
                child: const Text('Choose backup'),
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
        allowedExtensions: ['zip', 'json'],
        withData: true,
      );
      if (result == null) return;
      final bytes = result.files.single.bytes;
      if (bytes == null) {
        if (context.mounted) {
          _showMessage(
            context,
            'Could not read backup file',
            type: ToastType.error,
          );
        }
        return;
      }
      final isZip =
          (result.files.single.extension ?? '').toLowerCase() == 'zip';
      final summary = isZip
          ? DbHelper.previewBundle(bytes)
          : DbHelper.previewBackup(utf8.decode(bytes));
      if (context.mounted) {
        _showImportPreview(context, ref, bytes, isZip, summary);
      }
    } on FormatException {
      if (context.mounted) {
        _showMessage(
          context,
          'Backup file is not valid',
          type: ToastType.error,
        );
      }
    } catch (error) {
      if (context.mounted) {
        _showMessage(context, 'Import failed', type: ToastType.error);
      }
    }
  }

  void _showImportPreview(
    BuildContext context,
    WidgetRef ref,
    Uint8List bytes,
    bool isZip,
    BackupSummary summary,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _BottomPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Import backup?',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              'This backup contains ${summary.journalCount} journal entries, ${summary.ocdCount} OCD events, ${summary.delaySessionCount} delay sessions, ${summary.erpExercisePlanCount} ERP plans, and ${summary.erpExerciseSessionCount} ERP practices. Importing replaces your current entries.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await _finishImport(context, ref, bytes, isZip);
                    },
                    child: const Text('Replace'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finishImport(
    BuildContext context,
    WidgetRef ref,
    Uint8List bytes,
    bool isZip,
  ) async {
    try {
      if (isZip) {
        await DbHelper.instance.importBundle(bytes);
      } else {
        await DbHelper.instance.importAll(utf8.decode(bytes));
      }
      ref.invalidate(journalProvider);
      ref.invalidate(ocdProvider);
      ref.invalidate(delaySessionProvider);
      ref.invalidate(erpExercisePlanProvider);
      ref.invalidate(erpExerciseSessionProvider);
      ref.invalidate(exposureHierarchyProvider);
      ref.invalidate(exposureStepProvider);
      ref.invalidate(responsePreventionProvider);
      ref.invalidate(urgeSurfProvider);
      ref.invalidate(programEnrollmentProvider);
      ref.invalidate(programTaskProgressProvider);
      ref.invalidate(behavioralExperimentProvider);
      ref.invalidate(exposureReflectionProvider);
      ref.invalidate(actionPlanProvider);
      ref.invalidate(implementationIntentionProvider);
      ref.invalidate(uncertaintyLogProvider);
      ref.invalidate(exposureMaterialProvider);
      if (context.mounted) _showMessage(context, 'Data imported');
    } on FormatException {
      if (context.mounted) {
        _showMessage(
          context,
          'Backup file is not valid',
          type: ToastType.error,
        );
      }
    } catch (error) {
      if (context.mounted) {
        _showMessage(context, 'Import failed', type: ToastType.error);
      }
    }
  }

  void _confirmWipeData(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _BottomPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wipe all data?',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Text(
              'This deletes local journal entries, OCD events, ERP practice history, and app preferences from this device. This cannot be undone.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      await DbHelper.instance.clearAll();
                      await MaterialFileStore.deleteAll();
                      await clearLocalPreferences();
                      ref.invalidate(journalProvider);
                      ref.invalidate(ocdProvider);
                      ref.invalidate(delaySessionProvider);
                      ref.invalidate(erpExercisePlanProvider);
                      ref.invalidate(erpExerciseSessionProvider);
                      ref.invalidate(exposureMaterialProvider);
                      if (context.mounted) {
                        _showMessage(context, 'Local data wiped');
                      }
                    },
                    child: const Text('Wipe'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(
    BuildContext context,
    String message, {
    ToastType type = ToastType.success,
  }) {
    showAppSnackBar(context, message, type: type);
  }

  Future<void> _setAppLock(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    if (!enabled) {
      await ref.read(appLockEnabledProvider.notifier).setEnabled(false);
      if (context.mounted) _showMessage(context, 'App lock disabled');
      return;
    }

    try {
      final auth = ref.read(biometricAuthenticatorProvider);
      final supported = await auth.isDeviceSupported();
      if (!supported) {
        if (context.mounted) {
          _showMessage(
            context,
            'Device lock unavailable',
            type: ToastType.error,
          );
        }
        return;
      }
      // local_auth 3.x returns true only on success; everything else (cancel,
      // lockout, missing biometrics, etc.) is surfaced as LocalAuthException.
      await auth.authenticate(reason: 'Unlock Patterns to enable app lock.');
      await ref.read(appLockEnabledProvider.notifier).setEnabled(true);
      if (context.mounted) _showMessage(context, 'App lock enabled');
    } on LocalAuthException catch (e) {
      if (!context.mounted) return;
      switch (e.code) {
        case LocalAuthExceptionCode.userCanceled:
        case LocalAuthExceptionCode.systemCanceled:
        case LocalAuthExceptionCode.timeout:
        case LocalAuthExceptionCode.userRequestedFallback:
          // User-initiated abort - no message, the toggle simply stays off.
          break;
        case LocalAuthExceptionCode.temporaryLockout:
          _showMessage(
            context,
            'Too many attempts. Try again in a moment.',
            type: ToastType.error,
          );
          break;
        case LocalAuthExceptionCode.biometricLockout:
          _showMessage(
            context,
            'Biometric authentication is locked. Unlock your device with your passcode first.',
            type: ToastType.error,
          );
          break;
        case LocalAuthExceptionCode.noBiometricsEnrolled:
        case LocalAuthExceptionCode.noCredentialsSet:
        case LocalAuthExceptionCode.noBiometricHardware:
        case LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable:
          _showMessage(
            context,
            'Device lock unavailable',
            type: ToastType.error,
          );
          break;
        default:
          _showMessage(
            context,
            'Could not enable app lock',
            type: ToastType.error,
          );
      }
    } catch (_) {
      if (context.mounted) {
        _showMessage(
          context,
          'Could not enable app lock',
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
    if (!enabled) {
      await ref.read(reminderProvider.notifier).setEnabled(false);
      await NotificationService.cancelReminder();
      if (context.mounted) _showMessage(context, 'Daily reminder turned off');
      return;
    }

    final granted = await NotificationService.requestPermission();
    if (!granted) {
      if (context.mounted) {
        _showMessage(
          context,
          'Notifications are off for Patterns. Enable them in your device '
          'settings to get reminders.',
          type: ToastType.info,
        );
      }
      return;
    }

    final settings = ref.read(reminderProvider);
    await NotificationService.scheduleDailyReminder(
      TimeOfDay(hour: settings.hour, minute: settings.minute),
    );
    await ref.read(reminderProvider.notifier).setEnabled(true);
    if (context.mounted) _showMessage(context, 'Daily reminder is on');
  }

  Future<void> _pickReminderTime(BuildContext context, WidgetRef ref) async {
    final settings = ref.read(reminderProvider);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: settings.hour, minute: settings.minute),
    );
    if (picked == null) return;
    await ref
        .read(reminderProvider.notifier)
        .setTime(picked.hour, picked.minute);
    if (ref.read(reminderProvider).enabled) {
      await NotificationService.scheduleDailyReminder(picked);
      if (context.mounted) {
        _showMessage(context, 'Reminder set for ${picked.format(context)}');
      }
    }
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
              'Patterns stores journal entries, OCD events, distress ratings, and reflections on this device. Manual export creates an unencrypted JSON backup or PDF report wherever you choose to save it.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
            ),
            const SizedBox(height: 12),
            Text(
              'Patterns is for personal reflection and self-tracking. It does not diagnose, treat, or replace care from a qualified clinician.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.45),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => launchUrl(
                  Uri.parse('https://maskedsyntax.com/patterns/privacy'),
                  mode: LaunchMode.externalApplication,
                ),
                child: const Text('View full Privacy Policy'),
              ),
            ),
          ],
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

class _SettingsSwitchItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
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
    fontFamily: AppTheme.sansFamily,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -0.5,
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
