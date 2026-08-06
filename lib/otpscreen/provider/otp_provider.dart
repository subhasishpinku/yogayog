import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/services/otp_service.dart';

class OtpProvider extends ChangeNotifier {
  OtpProvider({OtpService? otpService}) : _otpService = otpService ?? OtpService();

  final OtpService _otpService;
  bool _isLoading = false;
  String? _errorMessage;
  VerifyOtpResponse? _response;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  VerifyOtpResponse? get response => _response;

  Future<bool> verifyOtp({
    required String mobile,
    required String otp,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _response = await _otpService.verifyOtp(mobile: mobile, otp: otp);
      if (_response!.token.isEmpty) {
        throw const OtpException('The server did not return a login token');
      }

      ApiClient.setToken(_response!.token);
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString('auth_token', _response!.token);
      return true;
    } on OtpException catch (error) {
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
}
