import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/category_viewmodel.dart';
import '../../viewmodel/product_viewmodel.dart';
import '../../viewmodel/profile_viewmodel.dart';
import '../../viewmodel/favorites_viewmodel.dart';

class SplashPage extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const SplashPage({
    super.key,
    required this.onInitializationComplete,
  });

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    try {
      // Tüm verileri paralel olarak yükle
      await Future.wait([
        context.read<CategoryViewModel>().fetchCategories(),
        context.read<ProductViewModel>().fetchFilters(),
        context.read<ProductViewModel>().fetchBestsellers(),
        context.read<ProductViewModel>().fetchNewArrivals(),
        context.read<ProductViewModel>().fetchAllProducts(refresh: true),
        context.read<ProfileViewModel>().fetchUser(),
        context.read<FavoritesViewModel>().fetchFavorites(),
      ]);

      // Verilerin UI'da işlenmesi için çok kısa bir bekleme (opsiyonel)
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      debugPrint('Error during splash initialization: $e');
    } finally {
      if (mounted) {
        widget.onInitializationComplete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/logos/Canvas701-Logo.png',
          width: 200, // İhtiyaca göre ayarlanabilir
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
