import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_constants.dart';
import '../model/kvkk_response.dart';

class GeneralService {
  static final GeneralService _instance = GeneralService._internal();
  factory GeneralService() => _instance;
  GeneralService._internal();

  Future<KvkkResponse> getKvkkPolicy() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.kvkkAgreement}');
    
    debugPrint('--- API REQUEST (GET) ---');
    debugPrint('URL: $url');
    debugPrint('-------------------');

    try {
      final response = await http.get(
        url,
        headers: _getHeaders(),
      );

      debugPrint('--- API RESPONSE ---');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Body: ${response.body}');
      debugPrint('--------------------');

      final responseData = jsonDecode(response.body);
      return KvkkResponse.fromJson(responseData);
    } catch (e) {
      debugPrint('--- API ERROR: $e ---');
      return KvkkResponse(
        error: true,
        success: false,
      );
    }
  }

  Map<String, String> _getHeaders() {
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('${ApiConstants.apiUsername}:${ApiConstants.apiPassword}'))}';
    return {
      'Content-Type': 'application/json',
      'Authorization': basicAuth,
    };
  }
}
