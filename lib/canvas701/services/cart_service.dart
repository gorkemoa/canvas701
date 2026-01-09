import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../model/basket_models.dart';
import 'base_service.dart';
import 'token_manager.dart';

/// Sepet işlemlerini yöneten servis
class CartService extends BaseService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final TokenManager _tokenManager = TokenManager();

  /// Sepete ürün ekle
  Future<AddBasketResponse> addToBasket({
    required int productId,
    required String variant,
    int quantity = 1,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.addBasket}');
    final userToken = await _tokenManager.getUserToken();

    final request = AddBasketRequest(
      userToken: userToken ?? '',
      productID: productId,
      quantity: quantity,
      variant: variant,
    );

    debugPrint('--- ADD TO BASKET REQUEST ---');
    debugPrint('URL: $url');
    debugPrint('Body: ${jsonEncode(request.toJson())}');

    try {
      final response = await http.post(
        url,
        headers: getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      debugPrint('--- ADD TO BASKET RESPONSE ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 403) {
        await _tokenManager.clearAll();
        _tokenManager.redirectToLogin();
        return AddBasketResponse(
          error: true,
          success: false,
          message: 'Oturum süreniz doldu. Lütfen tekrar giriş yapın.',
        );
      }

      if (isHtmlResponse(response.body)) {
        debugPrint('--- ADD TO BASKET ERROR: Received HTML instead of JSON ---');
        return AddBasketResponse(
          error: true,
          success: false,
          message: 'Bir hata oluştu. Lütfen tekrar deneyin.',
        );
      }

      final responseData = jsonDecode(response.body);
      return AddBasketResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- ADD TO BASKET ERROR: $e ---');
      return AddBasketResponse(
        error: true,
        success: false,
        message: 'Bağlantı hatası. Lütfen tekrar deneyin.',
      );
    }
  }

  /// Sepeti güncelle (adet veya varyant)
  Future<AddBasketResponse> updateBasket({
    required int basketId,
    required String variant,
    required int quantity,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.updateBasket}');
    final userToken = await _tokenManager.getUserToken();

    final request = UpdateBasketRequest(
      userToken: userToken ?? '',
      basketID: basketId,
      quantity: quantity,
      variant: variant,
    );

    debugPrint('--- UPDATE BASKET REQUEST ---');
    debugPrint('URL: $url');
    debugPrint('Body: ${jsonEncode(request.toJson())}');

    try {
      final response = await http.put(
        url,
        headers: getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      debugPrint('--- UPDATE BASKET RESPONSE ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 403) {
        await _tokenManager.clearAll();
        _tokenManager.redirectToLogin();
        return AddBasketResponse(
          error: true,
          success: false,
          message: 'Oturum süreniz doldu. Lütfen tekrar giriş yapın.',
        );
      }

      if (isHtmlResponse(response.body)) {
        return AddBasketResponse(
          error: true,
          success: false,
          message: 'Bir hata oluştu. Lütfen tekrar deneyin.',
        );
      }

      final responseData = jsonDecode(response.body);
      return AddBasketResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- UPDATE BASKET ERROR: $e ---');
      return AddBasketResponse(
        error: true,
        success: false,
        message: 'Bağlantı hatası. Lütfen tekrar deneyin.',
      );
    }
  }

  /// Sepet listesini getir
  Future<GetBasketsResponse> getUserBaskets() async {
    final userToken = await _tokenManager.getUserToken();
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.getUserBaskets}?userToken=${userToken ?? ""}',
    );

    debugPrint('--- GET USER BASKETS REQUEST ---');
    debugPrint('URL: $url');

    try {
      final response = await http.get(url, headers: getHeaders());

      debugPrint('--- GET USER BASKETS RESPONSE ---');
      debugPrint('Status Code: ${response.statusCode}');

      if (response.statusCode == 403) {
        await _tokenManager.clearAll();
        _tokenManager.redirectToLogin();
        return GetBasketsResponse(
          error: true,
          success: false,
          message: 'Oturum süreniz doldu. Lütfen tekrar giriş yapın.',
        );
      }

      if (isHtmlResponse(response.body)) {
        debugPrint('--- GET USER BASKETS ERROR: Received HTML instead of JSON ---');
        return GetBasketsResponse(
          error: true,
          success: false,
          message: 'Bir hata oluştu. Lütfen tekrar deneyin.',
        );
      }

      final responseData = jsonDecode(response.body);
      return GetBasketsResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- GET USER BASKETS ERROR: $e ---');
      return GetBasketsResponse(
        error: true,
        success: false,
        message: 'Bağlantı hatası. Lütfen tekrar deneyin.',
      );
    }
  }
}
