import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/canvas701_theme_data.dart';
import '../../model/model.dart';
import '../widgets/widgets.dart';
import '../../../core/widgets/app_mode_switcher.dart';
import '../../viewmodel/favorites_viewmodel.dart';
import '../product/product_detail_page.dart';

/// Canvas701 Favoriler Sayfası
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesViewModel>().fetchFavorites();
    });
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Canvas701Colors.background,
      appBar: AppBar(
        backgroundColor: Canvas701Colors.primary,
        elevation: 0,
        toolbarHeight: 45,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        foregroundColor: Colors.white,
        title: AppModeSwitcher(
          isBack: true,
          onMenuIconTap: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Canvas701SearchBar(
            controller: _searchController,
            onChanged: _onSearch,
            hintText: 'Favorilerimde ara',
            onClear: () {
              _searchController.clear();
              _onSearch('');
            },
          ),
        ),
      ),
      body: Consumer<FavoritesViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.favorites.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredProducts = viewModel.favorites.where((product) {
            return product.productName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
          }).toList();

          return RefreshIndicator(
            onRefresh: () async {
              await viewModel.fetchFavorites();
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Favorites List
                if (filteredProducts.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  )
                else
                  _buildFavoritesGrid(filteredProducts, viewModel),

                // Alt Boşluk
                const SliverToBoxAdapter(
                  child: SizedBox(height: Canvas701Spacing.xxl),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoritesGrid(
    List<ApiProduct> products,
    FavoritesViewModel viewModel,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.all(Canvas701Spacing.md),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.5,
          crossAxisSpacing: Canvas701Spacing.md,
          mainAxisSpacing: Canvas701Spacing.md,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final apiProduct = products[index];
          final product = Product.fromApi(apiProduct);
          return ProductCard(
            product: product,
            isFavorite: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(product: product),
                ),
              );
            },
            onFavorite: () {
              viewModel.toggleFavorite(apiProduct.productID);
            },
          );
        }, childCount: products.length),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_outline, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? 'Henüz favori ürününüz yok'
                : 'Aramanızla eşleşen ürün bulunamadı',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
          ),
          if (_searchController.text.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Beğendiğiniz ürünleri buraya ekleyebilirsiniz.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
            ),
          ],
        ],
      ),
    );
  }
}
