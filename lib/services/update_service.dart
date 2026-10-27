import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  static const String versionUrl = 'https://blantonslab.com/version.json';
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.blantons.app';
  static const String appStoreUrl = 'https://apps.apple.com/in/app/blantons/id6787939229';

  /// Checks for updates. Returns true if the app can proceed to home/login,
  /// or false if a forced update dialog is currently shown (blocking navigation).
  Future<bool> checkAndShowUpdateDialog(BuildContext context) async {
    try {
      // 1. Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // 2. Fetch latest version from server (message and local fallback info)
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 5);

      String message = 'A new version of Blantons is available. Please update to get the latest features!';
      String minVersionAndroid = '1.0.0';
      String latestVersionAndroid = '1.0.0';
      String minVersionIos = '1.0.0';
      String latestVersionIos = '1.0.0';

      try {
        final response = await dio.get(versionUrl);
        if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
          final data = response.data;
          minVersionAndroid = data['min_version_android'] ?? '1.0.0';
          latestVersionAndroid = data['latest_version_android'] ?? '1.0.0';
          minVersionIos = data['min_version_ios'] ?? '1.0.0';
          latestVersionIos = data['latest_version_ios'] ?? '1.0.0';
          message = data['message'] ?? message;
        }
      } catch (e) {
        debugPrint('Error fetching version.json: $e');
      }

      final isAndroid = Platform.isAndroid;
      final platformString = isAndroid ? 'android' : 'ios';
      final minVersion = isAndroid ? minVersionAndroid : minVersionIos;
      final latestVersion = isAndroid ? latestVersionAndroid : latestVersionIos;

      // 3. Call check-app-version API to verify if update is required
      bool hasUpdate = false;
      bool isForced = false;
      String? customUrl;
      bool apiCallSuccessful = false;

      debugPrint('Update Check: currentVersion=$currentVersion, platform=$platformString');
      try {
        final checkResponse = await dio.get(
          'https://blantonslab.com/m_api/check-app-version',
          data: {
            'version': currentVersion,
            'platform': platformString,
          },
          options: Options(
            contentType: Headers.jsonContentType,
          ),
        );
        debugPrint('Check App Version API Response: ${checkResponse.data}');
        if (checkResponse.statusCode == 200 && checkResponse.data is Map<String, dynamic>) {
          final responseData = checkResponse.data;
          if (responseData['status'] == true) {
            hasUpdate = responseData['update_required'] ?? false;
            isForced = responseData['force_update'] ?? false;
            customUrl = isAndroid ? responseData['playstore_url'] : responseData['appstore_url'];
            if (customUrl != null && customUrl.isEmpty) {
              customUrl = null;
            }
            apiCallSuccessful = true;
          }
        }
      } catch (e) {
        debugPrint('Error calling check-app-version API: $e');
      }

      // 4. Fallback to local check if API call was not successful
      if (!apiCallSuccessful) {
        debugPrint('Falling back to local version check');
        hasUpdate = _isVersionLessThan(currentVersion, latestVersion);
        isForced = _isVersionLessThan(currentVersion, minVersion);
      }

      if (hasUpdate && context.mounted) {
        if (isForced) {
          // Show blocking forced update dialog
          _showUpdateDialog(context, true, message, customUrl: customUrl);
          return false;
        } else {
          // Show optional update dialog and wait for it to be dismissed
          await _showUpdateDialog(context, false, message, customUrl: customUrl);
          return true;
        }
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
    return true; // Proceed if check fails or no update is needed
  }

  /// Programmatically checks if an update is available without showing a dialog.
  Future<bool> isUpdateAvailable() async {
    try {
      // 1. Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // 2. Fetch latest version info
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 5);

      String minVersionAndroid = '1.0.0';
      String latestVersionAndroid = '1.0.0';
      String minVersionIos = '1.0.0';
      String latestVersionIos = '1.0.0';

      try {
        final response = await dio.get(versionUrl);
        if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
          final data = response.data;
          minVersionAndroid = data['min_version_android'] ?? '1.0.0';
          latestVersionAndroid = data['latest_version_android'] ?? '1.0.0';
          minVersionIos = data['min_version_ios'] ?? '1.0.0';
          latestVersionIos = data['latest_version_ios'] ?? '1.0.0';
        }
      } catch (e) {
        debugPrint('Error fetching version.json: $e');
      }

      final isAndroid = Platform.isAndroid;
      final platformString = isAndroid ? 'android' : 'ios';
      final latestVersion = isAndroid ? latestVersionAndroid : latestVersionIos;

      bool hasUpdate = false;
      bool apiCallSuccessful = false;

      // 3. Call check-app-version API to verify
      try {
        final checkResponse = await dio.get(
          'https://blantonslab.com/m_api/check-app-version',
          data: {
            'version': currentVersion,
            'platform': platformString,
          },
          options: Options(
            contentType: Headers.jsonContentType,
          ),
        );
        if (checkResponse.statusCode == 200 && checkResponse.data is Map<String, dynamic>) {
          final responseData = checkResponse.data;
          if (responseData['status'] == true) {
            hasUpdate = responseData['update_required'] ?? false;
            apiCallSuccessful = true;
          }
        }
      } catch (e) {
        debugPrint('Error calling check-app-version API: $e');
      }

      // 4. Local version comparison fallback
      if (!apiCallSuccessful) {
        hasUpdate = _isVersionLessThan(currentVersion, latestVersion);
      }

      return hasUpdate;
    } catch (e) {
      debugPrint('Error checking isUpdateAvailable: $e');
      return false;
    }
  }

  bool _isVersionLessThan(String current, String target) {
    List<int> currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> targetParts = target.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    
    for (int i = 0; i < targetParts.length; i++) {
      int currentPart = i < currentParts.length ? currentParts[i] : 0;
      if (currentPart < targetParts[i]) return true;
      if (currentPart > targetParts[i]) return false;
    }
    return false;
  }

  Future<void> _showUpdateDialog(BuildContext context, bool forceUpdate, String message, {String? customUrl}) async {
    await showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (BuildContext context) {
        return PopScope(
          canPop: !forceUpdate,
          child: AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryButton.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.system_update_alt_rounded,
                    size: 40,
                    color: AppColors.primaryButton,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Update Available!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      launchStore(customUrl: customUrl);
                      if (!forceUpdate) {
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryButton,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Update Now',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (!forceUpdate) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Later',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> launchStore({String? customUrl}) async {
    final String urlString = customUrl ?? (Platform.isAndroid ? playStoreUrl : appStoreUrl);
    final Uri uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint('Could not launch store URL: $urlString');
      }
    } catch (e) {
      debugPrint('Error launching store URL: $e');
    }
  }
}
