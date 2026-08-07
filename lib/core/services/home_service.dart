import 'package:dio/dio.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';

class HomeService {
  HomeService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  Future<ProfileData> getProfile() async {
    try {
      final response = await _dio.get(ApiEndpoints.profile);
      final data = response.data;

      if (data is! Map || data['success'] != true || data['user'] is! Map) {
        throw HomeException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to load profile'
              : 'Invalid response from the server',
        );
      }

      return ProfileData.fromJson(
        Map<String, dynamic>.from(data['user'] as Map),
      );
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        throw HomeException(data['message'].toString());
      }
      throw HomeException(error.message ?? 'Network error while loading profile');
    }
  }
}

class ProfileData {
  const ProfileData({
    required this.name,
    required this.email,
    required this.mobile,
    required this.paymentMode,
    required this.accountType,
  });

  final String name;
  final String email;
  final String mobile;
  final String paymentMode;
  final String accountType;

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      paymentMode: json['payment_mode']?.toString() ?? '',
      accountType: json['acc_type']?.toString() ?? '',
    );
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class HomeException implements Exception {
  const HomeException(this.message);

  final String message;

  @override
  String toString() => message;
}
