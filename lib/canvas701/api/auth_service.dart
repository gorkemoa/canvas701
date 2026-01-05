import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/constants/api_constants.dart';
import '../../main.dart';
import '../model/login_request.dart';
import '../model/login_response.dart';
import '../model/user_response.dart';
import '../model/update_user_request.dart';
import '../model/update_user_response.dart';
import '../model/update_password_request.dart';
import '../model/update_password_response.dart';
import '../view/login_page.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Future<LoginResponse> login(LoginRequest request) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}');
    
    _logRequest('POST', url.toString(), request.toJson());

    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      _logResponse(response.statusCode, response.body);

      if (response.statusCode == 403) {
        await logout();
        _redirectToLogin();
        return LoginResponse(
          error: true,
          success: false,
          data: LoginData(status: 'error', message: 'Oturum süresi doldu (403)'),
        );
      }

      final responseData = jsonDecode(response.body);
      final loginResponse = LoginResponse.fromJson(responseData);

      if (response.statusCode == 401 || response.statusCode == 417) {
        return loginResponse;
      }

      if (response.statusCode == 200 && loginResponse.success) {
        if (loginResponse.data?.token != null) {
          await _saveToken(loginResponse.data!.token!);
          debugPrint('--- TOKEN SAVED: ${loginResponse.data!.token} ---');
          if (loginResponse.data!.userID != null) {
            await _saveUserId(loginResponse.data!.userID!);
            debugPrint('--- USER ID SAVED: ${loginResponse.data!.userID} ---');
          }
        }
      }
      
      return loginResponse;
    } catch (e) {
      return LoginResponse(
        error: true,
        success: false,
        data: LoginData(status: 'error', message: e.toString()),
      );
    }
  }

  Future<UserResponse> getUser() async {
    debugPrint('--- AuthService.getUser() CALLED ---');
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final token = prefs.getString('auth_token');

    debugPrint('--- STORAGE CHECK: userId=$userId, token=${token != null ? "EXISTS" : "NULL"} ---');

    if (userId == null || token == null) {
      debugPrint('--- GET USER ABORTED: userId or token is missing in SharedPreferences ---');
      return UserResponse(error: true, success: false);
    }

    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getUser(userId)}');
    debugPrint('--- TARGET URL: $url ---');
    
    final packageInfo = await PackageInfo.fromPlatform();
    
    final body = {
      'userToken': token,
      'version': packageInfo.version,
      'platform': Platform.isIOS ? 'ios' : 'android',
    };

    _logRequest('PUT', url.toString(), body);

    try {
      final response = await http.put(
        url,
        headers: _getHeaders(),
        body: jsonEncode(body),
      );

      _logResponse(response.statusCode, response.body);

      if (response.statusCode == 403) {
        debugPrint('--- 403 FORBIDDEN: LOGGING OUT ---');
        await logout();
        _redirectToLogin();
        return UserResponse(error: true, success: false);
      }

      final responseData = jsonDecode(response.body);
      final userResponse = UserResponse.fromJson(responseData);
      
      debugPrint('--- PARSED RESPONSE: success=${userResponse.success}, hasData=${userResponse.data != null} ---');
      
      return userResponse;
    } catch (e) {
      debugPrint('--- GET USER EXCEPTION: $e ---');
      return UserResponse(error: true, success: false);
    }
  }

  Future<UpdateUserResponse> updateUser(int userId, UpdateUserRequest request) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.updateUser(userId)}');
    
    _logRequest('PUT', url.toString(), request.toJson());

    try {
      final response = await http.put(
        url,
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      _logResponse(response.statusCode, response.body);

      if (response.statusCode == 403) {
        await logout();
        _redirectToLogin();
        return UpdateUserResponse(
          error: true,
          success: false,
          data: UpdateUserData(status: 'error', message: 'Oturum süresi doldu (403)'),
        );
      }

      final responseData = jsonDecode(response.body);
      final updateResponse = UpdateUserResponse.fromJson(responseData);

      return updateResponse;
    } catch (e) {
      return UpdateUserResponse(
        error: true,
        success: false,
        data: UpdateUserData(status: 'error', message: e.toString()),
      );
    }
  }

  Future<UpdatePasswordResponse> updatePassword(UpdatePasswordRequest request) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.updatePassword}');
    
    _logRequest('PUT', url.toString(), request.toJson());

    try {
      final response = await http.put(
        url,
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      _logResponse(response.statusCode, response.body);

      if (response.statusCode == 403) {
        await logout();
        _redirectToLogin();
        return UpdatePasswordResponse(
          error: true,
          success: false,
          data: UpdatePasswordData(status: 'error', message: 'Oturum süresi doldu (403)'),
        );
      }

      final responseData = jsonDecode(response.body);
      final updateResponse = UpdatePasswordResponse.fromJson(responseData);

      return updateResponse;
    } catch (e) {
      return UpdatePasswordResponse(
        error: true,
        success: false,
        data: UpdatePasswordData(status: 'error', message: e.toString()),
      );
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    debugPrint('--- LOGOUT SUCCESSFUL ---');
  }

  void _redirectToLogin() {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  Map<String, String> _getHeaders() {
    final String basicAuth = 'Basic ${base64Encode(utf8.encode('${ApiConstants.apiUsername}:${ApiConstants.apiPassword}'))}';
    return {
      'Content-Type': 'application/json',
      'Authorization': basicAuth,
    };
  }

  void _logRequest(String method, String url, dynamic body) {
    debugPrint('--- API REQUEST ---');
    debugPrint('Method: $method');
    debugPrint('URL: $url');
    if (body != null) debugPrint('Body: ${jsonEncode(body)}');
    debugPrint('-------------------');
  }

  void _logResponse(int statusCode, String body) {
    debugPrint('--- API RESPONSE ---');
    debugPrint('Status Code: $statusCode');
    debugPrint('Body: $body');
    debugPrint('--------------------');
  }
}
