import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../api/auth_service.dart';
import '../api/general_service.dart';
import '../model/register_request.dart';
import '../model/code_check_request.dart';
import '../model/resend_code_request.dart';
import '../model/kvkk_response.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final GeneralService _generalService = GeneralService();

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
        _errorMessage = response.errorMessage ?? response.data?.message ?? response.successMessage ?? 'Kayıt başarısız';
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
    debugPrint('--- RegisterViewModel.verifyCode() STARTED with code: $code ---');
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Get codeToken from storage if not in memory
      final storedCodeToken = _codeToken ?? await _authService.getCodeToken();
      debugPrint('--- RegisterViewModel.verifyCode() storedCodeToken: ${storedCodeToken != null ? "FOUND" : "NOT FOUND"} ---');
      
      if (storedCodeToken == null) {
        _errorMessage = 'Doğrulama oturumu bulunamadı. Lütfen yeni kod isteyin.';
        debugPrint('--- RegisterViewModel.verifyCode() FAILED: codeToken is null ---');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final request = CodeCheckRequest(
        code: code,
        codeToken: storedCodeToken,
      );

      final response = await _authService.checkCode(request);
      debugPrint('--- RegisterViewModel.verifyCode() API Response: success=${response.success}, error=${response.error} ---');

      if (response.success) {
        _successMessage = response.successMessage;
        debugPrint('--- RegisterViewModel.verifyCode() SUCCESS ---');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.errorMessage ?? response.data?.message ?? response.successMessage ?? 'Doğrulama başarısız';
        debugPrint('--- RegisterViewModel.verifyCode() API ERROR: $_errorMessage ---');
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
      debugPrint('--- RegisterViewModel.resendCode() storedUserToken: ${storedUserToken != null ? "FOUND" : "NOT FOUND"} ---');
      
      if (storedUserToken == null) {
        _errorMessage = 'Kullanıcı oturumu bulunamadı. Lütfen tekrar giriş yapın.';
        debugPrint('--- RegisterViewModel.resendCode() FAILED: userToken is null ---');
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final request = ResendCodeRequest(
        userToken: storedUserToken,
      );

      final response = await _authService.resendCode(request);
      debugPrint('--- RegisterViewModel.resendCode() API Response: success=${response.success}, error=${response.error} ---');

      if (response.success) {
        if (response.data?.codeToken != null) {
          _codeToken = response.data!.codeToken;
        }
        _successMessage = response.successMessage ?? 'Doğrulama kodu tekrar gönderildi';
        debugPrint('--- RegisterViewModel.resendCode() SUCCESS ---');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Kod gönderilemedi';
        debugPrint('--- RegisterViewModel.resendCode() API ERROR: $_errorMessage ---');
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

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
