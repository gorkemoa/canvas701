import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../model/product_models.dart';
import '../model/filter_list_response.dart';
import '../model/campaign_response.dart';

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

  List<ApiCampaign> _campaigns = [];
  List<ApiCampaign> get campaigns => _campaigns;

  ApiCampaign? _selectedCampaign;
  ApiCampaign? get selectedCampaign => _selectedCampaign;

  FilterListData? _filters;
  FilterListData? get filters => _filters;

  ApiProductDetail? _selectedProduct;
  ApiProductDetail? get selectedProduct => _selectedProduct;

  List<ApiProduct> _similarProducts = [];
  List<ApiProduct> get similarProducts => _similarProducts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isBestsellersLoading = false;
  bool get isBestsellersLoading => _isBestsellersLoading;

  bool _isNewArrivalsLoading = false;
  bool get isNewArrivalsLoading => _isNewArrivalsLoading;

  bool _isCampaignsLoading = false;
  bool get isCampaignsLoading => _isCampaignsLoading;

  bool _isCampaignDetailLoading = false;
  bool get isCampaignDetailLoading => _isCampaignDetailLoading;

  bool _isDetailLoading = false;
  bool get isDetailLoading => _isDetailLoading;

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

  Future<void> fetchCampaigns() async {
    if (_isCampaignsLoading) return;

    _isCampaignsLoading = true;
    notifyListeners();

    try {
      final response = await _productService.getCampaigns();

      if (response.success && response.data != null) {
        _campaigns = response.data!.campaigns;
      }
    } catch (e) {
      debugPrint('Fetch Campaigns Error: $e');
    } finally {
      _isCampaignsLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCampaignDetail(int campId) async {
    _isCampaignDetailLoading = true;
    _selectedCampaign = null;
    notifyListeners();

    try {
      final response = await _productService.getCampaignDetail(campId);

      if (response.success && response.data != null) {
        _selectedCampaign = response.data!.campaign;
      }
    } catch (e) {
      debugPrint('Fetch Campaign Detail Error: $e');
    } finally {
      _isCampaignDetailLoading = false;
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

  Future<void> fetchProductDetail(int productId) async {
    _isDetailLoading = true;
    _errorMessage = null;
    _selectedProduct = null;
    _similarProducts = [];
    notifyListeners();

    try {
      final response = await _productService.getProductDetail(productId);

      if (response.success && response.data != null) {
        _selectedProduct = response.data!.product;
        _similarProducts = response.data!.similarProducts;
      } else {
        _errorMessage = 'Ürün detayı yüklenemedi';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }
}
