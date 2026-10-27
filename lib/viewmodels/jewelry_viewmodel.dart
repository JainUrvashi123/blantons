import 'package:flutter/material.dart';
import '../models/jewelry_model.dart';
import '../models/jewelry_filter_model.dart';
import '../models/custom_jewelry_model.dart';
import '../services/jewelry_service.dart';

class JewelryViewModel extends ChangeNotifier {
  final JewelryService _service = JewelryService();

  bool _isLoadingFilters = false;
  bool _isLoadingJewelry = false;
  bool _isLoadingMore = false;
  String? _error;

  JewelryFilterData? _filterData;
  List<JewelryItem> _jewelryList = [];

  List<String> _selectedCategories = [];
  List<String> _selectedMetals = [];
  List<String> _selectedShapes = [];
  List<String> _selectedStoneNames = [];
  String? _selectedPriceRange;
  String _currentSort = 'p_low';

  // Pagination
  int _offset = 0;
  final int _limit = 10;
  bool _hasMore = true;

  // Getters
  bool get isLoadingFilters => _isLoadingFilters;
  bool get isLoadingJewelry => _isLoadingJewelry;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  JewelryFilterData? get filterData => _filterData;
  List<JewelryItem> get jewelryList => _jewelryList;
  bool get hasMore => _hasMore;

  List<String> get selectedCategories => _selectedCategories;
  List<String> get selectedMetals => _selectedMetals;
  List<String> get selectedShapes => _selectedShapes;
  List<String> get selectedStoneNames => _selectedStoneNames;
  String? get selectedPriceRange => _selectedPriceRange;
  String get currentSort => _currentSort;

  List<JewelryItem> _newArrivals = [];
  bool _isLoadingArrivals = false;

  List<JewelryItem> get newArrivals => _newArrivals;
  bool get isLoadingArrivals => _isLoadingArrivals;

  JewelryViewModel() {
    _initData();
  }

  Future<void> _initData() async {
    await fetchFilters();
    await fetchJewelry(reset: true);
    await fetchCustomCategories();
    await fetchCustomJewelry(reset: true);
  }

  Future<void> fetchFilters() async {
    _isLoadingFilters = true;
    notifyListeners();

    try {
      _filterData = await _service.getFilters();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingFilters = false;
      notifyListeners();
    }
  }

  Future<void> fetchNewArrivals() async {
    _isLoadingArrivals = true;
    _newArrivals = []; // Clear old list before loading
    notifyListeners();

    try {
      final response = await _service.getNewArrivals();

      // Double check that 'status' is true and 'records' is actually a List
      if (response != null && response['status'] == true) {
        final dynamic recordsData = response['records'];

        if (recordsData is List) {
          _newArrivals = recordsData
              .map((json) => JewelryItem.fromJson(json))
              .toList();
          debugPrint("Successfully loaded ${_newArrivals.length} arrivals");
        }
      }
    } catch (e) {
      debugPrint("New Arrival ViewModel Error: $e");
    } finally {
      _isLoadingArrivals = false;
      notifyListeners();
    }
  }

