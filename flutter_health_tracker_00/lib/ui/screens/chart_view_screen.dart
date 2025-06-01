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

import 'dart:math' as math;

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../../l10n/app_localizations.dart';
import '../../data/local/app_db.dart';
//import 'package:intl/intl.dart';
import 'patient_list_screen.dart'; //?
import '../public_classes.dart';

// Chart Lab types
const List<String> labTypes = [
  'HbA1c', 'FBS', '2HPP', 'Cholesterol', 'HDL', 'LDL', 'TG', 'SBP', 'DBP'
];
// Chart Previous Days Range
enum ChartRange { days7, days14, days30, days90 }

class ChartViewScreen extends StatefulWidget {
  final String patientId;
  final String patientLabType;
  const ChartViewScreen({super.key, required this.patientId, this.patientLabType = 'HbA1c'});

  @override
  State<ChartViewScreen> createState() => _ChartViewScreenState();
}

class _ChartViewScreenState extends State<ChartViewScreen> {
  ChartRange _selectedRange = ChartRange.days7;
  String _selectedLabType = labTypes.first; // check this for better code?
  late Future<List<LabEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _selectedLabType = widget.patientLabType;
    _loadLabEntries();
  }

  // Load lab entries for the selected date range and lab type
  void _loadLabEntries() {
    final now = DateTime.now();
    final from = now.subtract(Duration(days: _daysForRange(_selectedRange)));
    final query = (db.select(db.labEntries) // DB query
        ..where((tbl) => tbl.patientId.equals(widget.patientId)) // ID
        ..where((tbl) => tbl.type.equals(_selectedLabType)) // Lab Type
        ..where((tbl) => tbl.date.isBiggerOrEqualValue(from)) // Date Rnage
        ..orderBy([(t) => OrderingTerm.asc(t.date)]));

    setState(() {
      _entriesFuture = query.get();
    });
  }

  // Private function to return int days for each ChartRange
  static const Map<ChartRange, int> _rangeDays = {
    ChartRange.days7: 7,
    ChartRange.days14: 14,
    ChartRange.days30: 30,
    ChartRange.days90: 90,
  };
  int _daysForRange(ChartRange range) => _rangeDays[range]!;

  // Calculate optimal interval for Y axis (Value)
  double _calculateOptimalInterval(double range) {
    final magnitude = (math.log(range) / math.ln10).floor();
    final normalized = range / math.pow(10, magnitude);

    if (normalized <= 2) return 0.2 * math.pow(10, magnitude);
    if (normalized <= 5) return 0.5 * math.pow(10, magnitude);
    return math.pow(10, magnitude).toDouble();
  }

  // Calculate optimal interval for X axis (Date)
  double _calculateOptimalDateInterval(double range) {
    const day = 24 * 60 * 60 * 1000.0;
    if (range <= 7 * day) return 1 * day;      // 1 day interval
    if (range <= 14 * day) return 2 * day;     // 2 days interval
    if (range <= 30 * day) return 5 * day;     // 5 days interval
    return 10 * day;                           // 10 days interval
  }

  // Turn DB to Spots on the Chart
  List<FlSpot> dataToSpot(List<LabEntry> data) {
    final spots = <FlSpot>[];
    for (var e in data) {
      final x = e.date.millisecondsSinceEpoch.toDouble();
      final y = e.value.toDouble();
      spots.add(FlSpot(x, y));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final langLoc = AppLocalizations.of(context)!; // Applocalization Hassle!

    return Scaffold(
      body: SafeArea(
        // Single Scroll View
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Headroom
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
                height: 200,
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
                    List<FlSpot> spots = dataToSpot(data);
                    // Calculate intervals in single pass
                    final stats = spots.fold<Map<String, double>>(
                      {'minY': double.infinity, 'maxY': double.negativeInfinity},
                      (map, spot) => {
                      'minY': math.min(map['minY']!, spot.y),
                      'maxY': math.max(map['maxY']!, spot.y),
                      },
                    );

                    final minX = spots.first.x;
                    final maxX = spots.last.x;
                    final minY = stats['minY']! * 0.9;
                    final maxY = stats['maxY']! * 1.1;

                    // Optimize intervals for better readability
                    final dy = maxY - minY;
                    final yInterval = _calculateOptimalInterval(dy);
                    final xInterval = _calculateOptimalDateInterval(maxX - minX);

                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: LineChart(
                        LineChartData(
                          minX: minX,
                          minY: minY,
                          maxX: maxX,
                          maxY: maxY,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            horizontalInterval: yInterval,
                            verticalInterval: xInterval,
                            getDrawingHorizontalLine: (y) => FlLine(
                            color: Colors.grey.shade200,
                            strokeWidth: 0.5,
                          ),
                          getDrawingVerticalLine: (x) => FlLine(
                            color: Colors.grey.shade100,
                            strokeWidth: 0.5,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: xInterval,
                                getTitlesWidget: (value, meta) {
                                  final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                                  final jalaliDate = Jalali.fromDateTime(date);
                                  return RotatedBox(
                                    quarterTurns: 1,
                                    child: Text(
                                        '${persianizeNumber(jalaliDate.month.toString())}/${persianizeNumber(jalaliDate.day.toString())}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: yInterval,
                                reservedSize: 22,
                                getTitlesWidget: (value, meta) => Text(
                                  value.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false,),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              curveSmoothness: 0.2,
                              color: Theme.of(context).colorScheme.primary,
                              barWidth: 2,
                              dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                                radius: 3,
                                color: Theme.of(context).colorScheme.primary,
                                strokeWidth: 1,
                                strokeColor: Colors.white,
                                ),
                              ),
                              belowBarData: BarAreaData(
                              show: true,
                              color: Theme.of(context).colorScheme.primary
                                .withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: (LineBarSpot touchedSpot) {
                                return Colors.white.withValues(alpha: 0.8);
                              },
                              tooltipBorderRadius: BorderRadius.circular(8),
                              tooltipPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              tooltipMargin: 16,
                              fitInsideHorizontally: true,
                              fitInsideVertically: true,
                            ),
                          ),
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
