import 'dart:convert';
import 'package:canvas701/canvas701/constants/api_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/category_response.dart';
import '../model/product_models.dart';
import '../model/filter_list_response.dart';
import 'auth_service.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  Map<String, String> _getHeaders() {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('${ApiConstants.apiUsername}:${ApiConstants.apiPassword}'))}';
    return {'Content-Type': 'application/json', 'Authorization': basicAuth};
  }

  Future<CategoryResponse> getCategories() async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.getCategories}',
    );

    debugPrint('--- GET CATEGORIES REQUEST ---');
    debugPrint('URL: $url');

    try {
      final response = await http.get(url, headers: _getHeaders());

      debugPrint('--- GET CATEGORIES RESPONSE ---');
      debugPrint('Status Code: ${response.statusCode}');

      final body = response.body;
      if (body.trim().startsWith('<')) {
        debugPrint(
          '--- GET CATEGORIES ERROR: Received HTML instead of JSON ---',
        );
        return CategoryResponse(error: true, success: false);
      }

      final responseData = jsonDecode(body);
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

      final body = response.body;
      if (body.trim().startsWith('<')) {
        debugPrint(
          '--- GET ALL PRODUCTS ERROR: Received HTML instead of JSON ---',
        );
        return ProductListResponse(error: true, success: false);
      }

      final responseData = jsonDecode(body);
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
      final response = await http.get(url, headers: _getHeaders());

      debugPrint('--- GET FILTER LIST RESPONSE ---');
      debugPrint('Status Code: ${response.statusCode}');

      final body = response.body;
      if (body.trim().startsWith('<')) {
        debugPrint(
          '--- GET FILTER LIST ERROR: Received HTML instead of JSON ---',
        );
        return FilterListResponse(error: true, success: false);
      }

      final responseData = jsonDecode(body);
      return FilterListResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- GET FILTER LIST ERROR: $e ---');
      return FilterListResponse(error: true, success: false);
    }
  }
  Future<FavoriteListResponse> getFavorites() async {
    final userToken = await AuthService().getUserToken();
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.getFavorites}?userToken=${userToken ?? ""}',
    );

    debugPrint('--- GET FAVORITES REQUEST ---');
    debugPrint('URL: $url');

    try {
      final response = await http.get(url, headers: _getHeaders());

      debugPrint('--- GET FAVORITES RESPONSE ---');
      debugPrint('Status Code: ${response.statusCode}');

      if (response.statusCode == 403) {
        await AuthService().logout();
      }

      final body = response.body;
      if (body.trim().startsWith('<')) {
        debugPrint(
          '--- GET FAVORITES ERROR: Received HTML instead of JSON ---',
        );
        return FavoriteListResponse(error: true, success: false);
      }

      final responseData = jsonDecode(body);
      return FavoriteListResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- GET FAVORITES ERROR: $e ---');
      return FavoriteListResponse(error: true, success: false);
    }
  }

  Future<AddDeleteFavoriteResponse> toggleFavorite(int productId) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.addDeleteFavorite}',
    );
    final userToken = await AuthService().getUserToken();

    final request = AddDeleteFavoriteRequest(
      userToken: userToken,
      productID: productId,
    );

    debugPrint('--- TOGGLE FAVORITE REQUEST ---');
    debugPrint('URL: $url');
    debugPrint('Body: ${jsonEncode(request.toJson())}');

    try {
      final response = await http.put(
        url,
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      debugPrint('--- TOGGLE FAVORITE RESPONSE ---');
      debugPrint('Status Code: ${response.statusCode}');

      if (response.statusCode == 403) {
        await AuthService().logout();
      }

      final body = response.body;
      if (body.trim().startsWith('<')) {
        debugPrint(
          '--- TOGGLE FAVORITE ERROR: Received HTML instead of JSON ---',
        );
        return AddDeleteFavoriteResponse(error: true, success: false);
      }

      final responseData = jsonDecode(body);
      return AddDeleteFavoriteResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- TOGGLE FAVORITE ERROR: $e ---');
      return AddDeleteFavoriteResponse(error: true, success: false);
    }
  }
  Future<ProductDetailResponse> getProductDetail(int productId) async {
    final userToken = await AuthService().getUserToken();
    String urlString =
        '${ApiConstants.baseUrl}${ApiConstants.getProductDetail(productId)}';

    if (userToken != null && userToken.isNotEmpty) {
      urlString += '?userToken=$userToken';
    }

    final url = Uri.parse(urlString);

    debugPrint('--- GET PRODUCT DETAIL REQUEST ---');
    debugPrint('URL: $url');

    try {
      final response = await http.get(url, headers: _getHeaders());

      debugPrint('--- GET PRODUCT DETAIL RESPONSE ---');
      debugPrint('Status Code: ${response.statusCode}');

      if (response.statusCode == 403) {
        await AuthService().logout();
      }

      final body = response.body;
      if (body.trim().startsWith('<')) {
        debugPrint(
          '--- GET PRODUCT DETAIL ERROR: Received HTML instead of JSON ---',
        );
        debugPrint(
          'Response Body Overview: ${body.length > 200 ? body.substring(0, 200) : body}',
        );
        return ProductDetailResponse(error: true, success: false);
      }

      final responseData = jsonDecode(body);
      return ProductDetailResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- GET PRODUCT DETAIL ERROR: $e ---');
      return ProductDetailResponse(error: true, success: false);
    }
  }
}
