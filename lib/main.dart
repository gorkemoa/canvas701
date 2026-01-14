import 'package:canvas701/canvas701/services/firebase_messaging_service.dart';
import 'package:canvas701/canvas701/services/navigation_service.dart';
import 'package:canvas701/canvas701/theme/canvas701_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/app_mode.dart';
import 'canvas701/view/main_navigation_page.dart';
import 'canvas701/view/splash/splash_page.dart';
import 'canvas701/viewmodel/profile_viewmodel.dart';
import 'canvas701/viewmodel/register_viewmodel.dart';
import 'canvas701/viewmodel/category_viewmodel.dart';
import 'canvas701/viewmodel/product_viewmodel.dart';
import 'canvas701/viewmodel/favorites_viewmodel.dart';
import 'canvas701/viewmodel/general_viewmodel.dart';
import 'canvas701/viewmodel/ticket_viewmodel.dart';
import 'canvas701/viewmodel/about_viewmodel.dart';
import 'creators/view/creators_home_page.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Navigation and Firebase Messaging Service
  NavigationService.navigatorKey = navigatorKey;
  // Initialize Firebase Messaging Service
  await FirebaseMessagingService.initialize();

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
        ChangeNotifierProvider(create: (_) => RegisterViewModel()),
        ChangeNotifierProvider(create: (_) => CategoryViewModel()),
        ChangeNotifierProvider(create: (_) => ProductViewModel()),
        ChangeNotifierProvider(create: (_) => FavoritesViewModel()),
        ChangeNotifierProvider(create: (_) => GeneralViewModel()),
        ChangeNotifierProvider(create: (_) => TicketViewModel()),
        ChangeNotifierProvider(create: (_) => AboutViewModel()),
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
  bool _initialized = false;

  void _onInitializationComplete() {
    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appMode = AppModeManager.instance;

    return MaterialApp(
      title: 'Canvas701',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: Canvas701Theme.lightTheme,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            // Herhangi bir yere dokunulduğunda klavyeyi kapat
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: child,
        );
      },
      home: !_initialized
          ? SplashPage(onInitializationComplete: _onInitializationComplete)
          : ValueListenableBuilder<AppMode>(
              valueListenable: appMode.modeNotifier,
              builder: (context, currentMode, _) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: _buildHome(currentMode),
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
