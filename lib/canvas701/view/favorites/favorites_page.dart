import 'package:flutter/material.dart';
import '../../theme/canvas701_theme_data.dart';
import '../../api/dummy_data.dart';
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
    // Dummy favori verileri - Gerçek uygulamada bir state manager veya local storage'dan gelir
    _favoriteProducts = Canvas701Data.allProducts.take(5).toList();
    _filteredProducts = List.from(_favoriteProducts);
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = List.from(_favoriteProducts);
      } else {
        _filteredProducts = _favoriteProducts
            .where((product) =>
                product.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Canvas701Colors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Modern App Bar
          const SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: Canvas701Colors.primary,
            elevation: 0,
            toolbarHeight: 45,
            titleSpacing: 0,
            automaticallyImplyLeading: false,
            title: AppModeSwitcher(),
          ),

          // Arama Alanı (CategoriesPage stilinde)
          SliverToBoxAdapter(
            child: _buildSearchBar(),
          ),

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
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Canvas701Colors.primary,
      padding: const EdgeInsets.fromLTRB(
        Canvas701Spacing.md,
        5,
        Canvas701Spacing.md,
        Canvas701Spacing.md,
      ),
      child: Container(
        height: 35,
        padding: const EdgeInsets.symmetric(horizontal: Canvas701Spacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(19),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Canvas701Colors.primary, size: 20),
            const SizedBox(width: Canvas701Spacing.sm),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                style: Canvas701Typography.bodyMedium.copyWith(
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'Favorilerimde ara',
                  hintStyle: Canvas701Typography.bodyMedium.copyWith(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  filled: false,
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  _onSearch('');
                },
                child: Icon(Icons.close, color: Colors.grey.shade500, size: 18),
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
        delegate: SliverChildBuilderDelegate(
          (context, index) {
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
          },
          childCount: _filteredProducts.length,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isEmpty
                ? 'Henüz favori ürününüz yok'
                : 'Aramanızla eşleşen ürün bulunamadı',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          if (_searchController.text.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Beğendiğiniz ürünleri buraya ekleyebilirsiniz.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
