import 'package:dio/dio.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';

class AddDropAddressService {
  AddDropAddressService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  Future<void> addPickupAddress({required Map<String, dynamic> payload}) async {
    try {
      final response = await _dio.post(ApiEndpoints.pickupLocation, data: payload);
      final data = response.data;
      if (data is Map && data['success'] == false) {
        throw AddDropAddressException(data['message']?.toString() ?? 'Unable to save address');
      }
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        throw AddDropAddressException(data['message'].toString());
      }
      throw AddDropAddressException(error.message ?? 'Network error while saving address');
    }
  }
}

class AddDropAddressException implements Exception {
  const AddDropAddressException(this.message);
  final String message;
  @override
  String toString() => message;
}
