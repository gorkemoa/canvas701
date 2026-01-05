import 'package:flutter/material.dart';
import '../../theme/canvas701_theme_data.dart';
import '../../model/cart.dart';
import '../../api/dummy_data.dart';
import '../../../core/widgets/app_mode_switcher.dart';

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
      _cart = _cart.updateQuantity(item.productId, item.sizeId, item.quantity + delta);
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
      body: _cart.isEmpty ? _buildEmptyCart() : _buildCartContent(),
      bottomNavigationBar: _cart.isEmpty ? null : _buildCheckoutBar(),
    );
  }

  Widget _buildEmptyCart() {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          floating: true,
          pinned: true,
          backgroundColor: Canvas701Colors.primary,
          elevation: 0,
          toolbarHeight: 45,
          titleSpacing: 0,
          automaticallyImplyLeading: false,
          title: AppModeSwitcher(),
        ),
        SliverFillRemaining(
          child: Center(
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
                  style: Canvas701Typography.bodyMedium.copyWith(color: Canvas701Colors.textSecondary),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // Ana sayfaya yönlendir veya alışverişe başla
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Canvas701Colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Alışverişe Başla'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartContent() {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          floating: true,
          pinned: true,
          backgroundColor: Canvas701Colors.primary,
          elevation: 0,
          toolbarHeight: 45,
          titleSpacing: 0,
          automaticallyImplyLeading: false,
          title: AppModeSwitcher(),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Sepetim',
              style: Canvas701Typography.displaySmall,
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = _cart.items[index];
              return _CartItemTile(
                item: item,
                onIncrease: () => _updateQuantity(item, 1),
                onDecrease: () => _updateQuantity(item, -1),
                onRemove: () => _removeItem(item),
              );
            },
            childCount: _cart.items.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverToBoxAdapter(child: _buildOrderSummary()),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Canvas701Colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Canvas701Colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sipariş Özeti',
            style: Canvas701Typography.titleLarge,
          ),
          const SizedBox(height: 20),
          _SummaryRow(label: 'Ara Toplam', value: '${_cart.subtotal.toStringAsFixed(2)} TL'),
          const SizedBox(height: 12),
          const _SummaryRow(label: 'Kargo', value: 'Ücretsiz', valueColor: Canvas701Colors.success),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: Canvas701Colors.divider),
          ),
          _SummaryRow(
            label: 'Toplam',
            value: '${_cart.total.toStringAsFixed(2)} TL',
            isBold: true,
            fontSize: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Canvas701Colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Toplam',
                  style: Canvas701Typography.bodySmall.copyWith(color: Canvas701Colors.textSecondary),
                ),
                Text(
                  '${_cart.total.toStringAsFixed(2)} TL',
                  style: Canvas701Typography.titleLarge.copyWith(color: Canvas701Colors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                // Ödeme sayfasına git
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Canvas701Colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text('Sepeti Onayla'),
            ),
          ),
        ],
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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Canvas701Colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Canvas701Colors.divider),
      ),
      child: Row(
        children: [
          // Ürün Görseli
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.productImage,
              width: 80,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          // Ürün Bilgileri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        style: Canvas701Typography.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: onRemove,
                      icon: const Icon(Icons.close, size: 20, color: Canvas701Colors.textTertiary),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Beden: ${item.sizeName}',
                  style: Canvas701Typography.bodySmall.copyWith(color: Canvas701Colors.textSecondary),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.unitPrice.toStringAsFixed(2)} TL',
                      style: Canvas701Typography.titleMedium.copyWith(color: Canvas701Colors.primary),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Canvas701Colors.divider),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          _QuantityButton(icon: Icons.remove, onTap: onDecrease),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 18, color: Canvas701Colors.textPrimary),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final double fontSize;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.fontSize = 14,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
      color: Canvas701Colors.textPrimary,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style.copyWith(color: Canvas701Colors.textSecondary)),
        Text(value, style: style.copyWith(color: valueColor ?? Canvas701Colors.textPrimary)),
      ],
    );
  }
}
