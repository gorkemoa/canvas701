import 'package:flutter/material.dart';
import '../services/general_service.dart';
import '../model/about_info_model.dart';

class AboutViewModel extends ChangeNotifier {
  final GeneralService _generalService = GeneralService();

  AboutInfoData? _aboutInfo;
  AboutInfoData? get aboutInfo => _aboutInfo;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAboutInfo() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _generalService.getAboutInfo();
      if (response.success && response.data != null) {
        _aboutInfo = response.data;
      } else {
        _errorMessage = 'Hakkımızda bilgileri yüklenemedi.';
      }
    } catch (e) {
      _errorMessage = 'Bir hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
