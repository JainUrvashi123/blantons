import 'dart:convert';
import 'package:dio/dio.dart';

import '../core/network/dio_client.dart';
import '../models/jewelry_model.dart';

class SearchService {
  final Dio _dio = DioClient().dio;
  CancelToken? _cancelToken;

  Future<List<JewelryItem>> searchJewelry(String query) async {
    _cancelToken?.cancel('Cancelled by new request');
    _cancelToken = CancelToken();

    try {
      final response = await _dio.post(
        '/m_api/header-search',
        data: {'search': query},
        cancelToken: _cancelToken,
      );

      var responseData = response.data;
      if (responseData is String) {
        try {
          responseData = jsonDecode(responseData);
        } catch (_) {}
      }

      if (response.statusCode == 200) {
        if (responseData is Map && responseData['data'] != null) {
          final List records = responseData['data'];
          return records.map((e) => JewelryItem.fromJson(e)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to communicate with server');
      }
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        throw Exception('Cancelled');
      }
      throw Exception(DioClient.getErrorMessage(e, defaultMessage: 'An error occurred fetching search results'));
    } catch (e) {
      if (e.toString() == 'Exception: Cancelled') {
        rethrow;
      }
      throw Exception('An error occurred: $e');
    }
  }
}
