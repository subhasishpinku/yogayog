import 'package:dio/dio.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';

class PaymentService {
  PaymentService({Dio? dio}) : _dio = dio ?? ApiClient.dio;
  final Dio _dio;

  Future<void> payFromWallet({required double amount}) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.customerWalletPay,
        queryParameters: {'amount': amount},
      );
      final data = response.data;
      if (response.statusCode == null ||
          response.statusCode! >= 400 ||
          (data is Map && data['success'] == false)) {
        throw PaymentException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to debit wallet'
              : 'Unable to debit wallet',
        );
      }
    } on DioException catch (error) {
      final data = error.response?.data;
      throw PaymentException(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : error.message ?? 'Network error while debiting wallet',
      );
    }
  }

  Future<PaymentOrderResponse> createOrder({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _dio.post(ApiEndpoints.createOrder, data: payload);
      final data = response.data;
      if (data is! Map || data['success'] != true || data['order'] is! Map) {
        throw PaymentException(
          data is Map ? data['message']?.toString() ?? 'Unable to create order' : 'Invalid response from the server',
        );
      }
      return PaymentOrderResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        throw PaymentException(data['message'].toString());
      }
      throw PaymentException(error.message ?? 'Network error while creating order');
    }
  }
}

class PaymentOrderResponse {
  const PaymentOrderResponse({
    required this.orderId,
    required this.invoiceId,
    required this.invoiceUrl,
    this.databaseId,
  });
  final String orderId;
  final String invoiceId;
  final String invoiceUrl;
  /// Numeric database id required by `/orders/{id}/invoice/download`.
  final int? databaseId;

  factory PaymentOrderResponse.fromJson(Map<String, dynamic> json) {
    final order = json['order'] is Map ? Map<String, dynamic>.from(json['order']) : const <String, dynamic>{};
    return PaymentOrderResponse(
      orderId: order['order_id']?.toString() ?? order['id']?.toString() ?? '',
      invoiceId: order['invoice_id']?.toString() ?? '',
      invoiceUrl: order['invoice_url']?.toString() ?? '',
      databaseId: int.tryParse(order['id']?.toString() ?? ''),
    );
  }
}

class PaymentException implements Exception {
  const PaymentException(this.message);
  final String message;
  @override
  String toString() => message;
}
