import 'package:flutter/material.dart';
import '../../theme/canvas701_theme_data.dart';
import '../favorites/favorites_page.dart';
import '../cart/cart_page.dart';

class Canvas701SearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String hintText;
  final VoidCallback? onClear;

  const Canvas701SearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.hintText = 'Ürün, kategori veya marka ara',
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Canvas701Colors.primary,
      padding: const EdgeInsets.fromLTRB(
        Canvas701Spacing.md,
        5,
        Canvas701Spacing.md,
        10,
      ),
      child: Row(
        children: [
          // Arama Çubuğu
          Expanded(
            child: Container(
              height: 35,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                textInputAction: TextInputAction.search,
                textAlignVertical: TextAlignVertical.center,
                style: Canvas701Typography.bodyMedium.copyWith(
                  fontSize: 14,
                  color: Canvas701Colors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Canvas701Colors.primary,
                    size: 22,
                  ),
                  suffixIcon: controller != null && controller!.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: onClear,
                          color: Colors.grey.shade400,
                        )
                      : null,
                  hintStyle: Canvas701Typography.bodyMedium.copyWith(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Favoriler İkonu (Zil yerine favori kalıyor ama stil aynı)
          _buildActionButton(context, Icons.favorite_rounded, () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavoritesPage()),
            );
          }, isCircle: false),
          const SizedBox(width: 8),
          // Sepet İkonu (Profil yerine sepet, stil daire içinde)
          _buildActionButton(
            context,
            Icons.shopping_cart_outlined,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
            isCircle: true,
            showBadge: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    VoidCallback onTap, {
    bool showBadge = false,
    bool isCircle = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.15),
            border: isCircle
                ? Border.all(color: Colors.white.withOpacity(0.2), width: 1.5)
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
                
            ],
          ),
        ),
      ),
    );
  }
}
