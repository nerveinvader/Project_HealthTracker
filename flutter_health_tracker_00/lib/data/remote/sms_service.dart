import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SmsService {
  final _dio = Dio(BaseOptions(baseUrl: dotenv.env['SMS_API_URL']!));

  Future<void> sendOtp(String phoneNumber) async {
    final String _apiKey = dotenv.env['SMS_API_KEY']!;
    final response = await _dio.get('/v1/$_apiKey/sms/send.json', queryParameters: {
      'receptor': phoneNumber,
      'message': 'Your Health Tracker OTP code is: 123456', // Replace with actual OTP generation logic
    });
  // Parse Response and handle errors if needed
  }

  Future<bool> verifyOtp(String phoneNumber, String code) async {
    // stub: always return true for testing purposes
    return code == '123456';
  }
}
