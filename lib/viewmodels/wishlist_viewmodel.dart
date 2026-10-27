import 'package:flutter/foundation.dart';
import '../models/wishlist_model.dart';
import '../services/wishlist_service.dart';

class WishlistViewModel extends ChangeNotifier {
  final WishlistService _wishlistService = WishlistService();

  WishlistData? _wishlistData;
  WishlistData? get wishlistData => _wishlistData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchWishlist(String userId) async {
    if (userId.isEmpty) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _wishlistData = await _wishlistService.getWishlist(userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeItem(String userId, String type, String wishlistId) async {
    try {
      final success = await _wishlistService.removeWishlistItem(
        userId: userId,
        type: type,
        wishlistId: wishlistId,
      );

      if (success && _wishlistData != null) {
        if (type == 'jewelry') {
          _wishlistData!.jewelry.removeWhere((item) => item.wishlistId == wishlistId);
        } else if (type == 'diamond') {
          _wishlistData!.diamond.removeWhere((item) => item.wishlistId == wishlistId);
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addItem(String userId, String type, String productId) async {
    try {
      final success = await _wishlistService.addWishlistItem(
        userId: userId,
        type: type,
        productId: productId,
      );

      if (success) {
        // Refetch wishlist to get the updated list with proper wishlist_id
        await fetchWishlist(userId);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearWishlist() {
    _wishlistData = null;
    _errorMessage = null;
    notifyListeners();
  }
}
