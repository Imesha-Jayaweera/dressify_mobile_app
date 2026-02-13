import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../core/dio_interceptor.dart';
import '../constants/constants.dart';
import '../constants/enums.dart';

class AuthProvider with ChangeNotifier {
  final Dio _client = DioInterceptor.buildDioAPIClient();

  User? _user;
  String _accessToken = '';
  String _refreshToken = '';
  bool _isAuthenticated = false;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  String get accessToken => _accessToken;

  // Sign Up API Call
  Future<Map<String, dynamic>> signUp(Map<String, dynamic> data) async {
    try {
      final response = await _client.post(
        '$BASE_URL/user/register',
        data: json.encode(data),
      );

      if (!SUCCESS_CODES.contains(response.statusCode)) {
        throw response.data;
      }

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Sign In API Call
  Future<Map<String, dynamic>> signIn(Map<String, dynamic> data) async {
    try {
      final response = await _client.post(
        '$BASE_URL/user/login',
        data: json.encode(data),
      );

      if (!SUCCESS_CODES.contains(response.statusCode)) {
        throw response.data;
      }

      if (response.data['verificationRequired'] != true) {
        await _setAuthData(response.data);
      }

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // Verify OTP API Call
  Future<Map<String, dynamic>> verifyOtp(String email, String code) async {
    try {
      final response = await _client.post(
        '$BASE_URL/user/verify',
        data: json.encode({
          "email": email,
          "code": code,
        }),
      );

      if (!SUCCESS_CODES.contains(response.statusCode)) {
        throw response.data;
      }

      await _setAuthData(response.data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _setAuthData(Map<String, dynamic> data) async {
    final pref = await SharedPreferences.getInstance();

    _accessToken = data['access_token'] ?? '';
    _refreshToken = data['refresh_token'] ?? '';

    if (data['user'] != null) {
      _user = User.fromJson(data['user']);
    }

    final authData = json.encode({
      AuthKeysEnum.accessToken.name: _accessToken,
      AuthKeysEnum.refreshToken.name: _refreshToken,
      AuthKeysEnum.userId.name: _user?.id ?? '',
      AuthKeysEnum.userEmail.name: _user?.email ?? '',
      AuthKeysEnum.userName.name: _user?.name ?? '',
    });

    await pref.setString(AuthKeysEnum.authData.name, authData);

    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {
    final pref = await SharedPreferences.getInstance();
    await pref.clear();

    _accessToken = '';
    _refreshToken = '';
    _user = null;
    _isAuthenticated = false;

    notifyListeners();
  }

  Future<bool> checkAuthStatus() async {
    final pref = await SharedPreferences.getInstance();

    if (!pref.containsKey(AuthKeysEnum.authData.name)) {
      return false;
    }

    final extractedData = json.decode(
        pref.getString(AuthKeysEnum.authData.name).toString());

    _accessToken = extractedData[AuthKeysEnum.accessToken.name] ?? '';
    _refreshToken = extractedData[AuthKeysEnum.refreshToken.name] ?? '';

    if (_accessToken.isNotEmpty) {
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }

    return false;
  }
}