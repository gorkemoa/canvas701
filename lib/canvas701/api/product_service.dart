import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../model/category_response.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  Map<String, String> _getHeaders() {
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('${ApiConstants.apiUsername}:${ApiConstants.apiPassword}'))}';
    return {
      'Content-Type': 'application/json',
      'Authorization': basicAuth,
    };
  }

  Future<CategoryResponse> getCategories() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getCategories}');
    
    debugPrint('--- GET CATEGORIES REQUEST ---');
    debugPrint('URL: $url');

    try {
      final response = await http.get(
        url,
        headers: _getHeaders(),
      );

      debugPrint('--- GET CATEGORIES RESPONSE ---');
      debugPrint('Status Code: ${response.statusCode}');

      final responseData = jsonDecode(response.body);
      return CategoryResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- GET CATEGORIES ERROR: $e ---');
      return CategoryResponse(error: true, success: false);
    }
  }
}
