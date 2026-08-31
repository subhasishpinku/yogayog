import 'package:flutter/foundation.dart';
import 'package:yogayog/core/services/invoices_service.dart';

class InvoicesProvider extends ChangeNotifier {
  InvoicesProvider({InvoicesService? service})
    : _service = service ?? InvoicesService();

  final InvoicesService _service;
  List<InvoiceData> _invoices = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<InvoiceData> get invoices => _invoices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get pendingCount => _invoices
      .where((invoice) => invoice.paymentStatus.toLowerCase() == 'pending')
      .length;

  Future<void> loadInvoices() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _service.getInvoices();
      _invoices = response.invoices;
    } on InvoicesException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Something went wrong while loading invoices.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<int>> downloadInvoice(int orderId) {
    return _service.downloadInvoice(orderId);
  }
}
