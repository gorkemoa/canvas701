import 'package:canvas701/canvas701/theme/canvas701_theme_data.dart';
import 'package:canvas701/canvas701/view/product/product_detail_page.dart';
import 'package:canvas701/canvas701/view/product/product_list_page.dart';
import 'package:canvas701/canvas701/viewmodel/favorites_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../model/model.dart';
import '../../model/category_response.dart';
import '../../viewmodel/category_viewmodel.dart';
import '../../viewmodel/product_viewmodel.dart';
import '../widgets/widgets.dart';
import '../../../core/widgets/app_mode_switcher.dart';

/// Canvas701 Ana Sayfa
class HomePage extends StatefulWidget {
  final VoidCallback? onSeeAllCategories;
  const HomePage({super.key, this.onSeeAllCategories});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _bannerController = PageController();
  final TextEditingController _searchController = TextEditingController();
  int _currentBannerIndex = 0;

  final List<String> _banners = [];

  @override
  void initState() {
    super.initState();
    // Veriler Splash sayfasında yüklendiği için burada tekrar yüklemeye gerek yok.
    // Ancak sayfa her açıldığında güncel veri istenirse burası kalabilir.
    // Kullanıcı isteğine göre Splash'te yüklendiği için burayı boş bırakıyoruz.
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    if (value.trim().isEmpty) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListPage(
          title: 'Arama: $value',
          searchText: value,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Canvas701Colors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar & Search Bar
          SliverAppBar(
            floating: false,
            pinned: true,
            backgroundColor: Canvas701Colors.primary,
            elevation: 0,
            toolbarHeight: 45,
            titleSpacing: 0,
            automaticallyImplyLeading: false,
            title: const AppModeSwitcher(),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Canvas701SearchBar(
                controller: _searchController,
                onSubmitted: _onSearch,
                onClear: () => _searchController.clear(),
              ),
            ),
          ),

          // Hero Banner
          SliverToBoxAdapter(child: _buildHeroBanner()),

          // USP Bar
          SliverToBoxAdapter(child: _buildUSPBar()),

          // Categories Section
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              'Kategoriler',
              onSeeAll: widget.onSeeAllCategories,
            ),
          ),
          SliverToBoxAdapter(child: _buildCategoriesGrid()),

          // Bestsellers Section
          SliverToBoxAdapter(
            child: Consumer<ProductViewModel>(
              builder: (context, viewModel, _) {
                if (viewModel.isBestsellersLoading && viewModel.bestsellers.isEmpty) {
                  return const SizedBox.shrink();
                }
                if (viewModel.bestsellers.isEmpty) return const SizedBox.shrink();

                return Column(
                  children: [
                    _buildSectionHeader(
                      'Çok Satanlar',
                      onSeeAll: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProductListPage(
                              title: 'Çok Satanlar',
                              sortKey: 'sortBestSellers',
                            ),
                          ),
                        );
                      },
                    ),
                    _buildProductsRow(viewModel.bestsellers),
                  ],
                );
              },
            ),
          ),

          // New Arrivals Section
          SliverToBoxAdapter(
            child: Consumer<ProductViewModel>(
              builder: (context, viewModel, _) {
                if (viewModel.isNewArrivalsLoading && viewModel.newArrivals.isEmpty) {
                  return const SizedBox.shrink();
                }
                if (viewModel.newArrivals.isEmpty) return const SizedBox.shrink();

                return Column(
                  children: [
                    _buildSectionHeader(
                      'Son Eklenenler',
                      onSeeAll: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProductListPage(
                              title: 'Son Eklenenler',
                              sortKey: 'sortNewToOld',
                            ),
                          ),
                        );
                      },
                    ),
                    _buildProductsRow(viewModel.newArrivals),
                  ],
                );
              },
            ),
          ),

          // All Products Section
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              'Tüm Ürünler',
              onSeeAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductListPage(
                      title: 'Tüm Ürünler',
                      sortKey: 'sortDefault',
                    ),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Consumer<ProductViewModel>(
              builder: (context, viewModel, _) {
                if (viewModel.isLoading && viewModel.products.isEmpty) {
                  return const SizedBox(
                    height: 200,
                  );
                }
                if (viewModel.products.isEmpty) {
                  return const SizedBox(
                    height: 100,
                    child: Center(child: Text('Ürün bulunamadı')),
                  );
                }
                return _buildProductsRow(viewModel.products);
              },
            ),
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
    if (_banners.isEmpty) return const SizedBox.shrink();
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
                margin: const EdgeInsets.only(bottom: Canvas701Spacing.md),
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
    return Consumer<CategoryViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && viewModel.categories.isEmpty) {
          return const SizedBox(
            height: 100,
          );
        }

        if (viewModel.categories.isEmpty) {
          return const SizedBox.shrink();
        }

        final displayCategories = viewModel.categories.take(8).toList();

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
      },
    );
  }

  Widget _buildCategoryItem(ApiCategory category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductListPage(
              title: category.catName,
              categoryId: category.catID,
            ),
          ),
        );
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
                imageUrl: category.catThumbImage1,
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
              category.catName,
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

  Widget _buildProductsRow(List<ApiProduct> apiProducts) {
    return Consumer<FavoritesViewModel>(
      builder: (context, favViewModel, child) {
        return SizedBox(
          height: 350,
          child: ListView.separated(
            padding:
                const EdgeInsets.symmetric(horizontal: Canvas701Spacing.md),
            scrollDirection: Axis.horizontal,
            itemCount: apiProducts.length,
            separatorBuilder:
                (_, __) => const SizedBox(width: Canvas701Spacing.md),
            itemBuilder: (context, index) {
              final apiProduct = apiProducts[index];
              final product = Product.fromApi(apiProduct);
              final isFav = favViewModel.isFavorite(apiProduct.productID);

              return ProductCard(
                product: product,
                isFavorite: isFav,
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
                      action:
                          SnackBarAction(label: 'Geri Al', onPressed: () {}),
                    ),
                  );
                },
                onFavorite: () {
                  favViewModel.toggleFavorite(apiProduct.productID);
                },
              );
            },
          ),
        );
      },
    );
  }

}
