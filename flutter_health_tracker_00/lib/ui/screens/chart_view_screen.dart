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
import '../../l10n/app_localizations.dart';
import 'package:flutter_health_tracker_00/ui/screens/patient_list_screen.dart';
import 'package:intl/intl.dart';
import '../../data/local/app_db.dart';

// Chart Lab types
const List<String> labTypes = [
  'HbA1c', 'FBS', '2HPP', 'Cholesterol', 'HDL', 'LDL', 'TG', 'SBP', 'DBP'
];
// Chart Previous Days Range
enum ChartRange { days7, days14, days30, days90 }

class ChartViewScreen extends StatefulWidget {
  final String patientId;
  const ChartViewScreen({super.key, required this.patientId});

  @override
  State<ChartViewScreen> createState() => _ChartViewScreenState();
}

class _ChartViewScreenState extends State<ChartViewScreen> {
  ChartRange _selectedRange = ChartRange.days7;
  String _selectedLabType = labTypes.first;
  late Future<List<LabEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _loadLabEntries();
  }

  // Load lab entries for the selected date range and lab type
  void _loadLabEntries() {
    final now = DateTime.now();
    final from = now.subtract(Duration(days: _daysForRange(_selectedRange)));

    setState(() {
      final query = (db.select(db.labEntries) // DB query
          ..where((tbl) => tbl.patientId.equals(widget.patientId)) // ID
          ..where((tbl) => tbl.type.equals(_selectedLabType)) // Lab Type
          ..where((tbl) => tbl.date.isBiggerOrEqualValue(from)) // Date Rnage
          ..orderBy([(t) => OrderingTerm.asc(t.date)]));
        _entriesFuture = query.get();
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
    final langLoc = AppLocalizations.of(context)!; // Applocalization Hassle!
    return Scaffold(
      appBar: AppBar(
        title: Text(langLoc.chartTitle),
      ),
      body: Column(
        children: [
          // Lab Selector
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: DropdownButtonFormField(
              value: _selectedLabType,
              decoration: InputDecoration(
                labelText: langLoc.labType,
              ),
              items: labTypes
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
              onChanged: (val) {
                setState(() => _selectedLabType = val!);
                _loadLabEntries(); // Reload
              },
            ),
          ),
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
          Expanded(
            child: FutureBuilder<List<LabEntry>>(
              future: _entriesFuture,
              builder:(context, snapshot) {
                // Error Handling
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(langLoc.errorLoadingdata)),
                    );
                  });
                  return Center(child: Text(langLoc.errorPlaceholder));
                }
                // Data Handling
                final data = snapshot.data!;
                if (data.isEmpty) {
                  return Center(child: Text(langLoc.chartNoData));
                }
                // Build Chart
                final spots = <FlSpot>[];
                for (var e in data) {
                  final x = e.date.millisecondsSinceEpoch.toDouble();
                  final y = e.value.toDouble();
                  spots.add(FlSpot(x, y));
                }

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final date = DateTime.fromMicrosecondsSinceEpoch(value.toInt());
                              final label = DateFormat.Md('fa').format(date);
                              return Text(
                                  label, style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: false,
                          barWidth: 2,
                          dotData: FlDotData(show: true),
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}
