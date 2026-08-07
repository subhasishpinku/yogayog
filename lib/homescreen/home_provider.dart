import 'package:flutter/foundation.dart';
import 'package:yogayog/core/services/home_service.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider({HomeService? service}) : _service = service ?? HomeService();

  final HomeService _service;
  bool _isLoading = false;
  String? _errorMessage;
  ProfileData? _profile;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ProfileData? get profile => _profile;

  Future<void> loadProfile() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _service.getProfile();
    } on HomeException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Something went wrong while loading profile.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
