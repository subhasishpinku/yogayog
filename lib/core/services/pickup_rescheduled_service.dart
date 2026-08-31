import 'package:dio/dio.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';

class PickupRescheduledService {
  PickupRescheduledService({Dio? dio}) : _dio = dio ?? ApiClient.dio;
  final Dio _dio;

  Future<void> reschedulePickup({
    required String orderId,
    required String pickupDate,
    required String pickupTime,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.reschedulePickup,
        data: {
          'order_id': orderId,
          'pickup_date': pickupDate,
          'pickup_time': pickupTime,
        },
      );
      final data = response.data;
      if ((response.statusCode ?? 500) >= 400 ||
          data is Map && data['success'] == false) {
        throw PickupRescheduledException(
          data is Map && data['message'] != null
              ? data['message'].toString()
              : 'Unable to reschedule pickup',
        );
      }
    } on DioException catch (error) {
      final data = error.response?.data;
      throw PickupRescheduledException(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : error.message ?? 'Unable to reschedule pickup',
      );
    }
  }
}

class PickupRescheduledException implements Exception {
  const PickupRescheduledException(this.message);
  final String message;
  @override
  String toString() => message;
}
