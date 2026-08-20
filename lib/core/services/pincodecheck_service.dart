import 'package:dio/dio.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';

class PincodeCheckService {
  PincodeCheckService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  Future<PincodeServiceability> checkPincode(String pincode) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.pincodeServiceability,
        queryParameters: {'pincode': pincode},
      );
      final data = response.data;
      if (data is! Map || data['success'] != true) {
        throw PincodeCheckException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to check pincode'
              : 'Invalid response from the server',
        );
      }
      return PincodeServiceability.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        throw PincodeCheckException(data['message'].toString());
      }
      throw PincodeCheckException(
        error.message ?? 'Network error while checking pincode',
      );
    }
  }
}

class PincodeServiceability {
  const PincodeServiceability({
    required this.pincode,
    required this.serviceable,
    required this.message,
    required this.city,
    required this.state,
    required this.branchName,
  });

  final String pincode;
  final bool serviceable;
  final String message;
  final String city;
  final String state;
  final String branchName;

  factory PincodeServiceability.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : <String, dynamic>{};
    final serviceable = json['serviceable'] ?? data['serviceable'];
    return PincodeServiceability(
      pincode: data['pincode']?.toString() ?? '',
      serviceable: serviceable == true,
      message: json['message']?.toString() ?? '',
      city: data['city']?.toString() ?? '',
      state: data['state']?.toString() ?? '',
      branchName: data['branch_name']?.toString() ?? '',
    );
  }
}

class PincodeCheckException implements Exception {
  const PincodeCheckException(this.message);

  final String message;
}
