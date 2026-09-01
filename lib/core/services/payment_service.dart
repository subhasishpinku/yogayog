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
        throw PaymentException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to initialize payment'
              : 'Invalid response from the payment server',
        );
      }
      return BillDeskPaymentResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      final data = error.response?.data;
      throw PaymentException(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : error.message ?? 'Network error while initializing payment',
      );
    }
  }
}

class BillDeskPaymentResponse {
  const BillDeskPaymentResponse({
    required this.orderId,
    required this.merchantId,
    required this.billDeskOrderId,
    required this.authToken,
  });

  final String orderId;
  final String merchantId;
  final String billDeskOrderId;
  final String authToken;

  factory BillDeskPaymentResponse.fromJson(Map<String, dynamic> json) {
    final gateway = Map<String, dynamic>.from(json['gatewayResponse'] as Map);
    final links = gateway['links'] is List ? gateway['links'] as List : const [];
    Map<String, dynamic> redirect = const <String, dynamic>{};
    for (final link in links) {
      if (link is Map && link['rel']?.toString() == 'redirect') {
        redirect = Map<String, dynamic>.from(link);
        break;
      }
    }
    final headers = redirect['headers'] is Map
        ? Map<String, dynamic>.from(redirect['headers'] as Map)
        : const <String, dynamic>{};

    final authToken = headers['authorization']?.toString() ?? '';
    final parameters = redirect['parameters'] is Map
        ? Map<String, dynamic>.from(redirect['parameters'] as Map)
        : const <String, dynamic>{};
    final billDeskOrderId = parameters['bdorderid']?.toString() ?? '';
    final merchantId = gateway['mercid']?.toString() ?? '';
    if (authToken.isEmpty || billDeskOrderId.isEmpty || merchantId.isEmpty) {
      throw const PaymentException('Payment gateway details are incomplete');
    }
    return BillDeskPaymentResponse(
      orderId: json['orderId']?.toString() ?? gateway['orderid']?.toString() ?? '',
      merchantId: merchantId,
      billDeskOrderId: billDeskOrderId,
      authToken: authToken,
    );
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
