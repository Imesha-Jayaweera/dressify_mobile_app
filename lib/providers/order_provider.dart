import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/order.dart';
import '../core/dio_interceptor.dart';
import '../constants/constants.dart';

class OrderProvider with ChangeNotifier {
  final Dio _client = DioInterceptor.buildDioAPIClient();

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Create Order
  Future<bool> createOrder({
    required String customerId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required Map<String, dynamic> shippingAddress,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('📦 Creating order for customer: $customerId');

      final response = await _client.post(
        '$BASE_URL/order/',
        data: {
          'customerId': customerId,
          'customerName': customerName,
          'customerEmail': customerEmail,
          'customerPhone': customerPhone,
          'shippingAddress': shippingAddress,
          'items': items,
        },
      );

      print('✅ Order created: ${response.data}');

      if (response.data['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Create order error: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Fetch Customer Orders
  Future<void> fetchCustomerOrders(String customerId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('🔍 Fetching orders for customer: $customerId');

      final response = await _client.get('$BASE_URL/order/customer/$customerId');

      print('📦 Orders response: ${response.data}');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          _orders = data.map((o) => Order.fromJson(o as Map<String, dynamic>)).toList();
          print('✅ Loaded ${_orders.length} orders');
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Fetch orders error: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Fetch Shopping Center Orders
  Future<void> fetchShoppingCenterOrders(String shoppingCenterId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('🔍 Fetching orders for shopping center: $shoppingCenterId');

      final response = await _client.get('$BASE_URL/order/shopping-center/$shoppingCenterId');

      print('📦 Shopping center orders response: ${response.data}');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          _orders = data.map((o) => Order.fromJson(o as Map<String, dynamic>)).toList();
          print('✅ Loaded ${_orders.length} orders for shopping center');
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Fetch shopping center orders error: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Update Order Status (for shopping center)
  Future<void> updateStatus(String orderId, String status) async {
    try {
      print('🔄 Updating order status: $orderId -> $status');

      final response = await _client.put(
        '$BASE_URL/order/$orderId/status',
        data: {'status': status},
      );

      print('✅ Status update response: ${response.data}');

      if (response.data['success'] == true) {
        // ✅ Update local state immediately
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          // Recreate the order with new status
          final updatedOrder = Order.fromJson(response.data['data']);
          _orders[index] = updatedOrder;
          notifyListeners();
          print('✅ Local state updated successfully');
        }
      }
    } catch (e) {
      print('❌ Update status error: $e');
      rethrow;
    }
  }
}