import 'package:flutter/material.dart';
import 'package:flutter_health_tracker_00/ui/screens/patient_list_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

import 'ui/screens/login_screen.dart';
import 'ui/screens/otp_screen.dart';
import 'ui/screens/patient_home_screen.dart';

void main() async {
  await dotenv.load(); // load the .env file
  runApp(const HealthTracker());
}

class HealthTracker extends StatelessWidget {
  const HealthTracker({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Theme Data
    final primary = const Color.fromARGB(255, 113, 116, 187);
    final secondary = const Color(0xFFEE74B1);
    final bgLight = const Color(0xFFFFD4EB);
    final surfaceColor = const Color(0xFFFFFFFF);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Health Tracker',
      theme: ThemeData(
        primaryColor: primary,
        scaffoldBackgroundColor: surfaceColor,
        fontFamily: 'Vazir',
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: primary,
          secondary: secondary,
          surface: surfaceColor,
        ),
        // Default Card Styles
        cardTheme: CardTheme(
          color: bgLight,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        // Default Text Styles
        //textTheme: TextTheme(),
        // Default Button Shape
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('fa', 'IR'), // Set the default locale to Persian (fa)
      localizationsDelegates: const [
        PersianMaterialLocalizations.delegate,
        PersianCupertinoLocalizations.delegate,
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Routes Maps
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/otp': (context) => const OtpScreen(phone: ''),
        '/patients': (context) => const PatientListScreen(),
        '/patientHome': (context) => const PatientHomeScreen(patientId: '',),
      },
    );
  }
}
