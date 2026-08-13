import 'package:dio/dio.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';

class BikescreenService {
  BikescreenService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  Future<List<SavedLocation>> getLocations({required int serviceId}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.locations,
        queryParameters: {'service_id': serviceId},
      );
      final data = response.data;
      if (data is! Map || data['success'] != true || data['addresses'] is! List) {
        throw BikescreenException(
          data is Map ? data['message']?.toString() ?? 'Unable to load locations' : 'Invalid response from the server',
        );
      }
      return (data['addresses'] as List)
          .whereType<Map>()
          .map((item) => SavedLocation.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        throw BikescreenException(data['message'].toString());
      }
      throw BikescreenException(error.message ?? 'Network error while loading locations');
    }
  }
}

class SavedLocation {
  const SavedLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.pincode,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.flag,
  });

  final int id;
  final String name;
  final String address;
  final String city;
  final String pincode;
  final String state;
  final double? latitude;
  final double? longitude;
  final String flag;

  factory SavedLocation.fromJson(Map<String, dynamic> json) {
    double? number(Object? value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '');
    }
    return SavedLocation(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      address: json['street']?.toString() ?? json['house_numb']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      pincode: json['pin']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      latitude: number(json['lat']),
      longitude: number(json['lon']),
      flag: json['flag']?.toString() ?? '',
    );
  }
}

class BikescreenException implements Exception {
  const BikescreenException(this.message);
  final String message;
  @override
  String toString() => message;
}
