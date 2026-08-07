import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/services/login_save_service.dart';
import 'package:yogayog/core/services/mail_otp_service.dart';

class LoginSaveProvider extends ChangeNotifier {
  LoginSaveProvider({LoginSaveService? service, MailOtpService? mailOtpService})
    : _service = service ?? LoginSaveService(),
      _mailOtpService = mailOtpService ?? MailOtpService();

  final LoginSaveService _service;
  final MailOtpService _mailOtpService;
  bool _isLoading = false;
  bool _isSendingEmailOtp = false;
  bool _isVerifyingEmailOtp = false;
  bool _emailOtpSent = false;
  bool _emailOtpVerified = false;
  String? _errorMessage;
  RegisterCustomerResponse? _response;

  bool get isLoading => _isLoading;
  bool get isSendingEmailOtp => _isSendingEmailOtp;
  bool get isVerifyingEmailOtp => _isVerifyingEmailOtp;
  bool get emailOtpSent => _emailOtpSent;
  bool get emailOtpVerified => _emailOtpVerified;
  String? get errorMessage => _errorMessage;
  RegisterCustomerResponse? get response => _response;

  Future<bool> sendEmailOtp({
    required String email,
    required String name,
  }) async {
    _isSendingEmailOtp = true;
    _emailOtpVerified = false;
    _errorMessage = null;
    notifyListeners();
    try {
      await _mailOtpService.sendOtp(email: email, name: name);
      _emailOtpSent = true;
      return true;
    } on MailOtpException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong while sending email OTP.';
      return false;
    } finally {
      _isSendingEmailOtp = false;
      notifyListeners();
    }
  }

  Future<bool> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    _isVerifyingEmailOtp = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _mailOtpService.verifyOtp(email: email, otp: otp);
      _emailOtpVerified = true;
      return true;
    } on MailOtpException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong while verifying email OTP.';
      return false;
    } finally {
      _isVerifyingEmailOtp = false;
      notifyListeners();
    }
  }

  Future<bool> registerCustomer({
    required String name,
    required String email,
    required String clientType,
    required String paymentMode,
    required String address,
    required String city,
    required String state,
    required String pincode,
    required String mobile,
  }) async {
    if (!_emailOtpVerified) {
      _errorMessage = 'Please verify the email OTP first.';
      return false;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _response = await _service.registerCustomer(
        name: name,
        email: email,
        clientType: clientType,
        paymentMode: paymentMode,
        markupType: 'percent',
        address: address,
        city: city,
        state: state,
        pincode: pincode,
        mobile: mobile,
      );

      if (_response!.token.isEmpty) {
        throw const RegistrationException(
          'The server did not return a login token',
        );
      }

      ApiClient.setToken(_response!.token);
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString('auth_token', _response!.token);
      final user = _response!.user;
      if (user != null) {
        if (user.id != null) {
          await preferences.setInt('auth_user_id', user.id!);
        }
        await preferences.setString('auth_mobile', user.mobile);
      }
      return true;
    } on RegistrationException catch (error) {
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
