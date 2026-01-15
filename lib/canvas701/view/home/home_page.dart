import 'dart:async';
import 'package:canvas701/canvas701/theme/canvas701_theme_data.dart';
import 'package:canvas701/canvas701/view/product/product_detail_page.dart';
import 'package:canvas701/canvas701/view/product/product_list_page.dart';
import 'package:canvas701/canvas701/view/campaign/campaign_detail_page.dart';
import 'package:canvas701/canvas701/viewmodel/favorites_viewmodel.dart';
import 'package:canvas701/canvas701/viewmodel/general_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../model/model.dart';
import '../../model/category_response.dart';
import '../../model/product_models.dart';
import '../../model/banner_response.dart';
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
  int _currentAnnouncementIndex = 0;
  Timer? _bannerTimer;
  Timer? _announcementTimer;

  final List<String> _defaultAnnouncements = [
    'KAMPANYA: TÜM ÜRÜNLERDE KARGO BEDAVA!',
    'YENİ SEZON: ÖZEL TASARIM KANVAS TABLOLAR',
    'FIRSAT: %20 İNDİRİM BUGÜNE ÖZEL',
    'KALİTE: %100 PAMUKLU KANVAS KUMAŞI',
  ];

  String _stripHtml(String? htmlString) {
    if (htmlString == null || htmlString.isEmpty) return '';
    // HTML taglarını ve bazı yaygın entity'leri temizle
    return htmlString
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&ccedil;', 'ç')
        .replaceAll('&Ccedil;', 'Ç')
        .replaceAll('&ouml;', 'ö')
        .replaceAll('&Ouml;', 'Ö')
        .replaceAll('&uuml;', 'ü')
        .replaceAll('&Uuml;', 'Ü')
        .replaceAll('&igrave;', 'i')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('\r', '')
        .replaceAll('\n', '')
        .trim();
  }

  List<String> get _activeAnnouncements {
    final campaigns = context.read<ProductViewModel>().campaigns;
    if (campaigns.isEmpty) return _defaultAnnouncements;
    return campaigns.map((e) {
      final title = e.campTitle.toUpperCase();
      final desc = _stripHtml(e.campDesc);
      return desc.isEmpty ? title : '$title: $desc';
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _startBannerTimer();
    _startAnnouncementTimer();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _announcementTimer?.cancel();
    _bannerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      
      final viewModel = Provider.of<GeneralViewModel>(context, listen: false);
      if (viewModel.banners.isEmpty) return;

      if (_currentBannerIndex < viewModel.banners.length - 1) {
        _currentBannerIndex++;
      } else {
        _currentBannerIndex = 0;
      }

      if (_bannerController.hasClients) {
        _bannerController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _startAnnouncementTimer() {
    _announcementTimer?.cancel();
    _announcementTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      final currentAnnouncements = _activeAnnouncements;
      if (currentAnnouncements.isEmpty) return;

      setState(() {
        if (_currentAnnouncementIndex < currentAnnouncements.length - 1) {
          _currentAnnouncementIndex++;
        } else {
          _currentAnnouncementIndex = 0;
        }
      });
    });
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

  void _handleBannerTap(ApiBanner banner) {
    if (banner.postDeeplinkKey == 'product' && 
        banner.postDeeplinkValue != null && 
        banner.postDeeplinkValue!.isNotEmpty) {
      final productId = banner.postDeeplinkValue!;
      
      // Detay sayfası için minimal product objesi
      // Bu obje API'den detaylar gelene kadar placeholder görevi görecek
      final dummyProduct = Product(
        id: productId,
        code: '',
        name: banner.postTitle ?? '',
        description: banner.postExcerpt ?? '',
        price: 0,
        images: [banner.postMainImage ?? ''],
        thumbnailUrl: banner.postThumbImage ?? '',
        collectionId: '',
        tableType: '',
        categoryIds: [],
        availableSizes: [
          const ProductSize(
            id: 'default',
            name: '50x70 cm', // Varsayılan boyut
            width: 50,
            height: 70,
            price: 0,
            tableType: '',
          ),
        ],
        createdAt: DateTime.now(),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailPage(product: dummyProduct),
        ),
      );
    } else if (banner.postDeeplinkKey == 'categories') {
      widget.onSeeAllCategories?.call();
    }
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

          // Announcement Bar
          SliverToBoxAdapter(child: _buildAnnouncementBar()),

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
    return Consumer<GeneralViewModel>(
      builder: (context, viewModel, _) {
        final banners = viewModel.banners;
        if (banners.isEmpty) {
          if (viewModel.isLoading) {
            return Container(
              height: 250,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: Canvas701Spacing.md),
              color: Canvas701Colors.surfaceVariant,
              child: const Center(child: CircularProgressIndicator()),
            );
          }
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: Stack(
            alignment: Alignment.bottomCenter,
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
                  itemCount: banners.length,
                  itemBuilder: (context, index) {
                    final banner = banners[index];
                    return GestureDetector(
                      onTap: () => _handleBannerTap(banner),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(banner.postMainImage ?? ''),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: Canvas701Spacing.lg,
                              bottom: Canvas701Spacing.xl + 4,
                              right: Canvas701Spacing.lg,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (banner.postTitle != null)
                                    Text(
                                      banner.postTitle!,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        height: 1.1,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.9),
                                            offset: const Offset(0, 2),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (banner.postExcerpt != null) ...[
                                    const SizedBox(height: Canvas701Spacing.xs),
                                    Text(
                                      banner.postExcerpt!,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.9),
                                            offset: const Offset(0, 2),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Page Indicator
              Positioned(
                bottom: Canvas701Spacing.md,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(banners.length, (index) {
                    final isSelected = _currentBannerIndex == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isSelected ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildAnnouncementBar() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final campaigns = context.read<ProductViewModel>().campaigns;
        if (campaigns.isNotEmpty) {
          final safeIndex = _currentAnnouncementIndex >= campaigns.length
              ? 0
              : _currentAnnouncementIndex;
          final campaign = campaigns[safeIndex];

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CampaignDetailPage(
                campaignId: campaign.campID,
                title: campaign.campTitle,
              ),
            ),
          );
        }
      },
      child: Container(
        height: 44,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Canvas701Colors.surface,
          border: Border(
            bottom: BorderSide(
                color: Canvas701Colors.primary.withOpacity(0.08), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 1000),
          layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
            return Stack(
              alignment: Alignment.center,
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          transitionBuilder: (Widget child, Animation<double> animation) {
            final isEntering =
                child.key == ValueKey<int>(_currentAnnouncementIndex);

            return AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                final double angle = isEntering
                    ? (1.0 - animation.value) * -1.570796
                    : (1.0 - animation.value) * 1.570796;

                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.005) // 3D Derinlik
                    ..rotateX(angle),
                  alignment:
                      isEntering ? Alignment.topCenter : Alignment.bottomCenter,
                  child: Opacity(
                    opacity: animation.value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
            );
          },
          child: Container(
            key: ValueKey<int>(_currentAnnouncementIndex),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Consumer<ProductViewModel>(
                    builder: (context, viewModel, _) {
                      final announcements = _activeAnnouncements;
                      final safeIndex =
                          _currentAnnouncementIndex >= announcements.length
                              ? 0
                              : _currentAnnouncementIndex;

                      return Text(
                        announcements[safeIndex],
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Canvas701Colors.primary,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Canvas701Spacing.md,
        Canvas701Spacing.md,
        Canvas701Spacing.md,
        Canvas701Spacing.sm,
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
