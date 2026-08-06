import 'package:dio/dio.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';

class LoginSaveService {
  LoginSaveService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  Future<RegisterCustomerResponse> registerCustomer({
    required String name,
    required String email,
    required String clientType,
    required String paymentMode,
    required String markupType,
    required String address,
    required String city,
    required String state,
    required String pincode,
    required String mobile,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.authRegisterCustomer,
        data: {
          'name': name,
          'email': email,
          'client_type': clientType,
          'payment_mode': paymentMode,
          'markup_type': markupType,
          'address': address,
          'city': city,
          'state': state,
          'pincode': pincode,
          'mobile': mobile,
        },
      );

      final data = response.data;
      if (data is! Map) {
        throw const RegistrationException('Invalid response from the server');
      }

      final result = RegisterCustomerResponse.fromJson(
        Map<String, dynamic>.from(data),
      );
      if (!result.success) {
        throw RegistrationException(result.message);
      }
      return result;
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        throw RegistrationException(data['message'].toString());
      }
      throw RegistrationException(
        error.message ?? 'Network error while creating account',
      );
    }
  }
}

class RegisterCustomerResponse {
  const RegisterCustomerResponse({
    required this.success,
    required this.message,
    required this.token,
    this.user,
  });

  final bool success;
  final String message;
  final String token;
  final RegisteredUser? user;

  factory RegisterCustomerResponse.fromJson(Map<String, dynamic> json) {
    return RegisterCustomerResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? 'Unable to create account',
      token: json['token']?.toString() ?? '',
      user: json['user'] is Map
          ? RegisteredUser.fromJson(
              Map<String, dynamic>.from(json['user'] as Map),
            )
          : null,
    );
  }
}

class RegisteredUser {
  const RegisteredUser({required this.id, required this.mobile});

  final int? id;
  final String mobile;

  factory RegisteredUser.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    return RegisteredUser(
      id: rawId is int ? rawId : int.tryParse(rawId?.toString() ?? ''),
      mobile: json['mobile']?.toString() ?? '',
    );
  }
}

class RegistrationException implements Exception {
  const RegistrationException(this.message);

  final String message;

  @override
  String toString() => message;
}
