import 'package:cached_network_image/cached_network_image.dart';
import 'package:canvas701/canvas701/theme/canvas701_theme_data.dart';
import 'package:flutter/material.dart';
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
  Object? _selectedSize;
  int _quantity = 1;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.product.availableSizes.first;
    _isFavorite = widget.product.isFavorite;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductViewModel>().fetchProductDetail(
        int.parse(widget.product.id),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductViewModel>(
      builder: (context, viewModel, child) {
        final productDetail = viewModel.selectedProduct;
        final images =
            productDetail?.galleries.map((g) => g.img).toList() ??
            widget.product.images;

        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              // Modern AppBar with Gallery
              SliverAppBar(
                expandedHeight: 340,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      child: IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_outline,
                          color: _isFavorite ? Colors.red : Colors.black,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _isFavorite = !_isFavorite),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: ProductImageGallery(
                    images: images,
                    heroTag: 'product_${widget.product.id}',
                    hasDiscount:
                        productDetail != null &&
                        productDetail.productPriceDiscount != '0,00 TL',
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBreadcrumbs(productDetail),
                      const SizedBox(height: 16),
                      ProductInfoSection(
                        productDetail: productDetail,
                        selectedSize: _selectedSize,
                        fallbackName: widget.product.name,
                        fallbackCode: widget.product.code,
                      ),
                      const SizedBox(height: 32),
                      _buildSizeSelection(productDetail),
                      const SizedBox(height: 32),
                      ProductDescriptionTabs(
                        productDetail: productDetail,
                        fallbackDescription: widget.product.description,
                      ),
                      const SizedBox(height: 32),
                      _buildRelatedProducts(viewModel),
                      const SizedBox(height: 100), // Space for bottom bar
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomSheet: _buildBottomActionSheet(productDetail),
        );
      },
    );
  }

  Widget _buildBreadcrumbs(ApiProductDetail? productDetail) {
    return Row(
      children: [
        Text('Anasayfa', style: Canvas701Typography.labelSmall),
        const Icon(
          Icons.chevron_right,
          size: 12,
          color: Canvas701Colors.textTertiary,
        ),
        Text(
          productDetail?.categories?.name ?? 'Kanvas Tablolar',
          style: Canvas701Typography.labelSmall,
        ),
      ],
    );
  }

  Widget _buildSizeSelection(ApiProductDetail? productDetail) {
    final List<dynamic> sizes =
        productDetail?.sizes ?? widget.product.availableSizes;

    if (sizes.isEmpty) return const SizedBox.shrink();

    // Otomatik seçim: Hiç seçim yoksa veya detay verisi gelmişse
    // ama se&ccedil;ili olan hala eski modelden gelen veri ise ilkini seç.
    if (_selectedSize == null ||
        (productDetail != null && _selectedSize is! ApiProductSize)) {
      _selectedSize = sizes.first;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ölçü Seçimi',
          style: Canvas701Typography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 45,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sizes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final size = sizes[index];
              bool isSelected = false;
              String name = '';

              if (size is ApiProductSize) {
                isSelected =
                    _selectedSize is ApiProductSize &&
                    (_selectedSize as ApiProductSize).sizeID == size.sizeID;
                name = size.sizeName;
              } else if (size is ProductSize) {
                isSelected =
                    _selectedSize is ProductSize &&
                    (_selectedSize as ProductSize).id == size.id;
                name = size.name;
              }

              return GestureDetector(
                onTap: () => setState(() => _selectedSize = size),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Canvas701Colors.primary
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Canvas701Colors.primary
                          : Colors.grey[200]!,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionSheet(ApiProductDetail? productDetail) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                  ),
                  Text(
                    '$_quantity',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${productDetail?.productName ?? widget.product.name} sepete eklendi!',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Canvas701Colors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'SEPETE EKLE',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedProducts(ProductViewModel viewModel) {
    if (viewModel.isDetailLoading && viewModel.similarProducts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final relatedItems = viewModel.similarProducts;
    if (relatedItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Benzer Ürünler',
          style: Canvas701Typography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 360,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: relatedItems.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final product = Product.fromApi(relatedItems[index]);
              return SizedBox(
                width: 180, // Card original width is 180
                child: ProductCard(
                  product: product,
                  isFavorite: product.isFavorite,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductDetailPage(product: product),
                      ),
                    );
                  },
                  onFavorite: () {
                    // Favori işlemleri eklenebilir
                  },
                  onAddToCart: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} sepete eklendi!'),
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

// --- Product Widgets ---

class ProductImageGallery extends StatefulWidget {
  final List<String> images;
  final String heroTag;
  final bool hasDiscount;

  const ProductImageGallery({
    super.key,
    required this.images,
    required this.heroTag,
    this.hasDiscount = false,
  });

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Container(
        height: 400,
        color: Colors.grey[100],
        child: const Icon(Icons.image_outlined, size: 100, color: Colors.grey),
      );
    }

    return Stack(
      children: [
        Hero(
          tag: widget.heroTag,
          child: PageView.builder(
            itemCount: widget.images.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => FullScreenImageViewer.open(
                  context,
                  widget.images,
                  index: index,
                ),
                child: CachedNetworkImage(
                  imageUrl: widget.images[index],
                  fit: BoxFit.contain,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.image_outlined, size: 100),
                ),
              );
            },
          ),
        ),
        if (widget.hasDiscount)
          Positioned(
            top: 100,
            left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: const Text(
                'İNDİRİM',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        // Indicator
        if (widget.images.length > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.images.asMap().entries.map((entry) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentIndex == entry.key ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentIndex == entry.key
                        ? Canvas701Colors.primary
                        : Canvas701Colors.primary.withOpacity(0.2),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class ProductInfoSection extends StatelessWidget {
  final ApiProductDetail? productDetail;
  final dynamic selectedSize;
  final String fallbackName;
  final String fallbackCode;

  const ProductInfoSection({
    super.key,
    this.productDetail,
    this.selectedSize,
    required this.fallbackName,
    required this.fallbackCode,
  });

  @override
  Widget build(BuildContext context) {
    String currentPrice = '';
    String? oldPrice;

    if (selectedSize != null) {
      if (selectedSize is ApiProductSize) {
        final size = selectedSize as ApiProductSize;
        currentPrice = size.sizePriceDiscount != '0,00 TL'
            ? size.sizePriceDiscount
            : size.sizePrice;
        oldPrice = size.sizePriceDiscount != '0,00 TL' ? size.sizePrice : null;
      } else if (selectedSize is ProductSize) {
        // Fallback for ProductSize model
        final size = selectedSize as ProductSize;
        currentPrice =
            '${size.price.toStringAsFixed(2).replaceAll('.', ',')} TL';
      }
    } else if (productDetail != null) {
      currentPrice = productDetail!.productPriceDiscount != '0,00 TL'
          ? productDetail!.productPriceDiscount
          : productDetail!.productPrice;
      oldPrice = productDetail!.productPriceDiscount != '0,00 TL'
          ? productDetail!.productPrice
          : null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (productDetail != null && productDetail!.totalComments > 0) ...[
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text(
                '${productDetail!.rating} (${productDetail!.totalComments} Değerlendirme)',
                style: Canvas701Typography.labelSmall.copyWith(
                  color: Canvas701Colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: Canvas701Spacing.sm),
        ],
        Text(
          productDetail?.productName ?? fallbackName,
          style: Canvas701Typography.displaySmall.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            height: 1.2,
          ),
        ),
        const SizedBox(height: Canvas701Spacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ürün Kodu: ${productDetail?.productID ?? fallbackCode}',
                  style: Canvas701Typography.labelSmall.copyWith(
                    color: Canvas701Colors.textTertiary,
                  ),
                ),
                if (productDetail != null &&
                    productDetail!.productDiscount.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        if (productDetail!.productDiscountIcon.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: Image.network(
                              productDetail!.productDiscountIcon,
                              width: 14,
                              height: 14,
                            ),
                          ),
                        Text(
                          productDetail!.productDiscount,
                          style: Canvas701Typography.labelSmall.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (productDetail != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: productDetail!.productStock > 0
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      productDetail!.productStock > 0
                          ? Icons.check_circle
                          : Icons.error,
                      size: 12,
                      color: productDetail!.productStock > 0
                          ? Colors.green
                          : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      productDetail!.productStock > 0
                          ? 'Stokta Var'
                          : 'Stokta Yok',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: productDetail!.productStock > 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: Canvas701Spacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              currentPrice,
              style: Canvas701Typography.displaySmall.copyWith(
                color: Canvas701Colors.primary,
                fontWeight: FontWeight.w900,
                fontSize: 28,
              ),
            ),
            if (oldPrice != null) ...[
              const SizedBox(width: Canvas701Spacing.sm),
              Text(
                oldPrice,
                style: Canvas701Typography.bodyMedium.copyWith(
                  color: Canvas701Colors.textTertiary,
                  decoration: TextDecoration.lineThrough,
                  fontSize: 16,
                ),
              ),
            ],
          ],
        ),
        if (productDetail != null && productDetail!.cargoInfo.isNotEmpty) ...[
          const SizedBox(height: Canvas701Spacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_shipping_outlined,
                  color: Colors.orange,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productDetail!.cargoInfo,
                        style: Canvas701Typography.labelSmall.copyWith(
                          color: Colors.orange[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (productDetail!.cargoDetail.isNotEmpty)
                        Text(
                          productDetail!.cargoDetail,
                          style: Canvas701Typography.labelSmall.copyWith(
                            color: Colors.orange[700],
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class ProductDescriptionTabs extends StatefulWidget {
  final ApiProductDetail? productDetail;
  final String fallbackDescription;

  const ProductDescriptionTabs({
    super.key,
    this.productDetail,
    required this.fallbackDescription,
  });

  @override
  State<ProductDescriptionTabs> createState() => _ProductDescriptionTabsState();
}

class _ProductDescriptionTabsState extends State<ProductDescriptionTabs> {
  int _activeTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildTabItem(0, 'Özellikler'),
            _buildTabItem(1, 'Teslimat'),
            _buildTabItem(2, 'İade'),
          ],
        ),
        const Divider(height: 1),
        const SizedBox(height: Canvas701Spacing.md),
        _buildActiveContent(),
      ],
    );
  }

  Widget _buildTabItem(int index, String title) {
    final isActive = _activeTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTabIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveContent() {
    switch (_activeTabIndex) {
      case 0:
        String description =
            widget.productDetail?.cleanedDescription ??
            _cleanHtml(widget.fallbackDescription);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextContent(description),
            if (widget.productDetail?.productFeaturedImage != null &&
                widget.productDetail!.productFeaturedImage.isNotEmpty) ...[
              const SizedBox(height: Canvas701Spacing.lg),
              GestureDetector(
                onTap: () => FullScreenImageViewer.open(context, [
                  widget.productDetail!.productFeaturedImage,
                ]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.productDetail!.productFeaturedImage,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ],
        );
      case 1:
        return _buildDeliveryContent();
      case 2:
        return _buildReturnContent();
      default:
        return const SizedBox.shrink();
    }
  }

  String _cleanHtml(String html) {
    if (html.isEmpty) return '';
    return html
        .replaceAll('<p>', '')
        .replaceAll('</p>', '\n\n')
        .replaceAll('<br>', '\n')
        .replaceAll('<br />', '\n')
        .replaceAll('&bull;', '•')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();
  }

  Widget _buildTextContent(String text) {
    return Text(
      text,
      style: Canvas701Typography.bodyMedium.copyWith(
        height: 1.6,
        color: Canvas701Colors.textPrimary,
      ),
    );
  }

  Widget _buildDeliveryContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          Icons.local_shipping_outlined,
          widget.productDetail?.cargoInfo ?? 'Hızlı Teslimat',
        ),
        const SizedBox(height: 12),
        Text(
          widget.productDetail?.cargoDetail ??
              'Siparişleriniz en kısa sürede kargoya teslim edilir.',
          style: Canvas701Typography.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildReturnContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          Icons.assignment_return_outlined,
          '14 Gün İade Garantisi',
        ),
        const SizedBox(height: 12),
        Text(
          'Ürününüzü teslim aldığınız tarihten itibaren 14 gün içerisinde iade edebilirsiniz. Ambalajı açılmamış ve zarar görmemiş ürünler kabul edilmektedir.',
          style: Canvas701Typography.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Canvas701Colors.primary, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
