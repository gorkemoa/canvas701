import 'package:flutter/material.dart';
import '../model/banner_response.dart';
import '../services/general_service.dart';

class GeneralViewModel extends ChangeNotifier {
  final GeneralService _generalService = GeneralService();

  List<ApiBanner> _banners = [];
  List<ApiBanner> get banners => _banners;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchBanners() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _generalService.getBanners();
      if (response.success == true && response.data?.banners != null) {
        _banners = response.data!.banners!;
      }
    } catch (e) {
      debugPrint('GeneralViewModel fetchBanners Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
