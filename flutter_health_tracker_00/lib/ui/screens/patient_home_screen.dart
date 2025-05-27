// Description: Patient Home Screen
// User Page
// Patient home screen to navigate to other sub pages.

// Outline:
// Appbar
// Body > ProgressionCard, DiseaseCards, LearnCards
// Bottombar > Add, Profile, Chart

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../../data/local/app_db.dart';

import 'chart_view_screen.dart';
import 'patient_form_screen.dart';
import 'lab_entry_form_screen.dart';
import 'medication_form_screen.dart';

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
      body: SafeArea(
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
                    style: Theme.of(context).textTheme.displaySmall,
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
              const SizedBox(height: 16.0),
              // DiseaseCards
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // HTN Card
                  SizedBox(
                    child: DiseaseCard(
                      title: langLoc.uiLastBP,
                      value: _bloodPressure,
                      diseaseIcon: Icons.monitor_heart,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // DM Card
                  SizedBox(
                    child: DiseaseCard(
                      title: langLoc.uiLastFBS,
                      value: _fbs,
                      diseaseIcon: Icons.cookie,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  // HLP Card
                  SizedBox(
                    child: DiseaseCard(
                      title: langLoc.uiLastChol,
                      value: _cholesterol,
                      diseaseIcon: Icons.fastfood,
                      onTap: () {},
                    ),
                  ),
                ],
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
        ),
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
            IconButton(
              icon: Icon(Icons.add),
              tooltip: langLoc.uiAdd,
              onPressed: _showAddOptions,
            ),
            // Profile
            IconButton(
              icon: Icon(Icons.person),
              tooltip: langLoc.uiProfile,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PatientFormScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Private Classes

// Disease-specific Card showing for HTN, DM, HLP
// Has ability to Navigate to another screen
class DiseaseCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData diseaseIcon;
  final VoidCallback onTap;
  const DiseaseCard({super.key, required this.title, required this.value, required this.diseaseIcon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(horizontal: 32.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4.0,
              offset: Offset(0, 2.0),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(diseaseIcon, size: 32, color: Colors.white60),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4.0),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Learn More card for HTN, DM, HLP
// Has ability to Navigate to another screen
class LearnMoreCard extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const LearnMoreCard({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        width: double.infinity,
        height: 100.0,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}

// Progress Rating of the patient, out of 10
// Has ability to Navigate to another screen
class WeeklyProgressCard extends StatelessWidget {
  final int rating;
  final VoidCallback onTap;
  const WeeklyProgressCard({super.key, required this.rating, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final langLoc = AppLocalizations.of(context)!;
    final double rating10 = rating / 10;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    Text(langLoc.uiWeeklyProgress,
                    style: Theme.of(context).textTheme.titleLarge, // CHANGE TO UNIFIED THEME
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '$rating10',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 80.0,
              height: 80.0,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: rating / 100, // 0.0 - 1.0
                    strokeWidth: 6.0,
                    color: Colors.white,
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                  Text('$rating10'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
