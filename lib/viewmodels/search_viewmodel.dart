import 'package:flutter/material.dart';
import '../models/jewelry_model.dart';
import '../services/search_service.dart';

class SearchViewModel extends ChangeNotifier {
  final SearchService _searchService = SearchService();

  List<JewelryItem> _searchResults = [];
  List<JewelryItem> get searchResults => _searchResults;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String _currentQuery = '';
  String get currentQuery => _currentQuery;

  Future<void> performSearch(String query) async {
    _currentQuery = query;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (query.trim().isEmpty) {
        if (_currentQuery == query) {
          _searchResults = [];
          _isLoading = false;
          notifyListeners();
        }
      } else {
        final results = await _searchService.searchJewelry(query);
        if (_currentQuery == query) {
          _searchResults = results;
          _isLoading = false;
          notifyListeners();
        }
      }
    } catch (e) {
      if (e.toString() == 'Exception: Cancelled') {
        return; // Another request was started, so we ignore this one
      }
      if (_currentQuery == query) {
        _error = e.toString();
        _searchResults = [];
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void clearSearch() {
    _currentQuery = '';
    _searchResults = [];
    _error = null;
    notifyListeners();
  }

  void setQueryAndLoading(String query) {
    _currentQuery = query;
    _isLoading = true;
    _error = null;
    notifyListeners();
  }
}
