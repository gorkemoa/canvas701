import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../api/auth_service.dart';
import '../model/login_models.dart';
import 'profile_viewmodel.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: Platform.isIOS ? '943279152524-r1144khaidbp09ajr3mre248j9e6nt4n.apps.googleusercontent.com' : '943279152524-loaj3em69hbv3je03j829e00agmdlf3h.apps.googleusercontent.com',
  );

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> socialLogin(String platform) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? accessToken;
      String? idToken;

      if (platform == 'google') {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          _isLoading = false;
          notifyListeners();
          return false;
        }
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        accessToken = googleAuth.accessToken;
        idToken = googleAuth.idToken;
      } else if (platform == 'apple') {
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );
        accessToken = credential.authorizationCode;
        idToken = credential.identityToken;
      } else {
        throw Exception('Geçersiz platform: $platform');
      }

      final packageInfo = await PackageInfo.fromPlatform();
      final deviceInfo = DeviceInfoPlugin();
      String deviceID = '';

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceID = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceID = iosInfo.identifierForVendor ?? '';
      }

      final request = SocialLoginRequest(
        platform: platform,
        deviceID: deviceID,
        devicePlatform: Platform.isAndroid ? 'android' : 'ios',
        version: packageInfo.version,
        accessToken: accessToken,
        idToken: idToken,
      );

      final response = await _authService.loginSocial(request);

      if (response.success) {
        await ProfileViewModel().fetchUser();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.errorMessage ?? response.data?.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        _errorMessage = null;
      } else {
        _errorMessage = 'Apple ile giriş yapılırken bir hata oluştu.';
      }
      debugPrint('Apple login error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Social login error: $e');
      _errorMessage = 'Giriş yapılırken bir hata oluştu. Lütfen tekrar deneyin.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = LoginRequest(userEmail: email, userPassword: password);
      final response = await _authService.login(request);

      if (response.success) {
        // Giriş başarılı olduktan sonra kullanıcı bilgilerini çek
        await ProfileViewModel().fetchUser();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            response.errorMessage ??
            response.data?.message;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<ForgotPasswordResponse> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = ForgotPasswordRequest(userEmail: email);
      final response = await _authService.forgotPassword(request);

      if (!response.success) {
        _errorMessage = response.message;
      }

      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return ForgotPasswordResponse(
        error: true,
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<CodeCheckResponse> checkCode(String code) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final codeToken = await _authService.getCodeToken();
      if (codeToken == null) {
        throw Exception('Doğrulama tokenı bulunamadı');
      }

      final request = CodeCheckRequest(code: code, codeToken: codeToken);
      final response = await _authService.checkCode(request);

      if (!response.success) {
        _errorMessage = response.errorMessage ?? response.data?.message;
      }

      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return CodeCheckResponse(
        error: true,
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<ForgotPasswordUpdateResponse> updatePassword(
    String password,
    String passwordAgain,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final passToken = await _authService.getPassToken();
      if (passToken == null) {
        throw Exception('Şifre güncelleme tokenı bulunamadı');
      }

      final request = ForgotPasswordUpdateRequest(
        passToken: passToken,
        password: password,
        passwordAgain: passwordAgain,
      );
      final response = await _authService.forgotPasswordUpdate(request);

      if (!response.success) {
        _errorMessage = response.message;
      }

      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return ForgotPasswordUpdateResponse(
        error: true,
        success: false,
        message: e.toString(),
      );
    }
  }
}
