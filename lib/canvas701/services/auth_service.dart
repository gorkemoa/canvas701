import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../model/login_models.dart';
import 'base_service.dart';
import 'token_manager.dart';

/// Authentication işlemlerini yöneten servis
/// Login, register, kod doğrulama, şifre sıfırlama işlemleri
class AuthService extends BaseService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final TokenManager _tokenManager = TokenManager();

  // ==================== LOGIN ====================

  /// Normal email/şifre ile giriş
  Future<LoginResponse> login(LoginRequest request) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}');

    logRequest('POST', url.toString(), request.toJson());

    try {
      final response = await http.post(
        url,
        headers: getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      logResponse(response.statusCode, response.body);

      if (response.statusCode == 403) {
        await logout();
        _tokenManager.redirectToLogin();
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
        await _handleLoginSuccess(loginResponse);
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

  /// Google/Apple ile sosyal giriş
  Future<LoginResponse> loginSocial(SocialLoginRequest request) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginSocial}');

    logRequest('POST', url.toString(), request.toJson());

    try {
      final response = await http.post(
        url,
        headers: getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      logResponse(response.statusCode, response.body);

      if (response.statusCode == 403) {
        await logout();
        _tokenManager.redirectToLogin();
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
        await _handleLoginSuccess(loginResponse);
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

  /// Login başarılı olduğunda token ve userId kaydet
  Future<void> _handleLoginSuccess(LoginResponse loginResponse) async {
    if (loginResponse.data?.token != null) {
      await _tokenManager.saveAuthToken(loginResponse.data!.token!);
      debugPrint('--- TOKEN SAVED: ${loginResponse.data!.token} ---');
      
      if (loginResponse.data!.userID != null) {
        await _tokenManager.saveUserId(loginResponse.data!.userID!);
        debugPrint('--- USER ID SAVED: ${loginResponse.data!.userID} ---');
      }
    }
  }

  // ==================== REGISTER ====================

  /// Yeni kullanıcı kaydı
  Future<RegisterResponse> register(RegisterRequest request) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}');

    logRequest('POST', url.toString(), request.toJson());

    try {
      final response = await http.post(
        url,
        headers: getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      logResponse(response.statusCode, response.body);

      final responseData = jsonDecode(response.body);
      final registerResponse = RegisterResponse.fromJson(responseData);

      if (response.statusCode == 200 && registerResponse.success) {
        await _handleRegisterSuccess(registerResponse);
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

  /// Register başarılı olduğunda token'ları kaydet
  Future<void> _handleRegisterSuccess(RegisterResponse registerResponse) async {
    if (registerResponse.data?.userToken != null) {
      await _tokenManager.saveUserToken(registerResponse.data!.userToken!);
    }
    if (registerResponse.data?.codeToken != null) {
      await _tokenManager.saveCodeToken(registerResponse.data!.codeToken!);
    }
    if (registerResponse.data?.userID != null) {
      await _tokenManager.saveUserId(registerResponse.data!.userID!);
    }
  }

  // ==================== CODE VERIFICATION ====================

  /// Doğrulama kodunu kontrol et
  Future<CodeCheckResponse> checkCode(CodeCheckRequest request) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.checkCode}');

    logRequest('POST', url.toString(), request.toJson());

    try {
      final response = await http.post(
        url,
        headers: getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      logResponse(response.statusCode, response.body);

      final responseData = jsonDecode(response.body);
      final codeCheckResponse = CodeCheckResponse.fromJson(responseData);

      if (response.statusCode == 200 && codeCheckResponse.success) {
        if (codeCheckResponse.data?.passToken != null) {
          await _tokenManager.savePassToken(codeCheckResponse.data!.passToken!);
        }

        // Doğrulama başarılı - userToken'ı auth_token olarak kaydet
        final userToken = await _tokenManager.getUserToken();
        if (userToken != null) {
          await _tokenManager.saveAuthToken(userToken);
        }
        await _tokenManager.clearCodeToken();
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

  /// Doğrulama kodunu tekrar gönder
  Future<ResendCodeResponse> resendCode(ResendCodeRequest request) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.authSendCode}');

    logRequest('POST', url.toString(), request.toJson());

    try {
      final response = await http.post(
        url,
        headers: getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      logResponse(response.statusCode, response.body);

      final responseData = jsonDecode(response.body);
      final resendResponse = ResendCodeResponse.fromJson(responseData);

      if (response.statusCode == 200 && resendResponse.success) {
        if (resendResponse.data?.codeToken != null) {
          await _tokenManager.saveCodeToken(resendResponse.data!.codeToken!);
          debugPrint('--- NEW CODE TOKEN SAVED: ${resendResponse.data!.codeToken} ---');
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

  // ==================== FORGOT PASSWORD ====================

  /// Şifremi unuttum - kod gönder
  Future<ForgotPasswordResponse> forgotPassword(ForgotPasswordRequest request) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.forgotPassword}');

    logRequest('POST', url.toString(), request.toJson());

    try {
      final response = await http.post(
        url,
        headers: getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      logResponse(response.statusCode, response.body);

      final responseData = jsonDecode(response.body);
      final forgotResponse = ForgotPasswordResponse.fromJson(responseData);

      if (response.statusCode == 200 && forgotResponse.success) {
        if (forgotResponse.data?.codeToken != null) {
          await _tokenManager.saveCodeToken(forgotResponse.data!.codeToken!);
          debugPrint('--- FORGOT PASS CODE TOKEN SAVED: ${forgotResponse.data!.codeToken} ---');
        }
      }

      return forgotResponse;
    } catch (e) {
      return ForgotPasswordResponse(
        error: true,
        success: false,
        message: e.toString(),
      );
    }
  }

  /// Şifremi unuttum - yeni şifre belirle
  Future<ForgotPasswordUpdateResponse> forgotPasswordUpdate(
    ForgotPasswordUpdateRequest request,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.forgotPasswordUpdate}');

    logRequest('POST', url.toString(), request.toJson());

    try {
      final response = await http.post(
        url,
        headers: getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      logResponse(response.statusCode, response.body);

      final responseData = jsonDecode(response.body);
      return ForgotPasswordUpdateResponse.fromJson(responseData);
    } catch (e) {
      return ForgotPasswordUpdateResponse(
        error: true,
        success: false,
        message: e.toString(),
      );
    }
  }

  // ==================== SESSION ====================

  /// Çıkış yap - tüm token'ları temizle
  Future<void> logout() async {
    await _tokenManager.clearAll();
  }

  // ==================== TOKEN ACCESSORS (backward compatibility) ====================

  /// Auth token getir
  Future<String?> getToken() async => _tokenManager.getAuthToken();

  /// User token getir (auth veya user)
  Future<String?> getUserToken() async => _tokenManager.getUserToken();

  /// Code token getir
  Future<String?> getCodeToken() async => _tokenManager.getCodeToken();

  /// Pass token getir
  Future<String?> getPassToken() async => _tokenManager.getPassToken();
}
