import 'dart:convert';
import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../models/notification_model.dart';

class NotificationService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> getNotifications(String userId) async {
    try {
      final response = await _dio.post(
        '/m_api/notifications',
        data: {
          'user_id': userId,
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
          final int notificationCount = responseData['notification_count'] != null
              ? int.tryParse(responseData['notification_count'].toString()) ?? 0
              : 0;

          final list = (responseData['data'] as List?)
                  ?.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              [];

          return {
            'notification_count': notificationCount,
            'data': list,
          };
        } else {
          final msg = responseData is Map ? responseData['message'] : null;
          throw Exception(msg ?? 'Failed to fetch notifications');
        }
      } else {
        throw Exception('Failed to communicate with server');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'An error occurred fetching notifications'));
    }
  }
}
