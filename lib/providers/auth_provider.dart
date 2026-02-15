import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../core/dio_interceptor.dart';
import '../constants/constants.dart';

class AuthProvider with ChangeNotifier {
  final Dio _client = DioInterceptor.buildDioAPIClient();

  Map<String, dynamic>? _user;
  String? _token;
  bool _isAuthenticated = false;

  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;
  String? get userType => _user?['userType'];

  // SIGN UP
  Future<void> signUp(Map<String, dynamic> data) async {
    try {
      final response = await _client.post('$BASE_URL/user/register', data: data);

      if (response.data['success'] == true) {
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  // VERIFY OTP
  Future<void> verifyOtp(String email, String code) async {
    try {
      final response = await _client.post(
        '$BASE_URL/user/verify',
        data: {
          'email': email,
          'code': code,
        },
      );

      _token = response.data['token'] ?? response.data['data']?['token'];
      _user = response.data['user'] ?? response.data['data']?['user'];
      _isAuthenticated = true;

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      if (_token != null) {
        await prefs.setString('token', _token!);
      }
      if (_user != null) {
        await prefs.setString('userType', _user!['userType']);
        await prefs.setString('userId', _user!['_id'] ?? _user!['userId'] ?? '');
        await prefs.setString('user', jsonEncode(_user!)); // ✅ Save full user
      }

      notifyListeners();
    } catch (e) {
      print('OTP Verification Error: $e');
      rethrow;
    }
  }

  // SIGN IN
  Future<Map<String, dynamic>> signIn(Map<String, dynamic> data) async {
    try {
      final response = await _client.post('$BASE_URL/user/login', data: data);

      if (response.data['verificationRequired'] == true) {
        return {'verificationRequired': true};
      }

      // Extract token and user from response
      _token = response.data['token'] ?? response.data['data']?['token'];
      _user = response.data['user'] ?? response.data['data']?['user'];
      _isAuthenticated = true;

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      if (_token != null) {
        await prefs.setString('token', _token!);
      }
      if (_user != null) {
        await prefs.setString('userType', _user!['userType']);
        await prefs.setString('userId', _user!['_id'] ?? _user!['userId'] ?? '');
        await prefs.setString('user', jsonEncode(_user!)); // ✅ Save full user
      }

      notifyListeners();
      return {
        'verificationRequired': false,
        'userType': _user?['userType'] ?? 'CUSTOMER'
      };
    } catch (e) {
      print('Sign In Error: $e');
      rethrow;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    _user = null;
    _token = null;
    _isAuthenticated = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }

  // AUTO LOGIN
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userJson = prefs.getString('user');

    // ✅ FIXED: Check userJson instead of userType
    if (token != null && userJson != null && userJson.isNotEmpty) {
      _token = token;
      _isAuthenticated = true;
      _user = jsonDecode(userJson); // ✅ This is now safe because userJson is non-null

      print('✅ AutoLogin successful - user: $_user');

      notifyListeners();
      return true;
    }

    print('❌ AutoLogin failed - no saved session');
    return false;
  }
}