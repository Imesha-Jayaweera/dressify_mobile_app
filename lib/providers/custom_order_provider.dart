import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/custom_order.dart';
import '../core/dio_interceptor.dart';
import '../constants/constants.dart';

class CustomOrderProvider with ChangeNotifier {
  final Dio _client = DioInterceptor.buildDioAPIClient();

  List<CustomOrder> _customOrders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CustomOrder> get customOrders => _customOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Create Custom Order
  Future<bool> createCustomOrder({
    required String customerId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String productId,
    required int quantity,
    required String selectedColor,
    String? additionalNotes,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('📦 Creating custom order for product: $productId');

      final response = await _client.post(
        '$BASE_URL/custom-order/',
        data: {
          'customerId': customerId,
          'customerName': customerName,
          'customerEmail': customerEmail,
          'customerPhone': customerPhone,
          'productId': productId,
          'quantity': quantity,
          'selectedColor': selectedColor,
          'additionalNotes': additionalNotes,
        },
      );

      print('✅ Custom order created: ${response.data}');

      if (response.data['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      print('❌ Create custom order error: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Fetch Tailor Custom Orders
  Future<void> fetchTailorCustomOrders(String tailorId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('🔍 Fetching custom orders for tailor: $tailorId');

      final response = await _client.get('$BASE_URL/custom-order/tailor/$tailorId');

      print('📦 Custom orders response: ${response.data}');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          _customOrders = data.map((o) => CustomOrder.fromJson(o as Map<String, dynamic>)).toList();
          print('✅ Loaded ${_customOrders.length} custom orders');
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Fetch custom orders error: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Update Custom Order Status
  Future<void> updateStatus(String orderId, String status) async {
    try {
      print('🔄 Updating custom order status: $orderId -> $status');

      final response = await _client.put(
        '$BASE_URL/custom-order/$orderId/status',
        data: {'status': status},
      );

      print('✅ Status update response: ${response.data}');

      if (response.data['success'] == true) {
        // ✅ Update local state immediately
        final index = _customOrders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          // Recreate the order with new status
          final updatedOrder = CustomOrder.fromJson(response.data['data']);
          _customOrders[index] = updatedOrder;
          notifyListeners();
          print('✅ Local state updated successfully');
        }
      }
    } catch (e) {
      print('❌ Update custom order status error: $e');
      rethrow;
    }
  }

  // Fetch Customer Custom Orders
  Future<void> fetchCustomerCustomOrders(String customerId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('🔍 Fetching custom orders for customer: $customerId');

      final response = await _client.get('$BASE_URL/custom-order/customer/$customerId');

      print('📦 Customer custom orders response: ${response.data}');

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data is List) {
          _customOrders = data.map((o) => CustomOrder.fromJson(o as Map<String, dynamic>)).toList();
          print('✅ Loaded ${_customOrders.length} custom orders for customer');
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Fetch customer custom orders error: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}

