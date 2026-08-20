import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yogayog/core/network/api_client.dart';
import 'package:yogayog/core/services/profile_service.dart';
import 'package:yogayog/core/services/home_service.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({ProfileService? service})
    : _service = service ?? ProfileService();

  final ProfileService _service;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.logout();
      await _clearLocalSession();
      return true;
    } on ProfileException catch (error) {
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

  Future<void> _clearLocalSession() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('auth_token');
    await preferences.remove('auth_user_id');
    await preferences.remove('auth_mobile');
    await preferences.remove(HomeService.profileNameKey);
    await preferences.remove(HomeService.profileEmailKey);
    await preferences.remove(HomeService.profileMobileKey);
    await preferences.remove(HomeService.profilePaymentModeKey);
    await preferences.remove(HomeService.profileAccountTypeKey);
    await preferences.remove(HomeService.profileAddressKey);
    await preferences.remove(HomeService.profileCityKey);
    await preferences.remove(HomeService.profilePinKey);
    await preferences.remove(HomeService.profileStateKey);
    ApiClient.clearToken();
  }
}
