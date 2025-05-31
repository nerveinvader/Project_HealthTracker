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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Headroom
              // Anything else?
              // Top Margin
              const SizedBox(height: 100.0),
              Text(
                AppLocalizations.of(context)!.chartTitle,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              // Lab Selector
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48.0,
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
                padding: EdgeInsets.symmetric(vertical: 8),
                child: ToggleButtons(
                  renderBorder: false,
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(langLoc.chartLast7),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(langLoc.chartLast14),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(langLoc.chartLast30),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(langLoc.chartLast90),
                    ),
                  ],
                )
              ),
              // Chart View Panel
              SizedBox(
                height: 256,
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
                    // Convert spots to FlSpot
                    final spots = <FlSpot>[];
                    for (var e in data) {
                      final x = e.date.millisecondsSinceEpoch.toDouble();
                      final y = e.value.toDouble();
                      spots.add(FlSpot(x, y));
                    }
                    // Padding (easier?)
                    final minX = spots.first.x;
                    final maxX = spots.last.x;
                    final values = spots.map((s) => s.y).toList();
                    final minY = values.reduce((a, b) => a < b ? a : b) * 0.9;
                    final maxY = values.reduce((a, b) => a > b ? a : b) * 1.1;
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: LineChart(
                        LineChartData(
                          minX: minX,
                          minY: minY,
                          maxX: maxX,
                          maxY: maxY,
                          // Draw a Light Grid
                          gridData: FlGridData(
                            show: true,
                            horizontalInterval: (maxY - minY),
                            getDrawingHorizontalLine: (y) => FlLine(
                              color: Colors.grey.shade200,
                              strokeWidth: 1,
                            ),
                          ),
                          // Titles
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 22,
                                interval: (maxX - minX) / 4,
                                getTitlesWidget: (value, meta) {
                                  final date = DateTime.fromMicrosecondsSinceEpoch(value.toInt());
                                  // Show week dat in Persian format
                                  final label = DateFormat.Md('fa').format(date);
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(label, style: const TextStyle(fontSize: 10)),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: (maxY - minY),
                                reservedSize: 22,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toStringAsFixed(1), //
                                    style: const TextStyle(fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          // Border lines on bottom and left only
                          borderData: FlBorderData(
                            show: true,
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade400, width: 1),
                              left: BorderSide(color: Colors.grey.shade400, width: 1),
                              right: BorderSide(color: Colors.transparent),
                              top: BorderSide(color: Colors.transparent)
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: false,
                              color: Theme.of(context).colorScheme.primary,
                              barWidth: 2,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4, // dotSize
                                    color: Theme.of(context).colorScheme.primary, // dotColor
                                    strokeWidth: 0,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(show: false),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32,) // Placeholder
            ],
          ),
        ),
      ),
    );
  }

}
