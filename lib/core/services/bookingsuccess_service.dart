import 'package:dio/dio.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';
import 'package:yogayog/core/services/payment_service.dart';

class BookingSuccessService {
  BookingSuccessService({Dio? dio}) : _dio = dio ?? ApiClient.dio;
  final Dio _dio;

  Future<List<int>> downloadInvoiceForOrder({
    required PaymentOrderResponse order,
  }) async {
    if (order.invoiceUrl.trim().isNotEmpty) {
      return _download(order.invoiceUrl.trim());
    }
    final orderId = int.tryParse(order.orderId) ?? order.databaseId;
    if (orderId == null) {
      throw const BookingSuccessException(
        'Order ID is unavailable for invoice',
      );
    }
    return downloadInvoice(orderId: orderId);
  }

  Future<List<int>> downloadInvoice({required int orderId}) async {
    return _download(ApiEndpoints.invoiceDownload(orderId));
  }

  Future<List<int>> _download(String path) async {
    try {
      final response = await _dio.get<List<int>>(
        path,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Accept': 'application/pdf, application/octet-stream'},
        ),
      );
      if ((response.statusCode ?? 500) >= 400 ||
          response.data == null ||
          response.data!.isEmpty) {
        throw const BookingSuccessException('Unable to download invoice');
      }
      final bytes = response.data!;
      final isPdf =
          bytes.length >= 4 && String.fromCharCodes(bytes.take(4)) == '%PDF';
      if (!isPdf) {
        throw const BookingSuccessException(
          'Server did not return a valid invoice PDF',
        );
      }
      return bytes;
    } on DioException catch (error) {
      final body = error.response?.data;
      throw BookingSuccessException(
        body is Map && body['message'] != null
            ? body['message'].toString()
            : error.message ?? 'Unable to download invoice',
      );
    }
  }
}

class BookingSuccessException implements Exception {
  const BookingSuccessException(this.message);
  final String message;
  @override
  String toString() => message;
}
