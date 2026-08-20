import 'package:flutter/foundation.dart';
import 'package:yogayog/core/services/truck_local_service.dart';

class TruckLocalProvider extends ChangeNotifier {
  TruckLocalProvider({TruckLocalService? service}) : _service = service ?? TruckLocalService();
  final TruckLocalService _service;
  bool _isLoading = false;
  String? _errorMessage;
  TruckRateResponse? _rates;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TruckRateResponse? get rates => _rates;

  Future<TruckRateResponse?> loadRates({required Map<String, dynamic> payload}) async {
    if (_isLoading) return null;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _rates = await _service.getRates(payload: payload);
      return _rates;
    } on TruckLocalException catch (error) {
      _errorMessage = error.message;
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
