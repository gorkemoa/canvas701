import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';

/// Tüm servisler için base sınıf
/// HTTP header'ları ve loglama işlemleri burada merkezi olarak yönetilir
abstract class BaseService {
  /// Basic Auth header'ları ile birlikte standart HTTP header'ları döner
  Map<String, String> getHeaders() {
    final String basicAuth = 'Basic ${base64Encode(
      utf8.encode('${ApiConstants.apiUsername}:${ApiConstants.apiPassword}'),
    )}';
    return {
      'Content-Type': 'application/json',
      'Authorization': basicAuth,
    };
  }

  /// API request loglaması
  void logRequest(String method, String url, [dynamic body]) {
    debugPrint('--- API REQUEST ---');
    debugPrint('Method: $method');
    debugPrint('URL: $url');
    if (body != null) debugPrint('Body: ${jsonEncode(body)}');
    debugPrint('-------------------');
  }

  /// API response loglaması
  void logResponse(int statusCode, String body) {
    debugPrint('--- API RESPONSE ---');
    debugPrint('Status Code: $statusCode');
    debugPrint('Body: $body');
    debugPrint('--------------------');
  }

  /// HTML yanıt kontrolü (API bazen HTML dönebiliyor)
  bool isHtmlResponse(String body) {
    return body.trim().startsWith('<');
  }
}
