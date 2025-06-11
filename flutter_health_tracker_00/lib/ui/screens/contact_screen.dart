// Description: Contact and About Us
// Admin and User
// Shows the Contact info and About Us

import 'package:flutter/material.dart';
import 'package:flutter_health_tracker_00/l10n/app_localizations.dart';
import 'package:flutter_health_tracker_00/ui/theme/theme_related.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Final variables to print on screen
    final String textAppVersion =
        '${AppLocalizations.of(context)!.contVersion}: mvp 0.0.1';
    final String textNumber = '\u200E+98-911-222-3344'; // \u200E to make LTR text
    final String textSuppPhone =
        '${AppLocalizations.of(context)!.contPhone}: $textNumber';
    final String textSuppEMail =
        '${AppLocalizations.of(context)!.contEmail}: email@companyname.com';
    final String textSuppTelegram =
        '${AppLocalizations.of(context)!.contTelegram}: appnameuser';
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: GradientBackground(context)),
          ),
          SafeArea(
            child: Column(
              // Headroom
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios),
                      tooltip: '',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                const SizedBox(height: 64),
                Text(
                  AppLocalizations.of(context)!.contName, // Name
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      // App Name + Description
                      ListTile(
                        title: Text(
                          AppLocalizations.of(context)!.contAppName,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      ListTile(
                        title: Text(
                          AppLocalizations.of(context)!.contAppDescription,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      Divider(),
                      // Contact Info
                      ListTile(
                        title: SelectableText(
                          textSuppPhone,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      ListTile(
                        title: SelectableText(
                          textSuppEMail,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      ListTile(
                        title: SelectableText(
                          textSuppTelegram,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      Divider(),
                      // Version
                      ListTile(
                        title: Text(
                          textAppVersion,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
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
