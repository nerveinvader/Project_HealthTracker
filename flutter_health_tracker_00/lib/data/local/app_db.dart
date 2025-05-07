import 'package:drift/drift.dart';
import 'package:drift/native.dart'; // To use native SQLite database
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'app_db.g.dart'; // Generated code will be in app_db.g.dart

class Patients extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())(); // Patient ID
  TextColumn get name => text().withLength(min: 1, max: 50)(); // Patient Name
  TextColumn get location => text().withLength(min: 1, max: 100)(); // Patient Location
  DateTimeColumn get dateOfBirth => dateTime()(); // Patient Date of Birth
  RealColumn get height => real()(); // Patient Height
  RealColumn get weight => real()(); // Patient Weight
}

class LabEntries extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())(); // Lab Entry ID
  TextColumn get patientId => text().customConstraint('REFERENCES patients(id) NOT NULL')(); // Patient ID
  DateTimeColumn get date => dateTime()(); // Lab Entry Date
  TextColumn get type => text()(); // Labe Entry Type
  RealColumn get value => real()(); // Lab Entry Value
}

@DriftDatabase(tables: [Patients, LabEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  @override int get schemaVersion => 1; // Increment this when you change your schema
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final docs = await getApplicationDocumentsDirectory();
    final file = File(p.join(docs.path, 'health_tracker.sqlite'));
    return NativeDatabase(file); // Use NativeDatabase for SQLite
  });
}
