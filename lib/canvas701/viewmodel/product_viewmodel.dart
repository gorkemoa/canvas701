import 'package:flutter/material.dart';
import '../api/product_service.dart';
import '../model/product_list_response.dart';
import '../model/filter_list_response.dart';

class ProductViewModel extends ChangeNotifier {
  static final ProductViewModel _instance = ProductViewModel._internal();
  factory ProductViewModel() => _instance;
  ProductViewModel._internal();

  final ProductService _productService = ProductService();

  List<ApiProduct> _products = [];
  List<ApiProduct> get products => _products;

  List<ApiProduct> _bestsellers = [];
  List<ApiProduct> get bestsellers => _bestsellers;

  List<ApiProduct> _newArrivals = [];
  List<ApiProduct> get newArrivals => _newArrivals;

  FilterListData? _filters;
  FilterListData? get filters => _filters;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isBestsellersLoading = false;
  bool get isBestsellersLoading => _isBestsellersLoading;

  bool _isNewArrivalsLoading = false;
  bool get isNewArrivalsLoading => _isNewArrivalsLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _currentPage = 1;
  bool _hasNextPage = true;

  Future<void> fetchAllProducts({bool refresh = false}) async {
    if (_isLoading) return;
    if (refresh) {
      _currentPage = 1;
      _hasNextPage = true;
      _products = [];
    }

    if (!_hasNextPage) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _productService.getAllProducts(
        page: _currentPage,
        sortKey: 'sortDefault',
      );

      if (response.success && response.data != null) {
        if (refresh) {
          _products = response.data!.products;
        } else {
          _products.addAll(response.data!.products);
        }
        _hasNextPage = response.data!.hasNextPage;
        if (_hasNextPage) {
          _currentPage++;
        }
      } else {
        _errorMessage = 'Ürünler yüklenemedi';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBestsellers() async {
    if (_isBestsellersLoading) return;

    _isBestsellersLoading = true;
    notifyListeners();

    try {
      final response = await _productService.getAllProducts(
        page: 1,
        sortKey: 'sortBestSellers',
      );

      if (response.success && response.data != null) {
        _bestsellers = response.data!.products;
      }
    } catch (e) {
      debugPrint('Fetch Bestsellers Error: $e');
    } finally {
      _isBestsellersLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNewArrivals() async {
    if (_isNewArrivalsLoading) return;

    _isNewArrivalsLoading = true;
    notifyListeners();

    try {
      final response = await _productService.getAllProducts(
        page: 1,
        sortKey: 'sortNewToOld',
      );

      if (response.success && response.data != null) {
        _newArrivals = response.data!.products;
      }
    } catch (e) {
      debugPrint('Fetch New Arrivals Error: $e');
    } finally {
      _isNewArrivalsLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFilters() async {
    try {
      final response = await _productService.getFilterList();
      if (response.success && response.data != null) {
        _filters = response.data;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Fetch Filters Error: $e');
    }
  }
}
