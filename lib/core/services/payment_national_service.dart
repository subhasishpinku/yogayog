import 'package:dio/dio.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';
import 'package:yogayog/core/services/payment_service.dart';

class PaymentNationalService {
  PaymentNationalService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  Future<PaymentOrderResponse> createOrder({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _dio.post(ApiEndpoints.createOrder, data: payload);
      final data = response.data;
      if (data is! Map || data['success'] != true || data['order'] is! Map) {
        throw PaymentNationalException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to create national order'
              : 'Invalid response from the server',
        );
      }
      return PaymentOrderResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        throw PaymentNationalException(data['message'].toString());
      }
      throw PaymentNationalException(
        error.message ?? 'Network error while creating national order',
      );
    }
  }
}

class PaymentNationalException implements Exception {
  const PaymentNationalException(this.message);
  final String message;
}
