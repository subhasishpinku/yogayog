import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yogayog/core/services/home_service.dart';
import 'package:yogayog/core/services/paperwork_required_service.dart';

class PaperworkRequiredProvider extends ChangeNotifier {
  PaperworkRequiredProvider({PaperworkRequiredService? service})
      : _service = service ?? PaperworkRequiredService();

  final PaperworkRequiredService _service;
  bool _isLoading = false;
  String? _errorMessage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> verifyAndUploadPan({required String pan, required XFile image}) async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final verifiedName = await _service.verifyPan(pan);
      final preferences = await SharedPreferences.getInstance();
      final profileName = preferences.getString(HomeService.profileNameKey) ?? '';
      String normalize(String value) => value.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();
      if (normalize(verifiedName) != normalize(profileName)) {
        throw const PaperworkRequiredException(
          'PAN name does not match your profile name',
        );
      }
      await _service.uploadPan(image: image);
      return true;
    } on PaperworkRequiredException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong while verifying PAN.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
