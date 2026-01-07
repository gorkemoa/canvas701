import 'package:canvas701/canvas701/viewmodel/favorites_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/model.dart';
import '../../theme/canvas701_theme_data.dart';
import '../widgets/widgets.dart';
import '../../api/product_service.dart';
import '../../model/product_models.dart';
import 'product_detail_page.dart';

class ProductListPage extends StatefulWidget {
  final String title;
  final int? categoryId;
  final String? sortKey;
  final String? typeKey;
  final String? searchText;

  const ProductListPage({
    super.key,
    required this.title,
    this.categoryId,
    this.sortKey,
    this.typeKey,
    this.searchText,
  });

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ProductService _productService = ProductService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final List<ApiProduct> _products = [];
  bool _isLoading = false; // initState'de manuel tetikleyeceğiz
  int _currentPage = 1;
  bool _hasNextPage = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchText ?? '';
    // İlk yükleme için _isLoading check'ini bypass eden bir çağrı veya initState içinde olduğu için güvenli
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProducts();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    _fetchProducts(refresh: true);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _fetchProducts();
    }
  }

  Future<void> _fetchProducts({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _hasNextPage = true;
      // products.clear() yapmıyoruz, UI'da patlama olmasın diye.
      // Aşağıda başarılı olursa replace ederiz.
    }

    if (!_hasNextPage) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _productService.getAllProducts(
        catID: widget.categoryId ?? 0,
        sortKey: widget.sortKey ?? 'sortDefault',
        typeKey: widget.typeKey ?? '',
        searchText: _searchController.text,
        page: _currentPage,
      );

      if (response.success && response.data != null) {
        if (mounted) {
          context
              .read<FavoritesViewModel>()
              .updateFavoritesFromProducts(response.data!.products);
        }

        setState(() {
          if (refresh) {
            _products.clear();
          }
          _products.addAll(response.data!.products);
          _hasNextPage = response.data!.hasNextPage;
          if (_hasNextPage) _currentPage++;
        });
      } else {
        setState(() => _errorMessage = 'Ürünler yüklenemedi');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Canvas701Colors.background,
      appBar: AppBar(
        title: Text(widget.title,
            style: const TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: Canvas701Colors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Canvas701SearchBar(
            controller: _searchController,
            onSubmitted: _onSearch,
            onClear: () {
              _searchController.clear();
              _fetchProducts(refresh: true);
            },
          ),
        ),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _fetchProducts(refresh: true),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Text(
          _searchController.text.isNotEmpty
              ? '"${_searchController.text}" için sonuç bulunamadı.'
              : 'Ürün bulunamadı.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchProducts(refresh: true),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(Canvas701Spacing.md),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.5,
                crossAxisSpacing: Canvas701Spacing.md,
                mainAxisSpacing: Canvas701Spacing.md,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final apiProduct = _products[index];
                final product = Product.fromApi(apiProduct);

                return Consumer<FavoritesViewModel>(
                  builder: (context, favViewModel, child) {
                    final isFav = favViewModel.isFavorite(apiProduct.productID);
                    return ProductCard(
                      product: product,
                      isFavorite: isFav,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailPage(product: product),
                          ),
                        );
                      },
                      onAddToCart: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} sepete eklendi!'),
                          ),
                        );
                      },
                      onFavorite: () {
                        favViewModel.toggleFavorite(apiProduct.productID);
                      },
                    );
                  },
                );
              }, childCount: _products.length),
            ),
          ),
          if (_hasNextPage && _isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: Canvas701Spacing.lg),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          const SliverToBoxAdapter(
            child: SizedBox(height: Canvas701Spacing.xxl),
          ),
        ],
      ),
    );
  }
}
