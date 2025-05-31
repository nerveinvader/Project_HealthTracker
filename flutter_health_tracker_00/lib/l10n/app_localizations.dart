import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fa')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Tracker'**
  String get appTitle;

  /// No description provided for @loginPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter Phone Number'**
  String get loginPhone;

  /// No description provided for @loginSend.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get loginSend;

  /// No description provided for @patientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get patientsTitle;

  /// No description provided for @noPatients.
  ///
  /// In en, this message translates to:
  /// **'No patients yet'**
  String get noPatients;

  /// No description provided for @patientName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get patientName;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @selectDob.
  ///
  /// In en, this message translates to:
  /// **'Select Date of Birth'**
  String get selectDob;

  /// No description provided for @heightCm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightCm;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKg;

  /// No description provided for @addPatient.
  ///
  /// In en, this message translates to:
  /// **'Add Patient'**
  String get addPatient;

  /// No description provided for @editPatient.
  ///
  /// In en, this message translates to:
  /// **'Edit Patient'**
  String get editPatient;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @patientDeleted.
  ///
  /// In en, this message translates to:
  /// **'Patient deleted!'**
  String get patientDeleted;

  /// No description provided for @confirmDeletePatient.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this patient?'**
  String get confirmDeletePatient;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @labTitle.
  ///
  /// In en, this message translates to:
  /// **'Lab Results'**
  String get labTitle;

  /// No description provided for @labDeleted.
  ///
  /// In en, this message translates to:
  /// **'Lab Deleted'**
  String get labDeleted;

  /// No description provided for @noLabEntries.
  ///
  /// In en, this message translates to:
  /// **'No Lab Entry'**
  String get noLabEntries;

  /// No description provided for @confirmDeleteLab.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this lab entry?'**
  String get confirmDeleteLab;

  /// No description provided for @addLabEntry.
  ///
  /// In en, this message translates to:
  /// **'Add a Lab Entry'**
  String get addLabEntry;

  /// No description provided for @editLabEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit a Lab Entry'**
  String get editLabEntry;

  /// No description provided for @labDate.
  ///
  /// In en, this message translates to:
  /// **'Date of Lab'**
  String get labDate;

  /// No description provided for @labType.
  ///
  /// In en, this message translates to:
  /// **'Type of Lab'**
  String get labType;

  /// No description provided for @labValue.
  ///
  /// In en, this message translates to:
  /// **'Result of Lab'**
  String get labValue;

  /// No description provided for @viewLabs.
  ///
  /// In en, this message translates to:
  /// **'View Labs'**
  String get viewLabs;

  /// No description provided for @medicationTitle.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medicationTitle;

  /// No description provided for @medNone.
  ///
  /// In en, this message translates to:
  /// **'No Medicaitons'**
  String get medNone;

  /// No description provided for @medAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Medication'**
  String get medAdd;

  /// No description provided for @medEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Medication'**
  String get medEdit;

  /// No description provided for @medication.
  ///
  /// In en, this message translates to:
  /// **'Medication Name'**
  String get medication;

  /// No description provided for @medDosage.
  ///
  /// In en, this message translates to:
  /// **'Medication Dosage (mg)'**
  String get medDosage;

  /// No description provided for @invalidDosage.
  ///
  /// In en, this message translates to:
  /// **'Invalid Dosage'**
  String get invalidDosage;

  /// No description provided for @medFrequency.
  ///
  /// In en, this message translates to:
  /// **'Medication Frequency'**
  String get medFrequency;

  /// No description provided for @medStart.
  ///
  /// In en, this message translates to:
  /// **'Medication Start Date'**
  String get medStart;

  /// No description provided for @medEnd.
  ///
  /// In en, this message translates to:
  /// **'Medication End Date'**
  String get medEnd;

  /// No description provided for @selectEndDate.
  ///
  /// In en, this message translates to:
  /// **'Select End Date'**
  String get selectEndDate;

  /// No description provided for @confirmDeleteMed.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this medication?'**
  String get confirmDeleteMed;

  /// No description provided for @medDeleted.
  ///
  /// In en, this message translates to:
  /// **'Medication Deleted'**
  String get medDeleted;

  /// No description provided for @viewMeds.
  ///
  /// In en, this message translates to:
  /// **'View Medications'**
  String get viewMeds;

  /// No description provided for @q24hr.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get q24hr;

  /// No description provided for @q12hr.
  ///
  /// In en, this message translates to:
  /// **'Every 12h'**
  String get q12hr;

  /// No description provided for @q8hr.
  ///
  /// In en, this message translates to:
  /// **'Every 8h'**
  String get q8hr;

  /// No description provided for @q6hr.
  ///
  /// In en, this message translates to:
  /// **'Every 6h'**
  String get q6hr;

  /// No description provided for @q4hr.
  ///
  /// In en, this message translates to:
  /// **'Every 4h'**
  String get q4hr;

  /// No description provided for @chartTitle.
  ///
  /// In en, this message translates to:
  /// **'Charts'**
  String get chartTitle;

  /// No description provided for @chartLast7.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get chartLast7;

  /// No description provided for @chartLast14.
  ///
  /// In en, this message translates to:
  /// **'Last 14 Days'**
  String get chartLast14;

  /// No description provided for @chartLast30.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get chartLast30;

  /// No description provided for @chartLast90.
  ///
  /// In en, this message translates to:
  /// **'Last 3 Months'**
  String get chartLast90;

  /// No description provided for @chartNoData.
  ///
  /// In en, this message translates to:
  /// **'No Data for Charts'**
  String get chartNoData;

  /// No description provided for @errorLoadingdata.
  ///
  /// In en, this message translates to:
  /// **'Error on Loading Data'**
  String get errorLoadingdata;

  /// No description provided for @errorPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Error: Placeholder'**
  String get errorPlaceholder;

  /// No description provided for @uiuiui.
  ///
  /// In en, this message translates to:
  /// **'PATIENT_UI'**
  String get uiuiui;

  /// No description provided for @uiGreeting.
  ///
  /// In en, this message translates to:
  /// **'Greetings, '**
  String get uiGreeting;

  /// No description provided for @uiWeeklyProgress.
  ///
  /// In en, this message translates to:
  /// **'Weekly Rating of Your Health'**
  String get uiWeeklyProgress;

  /// No description provided for @uiLastBP.
  ///
  /// In en, this message translates to:
  /// **'Last Blood Pressure'**
  String get uiLastBP;

  /// No description provided for @uiLastFBS.
  ///
  /// In en, this message translates to:
  /// **'Last FBS'**
  String get uiLastFBS;

  /// No description provided for @uiLastChol.
  ///
  /// In en, this message translates to:
  /// **'Last Cholesterol'**
  String get uiLastChol;

  /// No description provided for @uiLearnHTN.
  ///
  /// In en, this message translates to:
  /// **'Learn more on Hypertension'**
  String get uiLearnHTN;

  /// No description provided for @uiLearnDM.
  ///
  /// In en, this message translates to:
  /// **'Learn more on Diabetes Mellitus'**
  String get uiLearnDM;

  /// No description provided for @uiLearnHLP.
  ///
  /// In en, this message translates to:
  /// **'Learn more on Hyperlipidemia'**
  String get uiLearnHLP;

  /// No description provided for @uiProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get uiProfile;

  /// No description provided for @uiAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get uiAdd;

  /// No description provided for @uiHTN.
  ///
  /// In en, this message translates to:
  /// **'Hypertention'**
  String get uiHTN;

  /// No description provided for @uiDM.
  ///
  /// In en, this message translates to:
  /// **'Diabetes Mellitus'**
  String get uiDM;

  /// No description provided for @uiHLP.
  ///
  /// In en, this message translates to:
  /// **'Hyperlipidemia'**
  String get uiHLP;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fa': return AppLocalizationsFa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
