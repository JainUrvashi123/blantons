import 'dart:convert';
import 'package:dio/dio.dart';

import '../core/network/dio_client.dart';
import '../models/wishlist_model.dart';

class WishlistService {
  final Dio _dio = DioClient().dio;

  Future<WishlistData> getWishlist(String userId) async {
    try {
      final response = await _dio.post(
        '/m_api/wishlist',
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
        if (responseData is Map && (responseData['status'] == 1 || responseData['code'] == 1)) {
          return WishlistData.fromJson(responseData['data'] ?? {});
        } else {
          final msg = responseData is Map ? responseData['message'] : null;
          throw Exception(msg ?? 'Failed to fetch wishlist');
        }
      } else {
        throw Exception('Failed to communicate with server');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'An error occurred fetching wishlist'));
    }
  }

  Future<bool> removeWishlistItem({
    required String userId,
    required String type,
    required String wishlistId,
  }) async {
    try {
      final response = await _dio.post(
        '/m_api/wishlist-remove',
        data: {
          'user_id': userId,
          'type': type,
          'wishlist_id': wishlistId,
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
          return true;
        } else {
          final msg = responseData is Map ? responseData['message'] : null;
          throw Exception(msg ?? 'Failed to remove wishlist item');
        }
      } else {
        throw Exception('Failed to communicate with server');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'An error occurred removing wishlist item'));
    }
  }

  Future<bool> addWishlistItem({
    required String userId,
    required String type,
    required String productId,
  }) async {
    try {
      final response = await _dio.post(
        '/m_api/jewelry-add-wishlist',
        data: {
          'user_id': userId,
          'jewelry_id': productId,
          'quantity': '1',
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
          return true;
        } else {
          final msg = responseData is Map ? responseData['message'] : null;
          throw Exception(msg ?? 'Failed to add to wishlist');
        }
      } else {
        throw Exception('Failed to communicate with server');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'An error occurred adding to wishlist'));
    }
  }
}
