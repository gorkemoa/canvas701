import 'package:flutter/material.dart';
import '../../core/widgets/app_mode_switcher.dart';
import '../../canvas701/theme/canvas701_theme_data.dart';

/// Creators Ana Sayfa - Placeholder
/// İleride tam fonksiyonel hale gelecek
class CreatorsHomePage extends StatelessWidget {
  const CreatorsHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Canvas701Colors.primary,
        elevation: 0,
        toolbarHeight: 45,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: const AppModeSwitcher(),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Creators Logo/Icon
              Container(
                width: 120,
                child: Image.network(
                  'https://office701.b-cdn.net/canvas701/logo/canvas701-creators-ogo-black.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
              const Text(
                'Creators',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 16),
              
              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Kendi sanat eserlerinizi yükleyin,\nsatın ve kazanın!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // Coming Soon Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Text(
                  'YAKINDA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
