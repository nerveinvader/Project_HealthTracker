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
  // Default toggles
  bool _reminderEnabled = false;
  bool _soundEnabled = false;
  bool _syncEnabled = false;
  // Language selection
  String _appLanguage = 'fa';

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
                SwitchListTile(
                  title: Text(langLoc.setReminder),
                  secondary: Icon(Icons.notifications),
                  inactiveTrackColor: Colors.grey,
                  value: _reminderEnabled,
                  onChanged: (val) {
                    setState(() {
                      _reminderEnabled = val;
                    });
                    // SAVE SETTING STATES
                  }
                ),
                SwitchListTile(
                  title: Text(langLoc.setNotifSound),
                  secondary: Icon(Icons.notifications_active),
                  inactiveTrackColor: Colors.grey,
                  value: _soundEnabled,
                  onChanged: (val) {
                    setState(() {
                      _soundEnabled = val;
                    });
                    // SAVE SETTING STATES
                  }
                ),
                // Language and Sync
                const SizedBox(height: 8),
                Text(
                  langLoc.setLangSync,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
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
                      // SAVE SETTING
                    }
                  ),
                ),
                // Sync
                SwitchListTile(
                  title: Text(langLoc.setSync),
                  secondary: Icon(Icons.sync),
                  inactiveTrackColor: Colors.grey,
                  value: _syncEnabled,
                  onChanged: (val) {
                    setState(() {
                      _syncEnabled = val;
                    });
                    // SAVE SETTING STATES
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
