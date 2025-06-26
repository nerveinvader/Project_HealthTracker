// Description: Patient Home Screen
// User Page
// Patient home screen to navigate to other sub pages.

// Outline:
// Appbar
// Body > ProgressionCard, DiseaseCards, LearnCards
// Bottombar > Add, Profile, Chart

import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import 'chart_view_screen.dart'; // Chart View Dashboard
import 'disease_dashboard_screen.dart'; // Disease Specific Dashboard
import 'setting_screen.dart'; // Settings
import 'contact_screen.dart'; // Contact Us

import '../../ui/fetch_lab.dart';
import '../theme/theme_related.dart'; // Theme
import '../widgets/cards.dart'; // Reusable Cards
import '../public_classes.dart'; // Public reusable classes

class PatientHomeScreen extends StatefulWidget {
  final String patientId;
  const PatientHomeScreen({super.key, required this.patientId});

  @override
  State<PatientHomeScreen> createState() => PatientHomeScreenState();
}

class PatientHomeScreenState extends State<PatientHomeScreen> {
  // Sample Placeholder values; replace later
  final int _progressPercent = 65; // CHANGE THIS, TO MAKE SURE IT IS OUT OF 10
  late (String value, String date) _latestSBP;
  late (String value, String date) _latestDBP;
  late (String value, String date) _latestCholesterol;
  late (String value, String date) _latestFBS;

  @override
  void initState() {
    super.initState();
    // LOAD Vars
    _latestSBP = ('--', '');
    _latestDBP = ('--', '');
    _latestCholesterol = ('--', '');
    _latestFBS = ('--', '');
    // LOAD STAT LATER FROM DB HERE
    _loadLab();
  }

  // Fetch latest labs
  Future<void> _loadLab() async {
    if (!mounted) return;
    final futureLabs = await Future.wait([
      fetchLatestLab(widget.patientId, 'SBP'),
      fetchLatestLab(widget.patientId, 'DBP'),
      fetchLatestLab(widget.patientId, 'FBS'),
      fetchLatestLab(widget.patientId, 'Cholesterol')
    ]);
    setState(() {
      _latestSBP = (
      futureLabs[0]?.value.toStringAsFixed(1) ?? '--',
      //futureLabs[0] != null ? intl.DateFormat.yMMMMd('fa').format(futureLabs[0]!.date) : ''
	  futureLabs[0] != null ? formatJalali(futureLabs[0]!.date) : ''
    );
      _latestDBP = (
        futureLabs[1]?.value.toStringAsFixed(1) ?? '--',
        futureLabs[1] != null ? formatJalali(futureLabs[1]!.date) : ''
      );
      _latestFBS = (
        futureLabs[2]?.value.toStringAsFixed(1) ?? '--',
        futureLabs[2] != null ? formatJalali(futureLabs[2]!.date) : ''
      );
      _latestCholesterol = (
        futureLabs[3]?.value.toStringAsFixed(1) ?? '--',
        futureLabs[3] != null ? formatJalali(futureLabs[3]!.date) : ''
      );
    });
  }



  @override
  Widget build(BuildContext context) {
    final langLoc = AppLocalizations.of(context)!;
    final patientName = langLoc.patientName;
    final (String value, String date) latestBP = (
      '${_latestSBP.$1}/${_latestDBP.$1}',
      _latestSBP.$2,
    );
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: CustomPaint(painter: GradientBackground(context)),
          ),
          // Logo in Background
          // const LogoBackground(), // Maybe later
          // Safe Area for Interactions
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadLab,
              child: Column(
                children: [
                  // Top bar with placeholder and back button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Button to be used ?
                        // IconButton(
                        //  icon: const Icon(Icons.arrow_back_ios),
                        //  onPressed: () => Navigator.pop(context),
                        //),
                        // Reminder button
                        IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ContactScreen(),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.notifications_active_outlined),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Top Margin
                            const SizedBox(height: 128.0),
                            // Greetings
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: Text(
                                langLoc.uiGreeting + patientName,
                                style: Theme.of(context).textTheme.displaySmall!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 32.0),
                            // Weekly Progress Card
                            WeeklyProgressCard(
                              rating:
                                  _progressPercent, // CHANGE THIS LATER FOR /10 RATING
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ChartViewScreen(
                                          patientId: widget.patientId,
                                        ), // CHANGE THIS LATER
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16.0),
                                ///////////
                                // HTN Card
                                ///////////
                                SizedBox(
                                  child: DiseaseCard(
                                    title: langLoc.uiLastBP,
                                    navPage: langLoc.uiHTN,
                                    value: latestBP.$1,
									labDate: latestBP.$2,
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => DiseaseDashboardScreen(
                                                type: DiseaseType.hypertension,
                                                patientId: widget.patientId,
                                              ),
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
                                    navPage: langLoc.uiDM,
                                    value: _latestFBS.$1,
									labDate: _latestFBS.$2,
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => DiseaseDashboardScreen(
                                                type: DiseaseType.diabetes,
                                                patientId: widget.patientId,
                                              ),
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
                                    navPage: langLoc.uiHLP,
                                    value: _latestCholesterol.$1,
									labDate: _latestCholesterol.$2,
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => DiseaseDashboardScreen(
                                                type:
                                                    DiseaseType.hyperlipidemia,
                                                patientId: widget.patientId,
                                              ),
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
                            // Column(
                            //   crossAxisAlignment: CrossAxisAlignment.start,
                            //   children: [
                            //     Text(
                            //       'آخرین مطالب در مورد بیماری خود را بخوانید',
                            //       style: Theme.of(context).textTheme.titleMedium!
                            //           .copyWith(fontWeight: FontWeight.bold),
                            //     ),
                            //     const SizedBox(height: 16.0),
                            //     // Learn HTN
                            //     LearnMoreCard(
                            //       text: langLoc.uiLearnHTN,
                            //       onTap: () {},
                            //     ),
                            //     const SizedBox(height: 16.0),
                            //     // Learn DM
                            //     LearnMoreCard(
                            //       text: langLoc.uiLearnDM,
                            //       onTap: () {},
                            //     ),
                            //     const SizedBox(height: 16.0),
                            //     // Learn HLP
                            //     LearnMoreCard(
                            //       text: langLoc.uiLearnHLP,
                            //       onTap: () {},
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                  MaterialPageRoute(
                    builder:
                        (_) => ChartViewScreen(patientId: widget.patientId),
                  ),
                );
              },
            ),
            // Add
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.7),
              ),
              child: IconButton(
                icon: Icon(Icons.add),
                tooltip: langLoc.uiAdd,
                onPressed: () => ShowAddOptions.show(context, patientId: widget.patientId),
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
