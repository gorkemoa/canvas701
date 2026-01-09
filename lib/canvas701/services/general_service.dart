import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../model/banner_response.dart';
import '../model/kvkk_response.dart';
import 'base_service.dart';

/// Genel amaçlı servis (KVKK, ayarlar vb.)
class GeneralService extends BaseService {
  static final GeneralService _instance = GeneralService._internal();
  factory GeneralService() => _instance;
  GeneralService._internal();

  /// KVKK metnini getir
  Future<KvkkResponse> getKvkkPolicy() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.kvkkAgreement}');

    debugPrint('--- API REQUEST (GET) ---');
    debugPrint('URL: $url');
    debugPrint('-------------------');

    try {
      final response = await http.get(url, headers: getHeaders());

      debugPrint('--- API RESPONSE ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
      debugPrint('--------------------');

      final responseData = jsonDecode(response.body);
      return KvkkResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- API ERROR: $e ---');
      return KvkkResponse(error: true, success: false);
    }
  }

  /// Banner listesini getir
  Future<BannerResponse> getBanners() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.bannerList}');

    debugPrint('--- API REQUEST (GET) ---');
    debugPrint('URL: $url');
    debugPrint('-------------------');

    try {
      final response = await http.get(url, headers: getHeaders());

      debugPrint('--- API RESPONSE ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
      debugPrint('--------------------');

      final responseData = jsonDecode(response.body);
      return BannerResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- API ERROR: $e ---');
      return BannerResponse(error: true, success: false);
    }
  }

}
