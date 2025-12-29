import 'package:canvas701/canvas701/theme/canvas701_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../model/model.dart';
import '../../api/dummy_data.dart';
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
          // Ürün Görseli (AppBar yerine en üstte)
          SliverToBoxAdapter(child: _buildProductImage()),

          // Ürün Bilgileri
          SliverToBoxAdapter(
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
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return Stack(
      children: [
        Container(
          color: Colors.white,
          width: double.infinity,
          height: 400,
          child: Hero(
            tag: 'product_${widget.product.id}',
            child: CachedNetworkImage(
              imageUrl: widget.product.images.first,
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.image_outlined, size: 100),
            ),
          ),
        ),
        // Floating Back Button
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
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
              icon: const Icon(Icons.arrow_back_ios_new, color: Canvas701Colors.textPrimary, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        // Floating Action Buttons
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
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
                    color: _isFavorite ? Colors.red : Canvas701Colors.textPrimary, size: 20
                  ),
                  onPressed: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_isFavorite ? 'Favorilere eklendi!' : 'Favorilerden çıkarıldı!'),
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
                  icon: const Icon(Icons.share_outlined, color: Canvas701Colors.textPrimary, size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Paylaşma özelliği yakında eklenecek!')),
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
        const Icon(Icons.chevron_right, size: 12, color: Canvas701Colors.textTertiary),
        Text('Kanvas Tablolar', style: Canvas701Typography.labelSmall),
        const Icon(Icons.chevron_right, size: 12, color: Canvas701Colors.textTertiary),
        Expanded(
          child: Text(
            widget.product.name,
            style: Canvas701Typography.labelSmall.copyWith(color: Canvas701Colors.textTertiary),
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
            Text('Kategori: ', style: Canvas701Typography.labelSmall.copyWith(fontWeight: FontWeight.w700)),
            Text('Kanvas Tablolar', style: Canvas701Typography.labelSmall),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text('Etiketler: ', style: Canvas701Typography.labelSmall.copyWith(fontWeight: FontWeight.w700)),
            Text('Dekorasyon, Sanat, Modern', style: Canvas701Typography.labelSmall),
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
                    color: isSelected ? Canvas701Colors.primary : Canvas701Colors.divider,
                  ),
                ),
                child: Text(
                  size.name,
                  style: Canvas701Typography.labelMedium.copyWith(
                    color: isSelected ? Colors.white : Canvas701Colors.textPrimary,
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
                    onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                  ),
                  Text(
                    '$_quantity',
                    style: Canvas701Typography.titleMedium,
                  ),
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
                      SnackBar(content: Text('${widget.product.name} sepete eklendi!')),
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
                    style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2),
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
              side: const BorderSide(color: Canvas701Colors.secondary, width: 1.5),
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
          _buildFeatureItem(Icons.check_circle_outline, 'Yüksek Çözünürlüklü Baskı'),
          const Divider(height: 24),
          _buildFeatureItem(Icons.check_circle_outline, 'Pamuklu Kanvas Kumaş'),
          const Divider(height: 24),
          _buildFeatureItem(Icons.check_circle_outline, 'Fırınlanmış Ahşap Şase'),
          const Divider(height: 24),
          _buildFeatureItem(Icons.local_shipping_outlined, 'Ücretsiz ve Hızlı Kargo'),
          const Divider(height: 24),
          _buildFeatureItem(Icons.security_outlined, '256 Bit SSL Güvenli Ödeme'),
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
    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TabBar(
            labelColor: Canvas701Colors.primary,
            unselectedLabelColor: Canvas701Colors.textTertiary,
            indicatorColor: Canvas701Colors.primary,
            labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            tabs: [
              Tab(text: 'Ürün Özellikleri'),
              Tab(text: 'Teslimat'),
              Tab(text: 'İade Koşulları'),
            ],
          ),
          SizedBox(
            height: 200,
            child: TabBarView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Canvas701Spacing.md),
                  child: Text(
                    widget.product.description,
                    style: Canvas701Typography.bodyMedium.copyWith(height: 1.6),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: Canvas701Spacing.md),
                  child: Text(
                    'Siparişleriniz 2-4 iş günü içerisinde kargoya teslim edilir. Tüm Türkiye\'ye ücretsiz kargo seçeneğimiz mevcuttur.',
                    style: Canvas701Typography.bodyMedium,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: Canvas701Spacing.md),
                  child: Text(
                    'Ürününüzü teslim aldığınız tarihten itibaren 14 gün içerisinde iade edebilirsiniz. Kişiye özel ürünlerde iade kabul edilmemektedir.',
                    style: Canvas701Typography.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedProducts() {
    final related = Canvas701Data.bestsellers.take(4).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Benzer Ürünler', style: Canvas701Typography.titleLarge),
        const SizedBox(height: Canvas701Spacing.md),
        SizedBox(
          height: 360, // Ürün kartı yüksekliği için yeterli alan (347px + padding)
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: related.length,
            separatorBuilder: (_, __) => const SizedBox(width: Canvas701Spacing.md),
            itemBuilder: (context, index) {
              return SizedBox(
                width: 180,
                child: ProductCard(
                  product: related[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailPage(product: related[index]),
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
  }
}
