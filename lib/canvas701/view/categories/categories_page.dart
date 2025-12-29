import 'package:canvas701/canvas701/theme/canvas701_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../api/dummy_data.dart';
import '../../model/model.dart';

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
    return SliverAppBar(
      floating: true,
      pinned: true,
      backgroundColor: Canvas701Colors.background,
      surfaceTintColor: Canvas701Colors.surface,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Kategoriler',
        style: Canvas701Typography.titleLarge.copyWith(
          color: Canvas701Colors.textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_outlined,
              color: Canvas701Colors.textPrimary),
          onPressed: () {},
        ),
        const SizedBox(width: Canvas701Spacing.xs),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Canvas701Spacing.md,
        Canvas701Spacing.sm,
        Canvas701Spacing.md,
        Canvas701Spacing.md,
      ),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Canvas701Colors.surface,
          borderRadius: Canvas701Radius.buttonRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Canvas701Colors.divider),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Sanat eseri veya kategori ara...',
            hintStyle: Canvas701Typography.bodyMedium.copyWith(
              color: Canvas701Colors.textTertiary,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Canvas701Colors.primary,
              size: 22,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
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
    final populars = Canvas701Data.categories.take(5).toList();
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
                  image: DecorationImage(
                    image: NetworkImage(category.imageUrl ?? ''),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category.name,
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
  }

  Widget _buildCategoriesGrid(BuildContext context) {
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
            final category = Canvas701Data.categories[index];
            return _CategoryCard(category: category);
          },
          childCount: Canvas701Data.categories.length,
        ),
      ),
    );
  }
}

/// Premium Kategori Kartı
class _CategoryCard extends StatelessWidget {
  final Category category;

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
              imageUrl: category.imageUrl ?? '',
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Canvas701Colors.surfaceVariant),
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
                    category.name,
                    style: Canvas701Typography.titleSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${category.productCount} Ürün',
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
