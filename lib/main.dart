import 'package:canvas701/canvas701/theme/canvas701_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/app_mode.dart';
import 'canvas701/view/main_navigation_page.dart';
import 'canvas701/view/login_page.dart';
import 'canvas701/api/auth_service.dart';
import 'canvas701/viewmodel/profile_viewmodel.dart';
import 'canvas701/viewmodel/category_viewmodel.dart';
import 'creators/view/creators_home_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => CategoryViewModel()),
      ],
      child: const Canvas701App(),
    ),
  );
}

/// Canvas701 & Creators Ana Uygulama
///
/// İki modül, tek uygulama:
/// - Canvas701: Kürasyonlu tablo satış (MVP'de aktif)
/// - Creators: Çoklu satıcı pazar yeri (ileride)
class Canvas701App extends StatefulWidget {
  const Canvas701App({super.key});

  @override
  State<Canvas701App> createState() => _Canvas701AppState();
}

class _Canvas701AppState extends State<Canvas701App> {
  late Future<String?> _tokenFuture;

  @override
  void initState() {
    super.initState();
    _tokenFuture = AuthService().getToken();
  }

  @override
  Widget build(BuildContext context) {
    final appMode = AppModeManager.instance;

    return MaterialApp(
      title: 'Canvas701',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: Canvas701Theme.lightTheme,
      home: FutureBuilder<String?>(
        future: _tokenFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          final bool isLoggedIn = snapshot.hasData && snapshot.data != null;
          
          if (!isLoggedIn) {
            return const LoginPage();
          }

          return ValueListenableBuilder<AppMode>(
            valueListenable: appMode.modeNotifier,
            builder: (context, currentMode, _) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                switchInCurve: Curves.easeInOutQuart,
                switchOutCurve: Curves.easeInOutQuart,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final offsetAnimation = Tween<Offset>(
                    begin: const Offset(0.0, 0.05),
                    end: Offset.zero,
                  ).animate(animation);

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    ),
                  );
                },
                child: _buildHome(currentMode),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHome(AppMode mode) {
    switch (mode) {
      case AppMode.canvas:
        return const MainNavigationPage(key: ValueKey('canvas'));
      case AppMode.creators:
        return const CreatorsHomePage(key: ValueKey('creators'));
      case AppMode.hybrid:
        return const MainNavigationPage(key: ValueKey('hybrid'));
    }
  }
}
