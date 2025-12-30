import 'package:canvas701/canvas701/theme/canvas701_theme_data.dart';
import 'package:canvas701/canvas701/view/product/product_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../api/dummy_data.dart';
import '../../model/model.dart';
import '../widgets/widgets.dart';
import '../../../core/widgets/app_mode_switcher.dart';

/// Canvas701 Ana Sayfa
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;

  final List<String> _banners = [
    'https://picsum.photos/seed/hero1/800/400',
    'https://picsum.photos/seed/hero2/800/400',
    'https://picsum.photos/seed/hero3/800/400',
    'https://picsum.photos/seed/hero4/800/400',
  ];

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Canvas701Colors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: Canvas701Colors.primary,
            elevation: 0,
            toolbarHeight: 45,
            titleSpacing: 0,
            automaticallyImplyLeading: false,
            title: const AppModeSwitcher(),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Container(
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
                    Text(
                      'Ürün, kategori veya marka ara',
                      style: Canvas701Typography.bodyMedium.copyWith(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
    );
  }

  Widget _buildHeroBanner() {
    return Column(
      children: [
        SizedBox(
          height: 250,
          width: double.infinity,
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: Canvas701Spacing.md),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(_banners[index]),
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
                          Text(
                            'Canvas701\nyine çok çekici!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              height: 1,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.9),
                                  offset: const Offset(0, 2),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: Canvas701Spacing.md),
                          const Text(
                            'Sanatın ve tasarımın buluşma noktası.\nDetaylar: canvas701.com.tr',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                                shadows: [
                                  Shadow(
                              
                                    offset: Offset(0, 2),
                                    blurRadius: 10,
                                  ),
                                ]

                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Page Indicator
        Padding(
          padding: const EdgeInsets.only(bottom: Canvas701Spacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_banners.length, (index) {
              final isSelected = _currentBannerIndex == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isSelected ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isSelected 
                      ? Canvas701Colors.primary 
                      : Canvas701Colors.primary.withOpacity(0.2),
                ),
              );
            }),
          ),
        ),
      ],
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(product: product),
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

}
