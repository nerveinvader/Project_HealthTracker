// Description: Disease Dashboard Screen
// User Page
// Disease dashboard screen to navigate to other sub pages.
// Shows labs and measurements for each disease type.
// Can navigate to medications (related to disease) screen.

import 'dart:ui';

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../data/local/app_db.dart';
import 'patient_home_screen.dart'; // for LearnMoreCard reuse

/// Enum to select disease type
enum DiseaseType { hypertension, diabetes, hyperlipidemia }

class DiseaseDashboardScreen extends StatelessWidget {
  final DiseaseType type;
  final String patientId;

  const DiseaseDashboardScreen({
    super.key,
    required this.type,
    required this.patientId,
  });

  // Disease type indicating other stuff (lab types, medications, learn more)
  String _title(AppLocalizations langLoc) {
    switch (type) {
      case DiseaseType.hypertension:
        return langLoc.uiHTN;
      case DiseaseType.diabetes:
        return langLoc.uiDM;
      case DiseaseType.hyperlipidemia:
        return langLoc.uiHLP;
    }
  }

  // Lab types related to Disease
  List<String> _labTypes() {
    switch (type) {
      case DiseaseType.diabetes:
        return ['HbA1c', 'FBS', '2HPP'];
      case DiseaseType.hypertension:
        return ['SBP', 'DBP'];
      case DiseaseType.hyperlipidemia:
        return ['Cholesterol', 'HDL', 'LDL', 'TG'];
    }
  }

  /// Fetch latest entry for lab type from DB
  Future<LabEntry?> _fetchLatest(BuildContext context, String labType) async {
    final db = AppDatabase();
    final entries = await (db.select(db.labEntries)
          ..where((t) => t.patientId.equals(patientId))
          ..where((t) => t.type.equals(labType))
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(1))
        .get();
    return entries.isNotEmpty ? entries.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final langLoc = AppLocalizations.of(context)!;
    final labTypes = _labTypes();
    final today = DateFormat.yMMMMd('fa').format(DateTime.now());

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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Placeholder button
                      IconButton(
                        icon: const Icon(Icons.more_horiz),
                        onPressed: () {},
                      ),
                      // Back button - To Home Page
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Disease title
                        Center(
                          child: Text(
                            _title(langLoc),
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Today date
                        Center(
                          child: Text(
                            today,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ////////////////////
                        // Measurement cards
                        ////////////////////
                        ...labTypes.map((lab) {
                          return FutureBuilder<LabEntry?>(
                            future: _fetchLatest(context, lab),
                            builder: (ctx, snap) {
                              final entry = snap.data;
                              final valueStr = entry != null
                                  ? entry.value.toString()
                                  : langLoc.errorLoadingdata;
                              final dateStr = entry != null
                                  ? DateFormat.yMd('fa').format(entry.date)
                                  : '';
                              return MeasurementCard(
                                label: lab,
                                value: valueStr,
                                date: dateStr,
                                onTap: () {
                                  // Navigate to form for this lab type
                                },
                              );
                            },
                          );
                        }),
                        const SizedBox(height: 16),
                        //////////////////////
                        // Learn more sections
                        //////////////////////
                        LearnMoreCard(
                          text: _learnText(langLoc),
                          onTap: () {},
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
      // FIX THIS JUST TESTING FOR NOW
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Chart
            IconButton(
              icon: Icon(Icons.show_chart),
              tooltip: langLoc.chartTitle,
              onPressed: () {},
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
                onPressed: () {}
              ),
            ),
            // Profile
            IconButton(
              icon: Icon(Icons.person),
              tooltip: langLoc.uiProfile,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  String _learnText(AppLocalizations langLoc) {
    switch (type) {
      case DiseaseType.hypertension:
        return langLoc.uiLearnHTN;
      case DiseaseType.diabetes:
        return langLoc.uiLearnDM;
      case DiseaseType.hyperlipidemia:
        return langLoc.uiLearnHLP;
    }
  }
}

/// A card showing a lab measurement with an arrow
class MeasurementCard extends StatelessWidget {
  final String label;
  final String value;
  final String date;
  final VoidCallback onTap;

  const MeasurementCard({
    super.key,
    required this.label,
    required this.value,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(date, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, size: 20),
          ],
        ),
      ),
    );
  }
}
