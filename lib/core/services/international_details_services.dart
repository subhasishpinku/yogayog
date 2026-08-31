import 'package:dio/dio.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';
import 'package:yogayog/core/services/national_service.dart';

class InternationalDetailsService {
  InternationalDetailsService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  Future<NationalRateResponse> getRates({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _dio.post(ApiEndpoints.rates, data: payload);
      final data = response.data;
      if (data is! Map || data['success'] != true || data['rates'] is! List) {
        throw InternationalDetailsException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to calculate rates'
              : 'Invalid response from rates API',
        );
      }
      return NationalRateResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      final data = error.response?.data;
      throw InternationalDetailsException(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : error.message ?? 'Network error while calculating rates',
      );
    }
  }

  Future<NationalOrderResponse> createPostpaidOrder({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.createPostpaidOrder,
        data: payload,
      );
      final data = response.data;
      if (data is! Map || data['success'] != true) {
        throw InternationalDetailsException(
          data is Map
              ? data['message']?.toString() ??
                    'Unable to create post-paid order'
              : 'Invalid response from post-paid order API',
        );
      }
      return NationalOrderResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      final data = error.response?.data;
      throw InternationalDetailsException(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : error.message ?? 'Network error while creating post-paid order',
      );
    }
  }
}

class InternationalDetailsException implements Exception {
  const InternationalDetailsException(this.message);
  final String message;
}
