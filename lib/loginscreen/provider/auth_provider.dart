import 'package:flutter/foundation.dart';
import 'package:yogayog/core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService})
    : _authService = authService ?? AuthService();

  final AuthService _authService;
  bool _isLoading = false;
  String? _errorMessage;
  SendOtpResponse? _lastOtpResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SendOtpResponse? get lastOtpResponse => _lastOtpResponse;

  Future<bool> sendOtp(String mobile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _lastOtpResponse = await _authService.sendOtp(mobile: mobile);
      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
