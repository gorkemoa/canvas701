import 'dart:convert';
import 'dart:io';
import 'package:canvas701/canvas701/constants/api_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../main.dart';
import '../model/login_models.dart';
import '../model/user_models.dart';
import '../model/address_models.dart';
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
          data: LoginData(
            status: 'error',
            message: 'Oturum süresi doldu (403)',
          ),
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

  Future<RegisterResponse> register(RegisterRequest request) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}');

    _logRequest('POST', url.toString(), request.toJson());

    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      _logResponse(response.statusCode, response.body);

      final responseData = jsonDecode(response.body);
      final registerResponse = RegisterResponse.fromJson(responseData);

      if (response.statusCode == 200 && registerResponse.success) {
        // Save userToken and codeToken for verification
        if (registerResponse.data?.userToken != null) {
          await _saveUserToken(registerResponse.data!.userToken!);
        }
        if (registerResponse.data?.codeToken != null) {
          await _saveCodeToken(registerResponse.data!.codeToken!);
        }
        if (registerResponse.data?.userID != null) {
          await _saveUserId(registerResponse.data!.userID!);
        }
      }

      return registerResponse;
    } catch (e) {
      return RegisterResponse(
        error: true,
        success: false,
        data: RegisterData(message: e.toString()),
      );
    }
  }

  Future<CodeCheckResponse> checkCode(CodeCheckRequest request) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.checkCode}');

    _logRequest('POST', url.toString(), request.toJson());

    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      _logResponse(response.statusCode, response.body);

      final responseData = jsonDecode(response.body);
      final codeCheckResponse = CodeCheckResponse.fromJson(responseData);

      if (response.statusCode == 200 && codeCheckResponse.success) {
        // Verification successful - copy userToken to auth_token
        final userToken = await getUserToken();
        if (userToken != null) {
          await _saveToken(userToken);
        }
        // Clean up temporary tokens
        await _clearCodeToken();
      }

      return codeCheckResponse;
    } catch (e) {
      return CodeCheckResponse(
        error: true,
        success: false,
        data: CodeCheckData(message: e.toString()),
      );
    }
  }

  Future<ResendCodeResponse> resendCode(ResendCodeRequest request) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.authSendCode}',
    );

    _logRequest('POST', url.toString(), request.toJson());

    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      _logResponse(response.statusCode, response.body);

      final responseData = jsonDecode(response.body);
      final resendResponse = ResendCodeResponse.fromJson(responseData);

      if (response.statusCode == 200 && resendResponse.success) {
        if (resendResponse.data?.codeToken != null) {
          await _saveCodeToken(resendResponse.data!.codeToken!);
          debugPrint(
            '--- NEW CODE TOKEN SAVED: ${resendResponse.data!.codeToken} ---',
          );
        }
      }

      return resendResponse;
    } catch (e) {
      return ResendCodeResponse(
        error: true,
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<UserResponse> getUser() async {
    debugPrint('--- AuthService.getUser() CALLED ---');
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final token = prefs.getString('auth_token');

    debugPrint(
      '--- STORAGE CHECK: userId=$userId, token=${token != null ? "EXISTS" : "NULL"} ---',
    );

    if (userId == null || token == null) {
      debugPrint(
        '--- GET USER ABORTED: userId or token is missing in SharedPreferences ---',
      );
      return UserResponse(error: true, success: false);
    }

    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.getUser(userId)}',
    );
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

      debugPrint(
        '--- PARSED RESPONSE: success=${userResponse.success}, hasData=${userResponse.data != null} ---',
      );

      return userResponse;
    } catch (e) {
      debugPrint('--- GET USER EXCEPTION: $e ---');
      return UserResponse(error: true, success: false);
    }
  }

  Future<UpdateUserResponse> updateUser(
    int userId,
    UpdateUserRequest request,
  ) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.updateUser(userId)}',
    );

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
          data: UpdateUserData(
            status: 'error',
            message: 'Oturum süresi doldu (403)',
          ),
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

  Future<UpdatePasswordResponse> updatePassword(
    UpdatePasswordRequest request,
  ) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.updatePassword}',
    );

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
          data: UpdatePasswordData(
            status: 'error',
            message: 'Oturum süresi doldu (403)',
          ),
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

  Future<AddAddressResponse> addAddress(AddAddressRequest request) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.addAddress}');

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
        return AddAddressResponse(
          error: true,
          success: false,
          data: AddAddressData(
            status: 'error',
            message: 'Oturum süresi doldu (403)',
          ),
        );
      }

      final responseData = jsonDecode(response.body);
      return AddAddressResponse.fromJson(responseData);
    } catch (e) {
      return AddAddressResponse(
        error: true,
        success: false,
        data: AddAddressData(status: 'error', message: e.toString()),
      );
    }
  }

  Future<AddAddressResponse> updateAddress(UpdateAddressRequest request) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.updateAddress}',
    );

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
        return AddAddressResponse(
          error: true,
          success: false,
          data: AddAddressData(
            status: 'error',
            message: 'Oturum süresi doldu (403)',
          ),
        );
      }

      final responseData = jsonDecode(response.body);
      return AddAddressResponse.fromJson(responseData);
    } catch (e) {
      return AddAddressResponse(
        error: true,
        success: false,
        data: AddAddressData(status: 'error', message: e.toString()),
      );
    }
  }

  Future<UserAddressesResponse> getUserAddresses() async {
    final token = await getToken();
    if (token == null) {
      return UserAddressesResponse(
        error: true,
        success: false,
        addresses: [],
        errorMessage: 'Oturum bilgisi bulunamadı',
        totalItems: 0,
        emptyMessage: '',
      );
    }

    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.getUserAddresses}?userToken=$token',
    );

    _logRequest('GET', url.toString(), null);

    try {
      final response = await http.get(url, headers: _getHeaders());

      _logResponse(response.statusCode, response.body);

      if (response.statusCode == 403) {
        await logout();
        _redirectToLogin();
        return UserAddressesResponse(
          error: true,
          success: false,
          addresses: [],
          errorMessage: 'Oturum süresi doldu (403)',
          totalItems: 0,
          emptyMessage: '',
        );
      }

      final responseData = jsonDecode(response.body);
      return UserAddressesResponse.fromJson(responseData);
    } catch (e) {
      return UserAddressesResponse(
        error: true,
        success: false,
        addresses: [],
        errorMessage: e.toString(),
        totalItems: 0,
        emptyMessage: '',
      );
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    // auth_token varsa artık user_token'a gerek yoktur
    await prefs.remove('user_token');
    debugPrint('--- AUTH TOKEN SAVED & USER TOKEN CLEARED ---');
  }

  Future<void> _saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
  }

  Future<void> _saveUserToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_token', token);
  }

  Future<void> _saveCodeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('code_token', token);
  }

  Future<String?> getUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    final userToken = prefs.getString('user_token');

    // Eğer giriş yapılmışsa (auth_token varsa) onu kullan, yoksa kayıt aşamasındaki user_token'ı kullan
    final currentToken = authToken ?? userToken;

    debugPrint(
      '--- AuthService.getUserToken() auth_token: ${authToken != null ? "EXISTS" : "NULL"}, user_token: ${userToken != null ? "EXISTS" : "NULL"} -> Using: ${currentToken != null ? "TOKEN FOUND" : "NULL"} ---',
    );
    return currentToken;
  }

  Future<String?> getCodeToken() async {
    final prefs = await SharedPreferences.getInstance();
    final codeToken = prefs.getString('code_token');
    debugPrint(
      '--- AuthService.getCodeToken() code_token: ${codeToken != null ? "EXISTS" : "NULL"} ---',
    );
    return codeToken;
  }

  Future<void> _clearCodeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('code_token');
    debugPrint('--- AuthService._clearCodeToken() DONE ---');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_token');
    await prefs.remove('code_token');
    debugPrint('--- LOGOUT SUCCESSFUL & ALL TOKENS CLEARED ---');
  }

  void _redirectToLogin() {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  Map<String, String> _getHeaders() {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('${ApiConstants.apiUsername}:${ApiConstants.apiPassword}'))}';
    return {'Content-Type': 'application/json', 'Authorization': basicAuth};
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
