import 'package:flutter/material.dart';
import '../model/banner_response.dart';
import '../model/type_model.dart';
import '../services/general_service.dart';

class GeneralViewModel extends ChangeNotifier {
  final GeneralService _generalService = GeneralService();

  List<ApiBanner> _banners = [];
  List<ApiBanner> get banners => _banners;

  List<ProductType> _productTypes = [];
  List<ProductType> get productTypes => _productTypes;

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

  Future<void> fetchProductTypes() async {
    if (_productTypes.isNotEmpty) return;

    try {
      final response = await _generalService.getTypes();
      if (response.success && response.data != null) {
        _productTypes = response.data!.types;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('GeneralViewModel fetchProductTypes Error: $e');
    }
  }
}
