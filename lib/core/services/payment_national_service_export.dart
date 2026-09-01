import 'package:dio/dio.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';
import 'package:yogayog/core/services/payment_service.dart';

class PaymentNationalExportService {
  PaymentNationalExportService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

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
        throw PaymentNationalExportException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to debit wallet'
              : 'Unable to debit wallet',
        );
      }
    } on DioException catch (error) {
      final data = error.response?.data;
      throw PaymentNationalExportException(
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

  Future<BillDeskPaymentResponse> createBillDeskPayment({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.createPayment,
        data: payload,
      );
      final data = response.data;
      if (data is! Map || data['success'] != true || data['gatewayResponse'] is! Map) {
        throw PaymentNationalExportException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to initialize payment'
              : 'Invalid response from the payment server',
        );
      }
      return BillDeskPaymentResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      final data = error.response?.data;
      throw PaymentNationalExportException(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : error.message ?? 'Network error while initializing payment',
      );
    } on PaymentException catch (error) {
      throw PaymentNationalExportException(error.message);
    }
  }
}

class PaymentNationalExportException implements Exception {
  const PaymentNationalExportException(this.message);
  final String message;
}
