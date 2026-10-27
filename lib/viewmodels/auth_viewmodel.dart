import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../models/profile_model.dart';
import '../core/network/dio_client.dart';


class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;

  Future<void> checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      try {
        final userData = jsonDecode(userDataString);
        _user = UserModel.fromJson(userData);
        notifyListeners();
      } catch (e) {
        await prefs.remove('user_data');
      }
    }
  }

  Future<bool> login(String email, String password, {String? deviceToken}) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      String? token = deviceToken;
      if (token == null) {
        try {
          token = await FirebaseMessaging.instance.getToken();
        } catch (e) {
          debugPrint('Error fetching FCM device token: $e');
        }
      }

      _user = await _authService.login(email, password, deviceToken: token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(_user!.toJson()));
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    if (_user != null) {
      try {
        await _authService.logout(_user!.userId);
      } catch (e) {
        debugPrint('Logout API failed: $e');
      }
    }
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('persisted_cookies');
    DioClient.cookies.clear();
    DioClient.csrfToken = null;
    notifyListeners();
  }

  Future<String?> register(Map<String, dynamic> userData) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final message = await _authService.register(userData);
      
      return message;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> forgotPassword(String email) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final message = await _authService.forgotPassword(email);
      return message;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<ProfileModel?> fetchProfile() async {
    if (_user == null) return null;
    _setLoading(true);
    _errorMessage = null;
    try {
      final profile = await _authService.getProfile(_user!.userId);
      return profile;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String mobile,
  }) async {
    if (_user == null) return false;

    _setLoading(true);
    _errorMessage = null;

    try {
      final success = await _authService.updateProfile(
        userId: _user!.userId,
        firstName: firstName,
        lastName: lastName,
        mobile: mobile,
      );
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (_user == null) return false;

    try {
      return await _authService.changePassword(
        userId: _user!.userId,
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    if (_user == null) return false;
    _setLoading(true);
    _errorMessage = null;
    try {
      final success = await _authService.deleteAccount(_user!.userId);
      if (success) {
        await logout();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
