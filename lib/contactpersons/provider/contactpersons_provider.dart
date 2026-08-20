import 'package:flutter/foundation.dart';
import 'package:yogayog/core/services/contactpersons_service.dart';

class ContactPersonsProvider extends ChangeNotifier {
  ContactPersonsProvider({ContactPersonsService? service})
    : _service = service ?? ContactPersonsService();

  final ContactPersonsService _service;
  bool _isLoading = false;
  String? _errorMessage;
  ContactPersonsData? _contacts;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ContactPersonsData? get contacts => _contacts;

  Future<void> loadContacts() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _contacts = await _service.getContacts();
    } on ContactPersonsException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Something went wrong while loading contacts.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
