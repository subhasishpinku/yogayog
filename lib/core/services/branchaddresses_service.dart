import 'package:dio/dio.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';

class BranchAddressesService {
  BranchAddressesService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  Future<List<BranchAddress>> getBranches({
    required String city,
    required String stateCode,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.nearbyBranches,
        queryParameters: {'city': city, 'state_code': stateCode},
      );
      final data = response.data;
      if (data is! Map || data['success'] != true || data['branches'] is! List) {
        throw BranchAddressesException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to load branches'
              : 'Invalid response from the server',
        );
      }
      return (data['branches'] as List)
          .whereType<Map>()
          .map((item) => BranchAddress.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (error) {
      throw BranchAddressesException(
        error.message ?? 'Network error while loading branches',
      );
    }
  }
}

class BranchAddress {
  const BranchAddress({
    required this.name,
    required this.branchType,
    required this.address,
    required this.city,
    required this.pin,
    required this.phone,
  });

  final String name;
  final String branchType;
  final String address;
  final String city;
  final String pin;
  final String phone;

  factory BranchAddress.fromJson(Map<String, dynamic> json) {
    return BranchAddress(
      name: json['name']?.toString() ?? 'Yogayog Branch',
      branchType: json['branch_type']?.toString() ?? 'Branch',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      pin: json['pin']?.toString() ?? '',
      phone: json['contact_numb']?.toString() ?? '',
    );
  }

  String get displayAddress => [address, city, pin]
      .where((part) => part.trim().isNotEmpty && part != 'null')
      .join(', ');
}

class BranchAddressesException implements Exception {
  const BranchAddressesException(this.message);

  final String message;
}
