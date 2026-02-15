import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/product.dart';
import '../core/dio_interceptor.dart';
import '../constants/constants.dart';
import 'dart:convert';
import 'dart:io';

class ProductProvider with ChangeNotifier {
  final Dio _client = DioInterceptor.buildDioAPIClient();

  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // FETCH MY PRODUCTS
  Future<void> fetchMyProducts(String shoppingCenterId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('🔍 Fetching products for shopping center: $shoppingCenterId');

      final response = await _client.get(
        '$BASE_URL/product/my-products/$shoppingCenterId',
      );

      print('📦 Raw response: ${response.data}');

      // Handle different response formats
      if (response.data is Map && response.data['success'] == true) {
        // Backend returns { success: true, data: [...] }
        final data = response.data['data'];
        if (data is List) {
          _products = data
              .map((p) => Product.fromJson(p as Map<String, dynamic>))
              .toList();
          print('✅ Loaded ${_products.length} products from wrapped response');
        }
      } else if (response.data is List) {
        // Backend returns [...] directly
        _products = (response.data as List)
            .map((p) => Product.fromJson(p as Map<String, dynamic>))
            .toList();
        print('✅ Loaded ${_products.length} products from direct list');
      } else {
        print('❌ Unexpected response format: ${response.data}');
        throw Exception('Unexpected response format');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Fetch error: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addProduct(
      Map<String, dynamic> productData,
      List<File> imageFiles,
      String shoppingCenterId,
      ) async {
    try {
      print('📦 Starting product upload with ${imageFiles.length} images...');

      List<MultipartFile> multipartFiles = [];
      for (int i = 0; i < imageFiles.length; i++) {
        multipartFiles.add(
          await MultipartFile.fromFile(
            imageFiles[i].path,
            filename: 'image_$i.jpg',
          ),
        );
      }

      print('✅ Created ${multipartFiles.length} MultipartFiles');

      // ✅ Build FormData properly
      Map<String, dynamic> formDataMap = {
        'name': productData['name'],
        'description': productData['description'] ?? '',
        'category': productData['category'],
        'genderType': productData['genderType'],
        'price': productData['price'].toString(),
        'shoppingCenterId': shoppingCenterId,
        'sizes': jsonEncode(productData['sizes']),
        'colors': jsonEncode(productData['colors']),
        'suitableBodyTypes': jsonEncode(productData['suitableBodyTypes']),
      };

      // ✅ Add images with same key 'images'
      formDataMap['images'] = multipartFiles;

      FormData formData = FormData.fromMap(formDataMap);

      print('📤 Sending ${multipartFiles.length} images...');
      print('📋 FormData ready');

      final response = await _client.post(
        '$BASE_URL/product/',
        data: formData,
        options: Options(
          sendTimeout: const Duration(seconds: 120),
          receiveTimeout: const Duration(seconds: 120),
        ),
      );

      print('✅ Add product response status: ${response.statusCode}');
      print('✅ Add product response: ${response.data}');

      // Handle both response formats
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('🔄 Refreshing product list after add');
        await fetchMyProducts(shoppingCenterId);
      }
    } catch (e) {
      print('❌ Add product error: $e');
      if (e is DioException) {
        print('DioError response: ${e.response?.data}');
        print('DioError message: ${e.message}');
      }
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // UPDATE PRODUCT - IMPROVED VERSION
  Future<void> updateProduct(String productId, Map<String, dynamic> productData) async {
    try {
      print('🔄 Updating product: $productId');
      print('📝 Update data: $productData');

      final response = await _client.put(
        '$BASE_URL/product/$productId',
        data: productData,
      );

      print('✅ Update response status: ${response.statusCode}');
      print('✅ Update response data: ${response.data}');

      // ✅ CRITICAL: Always refresh from backend after update
      if (response.statusCode == 200) {
        // Find the product's shopping center ID for refresh
        final product = _products.firstWhere(
              (p) => p.id == productId,
          orElse: () => _products.first,
        );

        print('🔄 Refreshing product list for shopping center: ${product.shoppingCenterId}');

        // Force refresh from backend to get updated totalStock
        await fetchMyProducts(product.shoppingCenterId);

        print('✅ Product list refreshed - new stock values loaded');
      }
    } catch (e) {
      print('❌ Update error: $e');
      if (e is DioException) {
        print('DioError response: ${e.response?.data}');
        print('DioError message: ${e.message}');
        print('DioError status: ${e.response?.statusCode}');
      }
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // DELETE PRODUCT
  Future<void> deleteProduct(String productId) async {
    try {
      print('🗑️ Deleting product: $productId');

      final response = await _client.delete('$BASE_URL/product/$productId');

      print('✅ Delete response: ${response.data}');

      if (response.statusCode == 200 || response.data['success'] == true) {
        _products.removeWhere((p) => p.id == productId);
        notifyListeners();
        print('✅ Product removed from local list');
      }
    } catch (e) {
      print('❌ Delete error: $e');
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // UPDATE INVENTORY
  Future<void> updateInventory(String productId, List<SizeStock> sizes) async {
    try {
      final sizesData = sizes.map((s) => s.toJson()).toList();

      await _client.put(
        '$BASE_URL/product/$productId',
        data: {'sizes': sizesData},
      );

      await fetchMyProducts(_products.first.shoppingCenterId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}