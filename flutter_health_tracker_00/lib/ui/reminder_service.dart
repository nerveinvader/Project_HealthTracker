// Description: Reminder Service
// Code
// Reminder Service to remind the user to take meds and do labs
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
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
  final FlutterLocalNotificationsPlugin _flnp =
      FlutterLocalNotificationsPlugin();
  // Permission for Notifications
  AndroidFlutterLocalNotificationsPlugin? get androidPermission =>
      _flnp
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
  late final bool grantedPermission;

  // IDs for MVP (reserved)
  static const _medIds = [100, 101, 102]; // 8 / 12 / 20 hours
  static const Map<String, int> _labBaseIds = {
    // + 90 and 180 days
    'HbA1c': 200, 'FBS': 202, '2HPP': 204, // DM
    'Cholesterol': 206, 'HDL': 208, 'LDL': 210, 'TG': 212, // HLP
    'SBP': 214, 'DBP': 216, // HTN
    // Add more if needed
  };

  // Call in main() once
  Future<void> init() async {
    try {
      // Initialize TimeZone
      tz.initializeTimeZones();
      final localName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localName));

      // Request Notification permission
      grantedPermission =
          await androidPermission?.requestNotificationsPermission() ?? false;
      // DEBUG
      // final hasExactAlarms = await androidPermission?.requestExactAlarmsPermission() ?? false;
      //if ((!hasExactAlarms)) {
      //  debugPrint('Exact alarms permission not granted');
      //}

      // Define notification channels
      const AndroidNotificationChannel medChannel = AndroidNotificationChannel(
        'med_channel',
        'Medication Reminders',
        description: 'Channel for daily medication reminders.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );
      const AndroidNotificationChannel labChannel = AndroidNotificationChannel(
        'lab_channel',
        'Lab Test Reminders',
        description: 'Channel for follow-up lab test reminders.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      // Create the notification channels
      await _flnp
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(medChannel);
      await _flnp
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(labChannel);

      // Initialize Flutter_Loc_Not for android and iOS
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
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
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
        tz.local,
        now.year,
        now.month,
        now.day,
        hours[i],
        0,
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
              'med_channel', // Ensure this matches the channel ID
              'Medication Reminders', // Channel name
              channelDescription: 'Daily Medication Reminders',
              importance:
                  Importance.high, // Importance for this specific notification
              playSound: true,
              enableVibration: true,
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
  Future<void> scheduleLabReminders(
    String labType,
  ) async {
    if (!_labBaseIds.containsKey(labType)) return; // Unknown type
    final base = _labBaseIds[labType]!; // type id num

    await cancelLabReminderFor(labType); // avoid duplicates

    // to repeat the For loop - watch for sec/min/hr/day
    var timeTriggers = [10, 180];

    for (int i = 0; i < timeTriggers.length; i++) {
      int trigger = timeTriggers[i];
      final timeNow = tz.TZDateTime.now(tz.local); // Time Now
      final scheduleTrigger = timeNow.add(Duration(seconds: trigger)); // DEBUG SECONDS
      try {
        await _flnp.zonedSchedule(
          base + i,
          'زمان انجام آزمایش بعدی شما فرا رسیده است', // title - generic
          labType, // body - labtype
          scheduleTrigger,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'lab_channel', // Ensure this matches the channel ID
              'Lab Test Reminders', // Channel name
              channelDescription: 'Follow-up Lab Reminders',
              importance:
                  Importance.high, // Importance for this specific notification
              enableVibration: true,
              playSound: true,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      } catch (e, st) {
        debugPrint('ReminderService - Scheduling Failed: $e\n$st');
      }
    }
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

  ///////////////////////////
  ////////// DEBUG //////////
  ///////////////////////////

  // Show Notification // THIS DOES WORK
  // Future<void> showNotification({
  //   int id = 0,
  //   String? title,
  //   String? body,
  // }) async {
  //   debugPrint('DEBUG - SHOW NOTIFICATION');
  //   return _flnp.show(
  //     id,
  //     title,
  //     body,
  //     const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'lab_channel', // Ensure this matches the channel ID
  //         'Lab Test Reminders', // Channel name
  //         channelDescription: 'Follow-up Lab Reminders',
  //         importance:
  //             Importance.high, // Importance for this specific notification
  //         enableVibration: true,
  //         playSound: true,
  //         ticker: 'RS - Lab reminder DEBUG',
  //         category: AndroidNotificationCategory.alarm,
  //       ),
  //       iOS: DarwinNotificationDetails(),
  //     ),
  //   );
  // }

  // Shcedule Notification
  // Future<void> scheduleNotification({
  //   int id = 1,
  //   required String title,
  //   required String body,
  //   required int hour,
  //   required int minute,
  // }) async {
  //   final nowTime = tz.TZDateTime.now(tz.local); // Get current Date/Time
  //   var scheduledDate = tz.TZDateTime(
  //     tz.local,
  //     nowTime.year,
  //     nowTime.month,
  //     nowTime.day,
  //     hour,
  //     minute,
  //   );

  //   // Schedule the Notification
  //   await _flnp.zonedSchedule(
  //     id,
  //     title,
  //     body,
  //     scheduledDate,
  //     const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'lab_channel', // Ensure this matches the channel ID
  //         'Lab Test Reminders', // Channel name
  //         channelDescription: 'Follow-up Lab Reminders',
  //         importance:
  //             Importance.high, // Importance for this specific notification
  //         enableVibration: true,
  //         playSound: true,
  //         ticker: 'RS - Lab reminder DEBUG',
  //         category: AndroidNotificationCategory.alarm,
  //       ),
  //       iOS: DarwinNotificationDetails(),
  //     ),
  //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //     // matchDateTimeComponents: DateTimeComponents.time // repeat each day at this time
  //   );
  //   debugPrint('');
  // }

  // // Get pending notifications
  // Future<List<PendingNotificationRequest>> getPendingNotifications() async {
  //   try {
  //     final pendingNotifications = await _flnp.pendingNotificationRequests();
  //     debugPrint('RS - Pending notifications count: ${pendingNotifications.length}');
  //     for (var notification in pendingNotifications) {
  //       debugPrint('''
  //         RS - Notification ID: ${notification.id}
  //         Title: ${notification.title}
  //         Body: ${notification.body}
  //         Payload: ${notification.payload}
  //       ''');
  //     }
  //     return pendingNotifications;
  //   } catch (e, st) {
  //     debugPrint('RS - Failed to get pending notifications: $e\n$st');
  //     return [];
  //   }
  // }
}
