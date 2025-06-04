// Description: Settings
// Admin and User
// Shows the Settings that the user can change

// Edit profile
// Change password ?
// Log out
// Enable Reminders
// Enable Notification Sound
// App Language
// Sync (online or offline)

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';

import 'login_screen.dart';
import 'patient_form_screen.dart';
import '../../ui/reminder_service.dart'; // REMINDER TEST
import '../../ui/theme/theme_related.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  // Preference keys
  static const _kMedReminderKey = 'pref_med_reminder_enabled';
  static const _kLabReminderKey = 'pref_lab_reminder_enabled';
  static const _kAutoSyncKey = 'pref_sync_enabled';
  static const _kLanguageKey = 'pref_language_key';
  // Default toggles
  bool _labReminderEnabled = false;
  bool _medReminderEnabled = false;
  bool _syncEnabled = false;
  String _appLanguage = 'fa';

  // Loading
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPreference(); // load preferences
  }

  // Load preferences from shared_preferences.
  Future<void> _loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final medReminder = prefs.getBool(_kMedReminderKey) ?? false;
      final labReminder = prefs.getBool(_kLabReminderKey) ?? false;
      final autosync = prefs.getBool(_kAutoSyncKey) ?? false;
      final language = prefs.getString(_kLanguageKey) ?? 'fa';

      if (!mounted) return;
      setState(() {
        _labReminderEnabled = labReminder;
        _medReminderEnabled = medReminder;
        _syncEnabled = autosync;
        _appLanguage = language;
        _loading = false;
      });
    } catch (e, st) {
      // Fallback to defaults if anything was wrong
      debugPrint('Error Loading SharedPreferences: $e\n$st');
      if (!mounted) return;
      setState(() {
        _medReminderEnabled = false;
        _labReminderEnabled = false;
        _syncEnabled = false;
        _appLanguage = 'fa';
        _loading = false;
      });
    }
  }

  // Checking Permission of Notifications
  Future<bool> _checkNotificationPermissions(BuildContext context) async {
    final service = ReminderService.instance;
    final hasPermission =
        await service.androidPermission?.requestNotificationsPermission() ??
        false;
    final hasExactAlarms =
        await service.androidPermission?.requestExactAlarmsPermission() ??
        false;
    if (!hasPermission || !hasExactAlarms) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !hasPermission
                ? 'Notification permission denied'
                : 'Exact alarm permission denied',
          ),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () {
              // Open app settings
              service.androidPermission?.requestNotificationsPermission();
            },
          ),
        ),
      );
      return false;
    }
    return true;
  }

  // Saving User Preference
  // Save a single bool preference under [key]
  Future<void> _saveBoolPreference(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e, st) {
      debugPrint('Error Saving Bool Prefs ($key): $e\n$st');
    }
  }

  // Save the Selected Language for the App
  Future<void> _saveStringPreference(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (e, st) {
      debugPrint('Error Saving String Prefs ($key): $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    final langLoc = AppLocalizations.of(context)!;

    // Loading
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    var listView = ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(langLoc.setProfile, style: Theme.of(context).textTheme.bodyMedium),
        // Profile
        ListTile(
          leading: const Icon(Icons.person),
          title: Text(langLoc.setEditProfile),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PatientFormScreen()),
            );
          },
        ),
        // Reminders of Lab and Med
        Text(
          langLoc.setRemindSound,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        // LAB REMINDER
        SwitchListTile(
          title: Text(langLoc.setLabReminder),
          secondary: Icon(Icons.notifications),
          inactiveTrackColor: Colors.grey,
          value: _labReminderEnabled,
          onChanged: (val) async {
            // Check permissions when enabling
            if (val && !await _checkNotificationPermissions(context)) {
              return;
            }
            setState(() {
              _labReminderEnabled = val;
            });
            if (val) {
              await _saveBoolPreference(_kLabReminderKey, val);
            } else {
              ReminderService.instance.cancelLabReminder();
            }
          },
        ),
        // MED REMINDER
        SwitchListTile(
          title: Text(langLoc.setMedReminder),
          secondary: Icon(Icons.notifications_active),
          inactiveTrackColor: Colors.grey,
          value: _medReminderEnabled,
          onChanged: (val) async {
            // Check permissions when enabling
            if (val && !await _checkNotificationPermissions(context)) {
              return;
            }
            setState(() {
              _medReminderEnabled = val;
            });
            if (val) {
              _saveBoolPreference(_kMedReminderKey, val);
              ReminderService.instance.scheduleMedReminders();
            } else {
              ReminderService.instance.cancelMedReminder();
            }
          },
        ),
        const Divider(),
        Text(
          langLoc.setLangSync,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        // LANGUAGE
        const SizedBox(height: 8),
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(langLoc.setAppLang),
          trailing: DropdownButton<String>(
            value: _appLanguage,
            items: [
              DropdownMenuItem(value: 'fa', child: Text('Persian')),
              DropdownMenuItem(value: 'en', child: Text('English')),
            ],
            onChanged: (val) {
              if (val == null) return;
              setState(() {
                _appLanguage = val;
              });
              _saveStringPreference(_kLanguageKey, val);
            },
          ),
        ),
        // SYNC
        SwitchListTile(
          title: Text(langLoc.setSync),
          secondary: Icon(Icons.sync),
          inactiveTrackColor: Colors.grey,
          value: _syncEnabled,
          onChanged: (val) {
            setState(() {
              _syncEnabled = val;
            });
            _saveBoolPreference(_kAutoSyncKey, val);
          },
        ),
        ///////////
        // DEBUG //
        ///////////
        ListTile(
          leading: const Icon(Icons.bug_report),
          title: const Text('Test Lab Reminder'),
          onTap: () async {
            _checkNotificationPermissions(context);
            try {
              // Schedule test notification
              final service = ReminderService.instance;
              await service.scheduleLabReminders('HbA1c');

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Lab Reminder Scheduled for 10 seconds from now.',
                  ),
                ),
              );
            } catch (e, st) {
              // Added stack trace for better debugging
              debugPrint('Setting - Error in Test Lab Reminder: $e\n$st');
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Setting - Error: $e')));
            }
          },
        ),
        const Divider(),
        // Logout
        ListTile(
          leading: const Icon(Icons.logout),
          title: Text(langLoc.setLogout),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
        ),
      ],
    );
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: GradientBackground(context)),
          ),
          SafeArea(
            child: Column(
              children: [
                // Headroom with Back button
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                      ), // Change this for consistency
                      tooltip: '', // Make tooltip in ARB files
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                const SizedBox(height: 64.0),
                Text(
                  AppLocalizations.of(context)!.setEditProfile,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 16),
                Expanded(child: listView),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
