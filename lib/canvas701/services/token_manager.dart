import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../view/login_page.dart';

/// Token yönetimi için merkezi sınıf
/// Tüm token işlemleri (kaydetme, okuma, silme) burada yapılır
class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  // SharedPreferences keys
  static const String _authTokenKey = 'auth_token';
  static const String _userTokenKey = 'user_token';
  static const String _codeTokenKey = 'code_token';
  static const String _passTokenKey = 'pass_token';
  static const String _userIdKey = 'user_id';

  // ==================== AUTH TOKEN ====================

  /// Ana authentication token'ı kaydet
  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
    // auth_token varsa artık user_token'a gerek yok
    await prefs.remove(_userTokenKey);
    debugPrint('--- AUTH TOKEN SAVED & USER TOKEN CLEARED ---');
  }

  /// Authentication token'ı getir
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  /// Authentication token'ı sil
  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
  }

  // ==================== USER TOKEN ====================

  /// Kayıt aşamasında kullanılan user token'ı kaydet
  Future<void> saveUserToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userTokenKey, token);
  }

  /// User token'ı getir (auth yoksa user token döner)
  Future<String?> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString(_authTokenKey);
    final userToken = prefs.getString(_userTokenKey);

    final currentToken = authToken ?? userToken;

    debugPrint(
      '--- TokenManager.getUserToken() auth: ${authToken != null ? "EXISTS" : "NULL"}, '
      'user: ${userToken != null ? "EXISTS" : "NULL"} -> '
      'Using: ${currentToken != null ? "TOKEN FOUND" : "NULL"} ---',
    );
    return currentToken;
  }

  // ==================== CODE TOKEN ====================

  /// Doğrulama kodu token'ı kaydet
  Future<void> saveCodeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_codeTokenKey, token);
  }

  /// Code token'ı getir
  Future<String?> getCodeToken() async {
    final prefs = await SharedPreferences.getInstance();
    final codeToken = prefs.getString(_codeTokenKey);
    debugPrint(
      '--- TokenManager.getCodeToken() code: ${codeToken != null ? "EXISTS" : "NULL"} ---',
    );
    return codeToken;
  }

  /// Code token'ı sil
  Future<void> clearCodeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_codeTokenKey);
    debugPrint('--- TokenManager.clearCodeToken() DONE ---');
  }

  // ==================== PASS TOKEN ====================

  /// Şifre sıfırlama token'ı kaydet
  Future<void> savePassToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passTokenKey, token);
  }

  /// Pass token'ı getir
  Future<String?> getPassToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_passTokenKey);
  }

  // ==================== USER ID ====================

  /// User ID kaydet
  Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
  }

  /// User ID getir
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  // ==================== LOGOUT ====================

  /// Tüm token ve oturum bilgilerini temizle
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userTokenKey);
    await prefs.remove(_codeTokenKey);
    await prefs.remove(_passTokenKey);
    debugPrint('--- LOGOUT: ALL TOKENS CLEARED ---');
  }

  /// Login sayfasına yönlendir
  void redirectToLogin() {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }
}
