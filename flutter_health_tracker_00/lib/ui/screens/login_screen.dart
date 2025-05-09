// Description: Login Screen
// User Page
// The first page to register on the DB.

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../data/remote/sms_service.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _sms = SmsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.loginPhone)),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(controller: _phoneController, keyboardType: TextInputType.phone),
              const SizedBox(height: 16.0),
              ElevatedButton(onPressed: () async {
                final phone = _phoneController.text;
                final navContext = context;
                await _sms.sendOtp(phone);
                if (!mounted) return;
                if (dotenv.env['SMS_API_KEY'] == null) {
                  Navigator.pushReplacementNamed(
                    navContext,
                    '/patients'
                  );
                } else {
                  Navigator.push(
                    navContext,
                    MaterialPageRoute(builder: (_) => OtpScreen(phone: phone))
                  );
                }
              },
              child: Text(AppLocalizations.of(context)!.loginSend),
              ),
            ],
          ),
        ),
      );
  }
}
