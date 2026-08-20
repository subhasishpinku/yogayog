import 'package:dio/dio.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/network/api_endpoints.dart';

class TruckLocalService {
  TruckLocalService({Dio? dio}) : _dio = dio ?? ApiClient.dio;
  final Dio _dio;

  Future<TruckRateResponse> getRates({required Map<String, dynamic> payload}) async {
    try {
      final response = await _dio.post(ApiEndpoints.rates, data: payload);
      final data = response.data;
      if (data is! Map || data['success'] != true || data['rates'] is! List) {
        throw TruckLocalException(
          data is Map ? data['message']?.toString() ?? 'Unable to calculate truck rates' : 'Invalid response from the server',
        );
      }
      return TruckRateResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      final data = error.response?.data;
      throw TruckLocalException(
        data is Map && data['message'] != null
            ? data['message'].toString()
            : error.message ?? 'Network error while calculating truck rates',
      );
    }
  }
}

class TruckRateResponse {
  const TruckRateResponse({required this.serviceType, required this.distance, required this.rates});
  final String serviceType;
  final double distance;
  final List<TruckVehicleRate> rates;

  factory TruckRateResponse.fromJson(Map<String, dynamic> json) => TruckRateResponse(
        serviceType: json['service_type']?.toString() ?? '',
        distance: _truckDouble(json['distance']),
        rates: (json['rates'] as List).whereType<Map>().map((item) => TruckVehicleRate.fromJson(Map<String, dynamic>.from(item))).toList(),
      );
}

class TruckVehicleRate {
  const TruckVehicleRate({required this.vehicleType, required this.basePrice, required this.price, required this.breakdown});
  final String vehicleType;
  final double basePrice;
  final double price;
  final TruckPriceBreakdown breakdown;

  factory TruckVehicleRate.fromJson(Map<String, dynamic> json) => TruckVehicleRate(
        vehicleType: json['vehicle_type']?.toString() ?? '',
        basePrice: _truckDouble(json['base_price']),
        price: _truckDouble(json['price']),
        breakdown: TruckPriceBreakdown.fromJson(json['price_breakdown'] is Map ? Map<String, dynamic>.from(json['price_breakdown']) : const {}),
      );
}

class TruckPriceBreakdown {
  const TruckPriceBreakdown({required this.basePrice, required this.otherCharges, required this.gstAmount, required this.finalPrice});
  final double basePrice;
  final double otherCharges;
  final double gstAmount;
  final double finalPrice;

  factory TruckPriceBreakdown.fromJson(Map<String, dynamic> json) => TruckPriceBreakdown(
        basePrice: _truckDouble(json['base_price']),
        otherCharges: _truckDouble(json['other_charges']),
        gstAmount: _truckDouble(json['gst_amount']),
        finalPrice: _truckDouble(json['final_price']),
      );
}

double _truckDouble(Object? value) => value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '') ?? 0;

class TruckLocalException implements Exception {
  const TruckLocalException(this.message);
  final String message;
  @override
  String toString() => message;
}
