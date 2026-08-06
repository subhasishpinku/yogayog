import 'package:dio/dio.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';

class AuthService {
  AuthService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  Future<SendOtpResponse> sendOtp({
    required String mobile,
    String loginAs = 'customer',
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.authSendOtp,
        data: {'login_as': loginAs, 'mobile': mobile},
      );

      final data = response.data;
      if (data is! Map) {
        throw const AuthException('Invalid response from the server');
      }

      final success = data['success'] == true;
      if (!success) {
        throw AuthException(
          data['message']?.toString() ?? 'Unable to send OTP',
        );
      }

      return SendOtpResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        throw AuthException(data['message'].toString());
      }
      throw AuthException(error.message ?? 'Network error while sending OTP');
    }
  }
}

class SendOtpResponse {
  const SendOtpResponse({
    required this.success,
    required this.message,
    this.otp,
  });

  final bool success;
  final String message;
  final int? otp;

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    final rawOtp = json['otp'];
    return SendOtpResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? 'OTP sent successfully',
      otp: rawOtp is int ? rawOtp : int.tryParse(rawOtp?.toString() ?? ''),
    );
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
