import 'package:dio/dio.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';

class ProfileService {
  ProfileService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  Future<LogoutResponse> logout() async {
    try {
      final response = await _dio.post(ApiEndpoints.authLogout);
      final data = response.data;
      if (data is! Map) {
        throw const ProfileException('Invalid response from the server');
      }

      final result = LogoutResponse.fromJson(Map<String, dynamic>.from(data));
      if (!result.success) {
        throw ProfileException(result.message);
      }
      return result;
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        throw ProfileException(data['message'].toString());
      }
      throw ProfileException(error.message ?? 'Network error while logging out');
    }
  }
}

class LogoutResponse {
  const LogoutResponse({required this.success, required this.message});

  final bool success;
  final String message;

  factory LogoutResponse.fromJson(Map<String, dynamic> json) {
    return LogoutResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? 'Logged out successfully',
    );
  }
}

class ProfileException implements Exception {
  const ProfileException(this.message);

  final String message;

  @override
  String toString() => message;
}
