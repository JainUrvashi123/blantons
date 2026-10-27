import 'dart:convert';
import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../models/user_model.dart';
import '../models/profile_model.dart';

class AuthService
{
  final Dio _dio = DioClient().dio;

  Future<UserModel> login(String email, String password, {String? deviceToken}) async {
    try {
      final Map<String, dynamic> requestData = {
        'username': email,
        'password': password,
      };
      if (deviceToken != null && deviceToken.isNotEmpty) {
        requestData['device_token'] = deviceToken;
      }
      final response = await _dio.post(
        '/m_api/login',
        data: requestData,
      );

      var responseData = response.data;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (_) {}
      }

      if (response.statusCode == 200) {
        if (responseData is Map && responseData['status'] == 1) {
          final dataField = responseData['data'];
          if (dataField is List) {
            if (dataField.isNotEmpty) {
              return UserModel.fromJson(dataField.first as Map<String, dynamic>);
            } else {
              throw Exception('User data is empty');
            }
          } else if (dataField is Map<String, dynamic>) {
            return UserModel.fromJson(dataField);
          } else {
            throw Exception('Unexpected data format from server');
          }
        } else {
          final msg = responseData is Map ? responseData['message'] : null;
          throw Exception(msg ?? 'Login failed');
        }
      } else {
         throw Exception('Failed to communicate with server');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'An error occurred during login'));
    }
  }

  Future<String> register(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '/m_api/signup',
        data: data,
      );

      var responseData = response.data;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (_) {}
      }

      if (response.statusCode == 200) {
        if (responseData is Map && responseData['status'] == 1) {
          return responseData['message'] ?? 'Thanks for registration. Admin will verify your account soon!';
        } else {
          final msg = responseData is Map ? responseData['message'] : null;
          throw Exception(msg ?? 'Signup failed');
        }
      } else {
         throw Exception('Failed to communicate with server');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'An error occurred during signup'));
    }
  }

  Future<String> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        '/m_api/forgot-password',
        data: {
          'email': email,
        },
      );

      var responseData = response.data;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (_) {}
      }

      if (response.statusCode == 200) {
        if (responseData is Map && responseData['status'] == 1) {
          return responseData['message'] ?? 'Password reset link sent to your email';
        } else {
          final msg = responseData is Map ? responseData['message'] : null;
          throw Exception(msg ?? 'Forgot password request failed');
        }
      } else {
         throw Exception('Failed to communicate with server');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'An error occurred'));
    }
  }
  Future<ProfileModel> getProfile(String userId) async {
    try {

      final response = await _dio.request(
        '/m_api/get-profile',
        options: Options(method: 'GET'),
        data: {
          'userId': userId,
        },
      );

      var responseData = response.data;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (_) {}
      }

      if (response.statusCode == 200) {
        if (responseData is Map && responseData['status'] == 1) {
          final dataField = responseData['data'];
          if (dataField is Map<String, dynamic>) {
            return ProfileModel.fromJson(dataField);
          } else {
            throw Exception('Unexpected data format from server');
          }
        } else {
          final msg = responseData is Map ? responseData['message'] : null;
          throw Exception(msg ?? 'Failed to fetch profile');
        }
      } else {
         throw Exception('Failed to communicate with server');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'An error occurred during profile fetch'));
    }
  }

  Future<bool> updateProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String mobile,
  }) async {
    try {
      final response = await _dio.post(
        '/m_api/profile-update',
        data: {
          "userId": int.parse(userId),
          "firstname": firstName,
          "lastname": lastName,
          "mobile": mobile,
        },
      );

      var responseData = response.data;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (_) {}
      }

      if (response.statusCode == 200) {
        if (responseData is Map && responseData['status'] == 1) {
          return true;
        } else {
          final msg = responseData is Map ? responseData['message'] : null;
          throw Exception(msg ?? 'Update failed');
        }
      } else {
        throw Exception('Server error');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'Something went wrong'));
    }
  }

  Future<bool> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/m_api/password-update',
        data: {
          "user_id": userId,
          "old_password": currentPassword,
          "new_password": newPassword,
          "confirm_password": confirmPassword,
        },
      );

      var responseData = response.data;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (_) {}
      }

      if (response.statusCode == 200) {
        return responseData is Map && responseData['status'] == 1;
      } else {
        throw Exception("Server error");
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'Password update failed'));
    }
  }

  Future<bool> deleteAccount(String userId) async {
    try {
      final response = await _dio.post(
        '/m_api/delete-account',
        data: {
          "user_id": userId,
        },
      );

      var responseData = response.data;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (_) {}
      }

      if (response.statusCode == 200) {
        if (responseData is Map && responseData['status'] == 1) {
          return true;
        } else {
          final msg = responseData is Map ? responseData['message'] : null;
          throw Exception(msg ?? 'Delete account failed');
        }
      } else {
        throw Exception('Server error');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'Something went wrong'));
    }
  }

  Future<bool> logout(String userId) async {
    try {
      final response = await _dio.post(
        '/m_api/logout',
        data: FormData.fromMap({
          'user_id': userId,
        }),
      );

      var responseData = response.data;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (_) {}
      }

      if (response.statusCode == 200) {
        if (responseData is Map) {
          if (responseData['status'] == 1 || responseData['status'] == true) {
            return true;
          } else {
            final msg = responseData['message'];
            throw Exception(msg ?? 'Logout failed');
          }
        }
        // Fallback for HTML page redirects or blank 200 OK responses
        return true;
      } else {
        throw Exception('Failed to communicate with server');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'An error occurred during logout'));
    }
  }
}
