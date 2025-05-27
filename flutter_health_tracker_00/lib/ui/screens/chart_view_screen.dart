// Description: Chart View
// Admin and User Page
// Displays a line chart of a patient's lab results,
// Over selectable time ranges.

/*
// Input: patientId
// State: selectedRange, labEntries
// Lifecycle: initState
// Controls: Segmented or Toggle
// Chart: fl_chart LineChart, X = date, Y = Lab
// Error: No entries, db failure, async gaps, data conversion and localization (date)
*/

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_health_tracker_00/ui/screens/patient_list_screen.dart';
import 'package:intl/intl.dart';
import '../../data/local/app_db.dart';

enum ChartRange { days7, days14, days30, days90 }

class ChartViewScreen extends StatefulWidget {
  final String patientId;
  const ChartViewScreen({super.key, required this.patientId});

  @override
  State<ChartViewScreen> createState() => _ChartViewScreenState();
}

class _ChartViewScreenState extends State<ChartViewScreen> {
  final ChartRange _selectedRange = ChartRange.days7;
  late Future<List<LabEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _loadLabEntries();
  }

  // Load lab entries in the selected date range, ascending by date
  void _loadLabEntries() {
    final now = DateTime.now();
    final from = now.subtract(Duration(days: _daysForRange(_selectedRange)));

    setState(() {
      _entriesFuture = (db.select(db.labEntries) // DB query
        ..where((tbl) => tbl.patientId.equals(widget.patientId))
        ..where((tbl) => tbl.date.isBiggerOrEqualValue(from))
        ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
    });
  }

  // Private function to return int days for each ChartRange
  int _daysForRange(ChartRange range) {
    switch (range) {
      case ChartRange.days7:
        return 7;
      case ChartRange.days14:
        return 14;
      case ChartRange.days30:
        return 30;
      case ChartRange.days90:
        return 90;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}


@override
Widget build(BuildContext context) {
  final langLoc = AppLocalizations.of(context)!; // Applocalization Hassle!
  return Scaffold(
    appBar: AppBar(
      title: Text(langLoc.chartTitle),
    ),
    body: Column(
      children: [
        // Range selector
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ToggleButtons(
            isSelected: ChartRange.values
              .map((r) => r == _selectedRange)
              .toList(),
            onPressed: (index) {
              setState(() {
                _selectedRange = ChartRange.values[index];
              });
              _loadLabEntries(); // Reload
            },
            children: [
              Text(langLoc.chartLast7),
              Text(langLoc.chartLast14),
              Text(langLoc.chartLast30),
              Text(langLoc.chartLast90),
              ],
            )
          ),
        Expanded(child: ),
      ],
    ),
  );
}
