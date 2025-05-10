// Description: Lab Entry Form
// Admin and User Page
// To add or edit lab results for a patient.

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_health_tracker_00/ui/screens/patient_list_screen.dart';
import 'package:intl/intl.dart';
import '../../data/local/app_db.dart';

const List<String> labTypes = [
  'HbA1c', 'FBS', '2HPP', 'Cholesterol', 'HDL', 'LDL', 'TG', 'SBP', 'DBP'
];

class LabEntryFormScreen extends StatefulWidget {
  final String patientId;
  final LabEntry? entry;
  const LabEntryFormScreen({super.key, required this.patientId, this.entry});

  @override
  State<LabEntryFormScreen> createState() => _LabEntryFormScreenState();
}

class _LabEntryFormScreenState extends State<LabEntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _date = DateTime.now();
  String _type = labTypes.first;
  final _valueCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _date = widget.entry!.date;
      _type = widget.entry!.type;
      _valueCtl.text = widget.entry!.value.toString();
    }
  }

  @override
  void dispose() {
    _valueCtl.dispose();
    super.dispose();
  }

  /// Show date picker and update [_date]
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  /// Validate form and save or update the LabEntry
  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;
    final navContext = context; // capture before async
    final comp = LabEntriesCompanion(
      id: widget.entry != null ? Value(widget.entry!.id) : const Value.absent(),
      patientId: Value(widget.patientId),
      date: Value(_date),
      type: Value(_type),
      value: Value(double.parse(_valueCtl.text)),
    );
    if (widget.entry == null) {
      await db.into(db.labEntries).insert(comp);
    } else {
      await db.update(db.labEntries).replace(comp);
    }
    if (!navContext.mounted) return;
    Navigator.pop(navContext);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null
            ? AppLocalizations.of(context)!.addLabEntry
            : AppLocalizations.of(context)!.editLabEntry),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Date picker
              ListTile(
                title: Text(DateFormat.yMMMd('fa').format(_date)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              // Lab type dropdown
              DropdownButtonFormField<String>(
                value: _type,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.labType,
                ),
                items: labTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
              // Value input
              TextFormField(
                controller: _valueCtl,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.labValue,
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty
                    ? AppLocalizations.of(context)!.fieldRequired
                    : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveEntry,
                child: Text(AppLocalizations.of(context)!.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
