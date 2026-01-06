import 'package:flutter/material.dart';
import '../api/auth_service.dart';
import '../model/login_models.dart';
import 'profile_viewmodel.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

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
            response.data?.message ??
            'Giriş başarısız';
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
}
