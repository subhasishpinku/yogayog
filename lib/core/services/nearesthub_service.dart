import 'package:dio/dio.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';

class NearestHubService {
  NearestHubService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  Future<NearbyBranchesResponse> getNearbyBranches({
    required String city,
    required String stateCode,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.nearbyBranches,
        queryParameters: {'city': city, 'state_code': stateCode},
      );
      final data = response.data;
      if (data is! Map || data['success'] != true) {
        throw NearestHubException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to load nearby hubs'
              : 'Invalid response from the server',
        );
      }

      final branches = (data['branches'] as List? ?? [])
          .whereType<Map>()
          .map((item) => NearbyBranch.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      final hubs = (data['hubs'] as List? ?? [])
          .whereType<Map>()
          .map((item) => NearbyHub.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      return NearbyBranchesResponse(branches: branches, hubs: hubs);
    } on DioException catch (error) {
      throw NearestHubException(
        error.message ?? 'Network error while loading nearby hubs',
      );
    }
  }
}

class NearbyBranchesResponse {
  const NearbyBranchesResponse({required this.branches, required this.hubs});

  final List<NearbyBranch> branches;
  final List<NearbyHub> hubs;
}

class NearbyBranch {
  const NearbyBranch({
    required this.name,
    required this.contactNumber,
    required this.address,
    required this.city,
    required this.pin,
  });

  final String name;
  final String contactNumber;
  final String address;
  final String city;
  final String pin;

  factory NearbyBranch.fromJson(Map<String, dynamic> json) {
    final address = json['address']?.toString().trim() ?? '';
    final city = json['city']?.toString().trim() ?? '';
    final pin = json['pin']?.toString().trim() ?? '';
    return NearbyBranch(
      name: json['name']?.toString() ?? 'Yogayog Branch',
      contactNumber: json['contact_numb']?.toString() ?? '',
      address: address,
      city: city,
      pin: pin,
    );
  }

  String get displayAddress {
    final parts = [
      address,
      city,
      pin,
    ].where((value) => value.isNotEmpty && value != 'null').toList();
    return parts.isEmpty ? 'Address unavailable' : parts.join(', ');
  }
}

class NearbyHub {
  const NearbyHub({
    required this.id,
    required this.hubName,
    required this.stateCode,
    required this.cityId,
    required this.phoneNumber,
    required this.address,
  });

  final int id;
  final String hubName;
  final String stateCode;
  final int cityId;
  final String phoneNumber;
  final String address;

  factory NearbyHub.fromJson(Map<String, dynamic> json) {
    return NearbyHub(
      id: int.tryParse(json['id'].toString()) ?? 0,
      hubName: json['hub_name']?.toString() ?? 'Yogayog Hub',
      stateCode: json['state_code']?.toString() ?? '',
      cityId: int.tryParse(json['city_id'].toString()) ?? 0,
      phoneNumber: json['phone_no']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
    );
  }
}

class NearestHubException implements Exception {
  const NearestHubException(this.message);

  final String message;

  @override
  String toString() => message;
}
