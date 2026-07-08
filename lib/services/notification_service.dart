import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Local daily reminder ("gentle check-in") notifications.
///
/// Scheduling is intentionally inexact ([AndroidScheduleMode.inexactAllowWhileIdle])
/// so we don't need the Android exact-alarm permission - a daily nudge doesn't
/// need to-the-minute precision, and the OS can batch it to save battery.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _reminderId = 1001;
  static const int _releaseAnnouncementId = 1002;
  static const int pauseTimerNotificationId = 2001;
  static const int erpTimerNotificationId = 2002;

  static const String _channelId = 'daily_reminder';
  static const String _channelName = 'Daily reminder';
  static const String _channelDescription =
      'A gentle daily nudge to check in with Patterns.';
  static const String _practiceTimerChannelId = 'practice_timer';
  static const String _practiceTimerChannelName = 'Practice timer';
  static const String _practiceTimerChannelDescription =
      'A gentle alert when a timed practice window is complete.';
  static const String _updateChannelId = 'app_updates';
  static const String _updateChannelName = 'App updates';
  static const String _updateChannelDescription =
      'Occasional notes when Patterns gets meaningful new recovery tools.';

  static const int defaultHour = 20; // 8:00 PM
  static const int defaultMinute = 0;

  static bool _initialized = false;
  static bool _tzReady = false;

  static bool get isSupported {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid;
  }

  /// Initialises the plugin and the timezone database. Safe to call repeatedly.
  static Future<void> init() async {
    if (!isSupported || _initialized) return;
    await _ensureTimeZone();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    // Don't request permission at init - we ask only when the user turns the
    // reminder on, so the system prompt has clear context.
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: darwin),
    );
    _initialized = true;
  }

  static Future<void> _ensureTimeZone() async {
    if (_tzReady) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Falls back to UTC. Scheduling still works; the fire time could be off
      // by the UTC offset in the rare case the device zone can't be resolved.
    }
    _tzReady = true;
  }

  /// Asks the OS for notification permission. Returns whether it was granted.
  static Future<bool> requestPermission() async {
    if (!isSupported) return false;
    await init();
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        false;
  }

  /// (Re)schedules the single daily reminder for [time], replacing any existing
  /// one. Repeats every day at that local time.
  static Future<void> scheduleDailyReminder(TimeOfDay time) async {
    if (!isSupported) return;
    await init();
    await _plugin.cancel(id: _reminderId);
    await _plugin.zonedSchedule(
      id: _reminderId,
      title: 'A quiet check-in',
      body: 'Take a gentle moment with Patterns whenever you’re ready.',
      scheduledDate: _nextInstanceOf(time),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelReminder() async {
    if (!isSupported) return;
    await init();
    await _plugin.cancel(id: _reminderId);
  }

  /// Schedules a one-time release note for users who already opted into
  /// notifications. This never requests permission; if the OS has not granted
  /// it, the notification simply will not surface.
  static Future<void> scheduleUpdateAnnouncement(DateTime scheduledAt) async {
    if (!isSupported) return;
    await init();
    final scheduled = _dateTimeInLocalZone(scheduledAt);
    if (!scheduled.isAfter(tz.TZDateTime.now(tz.local))) return;
    await _plugin.cancel(id: _releaseAnnouncementId);
    await _plugin.zonedSchedule(
      id: _releaseAnnouncementId,
      title: 'Patterns got better',
      body:
          'New recovery tools, progress insights, and a calmer Home are ready.',
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _updateChannelId,
          _updateChannelName,
          channelDescription: _updateChannelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static Future<void> cancelUpdateAnnouncement() async {
    if (!isSupported) return;
    await init();
    await _plugin.cancel(id: _releaseAnnouncementId);
  }

  /// Schedules a one-shot completion cue for an active ERP/urge timer.
  ///
  /// This is intentionally inexact on Android so the app does not need exact
  /// alarm permissions. The in-app timer still reconciles against wall-clock
  /// time when the user returns.
  static Future<bool> schedulePracticeTimerCompletion({
    required int id,
    required DateTime endsAt,
    required String title,
    required String body,
  }) async {
    if (!isSupported) return false;
    await init();
    final scheduled = _dateTimeInLocalZone(endsAt);
    if (!scheduled.isAfter(tz.TZDateTime.now(tz.local))) return false;
    try {
      await _plugin.cancel(id: id);
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduled,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _practiceTimerChannelId,
            _practiceTimerChannelName,
            channelDescription: _practiceTimerChannelDescription,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> cancelPracticeTimerCompletion(int id) async {
    if (!isSupported) return;
    await init();
    await _plugin.cancel(id: id);
  }

  static tz.TZDateTime _nextInstanceOf(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static tz.TZDateTime _dateTimeInLocalZone(DateTime value) {
    final local = value.toLocal();
    return tz.TZDateTime(
      tz.local,
      local.year,
      local.month,
      local.day,
      local.hour,
      local.minute,
      local.second,
      local.millisecond,
      local.microsecond,
    );
  }
}
