import 'package:canvas701/canvas701/theme/canvas701_theme_data.dart';
import 'package:flutter/material.dart';

/// Canvas701 Bottom Navigation Bar
/// Tüm sayfalarda kullanılan ortak bottom navigation widget'ı
class Canvas701BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const Canvas701BottomNav({super.key, this.currentIndex = 0, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Canvas701Colors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        border: const Border(
          top: BorderSide(color: Canvas701Colors.divider, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Canvas701Colors.primary,
          unselectedItemColor: Canvas701Colors.textTertiary,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          iconSize: 24,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Ana Sayfa',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view),
              label: 'Kategoriler',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag),
              label: 'Ürünler',
            ),
            BottomNavigationBarItem(
              icon: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Canvas701Colors.primary,
                    Canvas701Colors.favorite,
                    Canvas701Colors.warning,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: const Icon(Icons.auto_awesome_outlined, color: Colors.white),
              ),
              activeIcon: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Canvas701Colors.primary,
                    Canvas701Colors.favorite,
                    Canvas701Colors.warning,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: const Icon(Icons.auto_awesome, color: Colors.white),
              ),
              label: 'Sana Özel',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom Navigation İndeks Sabitleri
class NavIndex {
  NavIndex._();

  static const int home = 0;
  static const int categories = 1;
  static const int products = 2;
  static const int special = 3;
  static const int profile = 4;
}
