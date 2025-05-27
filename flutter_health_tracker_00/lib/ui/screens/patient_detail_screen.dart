// Description: Patient Detail Screen
// Admin / User Page
// To display each individual/patient has a dedicated page for itself.

import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_health_tracker_00/ui/screens/patient_list_screen.dart';
import 'package:intl/intl.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../../data/local/app_db.dart';
import 'lab_entry_form_screen.dart';

/// Screen to view details and lab entries of a specific patient.
class PatientDetailScreen extends StatefulWidget {
  final Patient patient;
  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  late Future<List<LabEntry>> _labsFuture;

  @override
  void initState() {
    super.initState();
    _loadLabEntries();
  }

  /// Load lab entries for this patient, ordered by date desc.
  void _loadLabEntries() {
    setState(() {
      _labsFuture = (db.select(db.labEntries)
            ..where((tbl) => tbl.patientId.equals(widget.patient.id))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();
    });
  }

  /// Delete a lab entry and refresh the list.
  Future<void> _deleteLabEntry(BuildContext context, LabEntry entry) async {
    final navContext = context;
    final confirmed = await showDialog<bool>(
      context: navContext,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(navContext)!.delete),
        content: Text(AppLocalizations.of(navContext)!.confirmDeleteLab),
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
    if (confirmed == true) {
      await db.delete(db.labEntries).delete(entry);
      if (!navContext.mounted) return;
      _loadLabEntries();
      ScaffoldMessenger.of(navContext).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(navContext)!.labDeleted)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.patient;
    //final formattedDate = Jalali.fromDateTime(p.dateOfBirth); // Jalali format
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.viewLabs), /// CHANGE THIS TO (labsTitle)
      ),
      body: FutureBuilder<List<LabEntry>>(
        future: _labsFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: \${snap.error}'));
          }
          final labs = snap.data!;
          if (labs.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)!.noLabEntries));
          }
          return ListView.builder(
            itemCount: labs.length,
            itemBuilder: (context, i) {
              final lab = labs[i];
              return Dismissible(
                key: ValueKey(lab.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Theme.of(context).colorScheme.secondary,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => _deleteLabEntry(context, lab),
                child: ListTile(
                  title: Text('${lab.type}: ${lab.value}'),
                  subtitle: Text(DateFormat.yMMMd('fa').format(lab.date)),
                  onTap: () async {
                    final navContext = context;
                    await Navigator.push(
                      navContext,
                      MaterialPageRoute(
                        builder: (_) => LabEntryFormScreen(
                          patientId: widget.patient.id,
                          entry: lab,
                        ),
                      ),
                    );
                    if (mounted) _loadLabEntries();
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final navContext = context;
          await Navigator.push(
            navContext,
            MaterialPageRoute(
              builder: (_) => LabEntryFormScreen(
                patientId: widget.patient.id,
              ),
            ),
          );
          if (mounted) _loadLabEntries();
        },
        child: const Icon(Icons.add_chart),
      ),
    );
  }
}
