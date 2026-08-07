import 'package:dio/dio.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';

class MailOtpService {
  MailOtpService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  Future<void> sendOtp({required String email, required String name}) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.mailSendOtp,
        data: {'email': email, 'name': name},
      );
      final data = response.data;
      if (data is! Map || data['success'] != true) {
        throw MailOtpException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to send email OTP'
              : 'Invalid response from the server',
        );
      }
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        throw MailOtpException(data['message'].toString());
      }
      throw MailOtpException(
        error.message ?? 'Network error while sending email OTP',
      );
    }
  }

  Future<void> verifyOtp({required String email, required String otp}) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.mailVerifyOtp,
        data: {'email': email, 'otp': otp},
      );
      final data = response.data;
      if (data is! Map || data['success'] != true) {
        throw MailOtpException(
          data is Map
              ? data['message']?.toString() ?? 'Invalid email OTP'
              : 'Invalid response from the server',
        );
      }
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        throw MailOtpException(data['message'].toString());
      }
      throw MailOtpException(
        error.message ?? 'Network error while verifying email OTP',
      );
    }
  }
}

class MailOtpException implements Exception {
  const MailOtpException(this.message);

  final String message;
}
