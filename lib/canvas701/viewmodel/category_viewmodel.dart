import 'package:flutter/material.dart';
import '../api/product_service.dart';
import '../model/category_response.dart';

class CategoryViewModel extends ChangeNotifier {
  static final CategoryViewModel _instance = CategoryViewModel._internal();
  factory CategoryViewModel() => _instance;
  CategoryViewModel._internal();

  final ProductService _productService = ProductService();

  List<ApiCategory> _categories = [];
  List<ApiCategory> get categories => _categories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCategories() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _productService.getCategories();
      if (response.success && response.data != null) {
        _categories = response.data!.categories;
      } else {
        _errorMessage = 'Kategoriler yüklenemedi';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
