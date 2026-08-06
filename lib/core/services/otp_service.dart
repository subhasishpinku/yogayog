import 'package:dio/dio.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';

class OtpService {
  OtpService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  Future<VerifyOtpResponse> verifyOtp({
    required String mobile,
    required String otp,
    String loginAs = 'customer',
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.authVerifyOtp,
        data: {
          'login_as': loginAs,
          'mobile': mobile,
          'otp': otp,
        },
      );

      final data = response.data;
      if (data is! Map) {
        throw const OtpException('Invalid response from the server');
      }

      if (data['success'] != true) {
        throw OtpException(data['message']?.toString() ?? 'Invalid OTP');
      }

      return VerifyOtpResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        throw OtpException(data['message'].toString());
      }
      throw OtpException(error.message ?? 'Network error while verifying OTP');
    }
  }
}

class VerifyOtpResponse {
  const VerifyOtpResponse({
    required this.success,
    required this.message,
    required this.token,
    this.user,
  });

  final bool success;
  final String message;
  final String token;
  final OtpUser? user;

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];
    return VerifyOtpResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? 'Login successful.',
      token: json['token']?.toString() ?? '',
      user: rawUser is Map
          ? OtpUser.fromJson(Map<String, dynamic>.from(rawUser))
          : null,
    );
  }
}

class OtpUser {
  const OtpUser({required this.id, required this.mobile});

  final int? id;
  final String mobile;

  factory OtpUser.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    return OtpUser(
      id: rawId is int ? rawId : int.tryParse(rawId?.toString() ?? ''),
      mobile: json['mobile']?.toString() ?? '',
    );
  }
}

class OtpException implements Exception {
  const OtpException(this.message);

  final String message;

  @override
  String toString() => message;
}
