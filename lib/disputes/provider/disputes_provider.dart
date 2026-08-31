import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yogayog/core/services/disputes_service.dart';

class DisputesProvider extends ChangeNotifier {
  DisputesProvider({DisputesService? service}) : _service = service ?? DisputesService();
  final DisputesService _service;
  bool _isSubmitting = false;
  String? _errorMessage;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  Future<bool> submitIssue({required int orderId, required String issue, required String description, required List<XFile> photos, XFile? video}) async {
    if (_isSubmitting) return false;
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.sendIssue(orderId: orderId, issue: issue, description: description, photos: photos, video: video);
      return true;
    } on DisputesException catch (error) {
      _errorMessage = error.message;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
