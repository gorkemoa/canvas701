import 'package:canvas701/canvas701/theme/canvas701_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app_mode.dart';
import 'canvas701/view/main_navigation_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(const Canvas701App());
}

/// Canvas701 & Creators Ana Uygulama
///
/// İki modül, tek uygulama:
/// - Canvas701: Kürasyonlu tablo satış (MVP'de aktif)
/// - Creators: Çoklu satıcı pazar yeri (ileride)
class Canvas701App extends StatelessWidget {
  const Canvas701App({super.key});

  @override
  Widget build(BuildContext context) {
    final appMode = AppModeManager.instance;

    return MaterialApp(
      title: 'Canvas701',
      debugShowCheckedModeBanner: false,

      // Canvas701 teması
      theme: Canvas701Theme.lightTheme,

      // Başlangıç sayfası - mod'a göre
      home: _buildHome(appMode.currentMode),
    );
  }

  Widget _buildHome(AppMode mode) {
    switch (mode) {
      case AppMode.canvas:
        return const MainNavigationPage();
      case AppMode.creators:
        // Creators henüz aktif değil, Canvas701'e yönlendir
        return const MainNavigationPage();
      case AppMode.hybrid:
        // İleride: TabBar ile iki modül birlikte
        return const MainNavigationPage();
    }
  }
}
