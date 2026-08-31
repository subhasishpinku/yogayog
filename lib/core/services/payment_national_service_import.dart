import 'package:dio/dio.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';
import 'package:yogayog/core/services/payment_service.dart';

class PaymentNationalImportService {
  PaymentNationalImportService({Dio? dio}) : _dio = dio ?? ApiClient.dio;
  final Dio _dio;
  Future<PaymentOrderResponse> createOrder({required Map<String, dynamic> payload}) async {
    try {
      final response = await _dio.post(ApiEndpoints.createOrder, data: payload);
      final data = response.data;
      if (data is! Map || data['success'] != true || data['order'] is! Map) {
        throw PaymentNationalImportException(data is Map ? data['message']?.toString() ?? 'Unable to create import order' : 'Invalid order response');
      }
      return PaymentOrderResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      final data = error.response?.data;
      throw PaymentNationalImportException(data is Map && data['message'] != null ? data['message'].toString() : error.message ?? 'Network error while creating import order');
    }
  }
}

class PaymentNationalImportException implements Exception {
  const PaymentNationalImportException(this.message);
  final String message;
}
