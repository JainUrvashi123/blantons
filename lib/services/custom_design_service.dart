import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';

class CustomDesignService {
  final Dio _dio = DioClient().dio;

  Future<String> submitCustomDesign(Map<String, dynamic> data, {List<String>? imagePaths}) async {
    try {
      var formDataMap = <String, dynamic>{};
      
      data.forEach((key, value) {
        if (value != null) {
          formDataMap[key] = value.toString();
        }
      });

      var formData = FormData.fromMap(formDataMap);

      if (imagePaths != null && imagePaths.isNotEmpty) {
        for (String path in imagePaths) {
          File file = File(path);
          if (await file.exists()) {
            String fileName = path.split('/').last.split('\\').last;
            formData.files.add(MapEntry(
              'img_upload[]',
              await MultipartFile.fromFile(path, filename: fileName),
            ));
          }
        }
      }

      final response = await _dio.post(
        '/m_api/custom-design-submit',
        data: formData,
        options: Options(responseType: ResponseType.plain),
      );

      var responseData = response.data;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (_) {}
      }

      if (response.statusCode == 200) {
        if (responseData is Map && (responseData['status'] == 1 || responseData['code'] == 1 || responseData['message'] == 'success')) {
          return responseData['message'] ?? 'Successfully submitted custom design request.';
        } else {
          final msg = responseData is Map ? responseData['message'] : null;
          throw Exception(msg ?? 'Failed to submit custom design.');
        }
      } else {
        throw Exception('Failed to communicate with server');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'An error occurred during submission'));
    }
  }

}
