import 'dart:convert';
import 'package:dio/dio.dart';

import '../core/network/dio_client.dart';
import '../models/my_file_model.dart';

class MyFilesService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, List<MyFileModel>>> getCustomerS3Files(String cadGalleryName) async {
    try {
      final response = await _dio.get(
        '/m_api/get-customer-s3-files',
        data: {
          'customer_id': cadGalleryName,
        },
      );

      var responseData = response.data;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (_) {}
      }

      if (response.statusCode == 200) {
        if (responseData is Map && (responseData['status'] == true || responseData['status'] == 1)) {
          final data = responseData['data'] as Map<String, dynamic>? ?? {};
          final myGallery = (data['mygallery'] as List?)?.map((item) => MyFileModel.fromJson(item)).toList() ?? [];
          final myCad = (data['mycad'] as List?)?.map((item) => MyFileModel.fromJson(item)).toList() ?? [];
          return {
            'mygallery': myGallery,
            'mycad': myCad,
          };
        } else {
          final msg = responseData is Map ? responseData['message'] : null;
          throw msg ?? 'Failed to fetch files';
        }
      } else {
        throw 'Server error';
      }
    } on DioException catch (e) {
      throw 'Network error: ${DioClient.getErrorMessage(e)}';
    } catch (e) {
      if (e is String) rethrow;
      throw 'An error occurred';
    }
  }
}
