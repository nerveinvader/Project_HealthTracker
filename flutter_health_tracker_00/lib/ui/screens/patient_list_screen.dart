// Description: Patient List Screen
// Admin Page
// Lists of all patients in the DB and navigates to the patient form screen
// to add or edit patients

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_health_tracker_00/ui/screens/patient_detail_screen.dart';
import 'medication_list_screen.dart';
import 'patient_form_screen.dart';
import '../../data/local/app_db.dart';

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
    _loadPatients();
  }

  // Load patients from the database
  void _loadPatients() {
    setState(() {
      _patientsFuture = db.select(db.patients).get();
    });
  }

  // Show popup options to choose action for a patient
  Future<void> _showPatientAction(Patient p) async {
    final navContext = context;
    final choice = await showModalBottomSheet<String>(
      context: navContext,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.biotech),
                title: Text(AppLocalizations.of(navContext)!.viewLabs),
                onTap: () => Navigator.pop(navContext, 'labs'),
              ),
              ListTile(
                leading: const Icon(Icons.medication),
                title: Text(AppLocalizations.of(navContext)!.viewMeds),
                onTap: () => Navigator.pop(navContext, 'meds'),
              ),
              ListTile(
                leading: const Icon(Icons.more_horiz),
                title: Text(AppLocalizations.of(navContext)!.other),
                onTap: () => Navigator.pop(navContext, 'other'),
              ),
            ],
          ));
      });
    if (choice == null) return; // User canceled the action
    if (choice == 'labs') {
      if (!navContext.mounted) return;
      await Navigator.push(
        navContext,
        MaterialPageRoute(builder: (_) => PatientDetailScreen(patient: p),
        ),
      );
    } else if (choice == 'meds') {
      if (!navContext.mounted) return;
      await Navigator.push(
        navContext,
        MaterialPageRoute(builder: (_) => MedicationListScreen(patientId: p.id),
        ),
      );
    } else if (choice == 'others') {
      // TODO OTHER STUFF
    }
  }


  // Delete a patient after confirmation
  Future<void> _deletePatient(BuildContext context, Patient patient) async {
    // Capture context
    final navContext = context;

    final confirm = await showDialog<bool>(
      context: navContext,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(navContext)!.editPatient),
        content: Text(AppLocalizations.of(navContext)!.confirmDeletePatient),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(navContext).pop(false),
            child: Text(AppLocalizations.of(navContext)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(navContext).pop(true),
            child: Text(AppLocalizations.of(navContext)!.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await (db.delete(db.patients)
          ..where((t) => t.id.equals(patient.id)))
          .go(); // Delete the patient from the database
      if (!navContext.mounted) return; // Check if the widget is still mounted
      _loadPatients(); // Refresh the list after deletion
      ScaffoldMessenger.of(navContext).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(navContext)!.patientDeleted))
      );
    }
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
          // ListView with dismissible to enable swipe to delete
          return ListView.builder(
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final p = patients[index];
              return ListTile(
                title: Text(p.name),
                subtitle: Text(p.location),
                onTap: () => _showPatientAction(p),
                onLongPress: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PatientFormScreen(patient: p),
                    ),
                  );
                  if (mounted) _loadPatients();
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deletePatient(context, p) /* () async {
                    await db.delete(db.patients).delete(p);
                    _loadPatients();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context)!.patientDeleted))
                      );
                    }
                  },*/
                ),
              );
            },
          );
        },
      ),
      // FAB to Add new patients
      floatingActionButton: FloatingActionButton (
        onPressed: () async {
          // Navigate to empty form to add a new patient
          final navContext = context;
          await Navigator.push(
            navContext,
            MaterialPageRoute (
              builder: (_) => const PatientFormScreen(),
            ),
          );
          if (mounted) _loadPatients();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
