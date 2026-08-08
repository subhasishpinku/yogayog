import 'package:flutter/foundation.dart';
import 'package:yogayog/core/services/history_service.dart';

class HistoryProvider extends ChangeNotifier {
  HistoryProvider({HistoryService? service}) : _service = service ?? HistoryService();

  final HistoryService _service;
  BookingHistory? _history;
  bool _isLoading = false;
  String? _errorMessage;

  BookingHistory? get history => _history;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadBookings({int? serviceId, int? subServiceId}) async {
    if (_isLoading) return;
    _isLoading = true;
    _history = null;
    _errorMessage = null;
    notifyListeners();
    try {
      _history = await _service.getBookings(
        serviceId: serviceId,
        subServiceId: subServiceId,
      );
    } on HistoryException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Something went wrong while loading bookings.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
