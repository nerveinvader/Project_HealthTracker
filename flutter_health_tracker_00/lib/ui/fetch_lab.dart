// Description: Fetch Lab Type
// User
// Fetch the latest entry from DataBase for this patient, or null if none found.

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../data/local/app_db.dart';

// Fetch latest lab entry for a type of lab.
Future<LabEntry?> fetchLatestLab(String patientId, String labType) async {
final appDB = AppDatabase();
	try {
		final query = appDB.select(appDB.labEntries)
			..where((t) => t.patientId.equals(patientId))
			..where((t) => t.type.equals(labType))
			..orderBy([(t) => OrderingTerm.desc(t.date)])
			..limit(1);

		final rows = await query.get();
		return rows.isEmpty ? null : rows.first;
	} catch (e, st) {
		debugPrint('latestForType error: $e\n$st');
		return null;
	}
}
