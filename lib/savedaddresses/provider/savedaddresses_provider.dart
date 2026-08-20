import 'package:flutter/foundation.dart';
import 'package:yogayog/savedaddresses/savedaddresses_service.dart';

class SavedAddressesProvider extends ChangeNotifier {
  SavedAddressesProvider({SavedAddressesService? service}) : _service = service ?? SavedAddressesService();
  final SavedAddressesService _service;
  List<SavedAddress> _addresses = const [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _loadedServiceId;

  List<SavedAddress> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAddresses(int serviceId) async {
    if (_isLoading || (_loadedServiceId == serviceId && _addresses.isNotEmpty)) return;
    _isLoading = true;
    _errorMessage = null;
    _addresses = const [];
    _loadedServiceId = serviceId;
    notifyListeners();
    try {
      _addresses = await _service.getAddresses(serviceId: serviceId);
    } on SavedAddressesException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Something went wrong while loading addresses.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(int serviceId) async {
    _loadedServiceId = null;
    await loadAddresses(serviceId);
  }
}
