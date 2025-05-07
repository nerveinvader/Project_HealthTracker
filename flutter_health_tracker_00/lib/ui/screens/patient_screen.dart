// Description: Patient Form Screen
// Form to create or update a patient record in the DB

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_health_tracker_00/ui/screens/patient_list_screen.dart';
import 'package:intl/intl.dart';
import '../../data/local/app_db.dart';

class PatientFormScreen extends StatefulWidget {
  final Patient? patient;
  const PatientFormScreen({super.key, this.patient});

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _formkey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  DateTime? _selectedDob;

  @override
  void initState() {
    super.initState();
    // If editing, prefill the fields of form
    if (widget.patient != null) {
      final p = widget.patient!;
      _nameController.text = p.name;
      _locController.text = p.location;
      _heightController.text = p.height.toString();
      _weightController.text = p.weight.toString();
      _selectedDob = p.dateOfBirth;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial = _selectedDob ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
      });
    }
  }

  Future<void> _savePatient() async {
    if (!_formkey.currentState!.validate() || _selectedDob == null) return;
    final comp = PatientsCompanion(
      id:widget.patient?.id != null ? Value(widget.patient!.id) : Value.absent(),
      name: Value(_nameController.text),
      location: Value(_locController.text),
      dateOfBirth: Value(_selectedDob!),
      height: Value(double.parse(_heightController.text)),
      weight: Value(double.parse(_weightController.text)),
    );
    // Insert or Update based on the presence of widget.patient
    if (widget.patient == null) {
      await db.into(db.patients).insert(comp);
    } else {
      await db.update(db.patients).replace(comp);
    }
    Navigator.pop(context);
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.patient == null
              ? AppLocalizations.of(context)!.addPatient
              : AppLocalizations.of(context)!.editPatient,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formkey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.patientName,
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.location,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                title: Text(_selectedDob == null
                    ? AppLocalizations.of(context)!.selectDob
                    : DateFormat.yMMMd('fa').format(_selectedDob!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDob,
              ),
              TextFormField(
                controller: _heightController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.heightCm,
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.weightKg,
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _savePatient,
                child: Text(AppLocalizations.of(context)!.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
