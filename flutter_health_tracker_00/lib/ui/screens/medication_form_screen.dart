// Description: Medication Entry Form
// Admin and User Page
// To add or edit medications for a patient.


// DEBUG
// Problem Updating Medication After Saving it Successfuly

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:flutter_health_tracker_00/ui/screens/patient_list_screen.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../../data/local/app_db.dart';

class MedicationFormScreen extends StatefulWidget {
  final String patientId;
  final MedicationEntry? entry;
  const MedicationFormScreen({super.key, required this.patientId, this.entry});

  @override
  State<MedicationFormScreen> createState() => _MedicationFormScreenState();
}

class _MedicationFormScreenState extends State<MedicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _dosageCtl = TextEditingController();
  final _freqCtl = TextEditingController();
  DateTime _start = DateTime.now();
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      final e = widget.entry!;
      _nameCtl.text = e.name;
      _dosageCtl.text = e.dosage.toString();
      _freqCtl.text = e.frequency ?? '';
      _start = e.start ?? DateTime.now();
      _end = e.end;
    }
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _dosageCtl.dispose();
    _freqCtl.dispose();
    super.dispose();
  }

  // Change/Normalize Persian numbers to English numbers
  String _normalizeNumber(String input) {
  const persianNums = ['۰','۱','۲','۳','۴','۵','۶','۷','۸','۹'];
  const englishNums = ['0','1','2','3','4','5','6','7','8','9'];
  for (var i = 0; i < persianNums.length; i++) {
    input = input.replaceAll(persianNums[i], englishNums[i]);
  }
  return input;
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart
        ? Jalali.fromDateTime(_start) : (_end != null ? Jalali.fromDateTime(_end!)
        : Jalali.now());
    final picked = await showPersianDatePicker(
      context: context,
      initialDate: initial,
      firstDate: Jalali(1300, 1),
      lastDate: Jalali.now(),
      locale: const Locale('fa', 'IR'),
      textDirection: TextDirection.rtl,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
            _start = picked.toDateTime();
        } else {
            _end = picked.toDateTime();
        }
      });
    }
  }

  Future<void> _saveMed() async {
    debugPrint('_saveMed Called');
    if (!_formKey.currentState!.validate()) {
        debugPrint('_saveMed no Valid');
        return;
    }
    // Parse dosage string to double if provided
    double? dosageValue;
    if (_dosageCtl.text.isNotEmpty) {
        final txt = _normalizeNumber(_dosageCtl.text);
        dosageValue = double.tryParse(txt);
        if (dosageValue == null) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.invalidDosage))
            );
            return;
        }
    }
    final navContext = context;
    final comp = MedicationEntriesCompanion(
      id: widget.entry != null
        ? Value(widget.entry!.id)
        : const Value.absent(),
      patientId: Value(widget.patientId),
      name: Value(_nameCtl.text),
      dosage: dosageValue != null
        ? Value(dosageValue)
        : const Value.absent(),
      frequency: Value(_freqCtl.text.isNotEmpty ? _freqCtl.text : null),
      start: Value(_start),
      end: _end != null
        ? Value(_end)
        : const Value.absent(),
    );
    if (widget.entry == null) {
      await db.into(db.medicationEntries).insert(comp);
    } else {
      await db.update(db.medicationEntries).replace(comp);
    }
    if (!navContext.mounted) return;
    Navigator.pop(navContext);
  }

  @override
  Widget build(BuildContext context) {
    final locOpt = AppLocalizations.of(context)!;
    final freqOptions = <String>[
    locOpt.q24hr,
    locOpt.q12hr,
    locOpt.q8hr,
    locOpt.q6hr,
    locOpt.q4hr,
  ];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null
            ? AppLocalizations.of(context)!.medAdd
            : AppLocalizations.of(context)!.medEdit),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtl,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.medication),
                validator: (v) => v == null || v.isEmpty
                    ? AppLocalizations.of(context)!.fieldRequired
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dosageCtl,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.medDosage),
                    keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField(
                value: _freqCtl.text.isNotEmpty
                    ? _freqCtl.text
                    : freqOptions.first,
                decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.medFrequency),
                items: freqOptions
                    .map((f) => DropdownMenuItem(
                        value: f,
                        child: Text(f)))
                    .toList(),
                onChanged: (v) {
                    setState(() {
                      _freqCtl.text = v!;
                    });
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                title: Text(Jalali.fromDateTime(_start).formatCompactDate()),
                subtitle: Text(AppLocalizations.of(context)!.medStart),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(isStart: true),
              ),
              ListTile(
                title: Text(_end != null
                    ? Jalali.fromDateTime(_end!).formatCompactDate()
                    : AppLocalizations.of(context)!.selectEndDate),
                subtitle: Text(AppLocalizations.of(context)!.medEnd),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(isStart: false),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveMed,
                child: Text(AppLocalizations.of(context)!.save)),
            ],
          ),
        ),
      ),
    );
  }
}
