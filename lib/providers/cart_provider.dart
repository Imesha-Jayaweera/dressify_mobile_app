import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../core/dio_interceptor.dart';
import '../constants/constants.dart';

class CartProvider with ChangeNotifier {
  final Dio _client = DioInterceptor.buildDioAPIClient();

  final Map<String, CartItem> _items = {};
  bool _isLoading = false;
  String? _userId;

  Map<String, CartItem> get items => {..._items};
  bool get isLoading => _isLoading;
  int get itemCount => _items.length;
  int get totalQuantity => _items.values.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  List<CartItem> get cartItems => _items.values.toList();

  // Set user ID (call this after login)
  void setUserId(String userId) {
    _userId = userId;
    fetchCart(); // Fetch cart when user is set
  }

  // Fetch cart from backend
  Future<void> fetchCart() async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _client.get('$BASE_URL/cart/$_userId');

      print('📦 Cart response: ${response.data}');

      if (response.data['success'] == true) {
        final cartData = response.data['data'];
        _items.clear();

        if (cartData != null && cartData['items'] != null) {
          for (var item in cartData['items']) {
            final product = Product.fromJson(item['productId']);
            final key = '${product.id}_${item['size']}_${item['color']}';

            _items[key] = CartItem(
              product: product,
              quantity: item['quantity'],
              selectedSize: item['size'],
              selectedColor: item['color'],
            );
          }
        }

        print('✅ Loaded ${_items.length} cart items');
      }
    } catch (e) {
      print('❌ Fetch cart error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save cart to backend
  Future<void> _saveCart() async {
    if (_userId == null) return;

    try {
      final items = _items.values.map((item) => item.toJson()).toList();

      await _client.put(
        '$BASE_URL/cart/$_userId',
        data: {'items': items},
      );

      print('✅ Cart saved to backend');
    } catch (e) {
      print('❌ Save cart error: $e');
    }
  }

  // Add item to cart
  Future<void> addItem(Product product, String size, String color) async {
    final key = '${product.id}_${size}_${color}';

    if (_items.containsKey(key)) {
      _items[key]!.quantity++;
    } else {
      _items[key] = CartItem(
        product: product,
        quantity: 1,
        selectedSize: size,
        selectedColor: color,
      );
    }

    notifyListeners();
    await _saveCart();
  }

  // Remove item from cart
  Future<void> removeItem(String productId, String size, String color) async {
    final key = '${productId}_${size}_${color}';
    _items.remove(key);
    notifyListeners();
    await _saveCart();
  }

  // Update quantity
  Future<void> updateQuantity(String productId, String size, String color, int newQuantity) async {
    final key = '${productId}_${size}_${color}';

    if (_items.containsKey(key)) {
      if (newQuantity > 0) {
        _items[key]!.quantity = newQuantity;
      } else {
        _items.remove(key);
      }
      notifyListeners();
      await _saveCart();
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    if (_userId == null) return;

    try {
      await _client.delete('$BASE_URL/cart/$_userId');
      _items.clear();
      notifyListeners();
      print('✅ Cart cleared');
    } catch (e) {
      print('❌ Clear cart error: $e');
    }
  }

  // Clear local cart (on logout)
  void clearLocalCart() {
    _items.clear();
    _userId = null;
    notifyListeners();
  }
}