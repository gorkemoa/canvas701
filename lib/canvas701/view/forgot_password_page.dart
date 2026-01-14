import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/login_viewmodel.dart';
import '../theme/canvas701_theme_data.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordAgainController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isPasswordAgainVisible = false;
  bool _isCodeSent = false;
  bool _isVerified = false;

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
    _codeController.dispose();
    _passwordController.dispose();
    _passwordAgainController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
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
            // Form
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Consumer<LoginViewModel>(
                builder: (context, viewModel, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 150),
                      // Logo
                      Image.network(
                        'https://office701.b-cdn.net/canvas701/logo/canvas701-new-logo-black.png',
                        height: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 40),
                      
                      Text(
                        _isVerified 
                          ? 'Yeni Şifrenizi Belirleyin' 
                          : (_isCodeSent ? 'Kodu Doğrulayın' : 'Şifremi Unuttum'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isVerified
                          ? 'Yeni şifrenizi giriniz.'
                          : (_isCodeSent 
                            ? 'E-posta adresinize gönderilen 6 haneli kodu giriniz.' 
                            : 'E-posta adresinizi giriniz, size şifre sıfırlama kodu gönderelim.'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 40),

                      if (!_isCodeSent) ...[
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
                        ),
                      ] else if (!_isVerified) ...[
                        // Code Field
                        TextField(
                          controller: _codeController,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: '6 Haneli Kod',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            prefixIcon: const Icon(Icons.security),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                        ),
                      ] else ...[
                        // Password Field
                        TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Yeni Şifre',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                color: Canvas701Colors.textTertiary,
                              ),
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Password Again Field
                        TextField(
                          controller: _passwordAgainController,
                          obscureText: !_isPasswordAgainVisible,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Yeni Şifre (Tekrar)',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordAgainVisible ? Icons.visibility_off : Icons.visibility,
                                color: Canvas701Colors.textTertiary,
                              ),
                              onPressed: () => setState(() => _isPasswordAgainVisible = !_isPasswordAgainVisible),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 32),

                      // Submit Button
                      ElevatedButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () async {
                                if (!_isCodeSent) {
                                  final response = await viewModel.forgotPassword(_emailController.text);
                                  if (response.success) {
                                    setState(() => _isCodeSent = true);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(response.message ?? viewModel.errorMessage ?? '')),
                                      );
                                    }
                                  } else {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(viewModel.errorMessage ?? '')),
                                      );
                                    }
                                  }
                                } else if (!_isVerified) {
                                  final response = await viewModel.checkCode(_codeController.text);
                                  if (response.success) {
                                    setState(() => _isVerified = true);
                                  } else {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(viewModel.errorMessage ?? '')),
                                      );
                                    }
                                  }
                                } else {
                                  if (RegExp(r'^\d+$').hasMatch(_passwordController.text)) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Şifre sadece rakamlardan oluşamaz')),
                                      );
                                    }
                                    return;
                                  }
                                  final response = await viewModel.updatePassword(
                                    _passwordController.text,
                                    _passwordAgainController.text,
                                  );
                                  if (response.success) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(response.message ?? 'Şifreniz güncellendi.')),
                                      );
                                      Navigator.of(context).pop();
                                    }
                                  } else {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(viewModel.errorMessage ?? '')),
                                      );
                                    }
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Canvas701Colors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                            : Text(
                                _isVerified 
                                  ? 'Şifreyi Güncelle' 
                                  : (_isCodeSent ? 'Kodu Doğrula' : 'Kod Gönder'),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
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
