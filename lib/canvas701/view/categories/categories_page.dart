import 'package:canvas701/canvas701/theme/canvas701_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/category_viewmodel.dart';
import '../../model/category_response.dart';
import '../../../core/widgets/app_mode_switcher.dart';

/// Canvas701 Kategoriler Sayfası
class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Canvas701Colors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Modern App Bar
          _buildAppBar(context),

          // Arama Alanı
          SliverToBoxAdapter(
            child: _buildSearchBar(context),
          ),

          // Öne Çıkanlar Başlığı
          SliverToBoxAdapter(
            child: _buildSectionHeader('Popüler Koleksiyonlar'),
          ),

          // Yatay Popüler Kategoriler
          SliverToBoxAdapter(
            child: _buildPopularCategories(),
          ),

          // Tüm Kategoriler Başlığı
          SliverToBoxAdapter(
            child: _buildSectionHeader('Tüm Kategoriler'),
          ),

          // Kategoriler Grid
          _buildCategoriesGrid(context),

          // Alt Boşluk
          const SliverToBoxAdapter(
            child: SizedBox(height: Canvas701Spacing.xxl),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return const SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: Canvas701Colors.primary,
      elevation: 0,
      toolbarHeight: 45,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      title: AppModeSwitcher(),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
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
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Canvas701Spacing.md,
        Canvas701Spacing.lg,
        Canvas701Spacing.md,
        Canvas701Spacing.md,
      ),
      child: Text(
        title,
        style: Canvas701Typography.titleMedium.copyWith(
          fontWeight: FontWeight.w800,
          color: Canvas701Colors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildPopularCategories() {
    return Consumer<CategoryViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && viewModel.categories.isEmpty) {
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final populars = viewModel.categories.take(5).toList();
        if (populars.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 120,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: Canvas701Spacing.md),
            scrollDirection: Axis.horizontal,
            itemCount: populars.length,
            separatorBuilder: (_, __) => const SizedBox(width: Canvas701Spacing.md),
            itemBuilder: (context, index) {
              final category = populars[index];
              return Column(
                children: [
                  Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Canvas701Colors.primary, width: 2),
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: category.catThumbImage1,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: Canvas701Colors.surfaceVariant),
                        errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.catName,
                    style: Canvas701Typography.labelSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Canvas701Colors.textSecondary,
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoriesGrid(BuildContext context) {
    return Consumer<CategoryViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading && viewModel.categories.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (viewModel.categories.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: Canvas701Spacing.md),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: Canvas701Spacing.md,
              crossAxisSpacing: Canvas701Spacing.md,
              childAspectRatio: 0.8,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = viewModel.categories[index];
                return _CategoryCard(category: category);
              },
              childCount: viewModel.categories.length,
            ),
          ),
        );
      },
    );
  }
}

/// Premium Kategori Kartı
class _CategoryCard extends StatelessWidget {
  final ApiCategory category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigasyon
      },
      child: Container(
        decoration: BoxDecoration(
          color: Canvas701Colors.surface,
          borderRadius: Canvas701Radius.cardRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Görsel
            CachedNetworkImage(
              imageUrl: category.catThumbImage1,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Canvas701Colors.surfaceVariant),
              errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
            ),

            // Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),

            // Bilgi
            Padding(
              padding: const EdgeInsets.all(Canvas701Spacing.sm),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.catName,
                    style: Canvas701Typography.titleSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Kategoriyi Gör',
                    style: Canvas701Typography.labelSmall.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            // Badge
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chevron_right, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
