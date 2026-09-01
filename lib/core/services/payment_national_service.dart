import 'package:dio/dio.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';
import 'package:yogayog/core/services/payment_service.dart';

class PaymentNationalService {
  PaymentNationalService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

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
        throw PaymentNationalException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to debit wallet'
              : 'Unable to debit wallet',
        );
      }
    } on DioException catch (error) {
      final data = error.response?.data;
      throw PaymentNationalException(
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
        throw PaymentNationalException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to initialize payment'
              : 'Invalid response from the payment server',
        );
      }
      return BillDeskPaymentResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      final data = error.response?.data;
      throw PaymentNationalException(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : error.message ?? 'Network error while initializing payment',
      );
    } on PaymentException catch (error) {
      throw PaymentNationalException(error.message);
    }
  }
}

class PaymentNationalException implements Exception {
  const PaymentNationalException(this.message);
  final String message;
}
