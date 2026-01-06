import 'dart:convert';
import 'package:canvas701/canvas701/constants/api_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/kvkk_response.dart';
import '../model/address_models.dart';

class GeneralService {
  static final GeneralService _instance = GeneralService._internal();
  factory GeneralService() => _instance;
  GeneralService._internal();

  Future<KvkkResponse> getKvkkPolicy() async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.kvkkAgreement}',
    );

    debugPrint('--- API REQUEST (GET) ---');
    debugPrint('URL: $url');
    debugPrint('-------------------');

    try {
      final response = await http.get(url, headers: _getHeaders());

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

  Future<CityResponse> getCities() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getCities}');

    debugPrint('--- API REQUEST (GET CITIES) ---');
    debugPrint('URL: $url');
    debugPrint('-------------------');

    try {
      final response = await http.get(url, headers: _getHeaders());

      debugPrint('--- API RESPONSE (CITIES) ---');
      debugPrint('Status Code: ${response.statusCode}');
      // debugPrint('Body: ${response.body}'); // Commented out to reduce noise
      debugPrint('--------------------');

      final responseData = jsonDecode(response.body);
      return CityResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- API ERROR: $e ---');
      return CityResponse(error: true, success: false);
    }
  }

  Future<DistrictResponse> getDistricts(int cityId) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.getDistrictsByCity(cityId)}',
    );

    debugPrint('--- API REQUEST (GET DISTRICTS) ---');
    debugPrint('URL: $url');
    debugPrint('-------------------');

    try {
      final response = await http.get(url, headers: _getHeaders());

      debugPrint('--- API RESPONSE (DISTRICTS) ---');
      debugPrint('Status Code: ${response.statusCode}');
      // debugPrint('Body: ${response.body}'); // Commented out to reduce noise
      debugPrint('--------------------');

      final responseData = jsonDecode(response.body);
      return DistrictResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- API ERROR: $e ---');
      return DistrictResponse(error: true, success: false);
    }
  }

  Map<String, String> _getHeaders() {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('${ApiConstants.apiUsername}:${ApiConstants.apiPassword}'))}';
    return {'Content-Type': 'application/json', 'Authorization': basicAuth};
  }
}
