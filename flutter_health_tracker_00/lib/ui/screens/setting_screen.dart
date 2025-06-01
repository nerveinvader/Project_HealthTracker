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
import 'package:path/path.dart';
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

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: GradientBackground(context),),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Profile
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: Text('Edit Profile'),
                  onTap:  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PatientFormScreen()),
                    );
                  }
                ),
                // Reminder and Sounds
                Text(
                  'Reminder and Sound',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: Text('Enable Reminder'),
                  value: _reminderEnabled,
                  onChanged: (val) {
                    setState(() {
                      _reminderEnabled = val;
                    });
                    // SAVE SETTING STATES
                  }
                ),
                SwitchListTile(
                  title: Text('Enable Sound'),
                  value: _soundEnabled,
                  onChanged: (val) {
                    setState(() {
                      _soundEnabled = val;
                    });
                    // SAVE SETTING STATES
                  }
                ),
                const Divider(),
                Text(
                  'Language and Sync',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text('App Language'),
                  trailing: DropdownButton<String>(
                    value: _appLanguage,
                    items: [
                      DropdownMenuItem(value: 'fa', child: Text('Persian')),
                      DropdownMenuItem(value: 'en', child: Text('Persian'))
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
                SwitchListTile(
                  title: Text('Enable Online Sync'),
                  value: _syncEnabled,
                  onChanged: (val) {
                    setState(() {
                      _syncEnabled = val;
                    });
                    // SAVE SETTING STATES
                  }
                ),
                const Divider(),
                // Logout
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text('Logout'),
                  onTap:  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
