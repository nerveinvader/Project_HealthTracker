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

import 'package:flutter/material.dart';
import 'package:flutter_health_tracker_00/ui/reminder_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';

import 'login_screen.dart';
import 'patient_form_screen.dart';
import '../../ui/theme/theme_related.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  // Preference keys
  static const _kReminderKey = 'pref_reminder_enabled';
  static const _kSoundKey = 'pref_sound_enabled';
  static const _kAutoSyncKey = 'pref_sync_enabled';
  static const _kLanguageKey = 'pref_language_key';

  // Default toggles -in Memory
  bool _reminderEnabled = false;
  bool _soundEnabled = false;
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
      final reminders = prefs.getBool(_kReminderKey) ?? false;
      final sound = prefs.getBool(_kSoundKey) ?? false;
      final autosync = prefs.getBool(_kAutoSyncKey) ?? false;
      final language = prefs.getString(_kLanguageKey) ?? 'fa';
      debugPrint('Error Loading');
      if (!mounted) return;
      setState(() {
        _reminderEnabled = reminders;
        _soundEnabled = sound;
        _syncEnabled = autosync;
        _appLanguage = language;
        _loading = false;
      });
    } catch (e, st) {
      // Fallback to defaults if anything was wrong
      debugPrint('Error Loading SharedPreferences: $e\n$st');
      if (!mounted) return;
      setState(() {
        _reminderEnabled = false;
        _soundEnabled = false;
        _syncEnabled = false;
        _appLanguage = 'fa';
        _loading = false;
      });
    }
  }

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

    // ListView Local Var for better readability (testing)
    var listView = ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  langLoc.setProfile,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                // Profile
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(langLoc.setEditProfile),
                  onTap:  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PatientFormScreen()),
                    );
                  }
                ),
                // Reminder and Sounds
                Text(
                  langLoc.setRemindSound,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                // REMINDER
                SwitchListTile(
                  title: Text(langLoc.setReminder),
                  secondary: Icon(Icons.notifications),
                  inactiveTrackColor: Colors.grey,
                  value: _reminderEnabled,
                  onChanged: (val) async {
                    setState(() {
                      _reminderEnabled = val;
                    });
                    await _saveBoolPreference(_kReminderKey, val); // SAVE SETTING STATES
                    if (val) {
                      ReminderService.instance.scheduleMedReminders();
                    } else {
                      ReminderService.instance.cancelMedReminder();
                      ReminderService.instance.cancelLabReminder();
                    }
                  }
                ),
                // NOTIF SOUND
                SwitchListTile(
                  title: Text(langLoc.setNotifSound),
                  secondary: Icon(Icons.notifications_active),
                  inactiveTrackColor: Colors.grey,
                  value: _soundEnabled,
                  onChanged: (val) {
                    setState(() {
                      _soundEnabled = val;
                    });
                    _saveBoolPreference(_kSoundKey, val); // SAVE SETTING STATES
                  }
                ),
                // Language and Sync
                const SizedBox(height: 8),
                Text(
                  langLoc.setLangSync,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                // LANGUAGE
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(langLoc.setAppLang),
                  trailing: DropdownButton<String>(
                    value: _appLanguage,
                    items: [
                      DropdownMenuItem(value: 'fa', child: Text('Persian')),
                      DropdownMenuItem(value: 'en', child: Text('English'))
                    ],
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() {
                        _appLanguage = val;
                      });
                      _saveStringPreference(_kLanguageKey, val); // SAVE SETTING STATES
                      // to Rebuild the app => wrap MaterialApp with ValueNotifier or Provider...
                    }
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
                    _saveBoolPreference(_kAutoSyncKey, val); // SAVE SETTING STATES
                    // TO DO SYNC
                  }
                ),
                const SizedBox(height: 8),
                // Logout
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text(langLoc.setLogout),
                  onTap:  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                ),
              ],
            );
    // Loading
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(),),
      );
    }
    // Main Page Scaffold
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: GradientBackground(context),),
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
                      icon: const Icon(Icons.arrow_back_ios), // Change this for consistency
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
                Expanded(
                  child: listView
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
