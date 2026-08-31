import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';

class InvoiceData {
  const InvoiceData({
    required this.id,
    required this.orderId,
    required this.invoiceId,
    required this.serviceId,
    required this.subServiceId,
    required this.fromLocationId,
    required this.toLocationId,
    required this.amount,
    required this.weight,
    required this.pickupDate,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
  });

  final int id;
  final String orderId;
  final String invoiceId;
  final int serviceId;
  final int subServiceId;
  final int fromLocationId;
  final int toLocationId;
  final double? amount;
  final double? weight;
  final String pickupDate;
  final String paymentMethod;
  final String paymentStatus;
  final String createdAt;

  factory InvoiceData.fromJson(Map<String, dynamic> json) {
    int number(Object? value) => int.tryParse(value?.toString() ?? '') ?? 0;
    double? decimal(Object? value) => value == null
        ? null
        : double.tryParse(value.toString());

    return InvoiceData(
      id: number(json['id']),
      orderId: json['order_id']?.toString() ?? '',
      invoiceId: json['invoice_id']?.toString() ?? '',
      serviceId: number(json['service_id']),
      subServiceId: number(json['sub_service_id']),
      fromLocationId: number(json['fr_loc']),
      toLocationId: number(json['to_loc']),
      amount: decimal(json['total_amnt'] ?? json['pack_value']),
      weight: decimal(json['charge_wt'] ?? json['pack_weight']),
      pickupDate: json['pickup_date']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class InvoicesResponse {
  const InvoicesResponse({required this.invoices});
  final List<InvoiceData> invoices;
}

class InvoicesService {
  InvoicesService({Dio? dio}) : _dio = dio ?? ApiClient.dio;
  final Dio _dio;

  Future<InvoicesResponse> getInvoices() async {
    try {
      final response = await _dio.get(ApiEndpoints.invoices);
      final data = response.data;
      if (data is! Map || data['success'] != true) {
        throw InvoicesException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to load invoices'
              : 'Invalid invoice response',
        );
      }
      final body = data['data'];
      final orders = body is Map ? body['orders'] : null;
      if (orders is! List) {
        throw const InvoicesException('Invalid invoice list response');
      }
      return InvoicesResponse(
        invoices: orders
            .whereType<Map>()
            .map((item) => InvoiceData.fromJson(Map<String, dynamic>.from(item)))
            .toList(),
      );
    } on DioException catch (error) {
      final data = error.response?.data;
      throw InvoicesException(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : error.message ?? 'Unable to load invoices',
      );
    }
  }

  Future<List<int>> downloadInvoice(int orderId) async {
    try {
      final response = await _dio.get<List<int>>(
        ApiEndpoints.invoiceDownload(orderId),
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Accept': 'application/pdf, application/octet-stream'},
        ),
      );
      if (response.statusCode == null || response.statusCode! >= 400) {
        throw const InvoicesException('Unable to download invoice');
      }
      final bytes = response.data;
      if (bytes == null || bytes.isEmpty) {
        throw const InvoicesException('Invoice PDF is empty');
      }
      final contentType = response.headers.value(Headers.contentTypeHeader) ?? '';
      final startsWithPdf = bytes.length >= 4 &&
          String.fromCharCodes(bytes.take(4)) == '%PDF';
      if (!startsWithPdf && contentType.contains('json')) {
        final body = jsonDecode(utf8.decode(bytes));
        throw InvoicesException(
          body is Map && body['message'] != null
              ? body['message'].toString()
              : 'Invoice PDF was not returned by the server',
        );
      }
      if (!startsWithPdf) {
        throw const InvoicesException('Server returned an invalid invoice PDF');
      }
      return bytes;
    } on DioException catch (error) {
      throw InvoicesException(
        error.message ?? 'Unable to download invoice',
      );
    }
  }
}

class InvoicesException implements Exception {
  const InvoicesException(this.message);
  final String message;
  @override
  String toString() => message;
}
