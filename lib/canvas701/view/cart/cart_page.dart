import 'package:canvas701/canvas701/services/cart_service.dart';
import 'package:canvas701/canvas701/services/product_service.dart';
import 'package:canvas701/canvas701/model/basket_models.dart';
import 'package:canvas701/canvas701/model/product_models.dart';
import 'package:flutter/material.dart';
import '../../theme/canvas701_theme_data.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cartService = CartService();

  bool _isLoading = true;
  String? _errorMessage;
  GetBasketsData? _basketData;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _cartService.getUserBaskets();

      if (response.success && response.data != null) {
        setState(() {
          _basketData = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Sepet yüklenemedi';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Bağlantı hatası oluştu';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchBaskets() async {
    try {
      final response = await _cartService.getUserBaskets();

      if (response.success && response.data != null) {
        setState(() {
          _basketData = response.data;
        });
      }
    } catch (e) {
      debugPrint('Error fetching baskets: $e');
    }
  }

  Future<void> _updateItem(
    int basketId,
    String variant,
    int quantity, {
    int isActive = 1,
  }) async {
    final response = await _cartService.updateBasket(
      basketId: basketId,
      variant: variant,
      quantity: quantity,
      isActive: isActive,
    );

    if (response.success) {
      await _fetchBaskets();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Hata oluştu')),
        );
      }
    }
  }

  Future<void> _toggleItemActive(
    int basketId,
    String variant,
    int quantity,
    bool currentActive,
  ) async {
    await _updateItem(
      basketId,
      variant,
      quantity,
      isActive: currentActive ? 0 : 1,
    );
  }

  Future<void> _deleteItem(int basketId) async {
    final response = await _cartService.deleteBasket(basketId: basketId);

    if (response.success) {
      await _fetchBaskets();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Ürün silinemedi')),
        );
      }
    }
  }

  Future<void> _clearBasket() async {
    final response = await _cartService.clearBasket();

    if (response.success) {
      await _fetchBaskets();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Sepet temizlenemedi')),
        );
      }
    }
  }

  bool get _isEmpty => _basketData == null || _basketData!.baskets.isEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Canvas701Colors.background,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Canvas701Colors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Canvas701Colors.surface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Sepetim',
          style: TextStyle(color: Canvas701Colors.textOnPrimary, fontSize: 18),
        ),
        actions: [
          if (!_isEmpty)
            IconButton(
              icon: const Icon(
                Icons.delete_sweep_outlined,
                color: Canvas701Colors.surface,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Sepeti Temizle'),
                    content: const Text(
                      'Sepetinizdeki tüm ürünler silinecek. Emin misiniz?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('İptal'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _clearBasket();
                        },
                        child: const Text(
                          'Temizle',
                          style: TextStyle(color: Canvas701Colors.error),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _isEmpty || _isLoading ? null : _buildCheckoutBar(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Canvas701Colors.primary),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Canvas701Colors.textTertiary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: Canvas701Typography.bodyMedium.copyWith(
                color: Canvas701Colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchBaskets,
              style: ElevatedButton.styleFrom(
                backgroundColor: Canvas701Colors.primary,
                foregroundColor: Canvas701Colors.textOnPrimary,
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      );
    }

    if (_isEmpty) {
      return _buildEmptyCart();
    }

    return _buildCartContent();
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Canvas701Colors.textTertiary.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sepetiniz Boş',
              style: Canvas701Typography.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Henüz sepetinize ürün eklemediniz.',
              style: Canvas701Typography.bodyMedium.copyWith(
                color: Canvas701Colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 180,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Canvas701Colors.primary,
                  foregroundColor: Canvas701Colors.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Canvas701Radius.md),
                  ),
                  elevation: 0,
                ),
                child: const Text('Alışverişe Başla'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent() {
    return RefreshIndicator(
      onRefresh: _fetchBaskets,
      color: Canvas701Colors.primary,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          ..._basketData!.baskets.map(
            (item) => _CartItemTile(
              item: item,
              onUpdate: _updateItem,
              onDelete: _deleteItem,
              onToggleActive: _toggleItemActive,
            ),
          ),
          const SizedBox(height: 16),
          _buildOrderSummary(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ödeme Detayı', style: Canvas701Typography.titleSmall),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Canvas701Colors.divider, thickness: 1),
          ),
          _buildSummaryRow('Sepet Toplamı', _basketData!.cartTotal),
          const SizedBox(height: 8),

          // Ara Toplam
          _buildSummaryRow('Ara Toplam', _basketData!.subtotal),
          const SizedBox(height: 8),

          _buildSummaryRow(
            'KDV (${_basketData!.vatRate})',
            _basketData!.vatAmount,
          ),
          const SizedBox(height: 8),

          // Kargo
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kargo',
                  style: Canvas701Typography.bodySmall.copyWith(
                    color: Canvas701Colors.textSecondary,
                  ),
                ),
                _basketData!.cargoPrice == '0,00 TL'
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_shipping_outlined,
                            size: 14,
                            color: Canvas701Colors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'ÜCRETSİZ',
                            style: Canvas701Typography.bodySmall.copyWith(
                              color: Canvas701Colors.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        _basketData!.cargoPrice,
                        style: Canvas701Typography.bodySmall.copyWith(
                          color: Canvas701Colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ],
            ),
          ),

          // İndirim
          if (_basketData!.discountAmount != '0,00 TL')
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildSummaryRow(
                'İndirim',
                '-${_basketData!.discountAmount}',
                valueColor: Canvas701Colors.success,
              ),
            ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Canvas701Colors.divider, thickness: 1),
          ),

          // Toplam
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Toplam (${_basketData!.activeItems} ürün)',
                style: Canvas701Typography.titleMedium,
              ),
              Text(
                _basketData!.grandTotal,
                style: Canvas701Typography.price.copyWith(fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Canvas701Typography.bodySmall.copyWith(
            color: Canvas701Colors.textSecondary,
          ),
        ),
        Text(
          value,
          style: Canvas701Typography.bodySmall.copyWith(
            color: valueColor ?? Canvas701Colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Canvas701Colors.favorite, Canvas701Colors.primary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(Canvas701Radius.lg),
          boxShadow: [
            BoxShadow(
              color: Canvas701Colors.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // TODO: Ödeme sayfasına git
            },
            borderRadius: BorderRadius.circular(Canvas701Radius.lg),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Canvas701Spacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ödemeye Geç',
                          style: TextStyle(
                            color: Canvas701Colors.textOnPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${_basketData!.activeItems} Ürün | ${_basketData!.grandTotal}',
                          style: TextStyle(
                            color: Canvas701Colors.textOnPrimary.withOpacity(
                              0.9,
                            ),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const VerticalDivider(
                    color: Colors.white24,
                    indent: 16,
                    endIndent: 16,
                    width: 32,
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Canvas701Colors.textOnPrimary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final BasketItem item;
  final Function(int, String, int, {int isActive}) onUpdate;
  final Function(int) onDelete;
  final Function(int, String, int, bool) onToggleActive;

  const _CartItemTile({
    required this.item,
    required this.onUpdate,
    required this.onDelete,
    required this.onToggleActive,
  });

  Future<void> _showSizePicker(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Canvas701Colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Canvas701Radius.xl),
        ),
      ),
      builder: (context) {
        return _CartSizePicker(
          productId: item.productID,
          currentVariant: item.variant,
          onSizeSelected: (newSize) {
            onUpdate(item.cartID, newSize, item.cartQuantity);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: item.isActive ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Canvas701Colors.surface,
          borderRadius: BorderRadius.circular(Canvas701Radius.md),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox for active/inactive
            Checkbox(
              value: item.isActive,
              onChanged: (value) => onToggleActive(
                item.cartID,
                item.variant,
                item.cartQuantity,
                item.isActive,
              ),
              activeColor: Canvas701Colors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            // Ürün Görseli
            Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                color: Canvas701Colors.surfaceVariant,
                borderRadius: BorderRadius.circular(Canvas701Radius.md),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Canvas701Radius.md),
                child: Image.network(
                  item.productImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.image_outlined,
                    color: Canvas701Colors.textTertiary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Ürün Bilgileri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.productTitle,
                          style: Canvas701Typography.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: Canvas701Colors.textTertiary,
                        ),
                        onPressed: () => onDelete(item.cartID),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Ölçü Değiştirme
                  InkWell(
                    onTap: () => _showSizePicker(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Canvas701Colors.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.variant,
                            style: Canvas701Typography.bodySmall.copyWith(
                              color: Canvas701Colors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 12,
                            color: Canvas701Colors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item.unitPrice,
                        style: Canvas701Typography.priceSmall.copyWith(
                          fontSize: 15,
                        ),
                      ),

                      // Adet Kontrolü
                      Container(
                        height: 32,
                        decoration: BoxDecoration(
                          border: Border.all(color: Canvas701Colors.divider),
                          borderRadius: BorderRadius.circular(
                            Canvas701Radius.sm,
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildQuantityBtn(
                              icon: Icons.remove,
                              onPressed: () {
                                if (item.cartQuantity > 1) {
                                  onUpdate(
                                    item.cartID,
                                    item.variant,
                                    item.cartQuantity - 1,
                                  );
                                } else {
                                  onDelete(item.cartID);
                                }
                              },
                            ),
                            Text(
                              '${item.cartQuantity}',
                              style: Canvas701Typography.titleSmall,
                            ),
                            _buildQuantityBtn(
                              icon: Icons.add,
                              onPressed: () {
                                onUpdate(
                                  item.cartID,
                                  item.variant,
                                  item.cartQuantity + 1,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityBtn({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(Canvas701Radius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Icon(icon, size: 14, color: Canvas701Colors.textPrimary),
      ),
    );
  }
}

class _CartSizePicker extends StatefulWidget {
  final int productId;
  final String currentVariant;
  final Function(String) onSizeSelected;

  const _CartSizePicker({
    required this.productId,
    required this.currentVariant,
    required this.onSizeSelected,
  });

  @override
  State<_CartSizePicker> createState() => _CartSizePickerState();
}

class _CartSizePickerState extends State<_CartSizePicker> {
  final ProductService _productService = ProductService();
  bool _isLoading = true;
  List<ApiProductSize> _sizes = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSizes();
  }

  Future<void> _loadSizes() async {
    try {
      final response = await _productService.getProductDetail(widget.productId);
      if (response.success && response.data?.product != null) {
        setState(() {
          _sizes = response.data!.product!.sizes;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Ölçüler yüklenemedi';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Bağlantı hatası';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Canvas701Colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ölçü Seçin',
                    style: Canvas701Typography.headlineSmall,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Canvas701Colors.primary,
                  ),
                ),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Center(child: Text(_error!)),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: _sizes.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final size = _sizes[index];
                    final isSelected = widget.currentVariant == size.sizeName;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      title: Text(
                        size.sizeName,
                        style: Canvas701Typography.bodyLarge.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? Canvas701Colors.primary : null,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            size.sizePrice,
                            style: Canvas701Typography.bodyMedium.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.check_circle,
                              color: Canvas701Colors.primary,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        if (!isSelected) {
                          widget.onSizeSelected(size.sizeName);
                        }
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
