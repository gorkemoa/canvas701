import 'package:flutter/material.dart';
import '../../theme/canvas701_theme_data.dart';
import '../../model/model.dart';
import '../widgets/widgets.dart';
import '../../../core/widgets/app_mode_switcher.dart';

/// Canvas701 Favoriler Sayfası
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _favoriteProducts = [];
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    // Başlangıçta boş
    _favoriteProducts = [];
    _filteredProducts = [];
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = List.from(_favoriteProducts);
      } else {
        _filteredProducts = _favoriteProducts
            .where(
              (product) =>
                  product.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
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
        automaticallyImplyLeading: true,
        foregroundColor: Colors.white,
        title: const AppModeSwitcher(),
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
      body: RefreshIndicator(
        onRefresh: () async {
          // Favorileri yenileme simülasyonu
          await Future.delayed(const Duration(seconds: 1));
          setState(() {
            _onSearch(_searchController.text);
          });
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Favorites List
            if (_filteredProducts.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(),
              )
            else
              _buildFavoritesGrid(),

            // Alt Boşluk
            const SliverToBoxAdapter(
              child: SizedBox(height: Canvas701Spacing.xxl),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesGrid() {
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
          final product = _filteredProducts[index];
          return ProductCard(
            product: product,
            isFavorite: true,
            onFavorite: () {
              setState(() {
                _favoriteProducts.remove(product);
                _onSearch(_searchController.text);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} favorilerden çıkarıldı'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          );
        }, childCount: _filteredProducts.length),
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
