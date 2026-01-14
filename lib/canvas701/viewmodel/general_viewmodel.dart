import 'package:flutter/material.dart';
import '../model/banner_response.dart';
import '../model/faq_model.dart';
import '../model/type_model.dart';
import '../services/general_service.dart';

class GeneralViewModel extends ChangeNotifier {
  final GeneralService _generalService = GeneralService();

  List<ApiBanner> _banners = [];
  List<ApiBanner> get banners => _banners;

  List<ProductType> _productTypes = [];
  List<ProductType> get productTypes => _productTypes;

  List<Faq> _faqs = [];
  List<Faq> get faqs => _faqs;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchFaqs() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _generalService.getFaqs();
      if (response.success == true && response.data?.faqs != null) {
        _faqs = response.data!.faqs!;
      }
    } catch (e) {
      debugPrint('GeneralViewModel fetchFaqs Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
