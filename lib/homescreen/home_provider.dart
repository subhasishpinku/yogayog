import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yogayog/core/services/home_service.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider({HomeService? service}) : _service = service ?? HomeService();

  final HomeService _service;
  bool _isLoading = false;
  String? _errorMessage;
  ProfileData? _profile;
  List<StaticService> _services = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ProfileData? get profile => _profile;
  List<StaticService> get services => _services;

  Future<void> loadProfile() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final preferences = await SharedPreferences.getInstance();
      if (preferences.containsKey(HomeService.profileNameKey)) {
        _profile = ProfileData(
          name: preferences.getString(HomeService.profileNameKey) ?? '',
          email: preferences.getString(HomeService.profileEmailKey) ?? '',
          mobile: preferences.getString(HomeService.profileMobileKey) ?? '',
          paymentMode:
              preferences.getString(HomeService.profilePaymentModeKey) ?? '',
          accountType: _optionalPreference(
            preferences,
            HomeService.profileAccountTypeKey,
          ),
          address: _optionalPreference(
            preferences,
            HomeService.profileAddressKey,
          ),
          city: _optionalPreference(preferences, HomeService.profileCityKey),
          pin: _optionalPreference(preferences, HomeService.profilePinKey),
          state: _optionalPreference(preferences, HomeService.profileStateKey),
        );
        notifyListeners();
      }
      _profile = await _service.getProfile();
      await _saveProfile(preferences, _profile!);
    } on HomeException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Something went wrong while loading profile.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String? _optionalPreference(SharedPreferences preferences, String key) {
    final value = preferences.getString(key) ?? '';
    return value.isEmpty ? null : value;
  }

  Future<void> _saveProfile(
    SharedPreferences preferences,
    ProfileData profile,
  ) async {
    await Future.wait([
      preferences.setString(HomeService.profileNameKey, profile.name),
      preferences.setString(HomeService.profileEmailKey, profile.email),
      preferences.setString(HomeService.profileMobileKey, profile.mobile),
      preferences.setString(
        HomeService.profilePaymentModeKey,
        profile.paymentMode,
      ),
      preferences.setString(
        HomeService.profileAccountTypeKey,
        profile.accountType ?? '',
      ),
      preferences.setString(
        HomeService.profileAddressKey,
        profile.address ?? '',
      ),
      preferences.setString(HomeService.profileCityKey, profile.city ?? ''),
      preferences.setString(HomeService.profilePinKey, profile.pin ?? ''),
      preferences.setString(HomeService.profileStateKey, profile.state ?? ''),
    ]);
  }

  Future<void> loadServices() async {
    try {
      _services = await _service.getStaticServices();
    } on HomeException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Something went wrong while loading services.';
    } finally {
      notifyListeners();
    }
  }

  Future<TrackOrderData> trackOrder(String trackingNumber) {
    return _service.trackOrder(trackingNumber);
  }
}
