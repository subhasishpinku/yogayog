import 'package:flutter/foundation.dart';
import 'package:yogayog/adddropadress/add_drop_address_service.dart';

class AddDropAddressProvider extends ChangeNotifier {
  AddDropAddressProvider({AddDropAddressService? service}) : _service = service ?? AddDropAddressService();
  final AddDropAddressService _service;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> addPickupAddress({required Map<String, dynamic> payload}) async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.addPickupAddress(payload: payload);
      return true;
    } on AddDropAddressException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong while saving address.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
