import 'package:flutter/foundation.dart';
import 'package:yogayog/core/services/viewledger_service.dart';

class ViewledgerProvider extends ChangeNotifier {
  ViewledgerProvider({ViewledgerService? service})
    : _service = service ?? ViewledgerService();

  final ViewledgerService _service;
  WalletLedger? _ledger;
  bool _isLoading = false;
  String? _errorMessage;

  WalletLedger? get ledger => _ledger;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadLedger() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _ledger = await _service.getLedger();
    } on ViewledgerException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Something went wrong while loading wallet ledger.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
