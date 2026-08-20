import 'package:dio/dio.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';

class SavedAddressesService {
  SavedAddressesService({Dio? dio}) : _dio = dio ?? ApiClient.dio;
  final Dio _dio;

  Future<List<SavedAddress>> getAddresses({required int serviceId}) async {
    try {
      final response = await _dio.get(ApiEndpoints.locations, queryParameters: {'service_id': serviceId});
      final data = response.data;
      if (data is! Map || data['success'] != true || data['addresses'] is! List) {
        throw SavedAddressesException(data is Map ? data['message']?.toString() ?? 'Unable to load addresses' : 'Invalid response from the server');
      }
      return (data['addresses'] as List).whereType<Map>().map((item) => SavedAddress.fromJson(Map<String, dynamic>.from(item))).toList();
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) throw SavedAddressesException(data['message'].toString());
      throw SavedAddressesException(error.message ?? 'Network error while loading addresses');
    }
  }
}

class SavedAddress {
  const SavedAddress({required this.id, required this.name, required this.mobile, required this.address, required this.city, required this.state, required this.pin, required this.flag});
  final int id;
  final String name;
  final String mobile;
  final String address;
  final String city;
  final String state;
  final String pin;
  final String flag;

  factory SavedAddress.fromJson(Map<String, dynamic> json) => SavedAddress(
    id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
    name: json['name']?.toString() ?? '',
    mobile: json['mobile']?.toString() ?? '',
    address: json['street']?.toString() ?? json['house_numb']?.toString() ?? '',
    city: json['city']?.toString() ?? '',
    state: json['state']?.toString() ?? '',
    pin: json['pin']?.toString() ?? '',
    flag: json['flag']?.toString() ?? '',
  );
}

class SavedAddressesException implements Exception {
  const SavedAddressesException(this.message);
  final String message;
  @override
  String toString() => message;
}
