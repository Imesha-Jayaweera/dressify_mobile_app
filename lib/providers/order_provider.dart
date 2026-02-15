import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/order.dart';
import '../core/dio_interceptor.dart';
import '../constants/constants.dart';

class OrderProvider with ChangeNotifier {
  final Dio _client = DioInterceptor.buildDioAPIClient();

  List<Order> _orders = [];

  List<Order> get orders => _orders;

  Future<void> fetchOrders() async {
    final response = await _client.get('$BASE_URL/orders');

    _orders = (response.data['data'] as List)
        .map((o) => Order.fromJson(o))
        .toList();

    notifyListeners();
  }

  Future<void> updateStatus(String orderId, String status) async {
    await _client.patch(
      '$BASE_URL/orders/$orderId',
      data: {"status": status},
    );

    await fetchOrders();
  }
}
