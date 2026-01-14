import 'package:cached_network_image/cached_network_image.dart';
import 'package:canvas701/canvas701/theme/canvas701_theme_data.dart';
import 'package:canvas701/canvas701/viewmodel/favorites_viewmodel.dart';
import 'package:canvas701/canvas701/viewmodel/general_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../model/model.dart';
import '../../viewmodel/product_viewmodel.dart';
import '../widgets/widgets.dart';
import '../../services/cart_service.dart';
import '../../model/product_models.dart';

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
  String? _selectedType;
  int _quantity = 1;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.product.availableSizes.first;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Sayfa her açıldığında seçimleri sıfırla ki build içinde tekrar hesaplansın
      setState(() {
        _selectedType = null;
        _selectedSize = null;
      });

      context.read<ProductViewModel>().fetchProductDetail(
        int.parse(widget.product.id),
      );
      context.read<GeneralViewModel>().fetchProductTypes();
    });
  }

  Future<void> _addToBasket() async {
    if (_selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir boyut seçin'),
          backgroundColor: Canvas701Colors.error,
        ),
      );
      return;
    }

    String variant = '';
    if (_selectedSize is ApiProductSize) {
      variant = (_selectedSize as ApiProductSize).sizeName;
    } else if (_selectedSize is ProductSize) {
      variant = (_selectedSize as ProductSize).name;
    }

    setState(() => _isAddingToCart = true);

    try {
      final response = await CartService().addToBasket(
        productId: int.parse(widget.product.id),
        variant: variant,
        quantity: _quantity,
      );

      if (mounted) {
        if (response.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Ürün sepete eklendi'),
              backgroundColor: Canvas701Colors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Bir hata oluştu'),
              backgroundColor: Canvas701Colors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bağlantı hatası oluştu'),
            backgroundColor: Canvas701Colors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProductViewModel, GeneralViewModel>(
      builder: (context, viewModel, generalViewModel, child) {
        final productDetail = viewModel.selectedProduct;

        // Önerilen tablo tipini ve ilk boyutu otomatik seç
        // productId kontrolü ekleyerek her ürün için ayrı hesaplanmasını sağla
        if (productDetail != null &&
            productDetail.productID.toString() == widget.product.id &&
            _selectedType == null &&
            generalViewModel.productTypes.isNotEmpty) {
          final availableTypes =
              productDetail.sizes
                  .map((s) => s.sizeTableType)
                  .where((t) => t.isNotEmpty)
                  .toSet();

          if (availableTypes.isNotEmpty) {
            final recommendedType = productDetail.productTableType;
            if (recommendedType.isNotEmpty &&
                availableTypes.contains(recommendedType)) {
              _selectedType = recommendedType;
            } else {
              _selectedType = availableTypes.first;
            }

            // Seçilen tipe ait ilk boyutu da seç
            _selectedSize = productDetail.sizes.firstWhere(
              (s) => s.sizeTableType == _selectedType,
              orElse: () => productDetail.sizes.first,
            );
          }
        }

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
                scrolledUnderElevation: 0,
                leadingWidth: 56,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Center(
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white.withOpacity(0.9),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.black,
                          size: 16,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ),
                actions: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: IconButton(
                      icon: const Icon(
                        Icons.share_outlined,
                        color: Colors.black,
                        size: 18,
                      ),
                      onPressed: () {
                        if (productDetail?.productLink != null &&
                            productDetail!.productLink.isNotEmpty) {
                          Share.share(
                            '${productDetail.productName}\n${productDetail.productLink}',
                            subject: productDetail.productName,
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white.withOpacity(0.9),
                      child: Consumer<FavoritesViewModel>(
                        builder: (context, favViewModel, child) {
                          final isFav = favViewModel
                              .isFavorite(int.parse(widget.product.id));
                          return IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_outline,
                              color: isFav ? Colors.red : Colors.black,
                              size: 18,
                            ),
                            onPressed: () => favViewModel
                                .toggleFavorite(int.parse(widget.product.id)),
                          );
                        },
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
                    productName: productDetail?.productName ?? widget.product.name,
                    productLink: productDetail?.productLink,
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBreadcrumbs(productDetail),
                      const SizedBox(height: 20),
                      ProductInfoSection(
                        productDetail: productDetail,
                        selectedSize: _selectedSize,
                        fallbackName: widget.product.name,
                        fallbackCode: widget.product.code,
                      ),
                      const SizedBox(height: 32),
                      _buildTypeSelection(productDetail, generalViewModel),
                      const SizedBox(height: 24),
                      _buildSizeSelection(productDetail),
                      const SizedBox(height: 32),
                      _buildCargoInfo(productDetail),
                      const SizedBox(height: 40),
                      ProductDescriptionTabs(
                        productDetail: productDetail,
                        fallbackDescription: widget.product.description,
                      ),
                      const SizedBox(height: 40),
                      _buildRelatedProducts(viewModel),
                      const SizedBox(height: 120), // Space for bottom bar
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
        Text(
          'Anasayfa',
          style: Canvas701Typography.labelSmall.copyWith(
            color: Canvas701Colors.textTertiary,
            fontSize: 10,
          ),
        ),
        const Icon(
          Icons.chevron_right,
          size: 10,
          color: Canvas701Colors.textTertiary,
        ),
        Text(
          productDetail?.categories?.name ?? 'Kanvas Tablolar',
          style: Canvas701Typography.labelSmall.copyWith(
            color: Canvas701Colors.textTertiary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildCargoInfo(ApiProductDetail? productDetail) {
    if (productDetail == null || productDetail.cargoInfo.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Canvas701Colors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_shipping_outlined,
            color: Canvas701Colors.textPrimary,
            size: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productDetail.cargoInfo,
                  style: Canvas701Typography.labelSmall.copyWith(
                    color: Canvas701Colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (productDetail.cargoDetail.isNotEmpty)
                  Text(
                    productDetail.cargoDetail,
                    style: Canvas701Typography.labelSmall.copyWith(
                      color: Canvas701Colors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelection(
    ApiProductDetail? productDetail,
    GeneralViewModel generalViewModel,
  ) {
    if (productDetail == null) return const SizedBox.shrink();

    if (generalViewModel.productTypes.isEmpty) {
      return const SizedBox.shrink();
    }

    // Üründe mevcut olan tipleri bul
    final availableTypesInProduct =
        productDetail.sizes
            .map((s) => s.sizeTableType)
            .where((t) => t.isNotEmpty)
            .toSet();

    if (availableTypesInProduct.isEmpty) return const SizedBox.shrink();

    // Sadece üründe olan tipleri filtrele
    final typesToShow =
        generalViewModel.productTypes
            .where((t) => availableTypesInProduct.contains(t.typeName))
            .toList();

    if (typesToShow.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tablo Tipi',
          style: Canvas701Typography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: typesToShow.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final type = typesToShow[index];
              final isSelected = _selectedType == type.typeName;
              final isRecommended =
                  type.typeName == productDetail.productTableType;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedType = type.typeName;
                    // Tip değişince o tipe ait ilk boyutu seç
                    final firstSizeOfType = productDetail.sizes.firstWhere(
                      (s) => s.sizeTableType == type.typeName,
                      orElse: () => productDetail.sizes.first,
                    );
                    _selectedSize = firstSizeOfType;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: isSelected ? Canvas701Colors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isSelected
                              ? Canvas701Colors.primary
                              : isRecommended
                                  ? Canvas701Colors.primary.withOpacity(0.3)
                                  : Canvas701Colors.border,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Text(
                        type.typeName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color:
                              isSelected
                                  ? Colors.white
                                  : Canvas701Colors.textPrimary,
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.star,
                          size: 12,
                          color: isSelected ? Colors.white : Canvas701Colors.primary,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (_selectedType != null &&
            productDetail.productTableType.isNotEmpty &&
            _selectedType != productDetail.productTableType)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.amber.shade900,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Önerilen tip dışındaki seçimlerde görselde kadraj kayması veya kalite kaybı oluşabilir.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSizeSelection(ApiProductDetail? productDetail) {
    List<dynamic> sizes = productDetail?.sizes ?? widget.product.availableSizes;

    // Seçili tip varsa ona göre filtrele
    if (productDetail != null && _selectedType != null) {
      sizes =
          productDetail.sizes
              .where((s) => s.sizeTableType == _selectedType)
              .toList();
    }

    if (sizes.isEmpty) return const SizedBox.shrink();

    // Otomatik seçim: Hiç seçim yoksa veya detay verisi gelmişse
    // ama se&ccedil;ili olan hala eski modelden gelen veri ise ilkini seç.
    if (_selectedSize == null ||
        (productDetail != null && _selectedSize is! ApiProductSize)) {
      _selectedSize = sizes.first;
    }

    // Eğer seçili boyut şu anki listede yoksa ilkini seç (Tip değişince gerekebilir)
    if (_selectedSize is ApiProductSize &&
        !sizes.any((s) => s is ApiProductSize && s.sizeID == (_selectedSize as ApiProductSize).sizeID)) {
      _selectedSize = sizes.first;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ölçü Seçimi',
          style: Canvas701Typography.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sizes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final size = sizes[index];
              bool isSelected = false;
              String name = '';
              String price = '';

              if (size is ApiProductSize) {
                isSelected =
                    _selectedSize is ApiProductSize &&
                    (_selectedSize as ApiProductSize).sizeID == size.sizeID;
                name = size.sizeName;
                price = size.sizePrice;
              } else if (size is ProductSize) {
                isSelected =
                    _selectedSize is ProductSize &&
                    (_selectedSize as ProductSize).id == size.id;
                name = size.name;
                price =
                    '${size.price.toStringAsFixed(2).replaceAll('.', ',')} TL';
              }

              return GestureDetector(
                onTap: () => setState(() => _selectedSize = size),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? Canvas701Colors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? Canvas701Colors.primary
                          : Canvas701Colors.border,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$name\n',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: price,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Canvas701Colors.textPrimary,
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Canvas701Colors.divider, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: Canvas701Colors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 16),
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                  ),
                  Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 16),
                    onPressed: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isAddingToCart ? null : _addToBasket,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Canvas701Colors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: _isAddingToCart
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'SEPETE EKLE',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          fontSize: 14,
                        ),
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
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 350,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: relatedItems.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final apiProduct = relatedItems[index];
              final product = Product.fromApi(apiProduct);
              return Consumer<FavoritesViewModel>(
                builder: (context, favViewModel, child) {
                  final isFav = favViewModel.isFavorite(apiProduct.productID);
                  return SizedBox(
                    width: 170, // Slightly reduced width
                    child: ProductCard(
                      product: product,
                      isFavorite: isFav,
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
                        favViewModel.toggleFavorite(apiProduct.productID);
                      },
                    ),
                  );
                },
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
  final String? productName;
  final String? productLink;

  const ProductImageGallery({
    super.key,
    required this.images,
    required this.heroTag,
    this.hasDiscount = false,
    this.productName,
    this.productLink,
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
                  productName: widget.productName,
                  productLink: widget.productLink,
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

    if (selectedSize != null) {
      if (selectedSize is ApiProductSize) {
      } else if (selectedSize is ProductSize) {
        // Fallback for ProductSize model
      }
    } else if (productDetail != null) {
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (productDetail != null && productDetail!.totalComments > 0) ...[
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 14),
              const SizedBox(width: 4),
              Text(
                '${productDetail!.rating} (${productDetail!.totalComments} Değerlendirme)',
                style: Canvas701Typography.labelSmall.copyWith(
                  color: Canvas701Colors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Text(
          productDetail?.productName ?? fallbackName,
          style: Canvas701Typography.displaySmall.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            height: 1.3,
            color: Canvas701Colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ürün Kodu: ${productDetail?.productCode ?? fallbackCode}',
                  style: Canvas701Typography.labelSmall.copyWith(
                    color: Canvas701Colors.textTertiary,
                    fontSize: 10,
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
                              width: 12,
                              height: 12,
                            ),
                          ),
                        Text(
                          productDetail!.productDiscount,
                          style: Canvas701Typography.labelSmall.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (productDetail != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: productDetail!.productStock > 0
                      ? Colors.green.withOpacity(0.05)
                      : Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: productDetail!.productStock > 0
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      productDetail!.productStock > 0
                          ? Icons.check_circle
                          : Icons.error,
                      size: 10,
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
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? Canvas701Colors.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive
                ? Canvas701Colors.primary
                : Canvas701Colors.textTertiary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
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
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => FullScreenImageViewer.open(
                  context,
                  [widget.productDetail!.productFeaturedImage],
                  productName: widget.productDetail?.productName,
                  productLink: widget.productDetail?.productLink,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
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
        fontSize: 13,
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
          style: Canvas701Typography.bodyMedium.copyWith(fontSize: 13),
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
          style: Canvas701Typography.bodyMedium.copyWith(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Canvas701Colors.primary, size: 18),
        const SizedBox(width: 8),
        Text(
          title, 
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