  Future<void> fetchJewelry({bool reset = false}) async {
    if (reset) {
      _offset = 0;
      _hasMore = true;
      _jewelryList.clear();
      _isLoadingJewelry = true;
      notifyListeners();
    } else {
      if (!_hasMore || _isLoadingMore) return;
      _isLoadingMore = true;
      notifyListeners();
    }

    try {
      final newItems = await _service.getJewelry(
        categoryName: _selectedCategories,
        metalType: _selectedMetals,
        stoneShape: _selectedShapes,
        stoneName: _selectedStoneNames,
        price: _selectedPriceRange,
        sort: _currentSort,
        offset: _offset,
        limit: _limit,
      );

      if (newItems.length < _limit) {
        _hasMore = false;
      }

      _jewelryList.addAll(newItems);
      _offset += newItems.length;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingJewelry = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }



  void toggleCategory(String category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
    notifyListeners();
  }

  void toggleMetal(String metal) {
    if (_selectedMetals.contains(metal)) {
      _selectedMetals.remove(metal);
    } else {
      _selectedMetals.add(metal);
    }
    notifyListeners();
  }

  void toggleShape(String shape) {
    if (_selectedShapes.contains(shape)) {
      _selectedShapes.remove(shape);
    } else {
      _selectedShapes.add(shape);
    }
    notifyListeners();
  }
  
  void setSort(String sort) {
    _currentSort = sort;
    fetchJewelry(reset: true);
  }

  void setPriceRange(String? maxPrice) {
    if (maxPrice == null || maxPrice.isEmpty) {
      _selectedPriceRange = null;
    } else {
      _selectedPriceRange = "0-$maxPrice"; // Simplification for slider
    }
    notifyListeners();
  }

  void applyFilters() {
    fetchJewelry(reset: true);
  }
  
  void clearFilters() {
    _selectedCategories.clear();
    _selectedMetals.clear();
    _selectedShapes.clear();
    _selectedStoneNames.clear();
    _selectedPriceRange = null;
    fetchJewelry(reset: true);
  }

  Future<Map<String, dynamic>> fetchJewelryDetail(String jewelryId) async {
    try {
      final response = await _service.getJewelryDetail(jewelryId);
      return response;
    } catch (e) {
      throw Exception('Failed to fetch details: $e');
    }
  }

  Future<bool> addToCart(String jewelryId, {String? userId}) async {
    try {
      final response = await _service.addToCart(jewelryId, userId: userId);
      return response['status'] == 1 || response['code'] == 1;
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  // Custom Jewelry State
  List<CustomJewelryCategory> _customCategories = [];
  String _selectedCustomCategory = 'BRIDAL';
  List<CustomJewelryItem> _customJewelryList = [];
  bool _isLoadingCustomCategories = false;
  bool _isLoadingCustomJewelry = false;
  bool _isLoadingMoreCustom = false;
  int _customCurrentPage = 1;
  int _customTotalPages = 1;
  bool _hasMoreCustom = true;
  String? _customError;

  List<CustomJewelryCategory> get customCategories => _customCategories;
  String get selectedCustomCategory => _selectedCustomCategory;
  List<CustomJewelryItem> get customJewelryList => _customJewelryList;
  bool get isLoadingCustomCategories => _isLoadingCustomCategories;
  bool get isLoadingCustomJewelry => _isLoadingCustomJewelry;
  bool get isLoadingMoreCustom => _isLoadingMoreCustom;
  bool get hasMoreCustom => _hasMoreCustom;
  String? get customError => _customError;

  Future<void> fetchCustomCategories() async {
    _isLoadingCustomCategories = true;
    notifyListeners();

    try {
      final categories = await _service.getCustomJewelryCategories();
      _customCategories = categories;
      if (_customCategories.isNotEmpty && !_customCategories.any((c) => c.categoryName == _selectedCustomCategory)) {
        _selectedCustomCategory = _customCategories.first.categoryName;
      }
      _customError = null;
    } catch (e) {
      _customError = e.toString();
    } finally {
      _isLoadingCustomCategories = false;
      notifyListeners();
    }
  }

  Future<void> selectCustomCategory(String category) async {
    if (_selectedCustomCategory == category) return;
    _selectedCustomCategory = category;
    notifyListeners();
    await fetchCustomJewelry(reset: true);
  }

  Future<void> fetchCustomJewelry({bool reset = false}) async {
    if (reset) {
      _customCurrentPage = 1;
      _customTotalPages = 1;
      _hasMoreCustom = true;
      _customJewelryList.clear();
      _isLoadingCustomJewelry = true;
      notifyListeners();
    } else {
      if (!_hasMoreCustom || _isLoadingMoreCustom || _isLoadingCustomJewelry) return;
      _isLoadingMoreCustom = true;
      notifyListeners();
    }

    try {
      final response = await _service.getCustomJewelry(
        category: _selectedCustomCategory,
        page: _customCurrentPage,
      );

      final totalPages = response['total_pages'] is int
          ? response['total_pages']
          : int.tryParse(response['total_pages']?.toString() ?? '1') ?? 1;
      _customTotalPages = totalPages;

      final recordsData = response['records'];
      if (recordsData is List) {
        final newItems = recordsData.map((e) => CustomJewelryItem.fromJson(e)).toList();
        _customJewelryList.addAll(newItems);
        if (_customCurrentPage >= _customTotalPages || newItems.isEmpty) {
          _hasMoreCustom = false;
        } else {
          _customCurrentPage++;
        }
      } else {
        _hasMoreCustom = false;
      }
      _customError = null;
    } catch (e) {
      _customError = e.toString();
    } finally {
      _isLoadingCustomJewelry = false;
      _isLoadingMoreCustom = false;
      notifyListeners();
    }
  }

  Future<CustomJewelryDetailData> fetchCustomJewelryDetails(String id) async {
    try {
      final data = await _service.getCustomJewelryDetails(id: id);
      return data;
    } catch (e) {
      throw Exception('Failed to fetch custom jewelry details: $e');
    }
  }

  Future<bool> addCustomJewelryToCart({
    required String customerId,
    required String productId,
    required String quantity,
    required String ringSize,
  }) async {
    try {
      final success = await _service.addCustomJewelryToCart(
        customerId: customerId,
        productId: productId,
        quantity: quantity,
        ringSize: ringSize,
      );
      return success;
    } catch (e) {
      throw Exception('Failed to add custom jewelry to cart: $e');
    }
  }
}
