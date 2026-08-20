import 'package:flutter/foundation.dart';
import 'package:yogayog/core/services/bikescreen_service.dart';

class BikescreenProvider extends ChangeNotifier {
  BikescreenProvider({BikescreenService? service}) : _service = service ?? BikescreenService();

  final BikescreenService _service;
  List<SavedLocation> _locations = [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _loadedServiceId;

  List<SavedLocation> get locations => _locations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isRateLoading => _isRateLoading;
  RateResponse? get rateResponse => _rateResponse;
  bool _isRateLoading = false;
  RateResponse? _rateResponse;

  Future<void> loadLocations({required int serviceId}) async {
    if (_isLoading) return;
    if (_locations.isNotEmpty && _loadedServiceId == serviceId) return;
    _isLoading = true;
    _errorMessage = null;
    _locations = [];
    _loadedServiceId = serviceId;
    notifyListeners();
    try {
      _locations = await _service.getLocations(serviceId: serviceId);
    } on BikescreenException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Something went wrong while loading saved locations.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> savePickupLocation({
    required Map<String, dynamic> payload,
  }) async {
    _errorMessage = null;
    try {
      await _service.savePickupLocation(payload: payload);
      _locations = [];
      _loadedServiceId = null;
      notifyListeners();
      return true;
    } on BikescreenException catch (error) {
      _errorMessage = error.message;
      notifyListeners();
      return false;
    }
  }

  Future<RateResponse?> loadRates({required Map<String, dynamic> payload}) async {
    _isRateLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _rateResponse = await _service.getRates(
        serviceId: payload['service_id'] as int,
        subServiceId: payload['sub_service_id'] as int,
        packageTypeId: payload['package_type_id'] as int,
        weight: (payload['weight'] as num).toDouble(),
        pickupLat: (payload['pickup_lat'] as num).toDouble(),
        pickupLng: (payload['pickup_lng'] as num).toDouble(),
        dropLat: (payload['drop_lat'] as num).toDouble(),
        dropLng: (payload['drop_lng'] as num).toDouble(),
        pickupPincode: payload['pickup_pincode'] as String,
        deliveryPincode: payload['delivery_pincode'] as String,
      );
      return _rateResponse;
    } on BikescreenException catch (error) {
      _errorMessage = error.message;
      return null;
    } finally {
      _isRateLoading = false;
      notifyListeners();
    }
  }

  Future<OrderCreated?> createOrder({required Map<String, dynamic> payload}) async {
    _errorMessage = null;
    notifyListeners();
    try {
      return await _service.createOrder(payload: payload);
    } on BikescreenException catch (error) {
      _errorMessage = error.message;
      return null;
    }
  }
}
