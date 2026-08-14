import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';

class HomeService {
  HomeService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  Future<ProfileData> getProfile() async {

    try {
      final response = await _dio.get(ApiEndpoints.profile);
      final data = response.data;

      if (data is! Map || data['success'] != true || data['user'] is! Map) {
        throw HomeException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to load profile'
              : 'Invalid response from the server',
        );
      }

      return ProfileData.fromJson(
        Map<String, dynamic>.from(data['user'] as Map),
      );
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        throw HomeException(data['message'].toString());
      }
      throw HomeException(error.message ?? 'Network error while loading profile');
    }
  }

  Future<List<StaticService>> getStaticServices() async {
    try {
      final response = await _dio.get(ApiEndpoints.staticServices);
      final data = response.data;
      if (data is! Map || data['success'] != true || data['data'] is! List) {
        throw HomeException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to load services'
              : 'Invalid response from the server',
        );
      }
      return (data['data'] as List)
          .whereType<Map>()
          .map((item) => StaticService.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        throw HomeException(data['message'].toString());
      }
      throw HomeException(
        error.message ?? 'Network error while loading services',
      );
    }
  }

  Future<TrackOrderData> trackOrder(String trackingNumber) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.trackOrder,
        queryParameters: {'tracking_number': trackingNumber},
      );
      final data = response.data;
      if (data is! Map || data['success'] != true) {
        throw HomeException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to track this order'
              : 'Invalid response from the server',
        );
      }
      return TrackOrderData.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        throw HomeException(data['message'].toString());
      }
      throw HomeException(
        error.message ?? 'Network error while tracking the order',
      );
    }
  }
}

class TrackOrderData {
  const TrackOrderData({
    required this.orderId,
    required this.customerName,
    required this.weight,
    required this.value,
    required this.status,
    required this.lastUpdated,
    required this.timeline,
  });

  final String orderId;
  final String customerName;
  final double weight;
  final double value;
  final String status;
  final String lastUpdated;
  final List<TrackingTimeline> timeline;

  factory TrackOrderData.fromJson(Map<String, dynamic> json) {
    return TrackOrderData(
      orderId: json['order_id']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? 'Customer',
      weight: double.tryParse(json['weight'].toString()) ?? 0,
      value: double.tryParse(json['value'].toString()) ?? 0,
      status: json['status']?.toString() ?? '',
      lastUpdated: json['last_updated']?.toString() ?? '',
      timeline: (json['timeline'] as List? ?? [])
          .whereType<Map>()
          .map(
            (item) => TrackingTimeline.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }
}

class TrackingTimeline {
  const TrackingTimeline({
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String status;
  final String createdAt;
  final String updatedAt;

  factory TrackingTimeline.fromJson(Map<String, dynamic> json) {
    return TrackingTimeline(
      status: json['status']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}

class StaticService {
  const StaticService({
    required this.serviceId,
    required this.name,
    required this.description,
    required this.icon,
    required this.price,
  });

  final int serviceId;
  final String name;
  final String description;
  final String icon;
  final String price;

  factory StaticService.fromJson(Map<String, dynamic> json) {
    return StaticService(
      serviceId: int.tryParse(json['service_id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '📦',
      price: json['price']?.toString() ?? '0.00',
    );
  }
}

class ProfileData {
  const ProfileData({
    required this.name,
    required this.email,
    required this.mobile,
    required this.paymentMode,
    required this.accountType,
    required this.address,
    required this.city,
    required this.pin,
    required this.state,
  });

  final String name;
  final String email;
  final String mobile;
  final String paymentMode;
  final String? accountType;
  final String? address;
  final String? city;
  final String? pin;
  final String? state;

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      paymentMode: json['payment_mode']?.toString() ?? '',
      accountType: json['acc_type']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      pin: json['pin']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
    );
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class HomeException implements Exception {
  const HomeException(this.message);

  final String message;

  @override
  String toString() => message;
}
