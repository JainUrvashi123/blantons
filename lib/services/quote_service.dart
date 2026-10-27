import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../models/quote_detail_model.dart';
import '../models/quote_model.dart';

class QuoteService {
  final Dio _dio = DioClient().dio;

  Future<QuoteResponse> getQuotes(String userId, {String offset = '0', String limit = '500'}) async {
    try {
      final response = await _dio.get(
        '/m_api/my-quotes',
        data: {
          'user_id': userId,
          'offset': offset,
          'limit': limit,
        },
      );

      var responseData = response.data;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (_) {}
      }

      if (response.statusCode == 200) {
        if (responseData is Map && (responseData['status'] == 1 || responseData['code'] == 1)) {
          return QuoteResponse.fromJson(responseData['data'] ?? {});
        } else {
          final msg = responseData is Map ? responseData['message'] : null;
          throw Exception(msg ?? 'Failed to fetch quotes');
        }
      } else {
        throw Exception('Failed to communicate with server');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'An error occurred fetching quotes'));
    }
  }

  Future<QuoteResponse> getMyOrders(String userId, {String offset = '0', String limit = '500'}) async {
    try {
      final response = await _dio.get(
        '/m_api/my-orders',
        data: {
          'user_id': userId,
          'offset': offset,
          'limit': limit,
        },
      );

      var responseData = response.data;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (_) {}
      }

      if (response.statusCode == 200) {
        if (responseData is Map && (responseData['status'] == 1 || responseData['code'] == 1)) {
          return QuoteResponse.fromJson(responseData['data'] ?? {});
        } else {
          final msg = responseData is Map ? responseData['message'] : null;
          throw Exception(msg ?? 'Failed to fetch orders');
        }
      } else {
        throw Exception('Failed to communicate with server');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'An error occurred fetching orders'));
    }
  }

  Future<QuoteResponse> getCompletedOrders(String userId, {String offset = '0', String limit = '500'}) async {
    try {
      final response = await _dio.get(
        '/m_api/completed-orders',
        data: {
          'user_id': userId,
          'offset': offset,
          'limit': limit,
        },
      );

      var responseData = response.data;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (_) {}
      }

      if (response.statusCode == 200) {
        if (responseData is Map && (responseData['status'] == 1 || responseData['code'] == 1)) {
          return QuoteResponse.fromJson(responseData['data'] ?? {});
        } else {
          final msg = responseData is Map ? responseData['message'] : null;
          throw Exception(msg ?? 'Failed to fetch completed orders');
        }
      } else {
        throw Exception('Failed to communicate with server');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'An error occurred fetching completed orders'));
    }
  }

  Future<QuoteDetailResponse> getQuoteDetail(String designId) async {
    try {
      final response = await _dio.post(
        '/m_api/design-detail',
        data: {
          'design_id': designId,
        },
      );

      var responseData = response.data;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (_) {}
      }

      if (response.statusCode == 200) {
        if (responseData is Map && (responseData['status'] == 1 || responseData['code'] == 1)) {
          return QuoteDetailResponse.fromJson(Map<String, dynamic>.from(responseData));
        } else {
          final msg = responseData is Map ? responseData['message'] : null;
          throw Exception(msg ?? 'Failed to fetch quote details');
        }
      } else {
        throw Exception('Failed to communicate with server');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'An error occurred fetching quote details'));
    }
  }

  Future<void> submitReply(String designId, String userId, String reply, {List<String>? imagePaths}) async {
    try {
      var formDataMap = <String, dynamic>{
        'design_id': designId,
        'user_id': userId,
        'reply': reply,
      };

      if (imagePaths != null && imagePaths.isNotEmpty) {
        List<MultipartFile> fileList = [];
        for (String path in imagePaths) {
          File file = File(path);
          if (await file.exists()) {
            fileList.add(await MultipartFile.fromFile(path));
          }
        }
        
        if (fileList.isNotEmpty) {
          formDataMap['img_upload[]'] = fileList;
        }
      }

      var formData = FormData.fromMap(formDataMap);

      final response = await _dio.post(
        '/m_api/design-process-submit',
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
        if (responseData is Map && (responseData['status'] == 1 || responseData['code'] == 1)) {
          return;
        } else {
          final msg = responseData is Map ? responseData['message'] : null;
          throw Exception(msg ?? 'Failed to submit reply');
        }
      } else {
        throw Exception('Failed to communicate with server');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'An error occurred submitting reply'));
    }
  }

  Future<void> sendImagesInEmail(String designId, String email) async {
    try {
      final response = await _dio.post(
        '/m_api/send-images',
        data: {
          'design_id': designId,
          'email': email,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      var responseData = response.data;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (_) {}
      }

      if (response.statusCode == 200) {
        if (responseData is Map && (responseData['status'] == 1 || responseData['code'] == 1 || responseData['status'] == true)) {
          return;
        } else {
          final msg = responseData is Map ? responseData['message'] : null;
          throw Exception(msg ?? 'Failed to send images');
        }
      } else {
        throw Exception('Failed to communicate with server');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'An error occurred sending images'));
    }
  }

  Future<AdminDesignsResponse> getAdminDesigns() async {
    try {
      final response = await _dio.get('/m_api/design-list');

      var responseData = response.data;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (_) {}
      }

      if (response.statusCode == 200) {
        if (responseData is Map && (responseData['status'] == true || responseData['status'] == 1)) {
          final recordsList = (responseData['records'] as List?)
                  ?.map((e) => QuoteModel.fromJson(e))
                  .toList() ??
              [];
          final int? adminCount = responseData['admin_notification_count'] != null
              ? int.tryParse(responseData['admin_notification_count'].toString())
              : null;
          final int? userCount = responseData['user_notification_count'] != null
              ? int.tryParse(responseData['user_notification_count'].toString())
              : null;

          return AdminDesignsResponse(
            records: recordsList,
            adminNotificationCount: adminCount,
            userNotificationCount: userCount,
          );
        } else {
          final msg = responseData is Map ? responseData['message'] : null;
          throw Exception(msg ?? 'Failed to fetch admin design list');
        }
      } else {
        throw Exception('Failed to communicate with server');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'An error occurred fetching admin design list'));
    }
  }

  Future<void> submitDesignEdit({
    required String designId,
    required String isApproved,
    required String processingStatus,
    required String diamondWeight,
    required String colorDiamondWeight,
    required String budget,
    required String metal,
    required String centerDiamond,
    required String referenceNumber,
    required String reply,
    List<String>? imagePaths,
    List<String>? videoPaths,
    String? status,
    String? po,
    String? userId,
  }) async {
    try {
      var formDataMap = <String, dynamic>{
        'design_id': designId,
        'is_approved': isApproved,
        'processing_status': processingStatus,
        'diamond_weight': diamondWeight,
        'color_diamond_weight': colorDiamondWeight,
        'budget': budget,
        'metal': metal,
        'center_diamond': centerDiamond,
        'reference_number': referenceNumber,
        'reply': reply,
      };
      if (status != null) {
        formDataMap['status'] = status;
      }
      if (po != null) {
        formDataMap['po'] = po;
      }
      if (userId != null) {
        formDataMap['user_id'] = userId;
      }

      if (imagePaths != null && imagePaths.isNotEmpty) {
        List<MultipartFile> fileList = [];
        for (String path in imagePaths) {
          File file = File(path);
          if (await file.exists()) {
            fileList.add(await MultipartFile.fromFile(path));
          }
        }
        if (fileList.isNotEmpty) {
          formDataMap['img_upload[]'] = fileList;
        }
      }

      if (videoPaths != null && videoPaths.isNotEmpty) {
        List<MultipartFile> fileList = [];
        for (String path in videoPaths) {
          File file = File(path);
          if (await file.exists()) {
            fileList.add(await MultipartFile.fromFile(path));
          }
        }
        if (fileList.isNotEmpty) {
          formDataMap['video_upload[]'] = fileList;
        }
      }

      var formData = FormData.fromMap(formDataMap);

      final response = await _dio.post(
        '/m_api/design-edit-submit',
        data: formData,
        options: Options(responseType: ResponseType.plain),
      );

      var responseData = response.data;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (_) {
          throw Exception('Server error (Invalid JSON response): $responseData');
        }
      }

      if (response.statusCode == 200) {
        if (responseData is Map && (responseData['status'] == 1 || responseData['status'] == true)) {
          return;
        } else {
          final msg = responseData is Map ? responseData['message'] : null;
          throw Exception(msg ?? 'Failed to update design');
        }
      } else {
        throw Exception('Failed to communicate with server');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'An error occurred updating design'));
    }
  }

  Future<void> deleteDesign(String designId) async {
    try {
      final response = await _dio.post(
        '/m_api/delete-design',
        data: FormData.fromMap({
          'design_id': designId,
        }),
      );

      var responseData = response.data;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (_) {}
      }

      if (response.statusCode == 200) {
        if (responseData is Map && (responseData['status'] == 1 || responseData['status'] == true)) {
          return;
        } else {
          final msg = responseData is Map ? responseData['message'] : null;
          throw Exception(msg ?? 'Failed to delete design');
        }
      } else {
        throw Exception('Failed to communicate with server');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'An error occurred deleting design'));
    }
  }
}
