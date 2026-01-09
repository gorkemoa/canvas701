import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import '../constants/api_constants.dart';
import '../model/user_models.dart';
import 'base_service.dart';
import 'token_manager.dart';

/// Kullanıcı profili ve şifre işlemlerini yöneten servis
class UserService extends BaseService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final TokenManager _tokenManager = TokenManager();

  /// Kullanıcı bilgilerini getir
  Future<UserResponse> getUser() async {
    debugPrint('--- UserService.getUser() CALLED ---');
    
    final userId = await _tokenManager.getUserId();
    final token = await _tokenManager.getAuthToken();

    debugPrint('--- STORAGE CHECK: userId=$userId, token=${token != null ? "EXISTS" : "NULL"} ---');

    if (userId == null || token == null) {
      debugPrint('--- GET USER ABORTED: userId or token is missing ---');
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

    logRequest('PUT', url.toString(), body);

    try {
      final response = await http.put(
        url,
        headers: getHeaders(),
        body: jsonEncode(body),
      );

      logResponse(response.statusCode, response.body);

      if (response.statusCode == 403) {
        debugPrint('--- 403 FORBIDDEN: LOGGING OUT ---');
        await _tokenManager.clearAll();
        _tokenManager.redirectToLogin();
        return UserResponse(error: true, success: false);
      }

      final responseData = jsonDecode(response.body);
      final userResponse = UserResponse.fromJson(responseData);

      debugPrint(
        '--- PARSED RESPONSE: success=${userResponse.success}, hasData=${userResponse.data != null} ---',
      );

      return userResponse;
    } catch (e) {
      debugPrint('--- GET USER EXCEPTION: $e ---');
      return UserResponse(error: true, success: false);
    }
  }

  /// Kullanıcı bilgilerini güncelle
  Future<UpdateUserResponse> updateUser(
    int userId,
    UpdateUserRequest request,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.updateUser(userId)}');

    logRequest('PUT', url.toString(), request.toJson());

    try {
      final response = await http.put(
        url,
        headers: getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      logResponse(response.statusCode, response.body);

      if (response.statusCode == 403) {
        await _tokenManager.clearAll();
        _tokenManager.redirectToLogin();
        return UpdateUserResponse(
          error: true,
          success: false,
          data: UpdateUserData(status: 'error', message: 'Oturum süresi doldu (403)'),
        );
      }

      final responseData = jsonDecode(response.body);
      return UpdateUserResponse.fromJson(responseData);
    } catch (e) {
      return UpdateUserResponse(
        error: true,
        success: false,
        data: UpdateUserData(status: 'error', message: e.toString()),
      );
    }
  }

  /// Şifre güncelle
  Future<UpdatePasswordResponse> updatePassword(UpdatePasswordRequest request) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.updatePassword}');

    logRequest('PUT', url.toString(), request.toJson());

    try {
      final response = await http.put(
        url,
        headers: getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      logResponse(response.statusCode, response.body);

      if (response.statusCode == 403) {
        await _tokenManager.clearAll();
        _tokenManager.redirectToLogin();
        return UpdatePasswordResponse(
          error: true,
          success: false,
          data: UpdatePasswordData(status: 'error', message: 'Oturum süresi doldu (403)'),
        );
      }

      final responseData = jsonDecode(response.body);
      return UpdatePasswordResponse.fromJson(responseData);
    } catch (e) {
      return UpdatePasswordResponse(
        error: true,
        success: false,
        data: UpdatePasswordData(status: 'error', message: e.toString()),
      );
    }
  }
}
