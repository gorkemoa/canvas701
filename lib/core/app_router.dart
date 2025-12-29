import 'package:flutter/material.dart';
import 'app_mode.dart';
import 'feature_flags.dart';

/// Uygulama routing kararları
/// Modülün değil, uygulamanın sorumluluğunda
class AppRouter {
  AppRouter._();

  static final AppRouter instance = AppRouter._();

  final _appMode = AppModeManager.instance;
  final _features = FeatureFlags.instance;

  /// Route isimleri
  static const String splash = '/';
  static const String home = '/home';
  static const String productList = '/products';
  static const String productDetail = '/product/:id';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success';
  static const String favorites = '/favorites';
  static const String search = '/search';
  static const String collections = '/collections';
  static const String collectionDetail = '/collection/:id';

  // Creators routes (ileride)
  static const String creatorsHome = '/creators';
  static const String creatorsOnboarding = '/creators/onboarding';

  /// Başlangıç route'u
  String get initialRoute {
    if (_appMode.isCanvas) {
      return home;
    } else if (_appMode.isCreators && _features.isCreatorsEnabled) {
      return creatorsHome;
    }
    return home;
  }

  /// Route erişim kontrolü
  bool canAccess(String route) {
    // Creators route'ları kontrol
    if (route.startsWith('/creators')) {
      return _features.isCreatorsEnabled;
    }

    // Favorites kontrolü
    if (route == favorites) {
      return _features.isFavoritesEnabled;
    }

    // Search kontrolü
    if (route == search) {
      return _features.isSearchEnabled;
    }

    return true;
  }

  /// Route generator (ileride genişletilecek)
  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // İleride burada route'lar oluşturulacak
    return null;
  }
}
