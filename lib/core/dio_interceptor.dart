import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/constants.dart';
import '../constants/enums.dart';
import '../utils/toaster.dart';

class DioInterceptor extends Interceptor {
  static final Dio http = Dio();
  static final Set<String> _retryingRequests = <String>{};
  static final Set<String> _errorShownRequests = <String>{};
  static Timer? _cleanupTimer;
  static bool _sessionExpiredHandled = false;

  static Dio buildDioAPIClient() {
    http.interceptors.clear();

    http.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, errorInterceptorHandler) async {
          final requestKey = _getRequestKey(error.requestOptions);

          // Skip refresh token endpoint
          if (error.requestOptions.path.contains("/user/refresh-token")) {
            errorInterceptorHandler.next(error);
            return;
          }

          // Handle 401 Unauthorized
          if (error.response?.statusCode == 401 &&
              !_retryingRequests.contains(requestKey)) {
            _retryingRequests.add(requestKey);
            try {
              String? token = await refreshToken();
              if (token != null) {
                error.requestOptions.headers['Authorization'] = 'Bearer $token';
                final response = await _retry(error.requestOptions);
                _retryingRequests.remove(requestKey);
                errorInterceptorHandler.resolve(response);
                return;
              } else {
                await _handleSessionExpired();
                return;
              }
            } catch (e) {
              await _handleSessionExpired();
              return;
            } finally {
              _retryingRequests.remove(requestKey);
            }
          }

          // Show error message once
          final errorKey = _getErrorKey(error);
          if (!_errorShownRequests.contains(errorKey)) {
            _errorShownRequests.add(errorKey);

            // Extract error message
            String errorMessage = "Something went wrong, Please try again!";
            if (error.response?.data != null) {
              if (error.response!.data is Map) {
                errorMessage = error.response!.data['message'] ?? errorMessage;
              } else if (error.response!.data is String) {
                errorMessage = error.response!.data;
              }
            }

            showErrorMsg(errorMessage);
            _scheduleCleanup(errorKey);
          }

          errorInterceptorHandler.next(error);
        },
        onRequest: (options, requestInterceptorHandler) async {
          final pref = await SharedPreferences.getInstance();
          String token = '';

          if (pref.containsKey(AuthKeysEnum.authData.name)) {
            final extractedData = json
                .decode(pref.getString(AuthKeysEnum.authData.name).toString());
            if (extractedData[AuthKeysEnum.accessToken.name]
                .toString()
                .isNotEmpty) {
              token = extractedData[AuthKeysEnum.accessToken.name];
            }
          }

          options.headers['Authorization'] = 'Bearer $token';
          return requestInterceptorHandler.next(options);
        },
        onResponse: (response, responseInterceptorHandler) {
          responseInterceptorHandler.next(response);
        },
      ),
    );
    return http;
  }

  static Future<void> _handleSessionExpired() async {
    if (_sessionExpiredHandled) return;
    _sessionExpiredHandled = true;

    final pref = await SharedPreferences.getInstance();
    await pref.clear();

    showErrorMsg("Your session has expired. Please log in again.");

    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/landing',
          (route) => false,
    );

    Timer(const Duration(seconds: 1), () {
      _sessionExpiredHandled = false;
    });
  }

  static String _getRequestKey(RequestOptions options) {
    return '${options.method}_${options.path}_${DateTime.now().millisecondsSinceEpoch}';
  }

  static String _getErrorKey(DioException error) {
    // ✅ FIXED: Safely extract error message
    String message = 'Unknown error';

    if (error.response?.data != null) {
      if (error.response!.data is Map) {
        message = error.response!.data['message']?.toString() ?? 'Unknown error';
      } else if (error.response!.data is String) {
        message = error.response!.data;
      }
    } else if (error.message != null) {
      message = error.message!;
    }

    final statusCode = error.response?.statusCode ?? 0;
    final path = error.requestOptions.path;

    return '${statusCode}_${path}_$message';
  }

  static void _scheduleCleanup(String errorKey) {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer(const Duration(seconds: 3), () {
      _errorShownRequests.remove(errorKey);
    });
  }

  static Future<String?> refreshToken() async {
    final pref = await SharedPreferences.getInstance();
    if (!pref.containsKey(AuthKeysEnum.authData.name)) {
      return null;
    }

    final extractedData =
    json.decode(pref.getString(AuthKeysEnum.authData.name).toString());
    if (extractedData[AuthKeysEnum.accessToken.name].toString().isEmpty) {
      return null;
    }

    try {
      final response = await http.post('$BASE_URL/user/refresh-token', data: {
        'refreshToken': extractedData[AuthKeysEnum.refreshToken.name]
      });

      final authData = json.encode({
        AuthKeysEnum.accessToken.name: response.data['access_token'],
        AuthKeysEnum.refreshToken.name:
        extractedData[AuthKeysEnum.refreshToken.name],
        AuthKeysEnum.userId.name: extractedData[AuthKeysEnum.userId.name],
        AuthKeysEnum.userEmail.name: extractedData[AuthKeysEnum.userEmail.name],
      });

      await pref.setString(AuthKeysEnum.authData.name, authData);
      return response.data['access_token'];
    } catch (e) {
      if (e is DioException) {
        print(e.response);
      }
    }
    return null;
  }

  static Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return http.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}