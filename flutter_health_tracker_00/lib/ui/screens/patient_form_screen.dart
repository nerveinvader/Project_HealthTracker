// Description: Patient Form Screen
// Admin Page
// Form to create or update a patient record in the DB

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_health_tracker_00/ui/screens/patient_list_screen.dart';
import 'package:intl/intl.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
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
  Jalali? _selectedJalali;
  DateTime? _selectedDob;

  String _normalizeNumber(String input) {
  const persianNums = ['۰','۱','۲','۳','۴','۵','۶','۷','۸','۹'];
  const englishNums = ['0','1','2','3','4','5','6','7','8','9'];
  for (var i = 0; i < persianNums.length; i++) {
    input = input.replaceAll(persianNums[i], englishNums[i]);
  }
  return input;
}

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
      // Date Picker Jalali and Georgian
      final existing = widget.patient!.dateOfBirth;
      _selectedJalali = Jalali.fromDateTime(existing);
      _selectedDob = existing;
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

  // Persian Date of Birth Picker
  Future<void> _pickDob() async {
    Jalali? picked = await showPersianDatePicker(
      context: context,
      locale: const Locale('fa', 'IR'),
      initialDate: Jalali.now(),
      firstDate: Jalali(1300, 1),
      lastDate: Jalali.now(),
      initialEntryMode: PersianDatePickerEntryMode.calendarOnly,
      initialDatePickerMode: PersianDatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        _selectedJalali = picked;
        _selectedDob = picked.toDateTime(); // Dart time for storage
      });
    }
  }

  Future<void> _savePatient() async {
    if (!_formkey.currentState!.validate() || _selectedDob == null) return;
    final navContext = context;
    final heightText = _normalizeNumber(_heightController.text);
    final weightText = _normalizeNumber(_weightController.text);
    final comp = PatientsCompanion(
      id:widget.patient?.id != null ? Value(widget.patient!.id) : Value.absent(),
      name: Value(_nameController.text),
      location: Value(_locController.text),
      dateOfBirth: Value(_selectedDob!),
      height: Value(double.parse(heightText)),
      weight: Value(double.parse(weightText)),
    );
    // Insert or Update based on the presence of widget.patient
    if (widget.patient == null) {
      await db.into(db.patients).insert(comp);
    } else {
      await db.update(db.patients).replace(comp);
    }
    if (!navContext.mounted) return;
    Navigator.pop(navContext);
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
              // Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.patientName,
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              // Location field
              TextFormField(
                controller: _locController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.location,
                ),
              ),
              const SizedBox(height: 8),
              // Date of Birth field (JALALI)
              ListTile(
                title: Text(_selectedJalali == null
                  ? AppLocalizations.of(context)!.selectDob
                  : _selectedJalali!.formatFullDate()
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDob,
              ),
              // Height field
              TextFormField(
                controller: _heightController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.heightCm,
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              // Weight Field
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.weightKg,
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              // Gender Picker
              // Save Button
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
