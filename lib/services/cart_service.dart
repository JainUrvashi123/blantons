import 'dart:convert';
import 'package:dio/dio.dart';

import '../core/network/dio_client.dart';
import '../models/cart_model.dart';

class CartService {
  final Dio _dio = DioClient().dio;

  Future<List<CartItem>> getCart(String userId) async {
    try {
      final response = await _dio.post(
        '/m_api/cart',
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
          final List<dynamic> data = responseData['data'] ?? [];
          return data.map((item) => CartItem.fromJson(item)).toList();
        } else {
          final msg = responseData is Map ? responseData['message'] : null;
          throw Exception(msg ?? 'Failed to fetch cart');
        }
      } else {
        throw Exception('Failed to communicate with server');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'An error occurred fetching cart'));
    }
  }

  Future<bool> removeFromCart({
    required String userId,
    required String type,
    required String cartId,
  }) async {
    try {
      final response = await _dio.post(
        '/m_api/cart-remove',
        data: {
          'user_id': userId,
          'type': type,
          'cart_id': cartId,
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
          throw Exception(msg ?? 'Failed to remove from cart');
        }
      } else {
        throw Exception('Failed to communicate with server');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'An error occurred removing from cart'));
    }
  }

  Future<Map<String, dynamic>> addToCart({
    required String userId,
    required String jewelryId,
    required String quantity,
  }) async {
    try {
      final response = await _dio.post(
        '/m_api/jewelry-add-cart',
        data: {
          'user_id': userId,
          'jewelry_id': jewelryId,
          'quantity': quantity,
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
          return responseData['record'] ?? {};
        } else {
          final msg = responseData is Map ? responseData['message'] : null;
          throw Exception(msg ?? 'Failed to add to cart');
        }
      } else {
        throw Exception('Failed to communicate with server');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'An error occurred adding to cart'));
    }
  }

  // Inside CartService class

  Future<bool> emailCart({
    required String userId,
    required String name,
    required String email,
    required String mobile,
    required String message,
  }) async {
    try {
      final response = await _dio.post(
        '/m_api/email-all-cart',
        data: {
          'user_id': userId,
          'name': name,
          'email': email,
          'mobile': mobile,
          'message': message,
          'terms': '1',
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
          throw Exception(msg ?? 'Failed to send email');
        }
      } else {
        throw Exception('Failed to communicate with server');
      }
    } on DioException catch (e) {
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'An error occurred sending email'));
    }
  }
}
