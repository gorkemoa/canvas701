import 'package:canvas701/canvas701/theme/canvas701_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../model/model.dart';
import 'size_selection_bottom_sheet.dart';

/// Canvas701 Ürün Kartı Widget
/// 
/// Gösterilen bilgiler:
/// - Ürün görseli (placeholder)
/// - Kategori badge
/// - Ürün adı
/// - Fiyat
/// - Sepete ekle butonu
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.onFavorite,
    this.isFavorite = false,
  });

  /// Boyut seçimi bottom sheet'ini aç
  void _showSizeSelection(BuildContext context) {
    SizeSelectionBottomSheet.show(
      context,
      productId: int.tryParse(product.id) ?? 0,
      productName: product.name,
      productImage: product.thumbnail,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Canvas701Colors.surface,
          borderRadius: Canvas701Radius.cardRadius,
          boxShadow: const [Canvas701Shadows.card],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            _buildInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      children: [
        // Gerçek ürün görseli
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(Canvas701Radius.md),
          ),
          child: CachedNetworkImage(
            imageUrl: product.images.isNotEmpty ? product.images.first : '',
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Canvas701Colors.surfaceVariant,
                    Canvas701Colors.background,
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.image_outlined,
                  color: Canvas701Colors.textTertiary.withOpacity(0.3),
                  size: 32,
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Canvas701Colors.surfaceVariant,
                    Canvas701Colors.background,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(Canvas701Spacing.md),
                      decoration: BoxDecoration(
                        color: Canvas701Colors.surface,
                        shape: BoxShape.circle,
                        boxShadow: const [Canvas701Shadows.subtle],
                      ),
                      child: Icon(
                        Icons.image_outlined,
                        size: 36,
                        color: Canvas701Colors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: Canvas701Spacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Canvas701Spacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Canvas701Colors.surface.withAlpha(200),
                        borderRadius: Canvas701Radius.chipRadius,
                      ),
                      child: Text(
                        product.code,
                        style: Canvas701Typography.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Durum badge (YENİ / ÇOK SATAN)
        if (product.isNew || product.isBestseller)
          Positioned(
            top: Canvas701Spacing.xs,
            left: Canvas701Spacing.xs,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Canvas701Spacing.xs,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: product.isNew 
                    ? Canvas701Colors.primary 
                    : Canvas701Colors.secondary,
                borderRadius: BorderRadius.circular(Canvas701Radius.xs),
              ),
              child: Text(
                product.isNew ? 'YENİ' : 'ÇOK SATAN',
                style: Canvas701Typography.badge.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),

        // Favori butonu
        Positioned(
          top: Canvas701Spacing.xs,
          right: Canvas701Spacing.xs,
          child: GestureDetector(
            onTap: onFavorite,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Canvas701Colors.surface,
                shape: BoxShape.circle,
                boxShadow: const [Canvas701Shadows.subtle],
              ),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_outline,
                size: 16,
                color: isFavorite ? Colors.red : Canvas701Colors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfo(BuildContext context) {
    // Kategori adı (ilk kategori)
    final categoryName = product.categoryIds.isNotEmpty 
        ? _getCategoryName(product.categoryIds.first)
        : 'Kanvas Tablo';

    return Padding(
      padding: const EdgeInsets.all(Canvas701Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kategori - SABİT YÜKSEKLİK: 16px
          SizedBox(
            height: 16,
            child: Text(
              categoryName.toUpperCase(),
              style: Canvas701Typography.labelSmall.copyWith(
                color: Canvas701Colors.accent,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: Canvas701Spacing.xs),

          // Başlık - SABİT YÜKSEKLİK: 40px (2 satır)
          SizedBox(
            height: 40,
            child: Text(
              product.name,
              style: Canvas701Typography.titleSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: Canvas701Spacing.xs),

          // Fiyat - SABİT YÜKSEKLİK: 23px
          SizedBox(
            height: 23,
            child: Row(
              children: [
                Text(
                  '₺${product.displayPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: Canvas701Typography.price.copyWith(fontSize: 16),
                ),
                if (product.hasDiscount) ...[
                  const SizedBox(width: Canvas701Spacing.xs),
                  Text(
                    '₺${product.price.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: Canvas701Typography.discountPrice,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: Canvas701Spacing.sm),

          // Sepete Ekle Butonu - SABİT YÜKSEKLİK: 36px
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              onPressed: onAddToCart ?? () => _showSizeSelection(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Canvas701Colors.primary,
                foregroundColor: Canvas701Colors.textOnPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: Canvas701Spacing.sm,
                  vertical: Canvas701Spacing.xs,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Canvas701Radius.sm),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 16),
                  const SizedBox(width: Canvas701Spacing.xs),
                  Text(
                    'Sepete Ekle',
                    style: Canvas701Typography.labelMedium.copyWith(
                      color: Canvas701Colors.textOnPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Kategori ID'den isim döndür
  String _getCategoryName(String categoryId) {
    final categoryMap = {
      'cat-araba': 'Araba',
      'cat-ataturk': 'Atatürk',
      'cat-bust-heykel': 'Büst & Heykel',
      'cat-deniz-canlilari': 'Deniz Canlıları',
      'cat-dini': 'Dini',
      'cat-dizi-film': 'Dizi & Film',
      'cat-doga': 'Doğa',
      'cat-kis': 'Kış',
      'cat-manzara': 'Manzara',
      'cat-marka': 'Marka',
      'cat-melek': 'Melek',
      'cat-minimalist': 'Minimalist',
      'cat-motorsiklet': 'Motorsiklet',
      'cat-mutfak': 'Mutfak',
      'cat-neon': 'Neon & Yazı',
      'cat-nu': 'Nu',
      'cat-oyun': 'Oyun',
      'cat-perspektif': 'Perspektif',
      'cat-popart': 'Popart',
      'cat-siyah-beyaz': 'Siyah Beyaz',
      'cat-spor': 'Spor',
      'cat-surrealist': 'Sürrealist',
      'cat-sehir': 'Şehir',
      'cat-tarih': 'Tarih',
      'cat-teknoloji': 'Teknoloji',
      'cat-turkculuk': 'Türkçülük',
      'cat-unlenmis': 'Ünlü Tablolar',
      'cat-unlu-sanatci': 'Ünlü Sanatçı',
      'cat-uzay': 'Uzay',
      'cat-vintage': 'Vintage',
      'cat-yesilcam': 'Yeşilçam',
    };
    
    return categoryMap[categoryId] ?? 'Kanvas';
  }
}
