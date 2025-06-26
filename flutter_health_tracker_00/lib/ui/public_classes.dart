// Description: Public Classes
// Code
// Put public class that are used a lot, in this file for easier access

import 'package:flutter/material.dart';
import 'package:flutter_health_tracker_00/l10n/app_localizations.dart';

import 'package:flutter_health_tracker_00/ui/screens/lab_entry_form_screen.dart';
import 'package:flutter_health_tracker_00/ui/screens/medication_form_screen.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

////////////////////////////
// Normalize Persian Numbers
String normalizeNumber(String input) {
  const persianNums = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  const englishNums = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  for (var i = 0; i < persianNums.length; i++) {
    input = input.replaceAll(persianNums[i], englishNums[i]);
  }
  return input;
}

/////////////////////////////
// Persianize English Numbers
String persianizeNumber(String input) {
  const persianNums = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  const englishNums = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  for (var i = 0; i < persianNums.length; i++) {
    input = input.replaceAll(englishNums[i], persianNums[i]);
  }
  return input;
}

// Shows adding options (Lab, Med) when (+) button is pressed.
class ShowAddOptions {
  const ShowAddOptions._();

  static Future<void> show(
    BuildContext context, {
    required String patientId,
  }) async {
    if (!context.mounted) return;
    try {
      final choice = await showModalBottomSheet<String>(
        context: context,
        builder:
            (bottomsheetContext) => SafeArea(
              child: Wrap(
                children: [
                  ListTile(
                    leading: const Icon(Icons.biotech),
                    title: Text(AppLocalizations.of(context)!.addLabEntry),
                    onTap: () => Navigator.pop(bottomsheetContext, 'lab'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.medication),
                    title: Text(AppLocalizations.of(context)!.medAdd),
                    onTap: () => Navigator.pop(bottomsheetContext, 'med'),
                  ),
                ],
              ),
            ),
      );
      if (!context.mounted || choice == null) return;
      switch (choice) {
        case 'lab':
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LabEntryFormScreen(patientId: patientId),
            ),
          );
          break;
        case 'med':
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MedicationFormScreen(patientId: patientId),
            ),
          );
          break;
      }
    } catch (e, st) {
      debugPrint(st.toString());
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorPlaceholder),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

// Utility call to make DateTime in Jalali format
String formatJalali(DateTime g) {
  final j = Jalali.fromDateTime(g);
  final f = j.formatter;
  return '${f.d} ${f.mN} ${f.yyyy}';
}

//* New Functions for Future
// FittedBox() to fit the text on the screen
// Wrap() to wrap elements
// SnackBarBehavior.floating for floating snackbar (visualy better)
// LayoutBuilder() for bigger screens
// LongPressDraggable() well, drag anything anywhere
// SelectableText() the text can be selected
// ShaderMask() for gradient text
// ListView for Lazyloading the widgets (instead of SignleChildScrollView)
// .adaptive for Android iOS adaptation of the widgets
