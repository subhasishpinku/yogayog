import 'package:dio/dio.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';

class CutOffTimeService {
  CutOffTimeService({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  Future<List<CutOffTimeData>> getCutOffTimes() async {
    try {
      final response = await _dio.get(ApiEndpoints.cutoffTimes);
      final data = response.data;
      if (data is! Map || data['success'] != true || data['data'] is! List) {
        throw CutOffTimeException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to load cut-off times'
              : 'Invalid response from the server',
        );
      }

      return (data['data'] as List)
          .whereType<Map>()
          .map((item) => CutOffTimeData.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (error) {
      throw CutOffTimeException(
        error.message ?? 'Network error while loading cut-off times',
      );
    }
  }

  Future<CutOffTimeData> getCutOffTime(int serviceId) async {
    try {
      final response = await _dio.get(ApiEndpoints.cutoffTime(serviceId));
      final data = response.data;
      if (data is! Map || data['success'] != true || data['data'] is! Map) {
        throw CutOffTimeException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to load cut-off time'
              : 'Invalid response from the server',
        );
      }
      return CutOffTimeData.fromJson(
        Map<String, dynamic>.from(data['data'] as Map),
      );
    } on DioException catch (error) {
      throw CutOffTimeException(
        error.message ?? 'Network error while loading cut-off time',
      );
    }
  }
}

class CutOffTimeData {
  const CutOffTimeData({
    required this.serviceId,
    required this.service,
    required this.cutoffTime,
    required this.cutoffTimeDisplay,
  });

  final int serviceId;
  final String service;
  final String cutoffTime;
  final String cutoffTimeDisplay;

  factory CutOffTimeData.fromJson(Map<String, dynamic> json) {
    return CutOffTimeData(
      serviceId: int.tryParse(json['service_id'].toString()) ?? 0,
      service: json['service']?.toString() ?? '',
      cutoffTime: json['cutoff_time']?.toString() ?? '',
      cutoffTimeDisplay: json['cutoff_time_display']?.toString() ?? '',
    );
  }
}

class CutOffTimeException implements Exception {
  const CutOffTimeException(this.message);

  final String message;

  @override
  String toString() => message;
}
