import 'package:dio/dio.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';

class NationalImportService {
  NationalImportService({Dio? dio}) : _dio = dio ?? ApiClient.dio;
  final Dio _dio;
  Future<NationalRateResponse> getRates({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _dio.post(ApiEndpoints.rates, data: payload);
      final data = response.data;
      if (data is! Map || data['success'] != true || data['rates'] is! List) {
        throw NationalImportException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to calculate rates'
              : 'Invalid rates response',
        );
      }
      return NationalRateResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      final data = error.response?.data;
      throw NationalImportException(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : error.message ?? 'Network error while calculating rates',
      );
    }
  }

  Future<Map<String, dynamic>> createPostpaidOrder({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.createPostpaidOrder,
        data: payload,
      );
      final data = response.data;
      if (data is! Map || data['success'] != true) {
        throw NationalImportException(
          data is Map
              ? data['message']?.toString() ??
                    'Unable to create post-paid order'
              : 'Invalid response from post-paid order API',
        );
      }
      return Map<String, dynamic>.from(data);
    } on DioException catch (error) {
      final data = error.response?.data;
      throw NationalImportException(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : error.message ?? 'Network error while creating post-paid order',
      );
    }
  }
}

class NationalImportException implements Exception {
  const NationalImportException(this.message);
  final String message;
}

class NationalRateResponse {
  const NationalRateResponse({
    required this.rates,
    required this.zone,
    required this.distance,
  });
  final List<NationalRate> rates;
  final String zone;
  final double distance;
  factory NationalRateResponse.fromJson(Map<String, dynamic> json) =>
      NationalRateResponse(
        rates: (json['rates'] as List)
            .whereType<Map>()
            .map(
              (item) => NationalRate.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList(),
        zone: json['zone']?.toString() ?? '',
        distance: _number(json['distance']),
      );
}

class NationalRate {
  const NationalRate(this.raw);
  final Map<String, dynamic> raw;
  factory NationalRate.fromJson(Map<String, dynamic> json) =>
      NationalRate(json);
  String get carrierName => raw['carrier_name']?.toString() ?? 'Courier';
  String get serviceMode => raw['service_mode']?.toString() ?? '';
  String get deliveryTime => raw['delivery_time']?.toString() ?? '';
  double get price => _number(raw['price']);
}

double _number(Object? value) => value is num
    ? value.toDouble()
    : double.tryParse(value?.toString() ?? '') ?? 0;
