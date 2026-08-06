import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/services/login_save_service.dart';

class LoginSaveProvider extends ChangeNotifier {
  LoginSaveProvider({LoginSaveService? service})
    : _service = service ?? LoginSaveService();

  final LoginSaveService _service;
  bool _isLoading = false;
  String? _errorMessage;
  RegisterCustomerResponse? _response;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RegisterCustomerResponse? get response => _response;

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
