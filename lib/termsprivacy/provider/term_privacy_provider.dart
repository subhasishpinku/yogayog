import 'package:flutter/foundation.dart';
import 'package:yogayog/core/services/term_privacy_services.dart';

class TermPrivacyProvider extends ChangeNotifier {
  TermPrivacyProvider({TermPrivacyService? service}) : _service = service ?? TermPrivacyService();
  final TermPrivacyService _service;
  TermsPrivacyDocument? _document;
  bool _isLoading = false;
  String? _errorMessage;

  TermsPrivacyDocument? get document => _document;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadTermsAndConditions() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _document = await _service.getTermsAndConditions();
    } on TermPrivacyException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Something went wrong while loading terms and privacy.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
