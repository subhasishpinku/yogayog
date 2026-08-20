import 'package:flutter/foundation.dart';
import 'package:yogayog/core/services/pincodecheck_service.dart';

class PincodeCheckProvider extends ChangeNotifier {
  PincodeCheckProvider({PincodeCheckService? service})
    : _service = service ?? PincodeCheckService();

  final PincodeCheckService _service;
  bool _isLoading = false;
  String? _errorMessage;
  PincodeServiceability? _result;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PincodeServiceability? get result => _result;

  Future<bool> checkPincode(String pincode) async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _result = await _service.checkPincode(pincode);
      return true;
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
}
