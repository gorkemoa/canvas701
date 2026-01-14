import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../model/about_info_model.dart';
import '../model/banner_response.dart';
import '../model/faq_model.dart';
import '../model/kvkk_response.dart';
import '../model/size_model.dart';
import '../model/specials_model.dart';
import '../model/type_model.dart';
import 'base_service.dart';

/// Genel amaçlı servis (KVKK, ayarlar vb.)
class GeneralService extends BaseService {
  static final GeneralService _instance = GeneralService._internal();
  factory GeneralService() => _instance;
  GeneralService._internal();

  /// Boyut listesini getir
  Future<SizeResponse> getSizes() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getSizeList}');

    logRequest('GET', url.toString());

    try {
      final response = await http.get(url, headers: getHeaders());

      logResponse(response.statusCode, response.body);

      final responseData = jsonDecode(response.body);
      return SizeResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- API ERROR: $e ---');
      return SizeResponse(error: true, success: false);
    }
  }

  /// Ürün tipi listesini getir
  Future<TypeListResponse> getTypes() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getTypeList}');

    logRequest('GET', url.toString());

    try {
      final response = await http.get(url, headers: getHeaders());

      logResponse(response.statusCode, response.body);

      final responseData = jsonDecode(response.body);
      return TypeListResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- API ERROR: $e ---');
      return TypeListResponse(error: true, success: false);
    }
  }

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

  /// Hakkımızda bilgilerini getir
  Future<AboutInfoResponse> getAboutInfo() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.aboutInfo}');

    logRequest('GET', url.toString());

    try {
      final response = await http.get(url, headers: getHeaders());

      logResponse(response.statusCode, response.body);

      final responseData = jsonDecode(response.body);
      return AboutInfoResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- API ERROR: $e ---');
      return AboutInfoResponse(error: true, success: false);
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

  /// Sana Özel onboarding görsellerini getir
  Future<SpecialsResponse> getSpecials() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getSpecials}');

    logRequest('GET', url.toString());

    try {
      final response = await http.get(url, headers: getHeaders());

      logResponse(response.statusCode, response.body);

      final responseData = jsonDecode(response.body);
      return SpecialsResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- API ERROR: $e ---');
      return SpecialsResponse(error: true, success: false);
    }
  }

  /// SSS (Sıkça Sorulan Sorular) listesini getir
  Future<FaqResponse> getFaqs() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.faqList}');

    logRequest('GET', url.toString());

    try {
      final response = await http.get(url, headers: getHeaders());

      logResponse(response.statusCode, response.body);

      final responseData = jsonDecode(response.body);
      return FaqResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- API ERROR: $e ---');
      return FaqResponse(error: true, success: false);
    }
  }
}
