import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../services/auth_service.dart';
import '../services/general_service.dart';
import '../services/firebase_messaging_service.dart';
import '../model/login_models.dart';
import '../model/kvkk_response.dart';
import 'profile_viewmodel.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final GeneralService _generalService = GeneralService();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: Platform.isIOS ? '943279152524-r1144khaidbp09ajr3mre248j9e6nt4n.apps.googleusercontent.com' : '943279152524-loaj3em69hbv3je03j829e00agmdlf3h.apps.googleusercontent.com',
  );

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  String? _userToken;
  String? get userToken => _userToken;

  String? _codeToken;
  String? get codeToken => _codeToken;

  KvkkData? _kvkkData;
  KvkkData? get kvkkData => _kvkkData;

  Future<void> fetchKvkkPolicy() async {
    try {
      final response = await _generalService.getKvkkPolicy();
      if (response.success && response.data != null) {
        _kvkkData = response.data;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching KVKK: $e');
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final packageInfo = await PackageInfo.fromPlatform();

      final request = RegisterRequest(
        userFirstname: firstName,
        userLastname: lastName,
        userEmail: email,
        userPassword: password,
        version: packageInfo.version,
        platform: Platform.isIOS ? 'ios' : 'android',
      );

      final response = await _authService.register(request);

      if (response.success) {
        _userToken = response.data?.userToken;
        _codeToken = response.data?.codeToken;
        _successMessage = response.successMessage;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            response.errorMessage ??
            response.data?.message ??
            response.successMessage ??
            'Kayıt başarısız';
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

  Future<bool> verifyCode(String code) async {
    debugPrint(
      '--- RegisterViewModel.verifyCode() STARTED with code: $code ---',
    );
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Get codeToken from storage if not in memory
      final storedCodeToken = _codeToken ?? await _authService.getCodeToken();
      debugPrint(
        '--- RegisterViewModel.verifyCode() storedCodeToken: ${storedCodeToken != null ? "FOUND" : "NOT FOUND"} ---',
      );

      if (storedCodeToken == null) {
        _errorMessage =
            'Doğrulama oturumu bulunamadı. Lütfen yeni kod isteyin.';
        debugPrint(
          '--- RegisterViewModel.verifyCode() FAILED: codeToken is null ---',
        );
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final request = CodeCheckRequest(code: code, codeToken: storedCodeToken);

      final response = await _authService.checkCode(request);
      debugPrint(
        '--- RegisterViewModel.verifyCode() API Response: success=${response.success}, error=${response.error} ---',
      );

      if (response.success) {
        _successMessage = response.successMessage;
        debugPrint('--- RegisterViewModel.verifyCode() SUCCESS ---');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            response.errorMessage ??
            response.data?.message ??
            response.successMessage ??
            'Doğrulama başarısız';
        debugPrint(
          '--- RegisterViewModel.verifyCode() API ERROR: $_errorMessage ---',
        );
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('--- RegisterViewModel.verifyCode() EXCEPTION: $e ---');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resendCode() async {
    debugPrint('--- RegisterViewModel.resendCode() STARTED ---');
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Get userToken from storage if not in memory
      final storedUserToken = _userToken ?? await _authService.getUserToken();
      debugPrint(
        '--- RegisterViewModel.resendCode() storedUserToken: ${storedUserToken != null ? "FOUND" : "NOT FOUND"} ---',
      );

      if (storedUserToken == null) {
        _errorMessage =
            'Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.';
        debugPrint(
          '--- RegisterViewModel.resendCode() FAILED: userToken is null ---',
        );
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final request = ResendCodeRequest(userToken: storedUserToken);

      final response = await _authService.resendCode(request);
      debugPrint(
        '--- RegisterViewModel.resendCode() API Response: success=${response.success}, error=${response.error} ---',
      );

      if (response.success) {
        if (response.data?.codeToken != null) {
          _codeToken = response.data!.codeToken;
        }
        _successMessage =
            response.successMessage ?? 'Doğrulama kodu tekrar gönderildi';
        debugPrint('--- RegisterViewModel.resendCode() SUCCESS ---');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Kod gönderilemedi';
        debugPrint(
          '--- RegisterViewModel.resendCode() API ERROR: $_errorMessage ---',
        );
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('--- RegisterViewModel.resendCode() EXCEPTION: $e ---');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

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
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
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
        // Subscribe to FCM topic immediately after login
        if (response.data?.userID != null) {
          FirebaseMessagingService.subscribeToUserTopic(
            response.data!.userID.toString(),
          );
        }

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
      _errorMessage =
          'Giriş yapılırken bir hata oluştu. Lütfen tekrar deneyin.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
