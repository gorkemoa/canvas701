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

  bool isFavorite(int productId) {
    return _favorites.any((p) => p.productID == productId);
  }

  void updateFavoriteStatus(int productId, bool isFav, {ApiProduct? product}) {
    final existingIndex = _favorites.indexWhere((p) => p.productID == productId);
    if (isFav && existingIndex == -1) {
      if (product != null) {
        _favorites.add(product);
      } else {
        // Not: Eğer ürün objesi yoksa bile belki bir dummy eklenebilir veya sadece ID bazlı tutulabilir.
        // Ama genellikle liste fetişlenirken tam obje gelir.
      }
      notifyListeners();
    } else if (!isFav && existingIndex != -1) {
      _favorites.removeAt(existingIndex);
      notifyListeners();
    }
  }

  void updateFavoritesFromProducts(List<ApiProduct> products) {
    bool changed = false;
    for (var product in products) {
      if (product.isFavorite) {
        if (!_favorites.any((p) => p.productID == product.productID)) {
          _favorites.add(product);
          changed = true;
        }
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  Future<bool> toggleFavorite(int productId) async {
    try {
      final response = await _productService.toggleFavorite(productId);
      if (response.success) {
        await fetchFavorites();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      return false;
    }
  }
}
