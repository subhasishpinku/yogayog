import 'package:flutter/foundation.dart';
import 'package:yogayog/core/services/bookingsuccess_service.dart';
import 'package:yogayog/core/services/payment_service.dart';

class BookingSuccessProvider extends ChangeNotifier {
  BookingSuccessProvider({BookingSuccessService? service})
    : _service = service ?? BookingSuccessService();

  final BookingSuccessService _service;
  bool _isDownloading = false;
  String? _errorMessage;

  bool get isDownloading => _isDownloading;
  String? get errorMessage => _errorMessage;

  Future<List<int>?> downloadInvoice(int orderId) async {
    if (_isDownloading) return null;
    _isDownloading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      return await _service.downloadInvoice(orderId: orderId);
    } on BookingSuccessException catch (error) {
      _errorMessage = error.message;
      return null;
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  Future<List<int>?> downloadInvoiceForOrder(PaymentOrderResponse order) async {
    if (_isDownloading) return null;
    _isDownloading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      return await _service.downloadInvoiceForOrder(order: order);
    } on BookingSuccessException catch (error) {
      _errorMessage = error.message;
      return null;
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }
}
