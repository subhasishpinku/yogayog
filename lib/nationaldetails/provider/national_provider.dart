import 'package:flutter/foundation.dart';
import 'package:yogayog/core/services/pincodecheck_service.dart';
import 'package:yogayog/core/services/national_service.dart';

class NationalProvider extends ChangeNotifier {
  NationalProvider({NationalService? service})
    : _service = service ?? NationalService();

  final NationalService _service;
  bool _isLoading = false;
  String? _errorMessage;
  PincodeServiceability? _result;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PincodeServiceability? get result => _result;
  NationalRateResponse? _rates;
  NationalRateResponse? get rates => _rates;

  Future<bool> checkPincode(String pincode) async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = null;
    _result = null;
    notifyListeners();
    try {
      _result = await _service.checkPincode(pincode);
      return _result?.serviceable == true;
    } on PincodeCheckException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong while checking the pincode.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<NationalRateResponse?> loadRates({
    required Map<String, dynamic> payload,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _rates = await _service.getRates(payload: payload);
      return _rates;
    } on NationalException catch (error) {
      _errorMessage = error.message;
      return null;
    } catch (_) {
      _errorMessage = 'Something went wrong while calculating rates.';
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
    } on NationalException catch (error) {
      _errorMessage = error.message;
      return null;
    } catch (_) {
      _errorMessage = 'Something went wrong while creating post-paid order.';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
