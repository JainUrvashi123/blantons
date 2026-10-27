import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationService _service = NotificationService();
  
  bool _isLoading = false;
  String? _errorMessage;
  List<NotificationModel> _notifications = [];
  Set<String> _localReadNotificationIds = {};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<NotificationModel> get notifications => _notifications;
  
  NotificationViewModel() {
    loadReadNotifications();
  }

  Future<void> loadReadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('read_notification_ids');
      if (list != null) {
        _localReadNotificationIds = list.toSet();
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    if (_localReadNotificationIds.contains(notificationId)) return;
    
    _localReadNotificationIds.add(notificationId);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('read_notification_ids', _localReadNotificationIds.toList());
    } catch (_) {}
    notifyListeners();
  }

  int get unreadCount {
    return _notifications.where((n) => n.isRead == '0' && !_localReadNotificationIds.contains(n.notificationId)).length;
  }

  bool isNotificationUnread(NotificationModel notification) {
    return notification.isRead == '0' && !_localReadNotificationIds.contains(notification.notificationId);
  }

  Future<void> fetchNotifications(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _service.getNotifications(userId);
      _notifications = res['data'] as List<NotificationModel>;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearNotifications() {
    _notifications = [];
    _localReadNotificationIds = {};
    _errorMessage = null;
    notifyListeners();
  }
}
