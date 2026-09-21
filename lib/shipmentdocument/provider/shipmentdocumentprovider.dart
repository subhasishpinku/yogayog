import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yogayog/core/services/shipment_document_service.dart';

class ShipmentDocumentProvider extends ChangeNotifier {
  ShipmentDocumentProvider({ShipmentDocumentService? service})
    : _service = service ?? ShipmentDocumentService();

  final ShipmentDocumentService _service;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> uploadDocument({
    required String orderId,
    required String documentType,
    required XFile file,
  }) async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.uploadDocument(
        orderId: orderId,
        documentType: documentType,
        file: file,
      );
      return true;
    } on ShipmentDocumentException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong while uploading document.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
