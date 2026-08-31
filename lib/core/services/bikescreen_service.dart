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
      if (data is! Map ||
          data['success'] != true ||
          data['addresses'] is! List) {
        throw BikescreenException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to load locations'
              : 'Invalid response from the server',
        );
      }
      return (data['addresses'] as List)
          .whereType<Map>()
          .map(
            (item) => SavedLocation.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        throw BikescreenException(data['message'].toString());
      }
      throw BikescreenException(
        error.message ?? 'Network error while loading locations',
      );
    }
  }

  Future<void> savePickupLocation({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.pickupLocation,
        data: payload,
      );
      final data = response.data;
      if (data is! Map || data['success'] == false) {
        throw BikescreenException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to save pickup location'
              : 'Invalid response from the server',
        );
      }
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        throw BikescreenException(data['message'].toString());
      }
      throw BikescreenException(
        error.message ?? 'Network error while saving pickup location',
      );
    }
  }

  Future<RateResponse> getRates({
    required int serviceId,
    required int subServiceId,
    required int packageTypeId,
    required double weight,
    required double pickupLat,
    required double pickupLng,
    required double dropLat,
    required double dropLng,
    required String pickupPincode,
    required String deliveryPincode,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.rates,
        data: {
          'service_id': serviceId,
          'sub_service_id': subServiceId,
          'package_type_id': packageTypeId,
          'weight': weight,
          'pickup_lat': pickupLat,
          'pickup_lng': pickupLng,
          'drop_lat': dropLat,
          'drop_lng': dropLng,
          'pickup_pincode': pickupPincode,
          'delivery_pincode': deliveryPincode,
        },
      );
      final data = response.data;
      if (data is! Map || data['success'] != true || data['rates'] is! List) {
        throw BikescreenException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to calculate rates'
              : 'Invalid response from the server',
        );
      }
      return RateResponse.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        throw BikescreenException(data['message'].toString());
      }
      throw BikescreenException(
        error.message ?? 'Network error while calculating rates',
      );
    }
  }

  Future<OrderCreated> createOrder({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _dio.post(ApiEndpoints.createOrder, data: payload);
      final data = response.data;
      if (data is! Map || data['success'] != true || data['order'] is! Map) {
        throw BikescreenException(
          data is Map
              ? data['message']?.toString() ?? 'Unable to create order'
              : 'Invalid response from the server',
        );
      }
      return OrderCreated.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        throw BikescreenException(data['message'].toString());
      }
      throw BikescreenException(
        error.message ?? 'Network error while creating order',
      );
    }
  }
}

class OrderCreated {
  const OrderCreated({
    required this.orderId,
    required this.invoiceId,
    required this.invoiceUrl,
  });
  final String orderId;
  final String invoiceId;
  final String invoiceUrl;

  factory OrderCreated.fromJson(Map<String, dynamic> json) {
    final order = json['order'] is Map
        ? Map<String, dynamic>.from(json['order'])
        : const <String, dynamic>{};
    return OrderCreated(
      orderId: order['order_id']?.toString() ?? order['id']?.toString() ?? '',
      invoiceId: order['invoice_id']?.toString() ?? '',
      invoiceUrl: order['invoice_url']?.toString() ?? '',
    );
  }
}

class RateResponse {
  const RateResponse({
    required this.serviceType,
    required this.distance,
    required this.rates,
  });
  final String serviceType;
  final double distance;
  final List<VehicleRate> rates;

  factory RateResponse.fromJson(Map<String, dynamic> json) {
    return RateResponse(
      serviceType: json['service_type']?.toString() ?? '',
      distance: _toDouble(json['distance']),
      rates: (json['rates'] as List)
          .whereType<Map>()
          .map((item) => VehicleRate.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }
}

class VehicleRate {
  const VehicleRate({
    required this.vehicleType,
    required this.basePrice,
    required this.price,
    required this.breakdown,
  });
  final String vehicleType;
  final double basePrice;
  final double price;
  final PriceBreakdown breakdown;

  factory VehicleRate.fromJson(Map<String, dynamic> json) => VehicleRate(
    vehicleType: json['vehicle_type']?.toString() ?? '',
    basePrice: _toDouble(json['base_price']),
    price: _toDouble(json['price']),
    breakdown: PriceBreakdown.fromJson(
      json['price_breakdown'] is Map
          ? Map<String, dynamic>.from(json['price_breakdown'])
          : const {},
    ),
  );
}

class PriceBreakdown {
  const PriceBreakdown({
    required this.basePrice,
    required this.otherCharges,
    required this.markupAmount,
    required this.gstAmount,
    required this.cgst,
    required this.sgst,
    required this.discountAmount,
    required this.finalPrice,
  });
  final double basePrice;
  final double otherCharges;
  final double markupAmount;
  final double gstAmount;
  final double cgst;
  final double sgst;
  final double discountAmount;
  final double finalPrice;

  factory PriceBreakdown.fromJson(Map<String, dynamic> json) => PriceBreakdown(
    basePrice: _toDouble(json['base_price']),
    otherCharges: _toDouble(json['other_charges']),
    markupAmount: _toDouble(json['markup_amount']),
    gstAmount: _toDouble(json['gst_amount']),
    cgst: _toDouble(json['cgst']),
    sgst: _toDouble(json['sgst']),
    discountAmount: _toDouble(json['discount_amount']),
    finalPrice: _toDouble(json['final_price']),
  );
}

double _toDouble(Object? value) => value is num
    ? value.toDouble()
    : double.tryParse(value?.toString() ?? '') ?? 0;

class SavedLocation {
  const SavedLocation({
    required this.id,
    required this.name,
    required this.mobile,
    this.houseNumber = '',
    required this.address,
    required this.city,
    required this.pincode,
    required this.state,
    required this.latitude,
    required this.longitude,
    required this.flag,
    this.country = '',
  });

  final int id;
  final String name;
  final String mobile;
  final String houseNumber;
  final String address;
  final String city;
  final String pincode;
  final String state;
  final double? latitude;
  final double? longitude;
  final String flag;
  final String country;

  factory SavedLocation.fromJson(Map<String, dynamic> json) {
    double? number(Object? value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '');
    }

    return SavedLocation(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      mobile:
          json['mobile']?.toString() ??
          json['phone']?.toString() ??
          json['phone_number']?.toString() ??
          '',
      houseNumber:
          json['house_numb']?.toString() ??
          json['house_number']?.toString() ??
          json['house_no']?.toString() ??
          '',
      address:
          json['street']?.toString() ?? json['house_numb']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      pincode: json['pin']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      latitude: number(json['lat']),
      longitude: number(json['lon']),
      flag: json['flag']?.toString() ?? '',
      country:
          json['country']?.toString() ??
          json['country_name']?.toString() ??
          json['country_code']?.toString() ??
          json['country_cde']?.toString() ??
          '',
    );
  }
}

class BikescreenException implements Exception {
  const BikescreenException(this.message);
  final String message;
  @override
  String toString() => message;
}
