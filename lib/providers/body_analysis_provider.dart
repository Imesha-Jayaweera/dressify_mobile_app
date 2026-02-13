import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/body_analysis.dart';
import '../core/dio_interceptor.dart';
import '../constants/constants.dart';

class BodyAnalysisProvider with ChangeNotifier {
  final Dio _client = DioInterceptor.buildDioAPIClient();

  BodyAnalysis? _currentAnalysis;
  bool _isLoading = false;

  BodyAnalysis? get currentAnalysis => _currentAnalysis;
  bool get isLoading => _isLoading;

  // Analyze Body Image API Call
  Future<BodyAnalysis?> analyzeBodyImage(String base64Image) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _client.post(
        '$BASE_URL/ai/analyze',
        data: json.encode({"imageBase64": base64Image}),
      );

      if (!SUCCESS_CODES.contains(response.statusCode)) {
        throw response.data;
      }

      _currentAnalysis = BodyAnalysis.fromJson(response.data);
      return _currentAnalysis;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearAnalysis() {
    _currentAnalysis = null;
    notifyListeners();
  }
}