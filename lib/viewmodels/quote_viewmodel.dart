import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quote_detail_model.dart';
import '../models/quote_model.dart';
import '../services/quote_service.dart';
import 'auth_viewmodel.dart';

class QuoteViewModel extends ChangeNotifier {
  final QuoteService _quoteService = QuoteService();
  
  bool _isLoading = false;
  String? _errorMessage;
  QuoteResponse? _quoteResponse;
  
  QuoteDetailResponse? _quoteDetail;
  bool _isDetailLoading = false;

  Map<String, String> _readQuoteEditDates = {};

  QuoteViewModel() {
    loadReadQuotes();
  }

  Future<void> loadReadQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('read_quotes_edit_dates');
    if (jsonStr != null) {
      try {
        final decoded = jsonDecode(jsonStr);
        if (decoded is Map) {
          _readQuoteEditDates = decoded.map((key, value) => MapEntry(key.toString(), value.toString()));
        }
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> markQuoteAsRead(String designId, String editDate) async {
    _readQuoteEditDates[designId] = editDate;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('read_quotes_edit_dates', jsonEncode(_readQuoteEditDates));
    notifyListeners();
  }

  bool isQuoteUnread(QuoteModel quote) {
    final hasUpdate = quote.reply.isNotEmpty || quote.isApproved != '0';
    if (!hasUpdate) return false;
    
    final lastReadDate = _readQuoteEditDates[quote.designId];
    if (lastReadDate == null) return true;
    
    return lastReadDate != quote.editDate;
  }

  // Store notification counts from the APIs
  int _apiUserQuotesNotificationCount = 0;
  int _apiUserOrdersNotificationCount = 0;
  int _apiUserCompletedOrdersNotificationCount = 0;
  int _apiAdminNotificationCount = 0;

  int get unreadQuotesCount => _apiUserQuotesNotificationCount;
  int get unreadMyOrdersCount => _apiUserOrdersNotificationCount;
  int get unreadCompletedOrdersCount => _apiUserCompletedOrdersNotificationCount;
  int get unreadAdminEnquiriesCount => _apiAdminNotificationCount;

  int get unreadAdminQuotesCount {
    return _adminDesigns.where((quote) => quote.status.toLowerCase() == 'quote' && isQuoteUnread(quote)).length;
  }

  int get unreadAdminOrdersCount {
    return _adminDesigns.where((quote) => quote.status.toLowerCase() == 'order' && isQuoteUnread(quote)).length;
  }

  int get unreadAdminCompletedOrdersCount {
    return _adminDesigns.where((quote) => quote.status.toLowerCase() == 'completed' && isQuoteUnread(quote)).length;
  }

  bool get isLoading => _isLoading;
  bool get isDetailLoading => _isDetailLoading;
  String? get errorMessage => _errorMessage;
  List<QuoteModel> get quotes => _quoteResponse?.records ?? [];
  
  QuoteResponse? _myOrdersResponse;
  List<QuoteModel> get myOrders => _myOrdersResponse?.records ?? [];

  QuoteResponse? _completedOrdersResponse;
  List<QuoteModel> get completedOrders => _completedOrdersResponse?.records ?? [];

  QuoteDetailResponse? get quoteDetail => _quoteDetail;

  Future<void> fetchQuotes(AuthViewModel authViewModel) async {
    final user = authViewModel.user;
    if (user == null) {
      _errorMessage = 'User not logged in';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _quoteResponse = await _quoteService.getQuotes(user.userId);
      _apiUserQuotesNotificationCount = _quoteResponse?.userNotificationCount ?? 0;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyOrders(AuthViewModel authViewModel) async {
    final user = authViewModel.user;
    if (user == null) {
      _errorMessage = 'User not logged in';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myOrdersResponse = await _quoteService.getMyOrders(user.userId);
      _apiUserOrdersNotificationCount = _myOrdersResponse?.userNotificationCount ?? 0;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCompletedOrders(AuthViewModel authViewModel) async {
    final user = authViewModel.user;
    if (user == null) {
      _errorMessage = 'User not logged in';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _completedOrdersResponse = await _quoteService.getCompletedOrders(user.userId);
      _apiUserCompletedOrdersNotificationCount = _completedOrdersResponse?.userNotificationCount ?? 0;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchQuoteDetail(String designId) async {
    _isDetailLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _quoteDetail = await _quoteService.getQuoteDetail(designId);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitReply(AuthViewModel authViewModel, String designId, String reply, {List<String>? imagePaths}) async {
    final user = authViewModel.user;
    if (user == null) {
      _errorMessage = 'User not logged in';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {

      await _quoteService.submitReply(designId, user.userId, reply, imagePaths: imagePaths);
      
      // Optionally re-fetch quotes after successful reply
      await fetchQuotes(authViewModel);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendImagesInEmail(AuthViewModel authViewModel, String designId, String email) async {
    final user = authViewModel.user;
    if (user == null) {
      _errorMessage = 'User not logged in';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _quoteService.sendImagesInEmail(designId, email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  List<QuoteModel> _adminDesigns = [];
  List<QuoteModel> get adminDesigns => _adminDesigns;

  Future<void> fetchAdminDesigns(AuthViewModel authViewModel) async {
    final user = authViewModel.user;
    if (user == null) {
      _errorMessage = 'User not logged in';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _quoteService.getAdminDesigns();
      _adminDesigns = response.records;
      _apiAdminNotificationCount = response.adminNotificationCount ?? 0;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitDesignEdit({
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _quoteService.submitDesignEdit(
        designId: designId,
        isApproved: isApproved,
        processingStatus: processingStatus,
        diamondWeight: diamondWeight,
        colorDiamondWeight: colorDiamondWeight,
        budget: budget,
        metal: metal,
        centerDiamond: centerDiamond,
        referenceNumber: referenceNumber,
        reply: reply,
        imagePaths: imagePaths,
        videoPaths: videoPaths,
        status: status,
        po: po,
        userId: userId,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDesign(String designId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _quoteService.deleteDesign(designId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearQuotes() {
    _quoteResponse = null;
    _quoteDetail = null;
    _myOrdersResponse = null;
    _completedOrdersResponse = null;
    _errorMessage = null;
    notifyListeners();
  }
}
