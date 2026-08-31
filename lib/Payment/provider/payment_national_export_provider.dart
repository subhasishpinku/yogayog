import 'package:flutter/foundation.dart';
import 'package:yogayog/core/services/payment_national_service_export.dart';
import 'package:yogayog/core/services/payment_service.dart';

class PaymentNationalExportProvider extends ChangeNotifier {
  PaymentNationalExportProvider({PaymentNationalExportService? service})
    : _service = service ?? PaymentNationalExportService();

  final PaymentNationalExportService _service;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<PaymentOrderResponse?> createOrder({
    required Map<String, dynamic> payload,
  }) async {
    if (_isLoading) return null;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      return await _service.createOrder(payload: payload);
    } on PaymentNationalExportException catch (error) {
      _errorMessage = error.message;
      return null;
    } catch (_) {
      _errorMessage = 'Something went wrong while creating export order.';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
