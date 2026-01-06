import 'package:flutter/material.dart';
import '../api/auth_service.dart';
import '../model/user_models.dart';

class ProfileViewModel extends ChangeNotifier {
  static final ProfileViewModel _instance = ProfileViewModel._internal();
  factory ProfileViewModel() => _instance;
  ProfileViewModel._internal();

  final AuthService _authService = AuthService();

  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUser() async {
    if (_isLoading) {
      debugPrint(
        '--- ProfileViewModel.fetchUser() ALREADY LOADING, SKIPPING ---',
      );
      return;
    }

    debugPrint('--- ProfileViewModel.fetchUser() STARTED ---');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.getUser();
      if (response.success && response.data?.user != null) {
        _user = response.data!.user;
        debugPrint('--- USER DATA FETCHED: ${_user?.userFullname} ---');
      } else {
        _errorMessage =
            response.errorMessage ?? 'Kullanıcı bilgileri alınamadı';
        debugPrint(
          '--- USER DATA FETCH FAILED: success=${response.success}, error=${response.error} ---',
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('--- USER DATA FETCH EXCEPTION: $e ---');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('--- ProfileViewModel.fetchUser() FINISHED ---');
    }
  }

  Future<UpdateUserResponse> updateUser(UpdateUserRequest request) async {
    if (_user == null) {
      return UpdateUserResponse(
        error: true,
        success: false,
        data: UpdateUserData(status: 'error', message: 'Kullanıcı bulunamadı'),
      );
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.updateUser(_user!.userID, request);
      if (response.success) {
        await fetchUser(); // Refresh user data after update
      }
      return response;
    } catch (e) {
      _errorMessage = e.toString();
      return UpdateUserResponse(
        error: true,
        success: false,
        data: UpdateUserData(status: 'error', message: e.toString()),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UpdatePasswordResponse> updatePassword(
    UpdatePasswordRequest request,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.updatePassword(request);
      return response;
    } catch (e) {
      _errorMessage = e.toString();
      return UpdatePasswordResponse(
        error: true,
        success: false,
        data: UpdatePasswordData(status: 'error', message: e.toString()),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
