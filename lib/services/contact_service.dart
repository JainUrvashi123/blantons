import 'dart:convert';
import 'package:dio/dio.dart';

import '../core/network/dio_client.dart';

class ContactService {
  final Dio _dio = DioClient().dio;

  Future<bool> submitContactForm({
    required String fullName,
    required String email,
    required String mobile,
    required String message,
  }) async {
    try {
      final response = await _dio.post(
        '/m_api/contact-submit',
        data: {
          'fullname': fullName,
          'email': email,
          'mobile': mobile,
          'massage': message, // Intentionally using 'massage' due to API spelling
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
          throw Exception(msg ?? 'Failed to submit form');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'An error occurred during submission'));
    }
  }
}
