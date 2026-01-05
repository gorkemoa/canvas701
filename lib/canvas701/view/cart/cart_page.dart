import 'package:flutter/material.dart';
import '../../theme/canvas701_theme_data.dart';
import '../../model/cart.dart';
import '../../api/dummy_data.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Sepet verisi
  late Cart _cart;

  @override
  void initState() {
    super.initState();
    _initializeCart();
  }

  void _initializeCart() {
    // Dummy verilerden ilk iki ürünü sepete ekleyelim
    final products = Canvas701Data.bestsellers.take(2).toList();

    final items = products.map((product) {
      final size = product.availableSizes.first;
      return CartItem(
        productId: product.id,
        productCode: product.code,
        productName: product.name,
        productImage: product.images.first,
        sizeId: size.id,
        sizeName: size.name,
        unitPrice: size.price,
        quantity: 1,
      );
    }).toList();

    _cart = Cart(items: items);
  }

  void _updateQuantity(CartItem item, int delta) {
    setState(() {
      _cart = _cart.updateQuantity(
        item.productId,
        item.sizeId,
        item.quantity + delta,
      );
    });
  }

  void _removeItem(CartItem item) {
    setState(() {
      _cart = _cart.removeItem(item.productId, item.sizeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Canvas701Colors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Canvas701Colors.primary,
        elevation: 0,
        title: const Text('Sepet', style: TextStyle(color: Canvas701Colors.textOnPrimary, fontSize: 18)),
        centerTitle: true,
      ),
      body: _cart.isEmpty ? _buildEmptyCart() : _buildCartContent(),
      bottomNavigationBar: _cart.isEmpty ? null : _buildCheckoutBar(),
    );
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
          const Text(
            'Sepetiniz Boş',
            style: Canvas701Typography.headlineMedium,
          ),
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
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      children: [
        ..._cart.items.map(
          (item) => _CartItemTile(
            item: item,
            onIncrease: () => _updateQuantity(item, 1),
            onDecrease: () => _updateQuantity(item, -1),
            onRemove: () => _removeItem(item),
          ),
        ),
        const SizedBox(height: 24),
        _buildOrderSummary(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ödeme Detayı', style: Canvas701Typography.labelLarge),
          const SizedBox(height: 12),
          ..._cart.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.productName,
                    style: Canvas701Typography.bodySmall.copyWith(
                      color: Canvas701Colors.textTertiary,
                    ),
                  ),
                  Text(
                    '₺${item.totalPrice.toInt()}',
                    style: Canvas701Typography.bodySmall.copyWith(
                      color: Canvas701Colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Canvas701Colors.divider, thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Toplam (${_cart.itemCount} ürün)',
                style: Canvas701Typography.headlineSmall,
              ),
              Text(
                '₺${_cart.total.toInt()}',
                style: Canvas701Typography.price.copyWith(fontSize: 20),
              ),
            ],
          ),
        ],
      ),
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
                  const Expanded(
                    child: Text(
                      'Teslimat Hizmetini Seçin',
                      style: TextStyle(
                        color: Canvas701Colors.textOnPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
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
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
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
              child: Image.network(item.productImage, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: Canvas701Spacing.md),
          // Ürün Bilgileri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: Canvas701Typography.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Canvas701Spacing.xxs),
                Text(
                  item.sizeName,
                  style: Canvas701Typography.bodySmall.copyWith(
                    color: Canvas701Colors.textTertiary,
                  ),
                ),
                const SizedBox(height: Canvas701Spacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₺${item.unitPrice.toInt()}',
                      style: Canvas701Typography.price,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Canvas701Spacing.xxs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Canvas701Colors.surfaceVariant,
                        borderRadius: BorderRadius.circular(Canvas701Radius.md),
                      ),
                      child: Row(
                        children: [
                          _QuantityButton(
                            icon: Icons.remove,
                            onTap: onDecrease,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Canvas701Spacing.xs,
                            ),
                            child: Text(
                              '${item.quantity}',
                              style: Canvas701Typography.titleMedium,
                            ),
                          ),
                          _QuantityButton(icon: Icons.add, onTap: onIncrease),
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
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Canvas701Radius.sm),
      child: Container(
        padding: const EdgeInsets.all(Canvas701Spacing.xxs),
        decoration: BoxDecoration(
          color: Canvas701Colors.surface,
          borderRadius: BorderRadius.circular(Canvas701Radius.xs),
        ),
        child: Icon(icon, size: 14, color: Canvas701Colors.textPrimary),
      ),
    );
  }
}
