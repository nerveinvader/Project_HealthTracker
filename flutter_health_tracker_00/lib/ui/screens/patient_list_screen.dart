// Description: Patient List Screen
// Lists all patients in the DB and navigates to the patient form screen
// to add or edit patients

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_health_tracker_00/ui/screens/patient_screen.dart';
import '../../data/local/app_db.dart';
import 'patient_form_screen.dart';

final AppDatabase db = AppDatabase(); // Initialize the database

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  late Future<List<Patient>> _patientsFuture;

  @override
  void initState() {
    super.initState();
    // Fetch patients from the database
    _patientsFuture = db.select(db.patients).get();
  }

  // Refresh the patient list
  void _refreshList() {
    setState(() {
      _patientsFuture = db.select(db.patients).get();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.patientsTitle),
      ),
      body: FutureBuilder<List<Patient>>(
        future: _patientsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: \${snapshot.error}'));
          }
          final patients = snapshot.data!;
          if (patients.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)!.noPatients));
          }
          return ListView.builder(
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final p = patients[index];
              return ListTile(
                title: Text(p.name),
                subtitle: Text(p.location),
                onTap: () async {
                  // Navigate to form in edit mode and refresh afterward
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PatientFormScreen(patient: p),
                    ),
                  );
                  _refreshList();
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton (
        onPressed: () async {
          // Navigate to empty form to add a new patient
          await Navigator.push(
            context,
            MaterialPageRoute (
              builder: (_) => const PatientFormScreen(),
            ),
          );
          _refreshList();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
