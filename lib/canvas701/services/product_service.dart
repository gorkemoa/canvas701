import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../model/category_response.dart';
import '../model/product_models.dart';
import '../model/filter_list_response.dart';
import 'base_service.dart';
import 'token_manager.dart';

/// Ürün işlemlerini yöneten servis
/// Ürün listeleme, detay, filtreleme, favoriler
class ProductService extends BaseService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  final TokenManager _tokenManager = TokenManager();

  // ==================== CATEGORIES ====================

  /// Tüm kategorileri getir
  Future<CategoryResponse> getCategories() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getCategories}');

    debugPrint('--- GET CATEGORIES REQUEST ---');
    debugPrint('URL: $url');

    try {
      final response = await http.get(url, headers: getHeaders());

      debugPrint('--- GET CATEGORIES RESPONSE ---');
      debugPrint('Status Code: ${response.statusCode}');

      if (isHtmlResponse(response.body)) {
        debugPrint('--- GET CATEGORIES ERROR: Received HTML instead of JSON ---');
        return CategoryResponse(error: true, success: false);
      }

      final responseData = jsonDecode(response.body);
      return CategoryResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- GET CATEGORIES ERROR: $e ---');
      return CategoryResponse(error: true, success: false);
    }
  }

  // ==================== PRODUCTS ====================

  /// Tüm ürünleri getir (filtreleme ve sayfalama destekli)
  Future<ProductListResponse> getAllProducts({
    int catID = 0,
    String typeKey = '',
    String sortKey = '',
    String searchText = '',
    int page = 1,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.allProducts}');
    final userToken = await _tokenManager.getUserToken();

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
        headers: getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      debugPrint('--- GET ALL PRODUCTS RESPONSE ---');
      debugPrint('Status Code: ${response.statusCode}');

      if (response.statusCode == 403) {
        await _tokenManager.clearAll();
        _tokenManager.redirectToLogin();
      }

      if (isHtmlResponse(response.body)) {
        debugPrint('--- GET ALL PRODUCTS ERROR: Received HTML instead of JSON ---');
        return ProductListResponse(error: true, success: false);
      }

      final responseData = jsonDecode(response.body);
      return ProductListResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- GET ALL PRODUCTS ERROR: $e ---');
      return ProductListResponse(error: true, success: false);
    }
  }

  /// Ürün detayını getir
  Future<ProductDetailResponse> getProductDetail(int productId) async {
    final userToken = await _tokenManager.getUserToken();
    String urlString = '${ApiConstants.baseUrl}${ApiConstants.getProductDetail(productId)}';

    if (userToken != null && userToken.isNotEmpty) {
      urlString += '?userToken=$userToken';
    }

    final url = Uri.parse(urlString);

    debugPrint('--- GET PRODUCT DETAIL REQUEST ---');
    debugPrint('URL: $url');

    try {
      final response = await http.get(url, headers: getHeaders());

      debugPrint('--- GET PRODUCT DETAIL RESPONSE ---');
      debugPrint('Status Code: ${response.statusCode}');

      if (response.statusCode == 403) {
        await _tokenManager.clearAll();
        _tokenManager.redirectToLogin();
      }

      if (isHtmlResponse(response.body)) {
        debugPrint('--- GET PRODUCT DETAIL ERROR: Received HTML instead of JSON ---');
        debugPrint('Response Body Overview: ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}');
        return ProductDetailResponse(error: true, success: false);
      }

      final responseData = jsonDecode(response.body);
      return ProductDetailResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- GET PRODUCT DETAIL ERROR: $e ---');
      return ProductDetailResponse(error: true, success: false);
    }
  }

  // ==================== FILTERS ====================

  /// Filtre listesini getir
  Future<FilterListResponse> getFilterList() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.filterList}');

    debugPrint('--- GET FILTER LIST REQUEST ---');
    debugPrint('URL: $url');

    try {
      final response = await http.get(url, headers: getHeaders());

      debugPrint('--- GET FILTER LIST RESPONSE ---');
      debugPrint('Status Code: ${response.statusCode}');

      if (isHtmlResponse(response.body)) {
        debugPrint('--- GET FILTER LIST ERROR: Received HTML instead of JSON ---');
        return FilterListResponse(error: true, success: false);
      }

      final responseData = jsonDecode(response.body);
      return FilterListResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- GET FILTER LIST ERROR: $e ---');
      return FilterListResponse(error: true, success: false);
    }
  }

  // ==================== FAVORITES ====================

  /// Favori ürünleri getir
  Future<FavoriteListResponse> getFavorites() async {
    final userToken = await _tokenManager.getUserToken();
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.getFavorites}?userToken=${userToken ?? ""}',
    );

    debugPrint('--- GET FAVORITES REQUEST ---');
    debugPrint('URL: $url');

    try {
      final response = await http.get(url, headers: getHeaders());

      debugPrint('--- GET FAVORITES RESPONSE ---');
      debugPrint('Status Code: ${response.statusCode}');

      if (response.statusCode == 403) {
        await _tokenManager.clearAll();
        _tokenManager.redirectToLogin();
      }

      if (isHtmlResponse(response.body)) {
        debugPrint('--- GET FAVORITES ERROR: Received HTML instead of JSON ---');
        return FavoriteListResponse(error: true, success: false);
      }

      final responseData = jsonDecode(response.body);
      return FavoriteListResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- GET FAVORITES ERROR: $e ---');
      return FavoriteListResponse(error: true, success: false);
    }
  }

  /// Favori ekle/kaldır toggle
  Future<AddDeleteFavoriteResponse> toggleFavorite(int productId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.addDeleteFavorite}');
    final userToken = await _tokenManager.getUserToken();

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
        headers: getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      debugPrint('--- TOGGLE FAVORITE RESPONSE ---');
      debugPrint('Status Code: ${response.statusCode}');

      if (response.statusCode == 403) {
        await _tokenManager.clearAll();
        _tokenManager.redirectToLogin();
      }

      if (isHtmlResponse(response.body)) {
        debugPrint('--- TOGGLE FAVORITE ERROR: Received HTML instead of JSON ---');
        return AddDeleteFavoriteResponse(error: true, success: false);
      }

      final responseData = jsonDecode(response.body);
      return AddDeleteFavoriteResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- TOGGLE FAVORITE ERROR: $e ---');
      return AddDeleteFavoriteResponse(error: true, success: false);
    }
  }
}
