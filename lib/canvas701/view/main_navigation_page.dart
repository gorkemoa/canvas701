import 'package:flutter/material.dart';
import 'home/home_page.dart';
import 'categories/categories_page.dart';
import 'favorites/favorites_page.dart';
import 'cart/cart_page.dart';
import 'profile/profile_page.dart';
import 'widgets/widgets.dart';

/// Canvas701 Ana Navigasyon Sayfası
/// Bottom navigation ile tüm ana sayfaları yönetir
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = NavIndex.home;

  // Sayfa listesi - lazy loading için
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const CategoriesPage(),
      const FavoritesPage(),
      const CartPage(),
      const ProfilePage(),
    ];
  }

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Canvas701BottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
