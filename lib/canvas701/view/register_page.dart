import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/register_viewmodel.dart';
import '../theme/canvas701_theme_data.dart';
import '../model/kvkk_response.dart';
import 'code_verification_page.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isKvkkAccepted = false;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RegisterViewModel>().fetchKvkkPolicy();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _showKvkkDialog(KvkkData? data) {
    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('KVKK metni yükleniyor, lütfen bekleyin...')),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data.postTitle),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              data.postContent
                  .replaceAll(RegExp(r'<[^>]*>'), '')
                  .replaceAll('&nbsp;', ' ')
                  .replaceAll('&quot;', '"')
                  .replaceAll('&amp;', '&')
                  .replaceAll('&lt;', '<')
                  .replaceAll('&gt;', '>')
                  .trim(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ),
            // Register Formu
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Consumer<RegisterViewModel>(
                builder: (context, viewModel, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 150),
                      // Logo
                      Image.asset(
                        'assets/Canvas701-Logo.png',
                        height: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Hesap Oluştur',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                        ),
                        textAlign: TextAlign.center,
                      ),
                     
                      
                      const SizedBox(height: 32),
                      // First Name & Last Name Row
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _firstNameController,
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: 'Adınız',
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                                prefixIcon: const Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.words,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _lastNameController,
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: 'Soyadınız',
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.9),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.words,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 16),
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
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      // Confirm Password Field
                      TextField(
                        controller: _confirmPasswordController,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Şifre Tekrarı',
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.9),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                              color: Canvas701Colors.textTertiary,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        obscureText: !_isConfirmPasswordVisible,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 16),
                      // KVKK Checkbox
                      Row(
                        children: [
                          Theme(
                            data: ThemeData(unselectedWidgetColor: Colors.white),
                            child: Checkbox(
                              value: _isKvkkAccepted,
                              onChanged: (value) {
                                setState(() {
                                  _isKvkkAccepted = value ?? false;
                                });
                              },
                              side: const BorderSide(color: Colors.white),
                              checkColor: Canvas701Colors.primary,
                              activeColor: Colors.white,
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _showKvkkDialog(viewModel.kvkkData),
                              child: const Text.rich(
                                TextSpan(
                                  text: 'KVKK Aydınlatma Metni',
                                  style: TextStyle(
                                    color: Colors.white,
                                    decoration: TextDecoration.underline,
                                    shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '\'ni okudum ve kabul ediyorum.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
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
                      // Register Button
                      ElevatedButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () async {
                                // Client-side validation
                                if (_firstNameController.text.trim().isEmpty ||
                                    _lastNameController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Ad ve soyad alanları zorunludur')),
                                  );
                                  return;
                                }
                                if (_passwordController.text != _confirmPasswordController.text) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Şifreler eşleşmiyor')),
                                  );
                                  return;
                                }

                                if (!_isKvkkAccepted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Lütfen KVKK Aydınlatma Metnini onaylayın')),
                                  );
                                  return;
                                }

                                final success = await viewModel.register(
                                  firstName: _firstNameController.text.trim(),
                                  lastName: _lastNameController.text.trim(),
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
                                );
                                
                                if (success && mounted) {
                                  // Navigate to code verification page
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => CodeVerificationPage(
                                        email: _emailController.text.trim(),
                                        userToken: viewModel.userToken,
                                        codeToken: viewModel.codeToken,
                                      ),
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
                                'Kayıt Ol',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(height: 24),
                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Zaten hesabınız var mı?',
                            style: TextStyle(
                              color: Colors.white,
                              shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Giriş Yap',
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
    );
  }
}
