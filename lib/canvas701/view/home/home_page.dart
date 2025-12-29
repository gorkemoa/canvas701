import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/theme.dart';
import '../../api/dummy_data.dart';
import '../../model/model.dart';
import '../widgets/widgets.dart';

/// Canvas701 Ana Sayfa
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Canvas701Colors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            backgroundColor: Canvas701Colors.surface,
            elevation: 0,
            title: Image.asset('assets/logo.png', height: 32),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.search, color: Canvas701Colors.primary),
              onPressed: () {
                // TODO: Search
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.favorite_outline,
                  color: Canvas701Colors.primary,
                ),
                onPressed: () {
                  // TODO: Favorites
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Canvas701Colors.primary,
                ),
                onPressed: () {
                  // TODO: Cart
                },
              ),
            ],
          ),

          // Hero Banner
          SliverToBoxAdapter(child: _buildHeroBanner()),

          // USP Bar
          SliverToBoxAdapter(child: _buildUSPBar()),

          // Categories Section
          SliverToBoxAdapter(
            child: _buildSectionHeader('Kategoriler', onSeeAll: () {}),
          ),
          SliverToBoxAdapter(child: _buildCategoriesGrid()),

          // Bestsellers Section
          SliverToBoxAdapter(
            child: _buildSectionHeader('Çok Satanlar', onSeeAll: () {}),
          ),
          SliverToBoxAdapter(
            child: _buildProductsRow(Canvas701Data.bestsellers),
          ),

          // New Arrivals Section
          SliverToBoxAdapter(
            child: _buildSectionHeader('Son Eklenenler', onSeeAll: () {}),
          ),
          SliverToBoxAdapter(
            child: _buildProductsRow(Canvas701Data.newArrivals),
          ),

          // Luxury Section
          SliverToBoxAdapter(
            child: _buildSectionHeader('Marka & Lüks', onSeeAll: () {}),
          ),
          SliverToBoxAdapter(
            child: _buildProductsRow(Canvas701Data.luxuryProducts),
          ),

          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: Canvas701Spacing.xxl),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(Canvas701Spacing.md),
      decoration: BoxDecoration(
        borderRadius: Canvas701Radius.cardRadius,
        image: const DecorationImage(
          image: NetworkImage('https://picsum.photos/seed/hero/800/400'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: Canvas701Spacing.lg,
            bottom: Canvas701Spacing.lg,
            right: Canvas701Spacing.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'YENİ KOLEKSİYON',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        offset: Offset(0, 1),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Canvas701Spacing.xs),
                Text(
                  'Evinize Sanat Katın',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.7),
                        offset: const Offset(0, 2),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUSPBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Canvas701Spacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildUSPItem(Icons.local_shipping_outlined, 'Ücretsiz Kargo'),
          _buildUSPItem(Icons.security, '3D Secure'),
          _buildUSPItem(Icons.replay, '14 Gün İade'),
        ],
      ),
    );
  }

  Widget _buildUSPItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Canvas701Colors.textSecondary),
        const SizedBox(height: Canvas701Spacing.xs),
        Text(text, style: Canvas701Typography.labelSmall),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Canvas701Spacing.md,
        Canvas701Spacing.lg,
        Canvas701Spacing.md,
        Canvas701Spacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Canvas701Typography.headlineSmall),
          if (onSeeAll != null)
            TextButton(onPressed: onSeeAll, child: const Text('Tümü')),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    // Canvas701.com'dan gerçek kategoriler
    final displayCategories = Canvas701Data.categories.take(8).toList();

    return SizedBox(
      height: 100,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: Canvas701Spacing.md),
        scrollDirection: Axis.horizontal,
        itemCount: displayCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: Canvas701Spacing.sm),
        itemBuilder: (context, index) {
          final category = displayCategories[index];
          return _buildCategoryItem(category);
        },
      ),
    );
  }

  Widget _buildCategoryItem(Category category) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to category
      },
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: category.imageUrl ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Canvas701Colors.surfaceVariant,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Canvas701Colors.accent,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Canvas701Colors.primary.withOpacity(0.1),
                    border: Border.all(
                      color: Canvas701Colors.primary.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.image_outlined,
                    size: 32,
                    color: Canvas701Colors.primary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Canvas701Spacing.xs),
          SizedBox(
            width: 70,
            child: Text(
              category.name,
              style: Canvas701Typography.labelSmall,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsRow(List<Product> products) {
    return SizedBox(
      height: 350,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: Canvas701Spacing.md),
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: Canvas701Spacing.md),
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} detayına git'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            onAddToCart: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} sepete eklendi!'),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(label: 'Geri Al', onPressed: () {}),
                ),
              );
            },
            onFavorite: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} favorilere eklendi!'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Canvas701Colors.surface,
        border: Border(top: BorderSide(color: Canvas701Colors.divider)),
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: 0,
          selectedItemColor: Canvas701Colors.primary,
          unselectedItemColor: Canvas701Colors.textTertiary,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Ana Sayfa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view),
              label: 'Kategoriler',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              activeIcon: Icon(Icons.favorite),
              label: 'Favoriler',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag),
              label: 'Sepet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
