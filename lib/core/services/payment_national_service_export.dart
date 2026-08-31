import 'package:dio/dio.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';
import 'package:yogayog/core/services/payment_service.dart';

class PaymentNationalExportService {
  PaymentNationalExportService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  Future<PaymentOrderResponse> createOrder({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _dio.post(ApiEndpoints.createOrder, data: payload);
      final data = response.data;
      if (data is! Map || data['success'] != true || data['order'] is! Map) {
        throw PaymentNationalExportException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to create export order'
              : 'Invalid response from order API',
        );
      }
      return PaymentOrderResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      final data = error.response?.data;
      throw PaymentNationalExportException(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : error.message ?? 'Network error while creating export order',
      );
    }
  }
}

class PaymentNationalExportException implements Exception {
  const PaymentNationalExportException(this.message);
  final String message;
}
