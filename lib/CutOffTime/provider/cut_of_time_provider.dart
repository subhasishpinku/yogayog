
import 'package:flutter/foundation.dart';
import 'package:yogayog/core/services/cut_of_time_service.dart';

class CutOffTimeProvider extends ChangeNotifier {
  CutOffTimeProvider({CutOffTimeService? service})
    : _service = service ?? CutOffTimeService();

  final CutOffTimeService _service;
  bool _isLoading = false;
  String? _errorMessage;
  List<CutOffTimeData> _cutOffTimes = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<CutOffTimeData> get cutOffTimes => _cutOffTimes;

  Future<void> loadCutOffTimes() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cutOffTimes = await _service.getCutOffTimes();
    } on CutOffTimeException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Something went wrong while loading cut-off times.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
