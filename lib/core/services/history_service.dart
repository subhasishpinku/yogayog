import 'package:dio/dio.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';

class HistoryService {
  HistoryService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  Future<BookingHistory> getBookings({
    int? serviceId,
    int? subServiceId,
  }) async {
    try {
      // The bookings endpoint is called with the supplied query parameters.
      final queryParameters = <String, dynamic>{};
      if (serviceId != null) queryParameters['service_id'] = serviceId;
      if (subServiceId != null)
        queryParameters['sub_service_id'] = subServiceId;

      final response = await _dio.post(
        ApiEndpoints.bookings,
        queryParameters: queryParameters,
      );
      final data = response.data;
      if (data is! Map || data['success'] != true || data['data'] is! Map) {
        throw HistoryException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to load bookings'
              : 'Invalid response from the server',
        );
      }
      return BookingHistory.fromJson(
        Map<String, dynamic>.from(data['data'] as Map),
      );
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        throw HistoryException(data['message'].toString());
      }
      throw HistoryException(
        error.message ?? 'Network error while loading bookings',
      );
    }
  }
}

class BookingHistory {
  const BookingHistory({
    required this.activeTab,
    required this.upcomingOrders,
    required this.pastOrders,
  });

  final String activeTab;
  final List<Booking> upcomingOrders;
  final List<Booking> pastOrders;

  List<Booking> get ordersToDisplay =>
      activeTab == 'past' ? pastOrders : upcomingOrders;

  factory BookingHistory.fromJson(Map<String, dynamic> json) {
    List<Booking> parse(Object? value) => value is List
        ? value
              .whereType<Map>()
              .map((item) => Booking.fromJson(Map<String, dynamic>.from(item)))
              .toList()
        : <Booking>[];
    return BookingHistory(
      activeTab: json['active_tab']?.toString() ?? 'upcoming',
      upcomingOrders: parse(json['upcoming_orders']),
      pastOrders: parse(json['past_orders']),
    );
  }
}

class Booking {
  const Booking({
    required this.orderId,
    required this.orderNo,
    required this.serviceId,
    required this.subServiceId,
    required this.orderDate,
    required this.serviceName,
    required this.subServiceName,
    required this.amount,
    required this.status,
    required this.pickupCity,
    required this.dropCity,
    required this.pickupName,
    required this.pickupAddress,
    required this.pickupMobile,
    required this.dropName,
    required this.dropAddress,
    required this.dropMobile,
    required this.riderName,
    required this.riderMobile,
    required this.paymentDone,
  });

  final String orderId;
  final String orderNo;
  final int serviceId;
  final int subServiceId;
  final String orderDate;
  final String serviceName;
  final String subServiceName;
  final double amount;
  final String status;
  final String pickupCity;
  final String dropCity;
  final String pickupName;
  final String pickupAddress;
  final String pickupMobile;
  final String dropName;
  final String dropAddress;
  final String dropMobile;
  final String riderName;
  final String riderMobile;
  final bool paymentDone;

  factory Booking.fromJson(Map<String, dynamic> json) {
    String nestedString(String key, String field) {
      final value = json[key];
      return value is Map ? value[field]?.toString() ?? '' : '';
    }

    final rawAmount = json['amount'];
    final rawStatus = json['status_text']?.toString().isNotEmpty == true
        ? json['status_text'].toString()
        : json['raw_status']?.toString() ?? '';
    String nestedValue(String key, String field) => nestedString(key, field);
    final rider = json['rider'];
    return Booking(
      orderId: json['order_id']?.toString() ?? '',
      orderNo:
          json['order_no']?.toString() ?? json['order_id']?.toString() ?? '',
      serviceId: int.tryParse(json['service_id']?.toString() ?? '') ?? 0,
      subServiceId: int.tryParse(json['sub_service_id']?.toString() ?? '') ?? 0,
      orderDate: json['order_date']?.toString() ?? '',
      serviceName: json['service_name']?.toString() ?? '',
      subServiceName: json['sub_service_name']?.toString() ?? '',
      amount: rawAmount is num
          ? rawAmount.toDouble()
          : double.tryParse(rawAmount?.toString() ?? '') ?? 0,
      status: _formatStatus(rawStatus),
      pickupCity: nestedString('pickup', 'city'),
      dropCity: nestedString('drop', 'city'),
      pickupName: nestedValue('pickup', 'name'),
      pickupAddress: nestedValue('pickup', 'area'),
      pickupMobile: nestedValue('pickup', 'mobile'),
      dropName: nestedValue('drop', 'name'),
      dropAddress: nestedValue('drop', 'area'),
      dropMobile: nestedValue('drop', 'mobile'),
      riderName: rider is Map ? rider['name']?.toString() ?? '' : '',
      riderMobile: rider is Map ? rider['mobile']?.toString() ?? '' : '',
      paymentDone: json['payment_done'] == true,
    );
  }

  static String _formatStatus(String status) {
    return status
        .replaceAll('_', ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map(
          (word) =>
              '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

class HistoryException implements Exception {
  const HistoryException(this.message);
  final String message;
  @override
  String toString() => message;
}
