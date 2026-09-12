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
  List<KycDocument> _documents = const [];
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<KycDocument> get documents => _documents;

  Future<void> loadDocuments() async {
    try {
      _documents = await _service.getDocuments();
      notifyListeners();
    } on PaperworkRequiredException catch (error) {
      _errorMessage = error.message;
      notifyListeners();
    }
  }

  Future<bool> verifyAndUploadPan({
    required String pan,
    required XFile image,
  }) async {
    print(
      'verifyAndUploadPan called with pan: $pan, image path: ${image.path}',
    );
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final verifiedName = await _service.verifyPan(pan);
      final preferences = await SharedPreferences.getInstance();
      final profileName =
          preferences.getString(HomeService.profileNameKey) ?? '';
      print('Verified name: $verifiedName, Profile name: $profileName');
      String normalize(String value) =>
          value.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();
      if (normalize(verifiedName) != normalize(profileName)) {
        throw const PaperworkRequiredException(
          'PAN name does not match your profile name',
        );
      }
      await _service.uploadPan(number: pan, image: image);
      await loadDocuments();
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

  Future<bool> uploadDocument({
    required String documentType,
    required XFile image,
  }) async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.uploadDocument(documentType: documentType, image: image);
      await loadDocuments();
      return true;
    } on PaperworkRequiredException catch (error) {
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

  Future<bool> verifyAndUploadAadhar({
    required String aadhar,
    required XFile image,
  }) async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final verifiedName = await _service.verifyAadhar(aadhar);
      final preferences = await SharedPreferences.getInstance();
      final profileName =
          preferences.getString(HomeService.profileNameKey) ?? '';
      String normalize(String value) =>
          value.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();
      if (verifiedName.trim().isNotEmpty &&
          normalize(verifiedName) != normalize(profileName)) {
        throw const PaperworkRequiredException(
          'Aadhaar name does not match your profile name',
        );
      }
      await _service.uploadDocument(
        documentType: 'aadhar',
        number: aadhar,
        image: image,
      );
      await loadDocuments();
      return true;
    } on PaperworkRequiredException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong while verifying Aadhaar.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyAndUploadVoter({
    required String voterNo,
    required XFile image,
  }) async {
    if (_isLoading) return false;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final verifiedName = await _service.verifyVoter(voterNo);
      final preferences = await SharedPreferences.getInstance();
      final profileName =
          preferences.getString(HomeService.profileNameKey) ?? '';
      String normalize(String value) =>
          value.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();
      if (normalize(verifiedName) != normalize(profileName)) {
        throw const PaperworkRequiredException(
          'Voter ID name does not match your profile name',
        );
      }
      await _service.uploadDocument(
        documentType: 'voter',
        number: voterNo,
        image: image,
      );
      await loadDocuments();
      return true;
    } on PaperworkRequiredException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong while verifying Voter ID.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
