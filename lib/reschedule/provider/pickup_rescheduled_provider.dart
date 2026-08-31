import 'package:flutter/foundation.dart';
import 'package:yogayog/core/services/pickup_rescheduled_service.dart';

class PickupRescheduledProvider extends ChangeNotifier {
  PickupRescheduledProvider({PickupRescheduledService? service})
      : _service = service ?? PickupRescheduledService();
  final PickupRescheduledService _service;
  bool _isSubmitting = false;
  String? _errorMessage;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  Future<bool> reschedulePickup({required String orderId, required String pickupDate, required String pickupTime}) async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.reschedulePickup(orderId: orderId, pickupDate: pickupDate, pickupTime: pickupTime);
      return true;
    } on PickupRescheduledException catch (error) {
      _errorMessage = error.message;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
