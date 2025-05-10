// Description: OTP Screen
// User Page
// The page to get OTP code and verify it, to register the user.

import 'package:flutter/material.dart';
import '../../data/remote/sms_service.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({required this.phone, super.key});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _codeController = TextEditingController();
  final _sms = SmsService();

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _codeController, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final code = _codeController.text;
                final navContext = context;
                final messengerContext = context;

                final isValid = await _sms.verifyOtp(widget.phone, code);
                if (!navContext.mounted) return;
                if (isValid) {
                  Navigator.pushReplacementNamed(
                    navContext,
                    '/patients'
                  );
                } else {
                  ScaffoldMessenger.of(messengerContext).showSnackBar(
                    const SnackBar(content: Text('Invalid code'))
                  );
                }
              },
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
