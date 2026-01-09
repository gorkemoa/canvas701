import 'dart:async';
import 'package:canvas701/canvas701/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodel/register_viewmodel.dart';
import '../theme/canvas701_theme_data.dart';
import 'main_navigation_page.dart';

class CodeVerificationPage extends StatefulWidget {
  final String email;
  final String? userToken;
  final String? codeToken;

  const CodeVerificationPage({
    super.key,
    required this.email,
    this.userToken,
    this.codeToken,
  });

  @override
  State<CodeVerificationPage> createState() => _CodeVerificationPageState();
}

class _CodeVerificationPageState extends State<CodeVerificationPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Arka plan görselleri listesi
  final List<String> _backgroundImages = [
    'assets/bg/image.png',
    'assets/bg/image copy.png',
    'assets/bg/image copy 2.png',
    'assets/bg/image copy 3.png',
  ];

  int _currentImageIndex = 0;
  Timer? _backgroundTimer;
  Timer? _resendTimer;
  int _resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    // Arka plan değişimi
    _backgroundTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _backgroundImages.length;
        });
      }
    });
    // Başlangıçta tekrar gönder butonu için 60 saniye beklet
    _startResendCountdown();
    
    // Sayfa açıldığında klavyeyi aç
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _focusNode.requestFocus();
      
      // Eğer bir doğrulama oturumu yoksa (Profil sayfasından gelmiş olabilir), otomatik kod gönder
      final viewModel = context.read<RegisterViewModel>();
      final hasToken = await AuthService().getCodeToken() != null;
      
      if (!hasToken && mounted) {
        debugPrint('--- CodeVerificationPage: No code token found, requesting new code... ---');
        viewModel.resendCode();
      }
    });
  }

  void _startResendCountdown() {
    _resendCountdown = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendCountdown > 0) {
            _resendCountdown--;
          } else {
            timer.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _backgroundTimer?.cancel();
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _verifyCode(RegisterViewModel viewModel) async {
    final code = _controller.text;
    
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen 6 haneli kodu girin')),
      );
      return;
    }

    final success = await viewModel.verifyCode(code);
    
    if (success && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainNavigationPage()),
        (route) => false,
      );
    }
  }

  Widget _buildCodeBox(int index) {
    String char = "";
    if (_controller.text.length > index) {
      char = _controller.text[index];
    }

    bool isFocused = _controller.text.length == index;
    if (_controller.text.length == 6 && index == 5) isFocused = true;

    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused ? Canvas701Colors.primary : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          if (isFocused)
            BoxShadow(
              color: Canvas701Colors.primary.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        char,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Canvas701Colors.textPrimary,
        ),
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
          // Verification Formu
          Consumer<RegisterViewModel>(
            builder: (context, viewModel, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 190),
                   
                    const Text(
                      'E-posta Doğrulama',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${widget.email} adresine gönderilen 6 haneli kodu girin',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    
                    // Code Input Area (Kopyala-yapıştır ve OTP desteği)
                    GestureDetector(
                      onTap: () => _focusNode.requestFocus(),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Görsel Kutucuklar (Altta)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(6, (index) => _buildCodeBox(index)),
                          ),
                          // TextField (Üstte ve Şeffaf - Etkileşim için)
                          TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            showCursor: false,
                            cursorColor: Colors.transparent,
                            textAlign: TextAlign.center,
                            autofillHints: const [AutofillHints.oneTimeCode], // Klavye üstünde otomatik kod önerisi
                            style: const TextStyle(
                              color: Colors.transparent, 
                              fontSize: 24, // Paste menüsünün doğru yerde çıkması için
                              letterSpacing: 28, // Kutucuklara hizalamaya yardımcı olur
                            ),
                            decoration: const InputDecoration(
                              counterText: "",
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              fillColor: Colors.transparent,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (value) {
                              setState(() {});
                              if (value.length == 6) {
                                _verifyCode(viewModel);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
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
                    // Success Message
                    if (viewModel.successMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            viewModel.successMessage!,
                            style: const TextStyle(color: Canvas701Colors.success),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    // Verify Button
                    ElevatedButton(
                      onPressed: viewModel.isLoading ? null : () => _verifyCode(viewModel),
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
                              'Doğrula',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),
                    // Resend Code
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Kod gelmedi mi?',
                          style: TextStyle(
                            color: Colors.white,
                            shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                          ),
                        ),
                        TextButton(
                          onPressed: (_resendCountdown > 0 || viewModel.isLoading)
                              ? null
                              : () async {
                                  final success = await viewModel.resendCode();
                                  if (success) {
                                    _startResendCountdown();
                                  }
                                },
                          child: Text(
                            _resendCountdown > 0
                                ? 'Tekrar Gönder (${_resendCountdown}s)'
                                : 'Tekrar Gönder',
                            style: TextStyle(
                              color: _resendCountdown > 0 
                                  ? Colors.white54 
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              decoration: _resendCountdown > 0 
                                  ? null 
                                  : TextDecoration.underline,
                              decorationColor: Colors.white,
                              shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Back Button
                    Center(
                      child: TextButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        label: const Text(
                          'Geri Dön',
                          style: TextStyle(
                            color: Colors.white,
                            shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
