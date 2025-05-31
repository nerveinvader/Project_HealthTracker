// Description: Medication List
// Admin and User Page
// Lists all the medication for a patient and navigates to the medication form screen
// to add or edit medications

import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_health_tracker_00/ui/screens/patient_list_screen.dart';
import 'medication_form_screen.dart';
import '../../data/local/app_db.dart';

class MedicationListScreen extends StatefulWidget {
  final String patientId;
  const MedicationListScreen({super.key, required this.patientId});

  @override
  State<MedicationListScreen> createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen> {
  late Future<List<MedicationEntry>> _medsFuture;

  @override
  void initState() {
    super.initState();
    _loadMeds();
  }

  void _loadMeds() {
    setState(() {
      _medsFuture = (db.select(db.medicationEntries)
            ..where((tbl) => tbl.patientId.equals(widget.patientId)))
          .get();
    });
  }

  Future<void> _deleteMed(BuildContext context, MedicationEntry med) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.delete),
        content: Text(AppLocalizations.of(context)!.confirmDeleteMed),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await db.delete(db.medicationEntries).delete(med);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.medDeleted)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.medicationTitle),
      ),
      body: FutureBuilder<List<MedicationEntry>>(
        future: _medsFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text("Error: \${snap.error}"));
          }
          final meds = snap.data!;
          if (meds.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)!.medNone));
          }
          return ListView.builder(
            itemCount: meds.length,
            itemBuilder: (context, i) {
              final m = meds[i];
              return Dismissible(
                key: ValueKey(m.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Theme.of(context).colorScheme.secondary,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => _deleteMed(context, m),
                child: ListTile(
                  title: Text(m.name),
                  subtitle: Text('${m.dosage} ${m.frequency ?? ''}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MedicationFormScreen(
                            patientId: widget.patientId,
                            entry: m,
                          ),
                        ),
                      );
                      if (mounted) _loadMeds();
                    }
                  ),
                ),
              );
            }
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MedicationFormScreen(patientId: widget.patientId),
            ),
          );
          if (mounted) _loadMeds();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
