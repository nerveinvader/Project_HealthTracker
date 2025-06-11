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
    return Scaffold(
			body: Stack(
				children: [
					Positioned.fill(
						child: CustomPaint(painter: GradientBackground(context))
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
											Text(
												AppLocalizations.of(context)!.contAppName,
												style: Theme.of(context).textTheme.bodyMedium,
											),
											Text(
												AppLocalizations.of(context)!.contAppDescription,
												style: Theme.of(context).textTheme.bodyMedium,
											),
											Divider(),
											// Contact Info
											SelectableText(
												AppLocalizations.of(context)!.contPhone,
												style: Theme.of(context).textTheme.bodyMedium,
											),
											SelectableText(
												AppLocalizations.of(context)!.contEmail,
												style: Theme.of(context).textTheme.bodyMedium,
											),
											SelectableText(
												AppLocalizations.of(context)!.contTelegram,
												style: Theme.of(context).textTheme.bodyMedium,
											),
											Divider(),
											// Version
											Text(
												AppLocalizations.of(context)!.contVersion,
												style: Theme.of(context).textTheme.bodyMedium,
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
