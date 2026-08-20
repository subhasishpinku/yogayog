import 'package:flutter/foundation.dart';
import 'package:yogayog/core/services/branchaddresses_service.dart';

class BranchAddressesProvider extends ChangeNotifier {
  BranchAddressesProvider({BranchAddressesService? service})
    : _service = service ?? BranchAddressesService();

  final BranchAddressesService _service;
  bool _isLoading = false;
  String? _errorMessage;
  List<BranchAddress> _branches = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<BranchAddress> get branches => _branches;

  Future<void> loadBranches({
    required String city,
    required String stateCode,
  }) async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _branches = await _service.getBranches(city: city, stateCode: stateCode);
    } on BranchAddressesException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Something went wrong while loading branches.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
