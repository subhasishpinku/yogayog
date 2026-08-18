import 'package:flutter/foundation.dart';
import 'package:yogayog/core/services/nearesthub_service.dart';

class NearestHubProvider extends ChangeNotifier {
  NearestHubProvider({NearestHubService? service})
    : _service = service ?? NearestHubService();

  final NearestHubService _service;
  bool _isLoading = false;
  String? _errorMessage;
  List<NearbyHub> _hubs = const [];
  List<NearbyBranch> _branches = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<NearbyHub> get hubs => _hubs;
  List<NearbyBranch> get branches => _branches;

  Future<void> loadNearbyHubs({
    required String city,
    required String stateCode,
  }) async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('Loading nearby hubs for city: $city, stateCode: $stateCode');
      final result = await _service.getNearbyBranches(
        city: city,
        stateCode: stateCode,
      );
      _hubs = result.hubs;
      _branches = result.branches;
    } on NearestHubException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Something went wrong while loading nearby hubs.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
