import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../model/address_models.dart';
import 'base_service.dart';

/// Şehir ve ilçe bilgilerini getiren servis
class LocationService extends BaseService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Tüm şehirleri getir
  Future<CityResponse> getCities() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getCities}');

    debugPrint('--- API REQUEST (GET CITIES) ---');
    debugPrint('URL: $url');
    debugPrint('-------------------');

    try {
      final response = await http.get(url, headers: getHeaders());

      debugPrint('--- API RESPONSE (CITIES) ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('--------------------');

      final responseData = jsonDecode(response.body);
      return CityResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- API ERROR: $e ---');
      return CityResponse(error: true, success: false);
    }
  }

  /// Belirli bir şehrin ilçelerini getir
  Future<DistrictResponse> getDistricts(int cityId) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.getDistrictsByCity(cityId)}',
    );

    debugPrint('--- API REQUEST (GET DISTRICTS) ---');
    debugPrint('URL: $url');
    debugPrint('-------------------');

    try {
      final response = await http.get(url, headers: getHeaders());

      debugPrint('--- API RESPONSE (DISTRICTS) ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('--------------------');

      final responseData = jsonDecode(response.body);
      return DistrictResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- API ERROR: $e ---');
      return DistrictResponse(error: true, success: false);
    }
  }
}
