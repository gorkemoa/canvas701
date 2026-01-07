import 'package:flutter/material.dart';
import '../../api/cart_service.dart';
import '../../api/product_service.dart';
import '../../model/product_models.dart';
import '../../theme/canvas701_theme_data.dart';

/// Boyut Seçimi Bottom Sheet
/// 
/// Ürün detayından boyutları çeker ve kullanıcıya seçim yaptırır.
/// Seçim yapıldığında sepete ekleme API'sine istek atar.
class SizeSelectionBottomSheet extends StatefulWidget {
  final int productId;
  final String productName;
  final String productImage;

  const SizeSelectionBottomSheet({
    super.key,
    required this.productId,
    required this.productName,
    required this.productImage,
  });

  /// Bottom sheet'i göster
  static Future<bool?> show(
    BuildContext context, {
    required int productId,
    required String productName,
    required String productImage,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SizeSelectionBottomSheet(
        productId: productId,
        productName: productName,
        productImage: productImage,
      ),
    );
  }

  @override
  State<SizeSelectionBottomSheet> createState() =>
      _SizeSelectionBottomSheetState();
}

class _SizeSelectionBottomSheetState extends State<SizeSelectionBottomSheet> {
  bool _isLoading = true;
  bool _isAddingToCart = false;
  String? _errorMessage;
  List<ApiProductSize> _sizes = [];
  ApiProductSize? _selectedSize;

  @override
  void initState() {
    super.initState();
    _loadProductSizes();
  }

  Future<void> _loadProductSizes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ProductService().getProductDetail(widget.productId);

      if (response.success && response.data?.product != null) {
        setState(() {
          _sizes = response.data!.product!.sizes;
          _isLoading = false;
          // İlk boyutu varsayılan olarak seç
          if (_sizes.isNotEmpty) {
            _selectedSize = _sizes.first;
          }
        });
      } else {
        setState(() {
          _errorMessage = 'Ürün bilgileri yüklenemedi.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Bir hata oluştu. Lütfen tekrar deneyin.';
        _isLoading = false;
      });
    }
  }

  Future<void> _addToCart() async {
    if (_selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen bir boyut seçin'),
          backgroundColor: Canvas701Colors.error,
        ),
      );
      return;
    }

    setState(() {
      _isAddingToCart = true;
    });

    try {
      final response = await CartService().addToBasket(
        productId: widget.productId,
        variant: _selectedSize!.sizeName,
        quantity: 1,
      );

      if (response.success) {
        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Ürün sepete eklendi'),
              backgroundColor: Canvas701Colors.success,
            ),
          );
        }
      } else {
        if (mounted) {
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
            content: Text('Bağlantı hatası. Lütfen tekrar deneyin.'),
            backgroundColor: Canvas701Colors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  double _parsePrice(String price) {
    return double.tryParse(
          price.replaceAll(' TL', '').replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Canvas701Colors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Canvas701Radius.xl),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            _buildHeader(),
            if (_isLoading)
              _buildLoading()
            else if (_errorMessage != null)
              _buildError()
            else
              _buildSizeList(),
            _buildAddToCartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: Canvas701Spacing.sm),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Canvas701Colors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(Canvas701Spacing.md),
      child: Row(
        children: [
          // Ürün görseli
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Canvas701Radius.sm),
              color: Canvas701Colors.surfaceVariant,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Canvas701Radius.sm),
              child: Image.network(
                widget.productImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_outlined,
                  color: Canvas701Colors.textTertiary,
                ),
              ),
            ),
          ),
          const SizedBox(width: Canvas701Spacing.md),
          // Ürün bilgisi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.productName,
                  style: Canvas701Typography.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Canvas701Spacing.xxs),
                Text(
                  'Boyut Seçin',
                  style: Canvas701Typography.bodySmall.copyWith(
                    color: Canvas701Colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Kapat butonu
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close,
              color: Canvas701Colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.all(Canvas701Spacing.xxl),
      child: Center(
        child: CircularProgressIndicator(
          color: Canvas701Colors.primary,
        ),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.all(Canvas701Spacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Canvas701Colors.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(height: Canvas701Spacing.md),
          Text(
            _errorMessage!,
            style: Canvas701Typography.bodyMedium.copyWith(
              color: Canvas701Colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Canvas701Spacing.md),
          TextButton(
            onPressed: _loadProductSizes,
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeList() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: Canvas701Spacing.md),
        itemCount: _sizes.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: Canvas701Spacing.xs),
        itemBuilder: (context, index) {
          final size = _sizes[index];
          final isSelected = _selectedSize?.sizeID == size.sizeID;
          final price = _parsePrice(size.sizePrice);
          final hasDiscount = size.sizeDiscountType > 0;
          final discountPrice = hasDiscount ? _parsePrice(size.sizePriceDiscount) : null;

          return GestureDetector(
            onTap: () => setState(() => _selectedSize = size),
            child: Container(
              padding: const EdgeInsets.all(Canvas701Spacing.md),
              decoration: BoxDecoration(
                color: isSelected
                    ? Canvas701Colors.primary.withOpacity(0.08)
                    : Canvas701Colors.surfaceVariant,
                borderRadius: BorderRadius.circular(Canvas701Radius.md),
                border: Border.all(
                  color: isSelected
                      ? Canvas701Colors.primary
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  // Seçim indikatörü
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Canvas701Colors.primary
                            : Canvas701Colors.border,
                        width: 2,
                      ),
                      color: isSelected
                          ? Canvas701Colors.primary
                          : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: Canvas701Spacing.md),
                  // Boyut adı
                  Expanded(
                    child: Text(
                      size.sizeName,
                      style: Canvas701Typography.titleMedium.copyWith(
                        color: isSelected
                            ? Canvas701Colors.primary
                            : Canvas701Colors.textPrimary,
                      ),
                    ),
                  ),
                  // Fiyat
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₺${price.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: Canvas701Typography.price.copyWith(
                          fontSize: 16,
                          color: isSelected
                              ? Canvas701Colors.primary
                              : Canvas701Colors.textPrimary,
                        ),
                      ),
                      if (hasDiscount && discountPrice != null && discountPrice > 0)
                        Text(
                          '₺${discountPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: Canvas701Typography.discountPrice.copyWith(
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddToCartButton() {
    final isDisabled = _isLoading || _selectedSize == null || _isAddingToCart;
    final price = _selectedSize != null ? _parsePrice(_selectedSize!.sizePrice) : 0.0;

    return Padding(
      padding: const EdgeInsets.all(Canvas701Spacing.md),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isDisabled ? null : _addToCart,
          style: ElevatedButton.styleFrom(
            backgroundColor: Canvas701Colors.primary,
            foregroundColor: Canvas701Colors.textOnPrimary,
            disabledBackgroundColor: Canvas701Colors.border,
            disabledForegroundColor: Canvas701Colors.textTertiary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Canvas701Radius.md),
            ),
          ),
          child: _isAddingToCart
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 20),
                    const SizedBox(width: Canvas701Spacing.xs),
                    Text(
                      _selectedSize != null
                          ? 'Sepete Ekle - ₺${price.toStringAsFixed(2).replaceAll('.', ',')}'
                          : 'Sepete Ekle',
                      style: Canvas701Typography.button,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
