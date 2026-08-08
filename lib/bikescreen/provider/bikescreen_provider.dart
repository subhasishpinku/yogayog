import 'package:flutter/foundation.dart';
import 'package:yogayog/core/services/bikescreen_service.dart';

class BikescreenProvider extends ChangeNotifier {
  BikescreenProvider({BikescreenService? service}) : _service = service ?? BikescreenService();

  final BikescreenService _service;
  List<SavedLocation> _locations = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SavedLocation> get locations => _locations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadLocations() async {
    if (_isLoading || _locations.isNotEmpty) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _locations = await _service.getLocations();
    } on BikescreenException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Something went wrong while loading saved locations.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
