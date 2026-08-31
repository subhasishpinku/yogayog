import 'package:flutter/foundation.dart';
import 'package:yogayog/core/services/international_details_services.dart';
import 'package:yogayog/core/services/national_service.dart';

class InternationalDetailsProvider extends ChangeNotifier {
  InternationalDetailsProvider({InternationalDetailsService? service})
    : _service = service ?? InternationalDetailsService();

  final InternationalDetailsService _service;
  bool _isLoading = false;
  String? _errorMessage;
  NationalRateResponse? _rates;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  NationalRateResponse? get rates => _rates;

  Future<NationalRateResponse?> loadRates({
    required Map<String, dynamic> payload,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _rates = await _service.getRates(payload: payload);
      return _rates;
    } on InternationalDetailsException catch (error) {
      _errorMessage = error.message;
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<NationalOrderResponse?> createPostpaidOrder({
    required Map<String, dynamic> payload,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      return await _service.createPostpaidOrder(payload: payload);
    } on InternationalDetailsException catch (error) {
      _errorMessage = error.message;
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
