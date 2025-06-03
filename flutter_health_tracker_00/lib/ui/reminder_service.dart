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
      final hasExactAlarms = await androidPermission?.requestExactAlarmsPermission() ?? false;
      if ((!hasExactAlarms)) {
        debugPrint('Exact alarms permission not granted');
      }

      // Plugin init
      const androidInit = AndroidInitializationSettings('app_icon');
      const iosInit = DarwinInitializationSettings();
      await _flnp.initialize(
        const InitializationSettings(android: androidInit, iOS: iosInit),
        onDidReceiveNotificationResponse: (NotificationResponse details) {
          debugPrint('Notification tapped: ${details.payload}');
        }
      );
    } catch (e, st) {
      debugPrint('Notification init failed: $e\n$st');
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
        debugPrint('Med Reminder Scheduling Failed: $e\n$st');
      }
    }
  }

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

		await cancelLabReminder();	// avoid duplicates

    final triggers = [
      latestEntryDate.add(const Duration(seconds: 90)), // DEBUG //
      latestEntryDate.add(const Duration(seconds: 180)), // DEBUG //
    ];

    for (int i = 0; i < triggers.length; i++) {
      //final id = _labIds[i];
			final trigger = triggers[i];
      final tzTrigger = tz.TZDateTime.from(trigger, tz.local);
      if (tzTrigger.isBefore(tz.TZDateTime.now(tz.local))) {
        continue;
      }
      try {
        await _flnp.zonedSchedule(
          base + i,
          'زمان انجام آزمایش بعدی $labType فرا رسیده است', // specific labtype
          '',
          tzTrigger,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'lab_channel',
              'Lab',
              channelDescription: 'Follow-up Lab Reminders',
              importance: Importance.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          // matchDateTimeComponents: DateTimeComponents.time, // ?
        );
      } catch (e, st) {
        debugPrint('Lab Reminder Scheduling Failed: $e\n$st');
      }
    }
  }

  Future<void> cancelLabReminder() async {
    for (final base in _labBaseIds.values) {
      try {
        await _flnp.cancel(base);
				await _flnp.cancel(base + 1);
      } catch (_) {}
    }
  }
}
