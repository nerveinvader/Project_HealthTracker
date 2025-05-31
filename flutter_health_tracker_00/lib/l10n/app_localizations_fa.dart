// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'ردیابی سلامت';

  @override
  String get loginPhone => 'شماره تلفن را وارد کنید';

  @override
  String get loginSend => 'ارسال کد تایید';

  @override
  String get patientsTitle => 'بیماران';

  @override
  String get noPatients => 'هیچ بیماری ثبت نشده';

  @override
  String get patientName => 'نام';

  @override
  String get location => 'محل زندگی';

  @override
  String get selectDob => 'انتخاب تاریخ تولد';

  @override
  String get heightCm => 'قد (سانتی متر)';

  @override
  String get weightKg => 'وزن (کلیوگرم)';

  @override
  String get addPatient => 'افزودن بیمار';

  @override
  String get editPatient => 'ویرایش بیمار';

  @override
  String get save => 'ذخیره';

  @override
  String get cancel => 'انصراف';

  @override
  String get delete => 'حذف';

  @override
  String get patientDeleted => 'بیمار حذف شد';

  @override
  String get confirmDeletePatient => 'آیا مطمئن هستید که می خواهید این بیمار را حذف کنید؟';

  @override
  String get fieldRequired => 'این فیلد الزامی است';

  @override
  String get labTitle => 'آزمایشات';

  @override
  String get labDeleted => 'آزمایش حذف شد';

  @override
  String get noLabEntries => 'آزمایشی پیدا نشد';

  @override
  String get confirmDeleteLab => 'آیا مطمئن هستید که می خواهید این آزمایش را حذف کنید؟';

  @override
  String get addLabEntry => 'آزمایش را وارد کنید';

  @override
  String get editLabEntry => 'آزمایش را ویرایش کنید';

  @override
  String get labDate => 'تاریخ آزمایش';

  @override
  String get labType => 'نوع آزمایش';

  @override
  String get labValue => 'نتیجه آزمایش';

  @override
  String get viewLabs => 'دیدن آزمایشات';

  @override
  String get medicationTitle => 'داروها';

  @override
  String get medNone => 'دارویی وجود ندارد';

  @override
  String get medAdd => 'دارو را اضافه کنید';

  @override
  String get medEdit => 'دارو را ویرایش کنید';

  @override
  String get medication => 'نام دارو';

  @override
  String get medDosage => ' دوز دارو به میلی گرم';

  @override
  String get invalidDosage => 'دوز اشتباه';

  @override
  String get medFrequency => 'تواتر دارو';

  @override
  String get medStart => 'تاریخ شروع دارو';

  @override
  String get medEnd => 'تاریخ پایان دارو';

  @override
  String get selectEndDate => 'روز پایان را انتخاب کنید';

  @override
  String get confirmDeleteMed => 'آیا مطمئن هستید که می خواهید این دارو را حذف کنید؟';

  @override
  String get medDeleted => 'دارو حذف شد';

  @override
  String get viewMeds => 'دیدن داروها';

  @override
  String get q24hr => 'روزانه';

  @override
  String get q12hr => 'هر 12 ساعت';

  @override
  String get q8hr => 'هر 8 ساعت';

  @override
  String get q6hr => 'هر 6 ساعت';

  @override
  String get q4hr => 'هر 4 ساعت';

  @override
  String get chartTitle => 'نمودار';

  @override
  String get chartLast7 => '7 روز گذشته';

  @override
  String get chartLast14 => '14 روز گذشته';

  @override
  String get chartLast30 => 'ماه گدشته';

  @override
  String get chartLast90 => '3 ماه گذشته';

  @override
  String get chartNoData => 'اطلاعاتی برای نمایش وجود ندارد';

  @override
  String get errorLoadingdata => 'خطای بارگذاری اطلاعات';

  @override
  String get errorPlaceholder => 'Error: Placeholder';

  @override
  String get uiuiui => 'PATIENT_UI';

  @override
  String get uiGreeting => 'سلام ';

  @override
  String get uiWeeklyProgress => 'امتیاز هفتگی سلامت شما';

  @override
  String get uiLastBP => 'آخرین فشار خون';

  @override
  String get uiLastFBS => 'آخرین قند خون';

  @override
  String get uiLastChol => 'آخرین کلسترول';

  @override
  String get uiLearnHTN => 'بیشتر درباره فشار خون بدانیم';

  @override
  String get uiLearnDM => 'بیشتر درباره دیابت بدانیم';

  @override
  String get uiLearnHLP => 'بیشتر درباره چربی خون بدانیم';

  @override
  String get uiProfile => 'پروفایل';

  @override
  String get uiAdd => 'افزودن';

  @override
  String get uiHTN => 'فشار خون';

  @override
  String get uiDM => 'دیابت';

  @override
  String get uiHLP => 'چربی خون';

  @override
  String get other => 'دیگر';
}
