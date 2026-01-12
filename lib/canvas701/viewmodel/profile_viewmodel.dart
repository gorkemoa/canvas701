import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../services/firebase_messaging_service.dart';
import '../model/user_models.dart';
import '../model/coupon_model.dart';

class ProfileViewModel extends ChangeNotifier {
  static final ProfileViewModel _instance = ProfileViewModel._internal();
  factory ProfileViewModel() => _instance;
  ProfileViewModel._internal();

  final UserService _userService = UserService();

  User? _user;
  User? get user => _user;

  List<Coupon> _coupons = [];
  List<Coupon> get coupons => _coupons;

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
      final response = await _userService.getUser();
      if (response.success && response.data?.user != null) {
        _user = response.data!.user;
        debugPrint('--- USER DATA FETCHED: ${_user?.userFullname} ---');

        // Subscribe to FCM topic for the user ID
        if (_user != null) {
          FirebaseMessagingService.subscribeToUserTopic(_user!.userID.toString());
        }
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

  Future<void> fetchCoupons() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _userService.getCoupons();
      if (response.success && response.data != null) {
        _coupons = response.data!.coupons;
      } else {
        _errorMessage = response.message ?? 'Kuponlar alınamadı';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
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
      final response = await _userService.updateUser(_user!.userID, request);
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
      final response = await _userService.updatePassword(request);
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

  Future<void> logout() async {
    if (_user != null) {
      // Unsubscribe from FCM topic before logging out
      await FirebaseMessagingService.unsubscribeFromUserTopic(
        _user!.userID.toString(),
      );
      _user = null;
      notifyListeners();
    }
    // Perform actual logout from auth service
    await AuthService().logout();
  }
}
