import 'package:flutter/material.dart';
import '../api/product_service.dart';
import '../model/product_models.dart';

class FavoritesViewModel extends ChangeNotifier {
  static final FavoritesViewModel _instance = FavoritesViewModel._internal();
  factory FavoritesViewModel() => _instance;
  FavoritesViewModel._internal();

  final ProductService _productService = ProductService();

  List<ApiProduct> _favorites = [];
  List<ApiProduct> get favorites => _favorites;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchFavorites() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _productService.getFavorites();

      if (response.success && response.data != null) {
        _favorites = response.data!.favoriteProducts;
      } else {
        _errorMessage = 'Favoriler yüklenemedi';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void removeFromFavorites(int productId) {
    _favorites.removeWhere((p) => p.productID == productId);
    notifyListeners();
  }
}
