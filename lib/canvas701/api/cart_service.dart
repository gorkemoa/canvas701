import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'auth_service.dart';

/// Sepet İşlemleri Service
class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  Map<String, String> _getHeaders() {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('${ApiConstants.apiUsername}:${ApiConstants.apiPassword}'))}';
    return {'Content-Type': 'application/json', 'Authorization': basicAuth};
  }

  /// Sepete ürün ekle
  Future<AddBasketResponse> addToBasket({
    required int productId,
    required String variant,
    int quantity = 1,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.addBasket}');
    final userToken = await AuthService().getUserToken();

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
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      debugPrint('--- ADD TO BASKET RESPONSE ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 403) {
        await AuthService().logout();
        return AddBasketResponse(
          error: true,
          success: false,
          message: 'Oturum süreniz doldu. Lütfen tekrar giriş yapın.',
        );
      }

      final body = response.body;
      if (body.trim().startsWith('<')) {
        debugPrint(
          '--- ADD TO BASKET ERROR: Received HTML instead of JSON ---',
        );
        return AddBasketResponse(
          error: true,
          success: false,
          message: 'Bir hata oluştu. Lütfen tekrar deneyin.',
        );
      }

      final responseData = jsonDecode(body);
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

  /// Sepet listesini getir
  Future<GetBasketsResponse> getUserBaskets() async {
    final userToken = await AuthService().getUserToken();
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.getUserBaskets}?userToken=${userToken ?? ""}',
    );

    debugPrint('--- GET USER BASKETS REQUEST ---');
    debugPrint('URL: $url');

    try {
      final response = await http.get(url, headers: _getHeaders());

      debugPrint('--- GET USER BASKETS RESPONSE ---');
      debugPrint('Status Code: ${response.statusCode}');

      if (response.statusCode == 403) {
        await AuthService().logout();
        return GetBasketsResponse(
          error: true,
          success: false,
          message: 'Oturum süreniz doldu. Lütfen tekrar giriş yapın.',
        );
      }

      final body = response.body;
      if (body.trim().startsWith('<')) {
        debugPrint(
          '--- GET USER BASKETS ERROR: Received HTML instead of JSON ---',
        );
        return GetBasketsResponse(
          error: true,
          success: false,
          message: 'Bir hata oluştu. Lütfen tekrar deneyin.',
        );
      }

      final responseData = jsonDecode(body);
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

/// Sepete Ekleme İstek Modeli
class AddBasketRequest {
  final String userToken;
  final int productID;
  final int quantity;
  final String variant;

  AddBasketRequest({
    required this.userToken,
    required this.productID,
    required this.quantity,
    required this.variant,
  });

  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken,
      'productID': productID,
      'quantity': quantity,
      'variant': variant,
    };
  }
}

/// Sepete Ekleme Cevap Modeli
class AddBasketResponse {
  final bool error;
  final bool success;
  final String? message;
  final AddBasketData? data;

  AddBasketResponse({
    required this.error,
    required this.success,
    this.message,
    this.data,
  });

  factory AddBasketResponse.fromJson(Map<String, dynamic> json) {
    return AddBasketResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      message: json['data']?['message'] ?? json['message'],
      data: json['data'] != null ? AddBasketData.fromJson(json['data']) : null,
    );
  }
}

/// Sepete Ekleme Data Modeli
class AddBasketData {
  final String? status;
  final String? message;

  AddBasketData({this.status, this.message});

  factory AddBasketData.fromJson(Map<String, dynamic> json) {
    return AddBasketData(
      status: json['status'],
      message: json['message'],
    );
  }
}

/// Sepet Listesi Cevap Modeli
class GetBasketsResponse {
  final bool error;
  final bool success;
  final String? message;
  final GetBasketsData? data;

  GetBasketsResponse({
    required this.error,
    required this.success,
    this.message,
    this.data,
  });

  factory GetBasketsResponse.fromJson(Map<String, dynamic> json) {
    return GetBasketsResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      message: json['data']?['message'] ?? json['message'],
      data: json['data'] != null ? GetBasketsData.fromJson(json['data']) : null,
    );
  }
}

/// Sepet Listesi Data Modeli
class GetBasketsData {
  final String cartTotal;
  final String subtotal;
  final String vatAmount;
  final String cargoPrice;
  final String discountAmount;
  final String grandTotal;
  final String vatRate;
  final int totalItems;
  final List<BasketItem> baskets;

  GetBasketsData({
    required this.cartTotal,
    required this.subtotal,
    required this.vatAmount,
    required this.cargoPrice,
    required this.discountAmount,
    required this.grandTotal,
    required this.vatRate,
    required this.totalItems,
    required this.baskets,
  });

  factory GetBasketsData.fromJson(Map<String, dynamic> json) {
    return GetBasketsData(
      cartTotal: json['cartTotal'] ?? '',
      subtotal: json['subtotal'] ?? '',
      vatAmount: json['vatAmount'] ?? '',
      cargoPrice: json['cargoPrice'] ?? '',
      discountAmount: json['discountAmount'] ?? '',
      grandTotal: json['grandTotal'] ?? '',
      vatRate: json['vatRate'] ?? '',
      totalItems: json['totalItems'] ?? 0,
      baskets: (json['baskets'] as List?)
              ?.map((b) => BasketItem.fromJson(b))
              .toList() ??
          [],
    );
  }
}

/// Sepet Ürün Modeli
class BasketItem {
  final int cartID;
  final int productID;
  final String productCode;
  final String productTitle;
  final String productImage;
  final String variant;
  final int cartQuantity;
  final String unitPrice;
  final String totalPrice;

  BasketItem({
    required this.cartID,
    required this.productID,
    required this.productCode,
    required this.productTitle,
    required this.productImage,
    required this.variant,
    required this.cartQuantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory BasketItem.fromJson(Map<String, dynamic> json) {
    return BasketItem(
      cartID: json['cartID'] ?? 0,
      productID: json['productID'] ?? 0,
      productCode: json['productCode'] ?? '',
      productTitle: json['productTitle'] ?? '',
      productImage: json['productImage'] ?? '',
      variant: json['variant'] ?? '',
      cartQuantity: json['cartQuantity'] ?? 0,
      unitPrice: json['unitPrice'] ?? '',
      totalPrice: json['totalPrice'] ?? '',
    );
  }
}
