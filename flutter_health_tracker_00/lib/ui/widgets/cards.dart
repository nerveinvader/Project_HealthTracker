// Description: Card Widget
// Code
// Abilities: Tap, Show element, Reusable

import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';


////////////////////////
// Disease Specific Card
class DiseaseCard extends StatelessWidget {
  final String title;
  final String navPage;
  final String value;
  final VoidCallback onTap;
  const DiseaseCard({super.key, required this.title, required this.navPage, required this.value, required this.onTap});

  // get the latest lab type date of it.

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 16.0,
              offset: Offset(0, 2.0),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium!,
                ),
                const SizedBox(height: 16.0),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge!,
                ),
                const SizedBox(height: 16.0),
                Text(
                  'تاریخ انجام: 12/مرداد/1403',
                  style: Theme.of(context).textTheme.bodySmall!,
                ),
              ],
            ),
            Text(
              navPage,
              style: Theme.of(context).textTheme.titleLarge!,
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}

///////////////////////
// Learn More About XXX
class LearnMoreCard extends StatelessWidget {
  final String text; // Text to Show on the Card
  final VoidCallback onTap; // Function after Tap
  const LearnMoreCard({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipPath(
            clipper: LargeCardClipper(),
            child: Container(
              width: 512,
              height: 100,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 16.0,
                    offset: Offset(0, 2.0),
                  )
                ],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: ClipPath(
              clipper: SmallCardClipper(),
              child: Container(
                alignment: Alignment.centerLeft,
                width: 90,
                height: 100.0,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.7),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 16.0,
                      offset: Offset(0, 2.0),
                    )
                  ],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SmallCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width * 0.8, 0);
    path.lineTo(size.width * 0.4, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class LargeCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width, size.height);
    path.lineTo(size.width * 0.15, size.height);
    path.lineTo(size.width * 0.25, 0);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

///////////////////////////////
// Progress Card with Indicator
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
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 32.0,
              offset: Offset(0, 2.0),
            ),
          ],
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
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
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

////////////////////
// Measurement Cards
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
