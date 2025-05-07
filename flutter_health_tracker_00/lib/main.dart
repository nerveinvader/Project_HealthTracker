import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'ui/screens/login_screen.dart';
import 'ui/screens/otp_screen.dart';
//import 'ui/screens/patients_screen.dart';

void main() async {
  await dotenv.load(); // load the .env file
  runApp(const HealthTracker());
}

class HealthTracker extends StatelessWidget {
  const HealthTracker({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Tracker',
      theme: ThemeData(
        primaryColor: const Color(0xFF2A9DF4),
        scaffoldBackgroundColor: const Color(0xFFD0EFFF),
        fontFamily: 'Helvetica',
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFFD8315B),
        ),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('fa'), // Set the default locale to Persian (fa)
      // Routes Map
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/otp': (context) => const OtpScreen(phone: ''),
        //'/patients': (context) => const PatientScreen(),
      },
    );
  }
}
