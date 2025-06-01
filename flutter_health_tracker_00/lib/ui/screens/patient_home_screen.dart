// Description: Patient Home Screen
// User Page
// Patient home screen to navigate to other sub pages.

// Outline:
// Appbar
// Body > ProgressionCard, DiseaseCards, LearnCards
// Bottombar > Add, Profile, Chart

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import 'chart_view_screen.dart'; // Chart View Dashboard
import 'lab_entry_form_screen.dart'; // Lab entry
import 'medication_form_screen.dart'; // Medication Entry
import 'disease_dashboard_screen.dart'; // Disease Specific Dashboard
import 'setting_screen.dart'; // Settings

import '../theme/theme_related.dart'; // Theme
import '../widgets/cards.dart'; // Reusable Cards

class PatientHomeScreen extends StatefulWidget {
  final String patientId;
  const PatientHomeScreen({super.key, required this.patientId});

  @override
  State<PatientHomeScreen> createState() => PatientHomeScreenState();
}

class PatientHomeScreenState extends State<PatientHomeScreen> {
  // Sample Placeholder values; replace later
  final int _progressPercent = 65; // CHANGE THIS, TO MAKE SURE IT IS OUT OF 10
  final String _bloodPressure = '120/80';
  final String _fbs = 'xxx';
  final String _cholesterol = 'xxx';

  @override
  void initState() {
    super.initState();
    // LOAD STAT LATER FROM DB HERE
  }

  // Show Add Entry Option
  Future<void> _showAddOptions() async {
    if (!mounted) return;  // Early return if widget is not mounted

    try {
      final choice = await showModalBottomSheet<String>(
        context: context,
        builder: (BuildContext bottomSheetContext) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.biotech),
                title: Text(AppLocalizations.of(context)!.addLabEntry),
                onTap: () => Navigator.pop(bottomSheetContext, 'lab'),
              ),
              ListTile(
                leading: const Icon(Icons.medication),
                title: Text(AppLocalizations.of(context)!.medAdd),
                onTap: () => Navigator.pop(bottomSheetContext, 'med'),
              ),
            ],
          ),
        ),
      );

      // Return early if the sheet was dismissed or widget is disposed
      if (!mounted || choice == null) return;

      // Navigate based on choice
      switch (choice) {
        case 'lab':
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LabEntryFormScreen(patientId: widget.patientId),
            ),
          );
          break;
        case 'med':
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MedicationFormScreen(patientId: widget.patientId),
            ),
          );
          break;
      }
    } catch (e) {
      if (!mounted) return;

      // Show error dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorPlaceholder),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final langLoc = AppLocalizations.of(context)!;
    final patientName = langLoc.patientName;
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: CustomPaint(painter: GradientBackground(context),),
          ),
          // Logo in Background
          Positioned.fill(
            child: IgnorePointer( // To ignore tap
              child: Center(child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Opacity(
                  opacity: 0.1,
                  child: Image.asset(
                    '', width: 200, height: 200, fit: BoxFit.contain,
                  ),
                ),
              ),),
            ),
          ),
          // Safe Area for Interactions
          SafeArea(
            child: Column(
              children: [
                // Top bar with placeholder and back button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Back button - To Home Page
                      // IconButton(
                      //  icon: const Icon(Icons.arrow_back_ios),
                      //  onPressed: () => Navigator.pop(context),
                      //),
                      // Reminder button
                      IconButton(
                        icon: const Icon(Icons.notifications_active_outlined),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Top Margin
                        const SizedBox(height: 128.0),
                        // Greetings
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                              langLoc.uiGreeting + patientName,
                              style: Theme.of(context).textTheme.displaySmall!.copyWith(fontWeight: FontWeight.bold),
                            ),
                        ),
                        const SizedBox(height: 32.0),
                        // Weekly Progress Card
                        WeeklyProgressCard(
                          rating: _progressPercent, // CHANGE THIS LATER FOR /10 RATING
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChartViewScreen(patientId: widget.patientId), // CHANGE THIS LATER
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 64.0),
                        ///////////////
                        // DiseaseCards
                        ///////////////
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'آخرین وضعیت اندازه گیری های شما',
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16.0),
                            ///////////
                            // HTN Card
                            ///////////
                            SizedBox(
                              child: DiseaseCard(
                                title: langLoc.uiLastBP,
                                value: _bloodPressure,
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DiseaseDashboardScreen(
                                        type: DiseaseType.hypertension, patientId: widget.patientId),
                                    ),
                                  );
                                  setState(() {
                                    // reload if want
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            ///////////
                            // DM Card
                            ///////////
                            SizedBox(
                              child: DiseaseCard(
                                title: langLoc.uiLastFBS,
                                value: _fbs,
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DiseaseDashboardScreen(
                                        type: DiseaseType.diabetes, patientId: widget.patientId),
                                    ),
                                  );
                                  setState(() {
                                    // reload if want
                                  });
                                },
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            ///////////
                            // HLP Card
                            ///////////
                            SizedBox(
                              child: DiseaseCard(
                                title: langLoc.uiLastChol,
                                value: _cholesterol,
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DiseaseDashboardScreen(
                                        type: DiseaseType.hyperlipidemia, patientId: widget.patientId),
                                    ),
                                  );
                                  setState(() {
                                    // reload if want
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 64.0),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'آخرین مطالب در مورد بیماری خود را بخوانید',
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16.0),
                            // Learn HTN
                            LearnMoreCard(
                              text: langLoc.uiLearnHTN,
                              onTap: () {},
                            ),
                            const SizedBox(height: 16.0),
                            // Learn DM
                            LearnMoreCard(
                              text: langLoc.uiLearnDM,
                              onTap: () {},
                            ),
                            const SizedBox(height: 16.0),
                            // Learn HLP
                            LearnMoreCard(
                              text: langLoc.uiLearnHLP,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Chart
            IconButton(
              icon: Icon(Icons.show_chart),
              tooltip: langLoc.chartTitle,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChartViewScreen(patientId: widget.patientId)),
                );
              },
            ),
            // Add
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
              ),
              child: IconButton(
                icon: Icon(Icons.add),
                tooltip: langLoc.uiAdd,
                onPressed: _showAddOptions,
              ),
            ),
            // Profile
            IconButton(
              icon: Icon(Icons.settings),
              tooltip: langLoc.uiProfile,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/* Private Classes */
