import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/login_viewmodel.dart';
import '../theme/canvas701_theme_data.dart';
import 'forgot_password_page.dart';
import 'main_navigation_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  // Arka plan görselleri listesi
  final List<String> _backgroundImages = [
    'assets/bg/image.png',
    'assets/bg/image copy.png',
    'assets/bg/image copy 2.png',
    'assets/bg/image copy 3.png',
  ];

  int _currentImageIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Her 5 saniyede bir arka planı değiştir
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _backgroundImages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _timer?.cancel();
    super.dispose();
  }


  Future<void> _handleSocialLogin(BuildContext context, LoginViewModel viewModel, String platform) async {
    final success = await viewModel.socialLogin(platform);
    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainNavigationPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Scaffold(
        body: Stack(
          children: [
            // Dinamik Arka Plan
            AnimatedSwitcher(
              duration: const Duration(seconds: 2),
              child: Container(
                key: ValueKey<int>(_currentImageIndex),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(_backgroundImages[_currentImageIndex]),
                    fit: BoxFit.cover,
                  ),
                ),
                // Görselin üzerine hafif bir karartma ekleyerek formun okunabilirliğini artırıyoruz
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ),
            // Login Formu
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Consumer<LoginViewModel>(
                builder: (context, viewModel, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 150),
                      // Başlık 
                       Image.asset(
                        'assets/Canvas701-Logo.png',
                        height: 100,
                      color: Color( 0xFFFFFFFF),
                      ),
                      const SizedBox(height: 40),

                      // Email Field
                      TextField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'E-posta adresiniz',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),
                      // Password Field
                      TextField(
                        controller: _passwordController,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Şifreniz',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                              color: Canvas701Colors.textTertiary,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        obscureText: !_isPasswordVisible,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 12),
                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ForgotPasswordPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Şifremi Unuttum',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Error Message
                      if (viewModel.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              viewModel.errorMessage!,
                              style: const TextStyle(color: Canvas701Colors.error),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      // Login Button
                      ElevatedButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () async {
                                final success = await viewModel.login(
                                  _emailController.text,
                                  _passwordController.text,
                                );
                                if (success && mounted) {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => const MainNavigationPage(),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Canvas701Colors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: viewModel.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Giriş Yap',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(height: 24),
                      const Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white70)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Veya şununla devam et',
                              style: TextStyle(
                                color: Colors.white,
                                shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.white70)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (Platform.isIOS) ...[
                        _SocialButton(
                          icon: Icons.apple,
                          label: 'Apple ile Giriş Yap',
                          onPressed: () => _handleSocialLogin(context, viewModel, 'apple'),
                        ),
                        const SizedBox(height: 12),
                      ],
                      _SocialButton(
                        imagePath: 'assets/google.png',
                        label: 'Google ile Giriş Yap',
                        onPressed: () => _handleSocialLogin(context, viewModel, 'google'),
                      ),
                      const SizedBox(height: 20),
                      // Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Hesabınız yok mu?',
                            style: TextStyle(
                              color: Colors.white,
                              shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Kayıt Ol',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                                shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData? icon;
  final String? imagePath;
  final String label;
  final VoidCallback onPressed;

  const _SocialButton({
    this.icon,
    this.imagePath,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null)
              Image.asset(imagePath!, height: 24)
            else if (icon != null)
              Icon(icon, size: 35, color: Colors.black),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
