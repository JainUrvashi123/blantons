import 'package:flutter/foundation.dart';
import '../services/contact_service.dart';

class ContactViewModel extends ChangeNotifier {
  final ContactService _contactService = ContactService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  Future<bool> submitContactForm({
    required String fullName,
    required String email,
    required String mobile,
    required String message,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final success = await _contactService.submitContactForm(
        fullName: fullName,
        email: email,
        mobile: mobile,
        message: message,
      );

      if (success) {
        _successMessage = "Thank you for contacting us. We will contact you very soon!";
        return true;
      } else {
        _errorMessage = "Failed to submit form.";
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
