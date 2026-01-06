import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_constants.dart';
import '../model/category_response.dart';
import '../model/product_list_request.dart';
import '../model/product_list_response.dart';
import '../model/filter_list_response.dart';
import 'auth_service.dart';

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

  Future<ProductListResponse> getAllProducts({
    int catID = 0,
    String typeKey = '',
    String sortKey = '',
    String searchText = '',
    int page = 1,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.allProducts}');
    final userToken = await AuthService().getUserToken();
    
    final request = ProductListRequest(
      userToken: userToken,
      catID: catID,
      typeKey: typeKey,
      sortKey: sortKey,
      searchText: searchText,
      page: page,
    );

    debugPrint('--- GET ALL PRODUCTS REQUEST ---');
    debugPrint('URL: $url');
    debugPrint('Body: ${jsonEncode(request.toJson())}');

    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      debugPrint('--- GET ALL PRODUCTS RESPONSE ---');
      debugPrint('Status Code: ${response.statusCode}');

      if (response.statusCode == 403) {
        // Handle unauthorized
        await AuthService().logout();
      }

      final responseData = jsonDecode(response.body);
      return ProductListResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- GET ALL PRODUCTS ERROR: $e ---');
      return ProductListResponse(error: true, success: false);
    }
  }

  Future<FilterListResponse> getFilterList() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.filterList}');
    
    debugPrint('--- GET FILTER LIST REQUEST ---');
    debugPrint('URL: $url');

    try {
      final response = await http.get(
        url,
        headers: _getHeaders(),
      );

      debugPrint('--- GET FILTER LIST RESPONSE ---');
      debugPrint('Status Code: ${response.statusCode}');

      final responseData = jsonDecode(response.body);
      return FilterListResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- GET FILTER LIST ERROR: $e ---');
      return FilterListResponse(error: true, success: false);
    }
  }
}
