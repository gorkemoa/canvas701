import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/category_viewmodel.dart';
import '../viewmodel/product_viewmodel.dart';
import '../viewmodel/profile_viewmodel.dart';
import 'home/home_page.dart';
import 'categories/categories_page.dart';
import 'product/product_list_page.dart';
import 'profile/profile_page.dart';
import 'special/special_page.dart';
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
      HomePage(onSeeAllCategories: () => _onNavTap(NavIndex.categories)),
      const CategoriesPage(),
      const ProductListPage(title: 'Tüm Ürünler', sortKey: 'sortDefault'),
      const SpecialPage(),
      const ProfilePage(),
    ];
  }

  void _onNavTap(int index) {
    if (_currentIndex == index) {
      // Aynı sekmeye tıklandığında da verileri yenile
      _refreshData(index);
    } else {
      // Farklı sekmeye geçildiğinde de verileri yenile
      _refreshData(index);
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _refreshData(int index) {
    switch (index) {
      case NavIndex.home:
        context.read<CategoryViewModel>().fetchCategories();
        context.read<ProductViewModel>().fetchAllProducts(refresh: true);
        context.read<ProductViewModel>().fetchBestsellers();
        context.read<ProductViewModel>().fetchNewArrivals();
        break;
      case NavIndex.categories:
        context.read<CategoryViewModel>().fetchCategories();
        break;
      case NavIndex.products:
        context.read<ProductViewModel>().fetchAllProducts(refresh: true);
        break;
      case NavIndex.special:
        // Şimdilik boş, ileride Sana Özel verileri buraya eklenebilir
        break;
      case NavIndex.profile:
        context.read<ProfileViewModel>().fetchUser();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Canvas701BottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
