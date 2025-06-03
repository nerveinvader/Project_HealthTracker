// Description: Reminder Service
// Code
// Reminder Service to remind the user to take meds and do labs
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdb;
import 'package:flutter_timezone/flutter_timezone.dart';

class ReminderService {
  // Add this static handler
  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse details) {
    debugPrint('RS - Background tap handler triggered');
    debugPrint('RS - Background notification ID: ${details.id}');
    debugPrint('RS - Background payload: ${details.payload}');
  }

  ReminderService._internal();
  static final ReminderService instance = ReminderService._internal();
  final FlutterLocalNotificationsPlugin _flnp = FlutterLocalNotificationsPlugin();
  // Permission for Notifications
  AndroidFlutterLocalNotificationsPlugin? get androidPermission =>
    _flnp.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  late final bool grantedPermission;

  // IDs for MVP (reserved)
  static const _medIds = [100, 101, 102]; // 8 / 12 / 20 hours
  static const Map<String, int> _labBaseIds =  {
    // + 90 and 180 days
    'HbA1c': 200,	'FBS': 202,	'2HPP': 204, // DM
		'Cholesterol': 206,	'HDL': 208,	'LDL': 210,	'TG': 212, // HLP
		'SBP': 214,	'DBP': 216, // HTN
		// Add more if needed
  };

  // Call in main() once
  Future<void> init() async {
    try {
      // TZ DB init
      tzdb.initializeTimeZones();
      final localName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localName));

      // Request Notification permission
      grantedPermission = await androidPermission?.requestNotificationsPermission() ?? false;
      // DEBUG
      // final hasExactAlarms = await androidPermission?.requestExactAlarmsPermission() ?? false;
      //if ((!hasExactAlarms)) {
      //  debugPrint('Exact alarms permission not granted');
      //}

      // Plugin init
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings();
      await _flnp.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit),
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          debugPrint('RS - Notification received and tapped!');
          debugPrint('RS - Notification ID: ${details.id}');
          debugPrint('RS - Payload: ${details.payload}');
        },
        // Add this parameter to track notification display
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground
      );
    } catch (e, st) {
      debugPrint('RS - Notification init failed: $e\n$st');
    }
  }

  // Daily Meds
  Future<void> scheduleMedReminders() async {
    await cancelMedReminder(); // avoid duplicates
    const hours = [8, 12, 20];
    for (int i = 0; i < hours.length; i++) {
      final id = _medIds[i];
      final now = tz.TZDateTime.now(tz.local);
      var first = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hours[i], 0
      );
      if (first.isBefore(now)) {
        first = first.add(const Duration(days: 1));
      }
      try {
        await _flnp.zonedSchedule(
          id,
          'زمان مصرف دارو فرا رسیده است',
          '',
          first,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'med_channel',
              'Medication',
              channelDescription: 'Daily Medication Reminders',
              importance: Importance.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } catch (e, st) {
        debugPrint('RS - Med Reminder Scheduling Failed: $e\n$st');
      }
    }
  }
  // Cacnel all med reminders
  Future<void> cancelMedReminder() async {
    for (final id in _medIds) {
      try {
        await _flnp.cancel(id);
      } catch (_) {}
    }
  }

  // Monthly Labs
  Future<void> scheduleLabReminders(String labType, DateTime latestEntryDate) async {
    if (!_labBaseIds.containsKey(labType)) return;	// Unknown type
		final base = _labBaseIds[labType]!;	// type id num

		await cancelLabReminderFor(labType);	// avoid duplicates

    final triggers = [
      latestEntryDate.add(const Duration(seconds: 10)), // DEBUG //
      latestEntryDate.add(const Duration(seconds: 180)), // DEBUG //
    ];

    for (int i = 0; i < triggers.length; i++) {
      //final id = _labIds[i];
			final trigger = triggers[i];
      final tzTrigger = tz.TZDateTime.from(trigger, tz.local);
      // DEBUG
      debugPrint('------- RS - Reminder #${i + 1} -------');
      debugPrint('RS - Trigger time: ${tzTrigger.toString()}');
      debugPrint('RS - Current time: ${tz.TZDateTime.now(tz.local).toString()}');
      debugPrint('RS - Notification ID: ${base + i}');

      if (tzTrigger.isBefore(tz.TZDateTime.now(tz.local))) {
        debugPrint('RS - Target time is in past, skipping...');
        continue;
      }
      try {
        debugPrint('RS - Attempting to schedule...');
        await _flnp.zonedSchedule(
          base + i,
          'زمان انجام آزمایش بعدی شما فرا رسیده است', // specific labtype
          labType,
          tzTrigger,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'lab_channel',
              'Lab',
              channelDescription: 'Follow-up Lab Reminders',
              importance: Importance.high,
              enableVibration: true,
              playSound: true,
              ticker: 'RS - Lab reminder DEBUG',
              category: AndroidNotificationCategory.alarm,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          // Add a payload to identify the notification
          payload: 'RS - lab_reminder_$labType _${DateTime.now().toIso8601String()}',
        );
        debugPrint('RS - Scheduled $labType reminder for: ${tzTrigger.toString()}');
      } catch (e, st) {
        debugPrint('RS - Lab Scheduling Failed: $e\n$st');
      }
    }
    debugPrint('RS – Pending ▶︎ ${(await _flnp.pendingNotificationRequests()).map((e)=>e.id).join(',')}');
  }
  // Cancel all lab reminders
  Future<void> cancelLabReminder() async {
    for (final base in _labBaseIds.values) {
      try {
        await _flnp.cancel(base);
				await _flnp.cancel(base + 1);
        debugPrint('NOTIFICATIONS ARE CANCELED!');
      } catch (_) {}
    }
  }
  // Cancel specific lab reminders
  Future<void> cancelLabReminderFor(String lab) async {
    final base = _labBaseIds[lab];
    if (base == null) return;
    await _flnp.cancel(base);
    await _flnp.cancel(base + 1);
  }
}
