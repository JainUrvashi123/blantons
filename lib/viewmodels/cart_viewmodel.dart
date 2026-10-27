import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_model.dart';
import '../services/cart_service.dart';
import '../models/user_model.dart';

class CartViewModel extends ChangeNotifier {
  final CartService _cartService = CartService();

  // Loading States
  bool _isLoading = false;      // Used for initial full-page fetch
  bool _isUpdating = false;     // Used for global overlay progress bar
  String? _error;
  List<CartItem> _cartItems = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get error => _error;
  List<CartItem> get cartItems => _cartItems;

  double get totalPrice {
    double total = 0;
    for (var item in _cartItems) {
      total += double.tryParse(item.totalPrice) ?? 0;
    }
    return total;
  }

  int get totalItemCount {
    int count = 0;
    for (var item in _cartItems) {
      count += int.tryParse(item.quantity) ?? 0;
    }
    return count;
  }

  CartViewModel() {
    fetchCart();
  }

  Future<UserModel?> _getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      try {
        return UserModel.fromJson(jsonDecode(userDataString));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<UserModel?> getUserData() async {
    return await _getUser();
  }

  /// Initial fetch of the cart
  Future<void> fetchCart() async {
    final user = await _getUser();
    if (user == null) {
      _error = 'User not logged in';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cartItems = await _cartService.getCart(user.userId);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Removes a single item and preserves sequence
  Future<bool> removeFromCart(String cartId, String type) async {
    final user = await _getUser();
    if (user == null) {
      _error = 'User not logged in';
      notifyListeners();
      return false;
    }

    _isUpdating = true; // Trigger global loader
    notifyListeners();

    try {
      final success = await _cartService.removeFromCart(
        userId: user.userId,
        type: type,
        cartId: cartId,
      );

      if (success) {
        // Remove locally so the list order doesn't jump
        _cartItems.removeWhere((item) => item.cartId == cartId);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  /// Removes all items one by one while showing the global loader
  Future<bool> removeAll() async {
    final user = await _getUser();
    if (user == null || _cartItems.isEmpty) return false;

    _isUpdating = true;
    notifyListeners();

    bool allSuccess = true;
    try {
      // Use a fixed list for iteration while modifying the original
      final itemsToRemove = List.from(_cartItems);
      for (var item in itemsToRemove) {
        final success = await _cartService.removeFromCart(
          userId: user.userId,
          type: item.productType,
          cartId: item.cartId,
        );
        if (success) {
          _cartItems.removeWhere((i) => i.cartId == item.cartId);
        } else {
          allSuccess = false;
        }
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      allSuccess = false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    return allSuccess;
  }

  /// Updates quantity locally and via API without re-fetching
  Future<bool> updateQuantity(CartItem item, int newQuantity) async {
    if (newQuantity < 1) return false;

    final user = await _getUser();
    if (user == null) return false;

    _isUpdating = true;
    notifyListeners();

    try {
      if (item.productType == 'jewelry') {
        await _cartService.addToCart(
          userId: user.userId,
          jewelryId: item.productId,
          quantity: newQuantity.toString(),
        );

        // Update the item in the local list to keep the sequence
        final index = _cartItems.indexWhere((element) => element.cartId == item.cartId);
        if (index != -1) {
          double unitPrice = double.tryParse(item.price) ?? 0;

          _cartItems[index] = CartItem(
            cartId: item.cartId,
            productId: item.productId,
            stockId: item.stockId,
            quantity: newQuantity.toString(),
            productType: item.productType,
            price: item.price,
            totalPrice: (unitPrice * newQuantity).toString(),
            name: item.name,
            description: item.description,
            attributes: item.attributes,
            infoArray: item.infoArray,
            image: item.image,
            diamondVideo: item.diamondVideo,
            reportFilename: item.reportFilename,
            createdAt: item.createdAt,
            customerId: item.customerId,
            isRingBuilder: item.isRingBuilder,
          );
        }
        return true;
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> addToCart(String jewelryId, String quantity) async {
    final user = await _getUser();
    if (user == null) {
      _error = 'User not logged in. Please log in to add to cart.';
      notifyListeners();
      return false;
    }

    _isUpdating = true;
    notifyListeners();

    try {
      await _cartService.addToCart(
        userId: user.userId,
        jewelryId: jewelryId,
        quantity: quantity,
      );
      // For adding new items, we fetch the whole list as sequence is less critical
      await fetchCart();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // Inside CartViewModel class

// Inside CartViewModel class

// Inside CartViewModel class

  Future<bool> sendEmailCart({
    required String name,
    required String email, // Added email parameter
    required String mobile,
    required String message,
  }) async {
    final user = await _getUser();
    if (user == null) {
      _error = 'User not logged in';
      notifyListeners();
      return false;
    }

    _isUpdating = true;
    notifyListeners();

    try {
      final success = await _cartService.emailCart(
        userId: user.userId,
        name: name,
        email: email, // Now using the email passed from the UI
        mobile: mobile,
        message: message,
      );

      if (success) {
        _cartItems = [];
        _error = null;
        notifyListeners();
        await fetchCart();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems = [];
    _error = null;
    notifyListeners();
  }
}