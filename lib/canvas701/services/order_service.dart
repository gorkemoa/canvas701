import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../model/order_models.dart';
import 'base_service.dart';
import 'token_manager.dart';

/// Sipariş işlemlerini yöneten servis
class OrderService extends BaseService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal();

  final TokenManager _tokenManager = TokenManager();

  /// Kullanıcının siparişlerini getir
  Future<UserOrdersResponse> getOrders() async {
    debugPrint('--- OrderService.getOrders() CALLED ---');

    final token = await _tokenManager.getAuthToken();

    if (token == null) {
      debugPrint('--- GET ORDERS ABORTED: token is missing ---');
      return UserOrdersResponse(error: true, success: false);
    }

    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.getUserOrders}?userToken=$token',
    );

    logRequest('GET', url.toString());

    try {
      final response = await http.get(url, headers: getHeaders());

      logResponse(response.statusCode, response.body);

      // HTML yanıt kontrolü
      if (isHtmlResponse(response.body)) {
        debugPrint('--- HTML yanıt alındı, API hatası ---');
        return UserOrdersResponse(error: true, success: false);
      }

      // 403 - Token geçersiz
      if (response.statusCode == 403) {
        _tokenManager.redirectToLogin();
        return UserOrdersResponse(error: true, success: false);
      }

      final responseData = jsonDecode(response.body);
      return UserOrdersResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- OrderService.getOrders() ERROR: $e ---');
      return UserOrdersResponse(error: true, success: false);
    }
  }

  /// Sipariş durum listesini getir
  Future<OrderStatusListResponse> getOrderStatusList() async {
    debugPrint('--- OrderService.getOrderStatusList() CALLED ---');

    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.getOrderStatusList}',
    );

    logRequest('GET', url.toString());

    try {
      final response = await http.get(url, headers: getHeaders());

      logResponse(response.statusCode, response.body);

      // HTML yanıt kontrolü
      if (isHtmlResponse(response.body)) {
        debugPrint('--- HTML yanıt alındı, API hatası ---');
        return OrderStatusListResponse(
          error: true,
          success: false,
          statusList: [],
        );
      }

      final responseData = jsonDecode(response.body);
      return OrderStatusListResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- OrderService.getOrderStatusList() ERROR: $e ---');
      return OrderStatusListResponse(
        error: true,
        success: false,
        statusList: [],
      );
    }
  }

  /// Sipariş detayını getir
  Future<UserOrderDetailResponse> getOrderDetail(int orderID) async {
    debugPrint('--- OrderService.getOrderDetail($orderID) CALLED ---');

    final token = await _tokenManager.getAuthToken();

    if (token == null) {
      debugPrint('--- GET ORDER DETAIL ABORTED: token is missing ---');
      return UserOrderDetailResponse(error: true, success: false);
    }

    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.getOrderDetail}?userToken=$token&orderID=$orderID',
    );

    logRequest('GET', url.toString());

    try {
      final response = await http.get(url, headers: getHeaders());

      logResponse(response.statusCode, response.body);

      // HTML yanıt kontrolü
      if (isHtmlResponse(response.body)) {
        debugPrint('--- HTML yanıt alındı, API hatası ---');
        return UserOrderDetailResponse(error: true, success: false);
      }

      // 403 - Token geçersiz
      if (response.statusCode == 403) {
        _tokenManager.redirectToLogin();
        return UserOrderDetailResponse(error: true, success: false);
      }

      final responseData = jsonDecode(response.body);
      return UserOrderDetailResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- OrderService.getOrderDetail() ERROR: $e ---');
      return UserOrderDetailResponse(error: true, success: false);
    }
  }
}
