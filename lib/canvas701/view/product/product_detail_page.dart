import 'package:canvas701/canvas701/theme/canvas701_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../model/model.dart';
import '../../viewmodel/product_viewmodel.dart';
import '../widgets/widgets.dart';

/// Canvas701 Ürün Detay Sayfası
/// Tasarım: https://www.canvas701.com/gucci-magaza-onu-kanvas-tablo
class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late ProductSize _selectedSize;
  int _quantity = 1;
  bool _isFavorite = false;
  int _activeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.product.availableSizes.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Canvas701Colors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildProductImage()),
          // Ürün Bilgileri
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              transform: Matrix4.translationValues(0, -30, 0),
              child: Padding(
                padding: const EdgeInsets.all(Canvas701Spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBreadcrumbs(),
                    const SizedBox(height: Canvas701Spacing.sm),
                    _buildTitleAndPrice(),
                    const SizedBox(height: Canvas701Spacing.lg),
                    _buildSizeSelection(),
                    const SizedBox(height: Canvas701Spacing.lg),
                    _buildQuantityAndAdd(),
                    const SizedBox(height: Canvas701Spacing.xl),
                    _buildProductFeatures(),
                    const SizedBox(height: Canvas701Spacing.xl),
                    _buildDescription(),
                    const SizedBox(height: Canvas701Spacing.xl),
                    _buildRelatedProducts(),
                    const SizedBox(height: Canvas701Spacing.xxl),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 400,
          color: Colors.white,
          child: Hero(
            tag: 'product_${widget.product.id}',
            child: CachedNetworkImage(
              imageUrl: widget.product.images.first,
              fit: BoxFit.contain,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.image_outlined, size: 100),
            ),
          ),
        ),
        // Back Button
        Positioned(
          top: 60,
          left: Canvas701Spacing.md,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Canvas701Colors.textPrimary,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        // Floating Action Buttons
        Positioned(
          top: 60,
          right: Canvas701Spacing.md,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_outline,
                    color: _isFavorite
                        ? Colors.red
                        : Canvas701Colors.textPrimary,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _isFavorite
                              ? 'Favorilere eklendi!'
                              : 'Favorilerden çıkarıldı!',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: Canvas701Spacing.sm),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.share_outlined,
                    color: Canvas701Colors.textPrimary,
                    size: 20,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Paylaşma özelliği yakında eklenecek!'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBreadcrumbs() {
    return Row(
      children: [
        Text('Anasayfa', style: Canvas701Typography.labelSmall),
        const Icon(
          Icons.chevron_right,
          size: 12,
          color: Canvas701Colors.textTertiary,
        ),
        Text('Kanvas Tablolar', style: Canvas701Typography.labelSmall),
        const Icon(
          Icons.chevron_right,
          size: 12,
          color: Canvas701Colors.textTertiary,
        ),
        Expanded(
          child: Text(
            widget.product.name,
            style: Canvas701Typography.labelSmall.copyWith(
              color: Canvas701Colors.textTertiary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleAndPrice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.name,
          style: Canvas701Typography.displaySmall.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: Canvas701Spacing.xs),
        Text(
          'Ürün Kodu: ${widget.product.code}',
          style: Canvas701Typography.labelSmall,
        ),
        const SizedBox(height: Canvas701Spacing.md),
        Row(
          children: [
            Text(
              'Kategori: ',
              style: Canvas701Typography.labelSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text('Kanvas Tablolar', style: Canvas701Typography.labelSmall),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              'Etiketler: ',
              style: Canvas701Typography.labelSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Dekorasyon, Sanat, Modern',
              style: Canvas701Typography.labelSmall,
            ),
          ],
        ),
        const SizedBox(height: Canvas701Spacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${_selectedSize.price.toStringAsFixed(2)} TL',
              style: Canvas701Typography.displaySmall.copyWith(
                color: Canvas701Colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: Canvas701Spacing.sm),
            if (widget.product.hasDiscount)
              Text(
                '${widget.product.price.toStringAsFixed(2)} TL',
                style: Canvas701Typography.bodyMedium.copyWith(
                  color: Canvas701Colors.textTertiary,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSizeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ölçü Seçimi', style: Canvas701Typography.titleMedium),
        const SizedBox(height: Canvas701Spacing.sm),
        Wrap(
          spacing: Canvas701Spacing.sm,
          runSpacing: Canvas701Spacing.sm,
          children: widget.product.availableSizes.map((size) {
            final isSelected = _selectedSize.id == size.id;
            return GestureDetector(
              onTap: () => setState(() => _selectedSize = size),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Canvas701Spacing.md,
                  vertical: Canvas701Spacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Canvas701Colors.primary : Colors.white,
                  borderRadius: Canvas701Radius.buttonRadius,
                  border: Border.all(
                    color: isSelected
                        ? Canvas701Colors.primary
                        : Canvas701Colors.divider,
                  ),
                ),
                child: Text(
                  size.name,
                  style: Canvas701Typography.labelMedium.copyWith(
                    color: isSelected
                        ? Colors.white
                        : Canvas701Colors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuantityAndAdd() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: Canvas701Colors.divider),
                borderRadius: Canvas701Radius.buttonRadius,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                  ),
                  Text('$_quantity', style: Canvas701Typography.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ),
            const SizedBox(width: Canvas701Spacing.md),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${widget.product.name} sepete eklendi!'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Canvas701Colors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: Canvas701Radius.buttonRadius,
                    ),
                  ),
                  child: const Text(
                    'SEPETE EKLE',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Canvas701Spacing.md),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: Canvas701Colors.secondary,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: Canvas701Radius.buttonRadius,
              ),
            ),
            child: const Text(
              'HEMEN AL',
              style: TextStyle(
                color: Canvas701Colors.secondary,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductFeatures() {
    return Container(
      padding: const EdgeInsets.all(Canvas701Spacing.md),
      decoration: BoxDecoration(
        color: Canvas701Colors.surfaceVariant,
        borderRadius: Canvas701Radius.cardRadius,
      ),
      child: Column(
        children: [
          _buildFeatureItem(
            Icons.check_circle_outline,
            'Yüksek Çözünürlüklü Baskı',
          ),
          const Divider(height: 24),
          _buildFeatureItem(Icons.check_circle_outline, 'Pamuklu Kanvas Kumaş'),
          const Divider(height: 24),
          _buildFeatureItem(
            Icons.check_circle_outline,
            'Fırınlanmış Ahşap Şase',
          ),
          const Divider(height: 24),
          _buildFeatureItem(
            Icons.local_shipping_outlined,
            'Ücretsiz ve Hızlı Kargo',
          ),
          const Divider(height: 24),
          _buildFeatureItem(
            Icons.security_outlined,
            '256 Bit SSL Güvenli Ödeme',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Canvas701Colors.primary),
        const SizedBox(width: Canvas701Spacing.sm),
        Text(text, style: Canvas701Typography.bodyMedium),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTabItem(0, 'Ürün Özellikleri'),
            _buildTabItem(1, 'Teslimat'),
            _buildTabItem(2, 'İade Koşulları'),
          ],
        ),
        const Divider(height: 1, thickness: 1, color: Canvas701Colors.divider),
        const SizedBox(height: Canvas701Spacing.md),
        _buildTabContent(),
      ],
    );
  }

  Widget _buildTabItem(int index, String title) {
    final isActive = _activeTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Canvas701Spacing.md,
          vertical: Canvas701Spacing.sm,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? Canvas701Colors.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive
                ? Canvas701Colors.primary
                : Canvas701Colors.textTertiary,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_activeTabIndex) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.product.description,
              style: Canvas701Typography.bodyMedium.copyWith(height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Canvas701Spacing.md),
            _buildBulletPoint('380 gr/m² %100 Pamuklu Kanvas Kumaş'),
            _buildBulletPoint('HP Latex Mürekkep (Kokusuz ve Sağlıklı)'),
            _buildBulletPoint('3cm Derinliğinde Fırınlanmış Ahşap Şase'),
            _buildBulletPoint('Kenarlar Görselin Devamı Şeklinde Kaplanır'),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_shipping_outlined,
                  color: Canvas701Colors.primary,
                  size: 20,
                ),
                const SizedBox(width: Canvas701Spacing.sm),
                Text(
                  'Hızlı ve Güvenli Teslimat',
                  style: Canvas701Typography.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: Canvas701Spacing.sm),
            Text(
              'Siparişleriniz 2-4 iş günü içerisinde kargoya teslim edilir. Özel korumalı ambalajı ile hasarsız teslimat garantisi sunuyoruz.',
              style: Canvas701Typography.bodyMedium.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.assignment_return_outlined,
                  color: Canvas701Colors.primary,
                  size: 20,
                ),
                const SizedBox(width: Canvas701Spacing.sm),
                Text(
                  'Kolay İade Süreci',
                  style: Canvas701Typography.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: Canvas701Spacing.sm),
            Text(
              'Ürününüzü teslim aldığınız tarihten itibaren 14 gün içerisinde iade edebilirsiniz. Kişiye özel hazırlanan ürünlerde (isimli vb.) iade kabul edilmemektedir.',
              style: Canvas701Typography.bodyMedium.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: Canvas701Colors.primary),
          ),
          const SizedBox(width: Canvas701Spacing.sm),
          Flexible(child: Text(text, style: Canvas701Typography.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildRelatedProducts() {
    return Consumer<ProductViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.products.isEmpty) return const SizedBox.shrink();

        final related = viewModel.products
            .where((p) => p.productID.toString() != widget.product.id)
            .take(4)
            .map((p) => Product.fromApi(p))
            .toList();

        if (related.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Benzer Ürünler', style: Canvas701Typography.titleLarge),
            const SizedBox(height: Canvas701Spacing.md),
            SizedBox(
              height:
                  360, // Ürün kartı yüksekliği için yeterli alan (347px + padding)
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: related.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: Canvas701Spacing.md),
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 180,
                    child: ProductCard(
                      product: related[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailPage(product: related[index]),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
