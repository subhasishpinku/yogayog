import 'package:dio/dio.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';
import 'package:yogayog/core/services/pincodecheck_service.dart';

class NationalService {
  NationalService({PincodeCheckService? service})
    : _service = service ?? PincodeCheckService();

  final PincodeCheckService _service;

  Future<PincodeServiceability> checkPincode(String pincode) {
    return _service.checkPincode(pincode);
  }

  Future<NationalRateResponse> getRates({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        ApiEndpoints.rates,
        data: payload,
      );
      final data = response.data;
      if (data is! Map || data['success'] != true || data['rates'] is! List) {
        throw NationalException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to calculate rates'
              : 'Invalid response from the server',
        );
      }
      return NationalRateResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        throw NationalException(data['message'].toString());
      }
      throw NationalException(
        error.message ?? 'Network error while calculating rates',
      );
    }
  }
}

class NationalException implements Exception {
  const NationalException(this.message);
  final String message;
}

class NationalRateResponse {
  const NationalRateResponse({
    required this.rates,
    required this.zone,
    required this.distance,
    required this.raw,
  });

  final List<NationalRate> rates;
  final String zone;
  final double distance;
  final Map<String, dynamic> raw;

  factory NationalRateResponse.fromJson(Map<String, dynamic> json) {
    return NationalRateResponse(
      rates: (json['rates'] as List)
          .whereType<Map>()
          .map((item) => NationalRate.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      zone: json['zone']?.toString() ?? '',
      distance: _toDouble(json['distance']),
      raw: json,
    );
  }
}

class NationalRate {
  const NationalRate({required this.raw});

  final Map<String, dynamic> raw;

  factory NationalRate.fromJson(Map<String, dynamic> json) {
    return NationalRate(raw: json);
  }

  String get carrierName => raw['carrier_name']?.toString() ?? 'Courier';
  String get serviceMode => raw['service_mode']?.toString() ?? '';
  String get deliveryTime => raw['delivery_time']?.toString() ?? '';
  double get price => _toDouble(raw['price']);
  String get icon => raw['icon']?.toString() ?? '';
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
