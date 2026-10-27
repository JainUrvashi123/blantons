import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';




class DioClient {
  static final DioClient _instance = DioClient._internal();
  late Dio _dio;

  // Added this constant for global image access
  static const String baseImageUrl = 'https://blantonslab.com/';

  static String? csrfToken;
  static Map<String, String> cookies = {};

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    BaseOptions options = BaseOptions(
      baseUrl: 'https://blantonslab.com/',
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    _dio = Dio(options);
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (options.path.startsWith('/')) {
          options.path = options.path.substring(1);
        }
        if (options.data is FormData) {
          options.headers.remove('Content-Type');
          options.headers.remove('content-type');
          options.contentType = null; // Let Dio set it with the boundary!
        }

        if (cookies.isNotEmpty) {
          final cookieString = cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
          options.headers['Cookie'] = cookieString;
        }

        if (csrfToken != null) {
          options.headers['X-CSRF-TOKEN'] = csrfToken;
          options.headers['X-XSRF-TOKEN'] = csrfToken;

          final data = options.data;
          if (data is Map<String, dynamic>) {
            data['csrf_diamond_token'] = csrfToken;
            data['csrf_diamond_cookie'] = csrfToken;
            data['csrf_test_name'] = csrfToken;
          } else if (data is FormData) {
            if (!data.fields.any((element) => element.key == 'csrf_diamond_token')) {
              data.fields.add(MapEntry('csrf_diamond_token', csrfToken!));
            }
            if (!data.fields.any((element) => element.key == 'csrf_diamond_cookie')) {
              data.fields.add(MapEntry('csrf_diamond_cookie', csrfToken!));
            }
            if (!data.fields.any((element) => element.key == 'csrf_test_name')) {
              data.fields.add(MapEntry('csrf_test_name', csrfToken!));
            }
          }
        }

        // Detailed logging for FormData requests
        if (options.data is FormData) {
          final formData = options.data as FormData;
          debugPrint("--- Dio Client FormData debug ---");
          debugPrint("URI: ${options.uri}");
          debugPrint("Cookie sent: ${options.headers['Cookie']}");
          debugPrint("CSRF Token in headers: ${options.headers['X-CSRF-TOKEN']}");
          debugPrint("Fields in FormData:");
          for (var field in formData.fields) {
            debugPrint("  ${field.key}: ${field.value}");
          }
          debugPrint("Files in FormData:");
          for (var file in formData.files) {
            debugPrint("  ${file.key}: ${file.value.filename} (${file.value.length} bytes)");
          }
          debugPrint("---------------------------------");
        }

        return handler.next(options);
      },
      onResponse: (response, handler) {
        _extractCookies(response);
        return handler.next(response);
      },
      onError: (DioException err, handler) {
        if (err.response != null) {
          _extractCookies(err.response!);
        }
        return handler.next(err);
      },
    ));
    _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }

  static void _extractCookies(Response response) {
    final setCookieHeaders = response.headers['set-cookie'];
    if (setCookieHeaders != null) {
      var updated = false;
      for (var header in setCookieHeaders) {
        final parts = header.split(';');
        if (parts.isNotEmpty) {
          final cookiePair = parts[0].trim();
          final eqIdx = cookiePair.indexOf('=');
          if (eqIdx != -1) {
            final name = cookiePair.substring(0, eqIdx).trim();
            final value = cookiePair.substring(eqIdx + 1).trim();
            cookies[name] = value;
            updated = true;
            if (name == 'csrf_diamond_cookie') {
              csrfToken = value;
            }
          }
        }
      }
      if (updated) {
        _saveCookies();
      }
    }
  }

  static Future<void> initCookies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cookiesJson = prefs.getString('persisted_cookies');
      if (cookiesJson != null) {
        final decoded = jsonDecode(cookiesJson);
        if (decoded is Map) {
          decoded.forEach((key, value) {
            cookies[key.toString()] = value.toString();
            if (key.toString() == 'csrf_diamond_cookie') {
              csrfToken = value.toString();
            }
          });
        }
      }
    } catch (_) {}
  }

  static Future<void> _saveCookies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('persisted_cookies', jsonEncode(cookies));
    } catch (_) {}
  }


  // Deprecated alias for backwards compatibility during hot reloads
  static void _extractCsrfToken(Response response) {
    _extractCookies(response);
  }

  Dio get dio => _dio;

  /// Helper to safely combine base URL and image path
  static String getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    String fullUrl;
    if (path.startsWith('http')) {
      fullUrl = path;
    } else if (path.startsWith('//')) {
      fullUrl = "https:$path";
    } else {
      // Ensures we don't get double slashes //
      String cleanPath = path.startsWith('/') ? path.substring(1) : path;
      fullUrl = "$baseImageUrl$cleanPath";
    }
    
    // Safely encode characters like spaces
    return Uri.encodeFull(fullUrl);
  }

  /// Safely extracts the error message from a [DioException] without throwing runtime casting exceptions.
  static String getErrorMessage(DioException e, {String defaultMessage = 'An error occurred'}) {
    final response = e.response;
    if (response != null && response.data != null) {
      var data = response.data;
      if (data is String) {
        final trimmed = data.trim();
        if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
          try {
            data = jsonDecode(trimmed);
          } catch (_) {}
        }
      }
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      } else if (data is String) {
        if (data.trim().startsWith('<')) {
          return 'Server Error: ${response.statusCode} ${response.statusMessage ?? "Forbidden"}';
        } else if (data.trim().isNotEmpty) {
          return data.trim();
        }
      }
    }
    return e.message ?? defaultMessage;
  }
}