import 'package:flutter/foundation.dart';
import 'package:yogayog/core/services/national_service_import.dart';

class InternationalImportProvider extends ChangeNotifier {
  InternationalImportProvider({NationalImportService? service})
    : _service = service ?? NationalImportService();
  final NationalImportService _service;
  NationalRateResponse? _rates;
  String? _errorMessage;
  bool _isLoading = false;
  NationalRateResponse? get rates => _rates;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<NationalRateResponse?> loadRates({
    required Map<String, dynamic> payload,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _rates = await _service.getRates(payload: payload);
      return _rates;
    } on NationalImportException catch (error) {
      _errorMessage = error.message;
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> createPostpaidOrder({
    required Map<String, dynamic> payload,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      return await _service.createPostpaidOrder(payload: payload);
    } on NationalImportException catch (error) {
      _errorMessage = error.message;
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
