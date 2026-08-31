
import 'package:flutter/foundation.dart';
import 'package:yogayog/core/services/payment_national_service_import.dart';
import 'package:yogayog/core/services/payment_service.dart';

class PaymentNationalImportProvider extends ChangeNotifier {
  PaymentNationalImportProvider({PaymentNationalImportService? service}) : _service = service ?? PaymentNationalImportService();
  final PaymentNationalImportService _service;
  bool _isLoading = false;
  String? _errorMessage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Future<PaymentOrderResponse?> createOrder({required Map<String, dynamic> payload}) async {
    if (_isLoading) return null;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      return await _service.createOrder(payload: payload);
    } on PaymentNationalImportException catch (error) {
      _errorMessage = error.message;
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
