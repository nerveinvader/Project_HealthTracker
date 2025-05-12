// Description: Medication List
// Admin and User Page
// Lists all the medication for a patient and navigates to the medication form screen
// to add or edit medications

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

class MedicationListScreen extends StatefulWidget {
  final String patientId;
  const MedicationListScreen({super.key, required this.patientId});

  @override
  State<MedicationListScreen> createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
