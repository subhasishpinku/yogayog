import 'package:flutter/foundation.dart';
import 'package:yogayog/core/services/bikescreen_service.dart';

class BikescreenProvider extends ChangeNotifier {
  BikescreenProvider({BikescreenService? service}) : _service = service ?? BikescreenService();

  final BikescreenService _service;
  List<SavedLocation> _locations = [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _loadedServiceId;

  List<SavedLocation> get locations => _locations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadLocations({required int serviceId}) async {
    if (_isLoading) return;
    if (_locations.isNotEmpty && _loadedServiceId == serviceId) return;
    _isLoading = true;
    _errorMessage = null;
    _locations = [];
    _loadedServiceId = serviceId;
    notifyListeners();
    try {
      _locations = await _service.getLocations(serviceId: serviceId);
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
