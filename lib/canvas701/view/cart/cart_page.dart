import 'package:canvas701/canvas701/api/cart_service.dart';
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
    _fetchBaskets();
  }

  Future<void> _fetchBaskets() async {
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Canvas701Colors.textTertiary.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          const Text('Sepetiniz Boş', style: Canvas701Typography.headlineMedium),
          const SizedBox(height: 12),
          Text(
            'Henüz sepetinize ürün eklemediniz.',
            style: Canvas701Typography.bodyMedium.copyWith(
              color: Canvas701Colors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Canvas701Colors.primary,
              foregroundColor: Canvas701Colors.textOnPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: Canvas701Spacing.xl,
                vertical: Canvas701Spacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Canvas701Radius.sm),
              ),
              elevation: 0,
            ),
            child: const Text('Alışverişe Başla'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return RefreshIndicator(
      onRefresh: _fetchBaskets,
      color: Canvas701Colors.primary,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          ..._basketData!.baskets.map(
            (item) => _CartItemTile(
              item: item,
              onRefresh: _fetchBaskets,
            ),
          ),
          const SizedBox(height: 24),
          _buildOrderSummary(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ödeme Detayı', style: Canvas701Typography.labelLarge),
         
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Canvas701Colors.divider, thickness: 1),
          ),
          const SizedBox(height: 4),
          _buildSummaryRow('Sepet Toplamı', _basketData!.cartTotal),
           const SizedBox(height: 4),

          // Ara Toplam
          _buildSummaryRow('Ara Toplam', _basketData!.subtotal),
          const SizedBox(height: 4),
          
          _buildSummaryRow('KDV (${_basketData!.vatRate})', _basketData!.vatAmount),
          const SizedBox(height: 4),

          // Kargo
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
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
                    ? Container(
                      

                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_shipping_outlined,
                              size: 14,
                              color: Canvas701Colors.success,
                            ),
                            const SizedBox(width: 6),
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
                        ),
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
              padding: const EdgeInsets.only(bottom: 4),
              child: _buildSummaryRow(
                'İndirim',
                '-${_basketData!.discountAmount}',
                valueColor: Canvas701Colors.success,
              ),
            ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Canvas701Colors.divider, thickness: 1),
          ),
          
          // Toplam
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Toplam (${_basketData!.totalItems} ürün)',
                style: Canvas701Typography.headlineSmall,
              ),
              Text(
                _basketData!.grandTotal,
                style: Canvas701Typography.price.copyWith(fontSize: 20),
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
        20,
        10,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Canvas701Colors.favorite, Canvas701Colors.primary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(Canvas701Radius.xl),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // TODO: Ödeme sayfasına git
            },
            borderRadius: BorderRadius.circular(Canvas701Radius.xl),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Canvas701Spacing.md,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(Canvas701Spacing.xs),
                    decoration: BoxDecoration(
                      color: Canvas701Colors.surface.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(Canvas701Radius.md),
                    ),
                    child: const Icon(
                      Icons.local_shipping,
                      color: Canvas701Colors.textOnPrimary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: Canvas701Spacing.md),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Teslimat Hizmetini Seçin',
                          style: TextStyle(
                            color: Canvas701Colors.textOnPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _basketData!.grandTotal,
                          style: TextStyle(
                            color: Canvas701Colors.textOnPrimary.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: Canvas701Colors.surface.withOpacity(0.3),
                  ),
                  const SizedBox(width: Canvas701Spacing.md),
                  Container(
                    padding: const EdgeInsets.all(Canvas701Spacing.xxs),
                    decoration: const BoxDecoration(
                      color: Canvas701Colors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Canvas701Colors.favorite,
                      size: 16,
                    ),
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
  final VoidCallback onRefresh;

  const _CartItemTile({
    required this.item,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Canvas701Colors.surface,
        borderRadius: Canvas701Radius.cardRadius,
        boxShadow: [Canvas701Shadows.card],
      ),
      child: Row(
        children: [
          // Ürün Görseli
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Canvas701Colors.surfaceVariant,
              borderRadius: BorderRadius.circular(Canvas701Radius.lg),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Canvas701Radius.lg),
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
          const SizedBox(width: Canvas701Spacing.md),
          // Ürün Bilgileri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productTitle,
                  style: Canvas701Typography.titleLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Canvas701Spacing.xxs),
                Text(
                  item.variant,
                  style: Canvas701Typography.bodySmall.copyWith(
                    color: Canvas701Colors.textTertiary,
                  ),
                ),
                const SizedBox(height: Canvas701Spacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.unitPrice,
                      style: Canvas701Typography.price,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Canvas701Spacing.sm,
                        vertical: Canvas701Spacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: Canvas701Colors.surfaceVariant,
                        borderRadius: BorderRadius.circular(Canvas701Radius.md),
                      ),
                      child: Text(
                        'x${item.cartQuantity}',
                        style: Canvas701Typography.titleMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
