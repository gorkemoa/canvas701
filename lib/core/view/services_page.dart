import 'dart:async';
import 'package:flutter/material.dart';
import '../../canvas701/theme/canvas701_theme_data.dart';
import '../widgets/app_mode_switcher.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> _banners = [
    {
      'title': 'OFFICE701',
      'subtitle': 'Dijital Dönüşümün Merkezi',
      'description': 'Yazılım, Tasarım ve Strateji ile İşinizi Geleceğe Taşıyoruz.',
      'image': 'https://office701.com/upload/2017/06/oynandi-shutterstock-448051108.jpg',
    },
    {
      'title': 'STUDIOS701',
      'subtitle': 'Yaratıcı Medya Çözümleri',
      'description': 'Prodüksiyon, 3D Tasarım ve Kast Hizmetleri.',
      'image': 'https://office701.com/upload/2017/05/oynanmis-shutterstock-365367170.jpg',
    },
    {
      'title': 'MARKET701',
      'subtitle': 'Sanatın Dijital Pazarı',
      'description': 'Binlerce Kanvas Tablo ve Dekorasyon Ürünleri.',
      'image': 'https://www.market701.com/upload/2023/02/asker-ataturk-2-logolu.jpg',
    },
    {
      'title': 'WEB TASARIM ATOLYE',
      'subtitle': 'Butik Tasarım Deneyimi',
      'description': 'Markanıza Özel Yenilikçi Web Çözümleri.',
      'image': 'http://www.webtasarimatolye.com/upload/2019/02/bg1_1350_885.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < _banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutQuart,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Canvas701Colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Mode Switcher as AppBar
              const AppModeSwitcher(
                isBack: true,
                trailing: [
                  Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Icon(Icons.account_circle_outlined, color: Colors.white, size: 24),
                ],
              ),

              // Banner Section (Carousel)
              SizedBox(
                height: 260,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemCount: _banners.length,
                  itemBuilder: (context, index) {
                    final banner = _banners[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: Canvas701Spacing.md,
                        vertical: Canvas701Spacing.sm,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Canvas701Radius.lg),
                        image: DecorationImage(
                          image: NetworkImage(banner['image']!),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Canvas701Radius.lg),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        padding: const EdgeInsets.all(Canvas701Spacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Canvas701Colors.primary,
                                borderRadius: BorderRadius.circular(Canvas701Radius.xs),
                              ),
                              child: Text(
                                banner['title']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: Canvas701Spacing.sm),
                            Text(
                              banner['subtitle']!,
                              style: Canvas701Typography.headlineMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              banner['description']!,
                              style: Canvas701Typography.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Page Indicator
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_banners.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _currentPage == index ? 24 : 8,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: _currentPage == index 
                            ? Canvas701Colors.primary 
                            : Canvas701Colors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: Canvas701Spacing.lg),

              // Services Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Canvas701Spacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Markalarımız',
                      style: Canvas701Typography.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                  ],
                ),
              ),

              const SizedBox(height: Canvas701Spacing.sm),

              // Grid Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Canvas701Spacing.md),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: Canvas701Spacing.md,
                  crossAxisSpacing: Canvas701Spacing.md,
                  childAspectRatio: 0.9,
                  children: [
                    _buildServiceCard(
                      title: 'OFFICE701',
                      subtitle: 'Dijital Dönüşüm',
                      assetPath: 'assets/logos/office701.png',
                    ),
                    _buildServiceCard(
                      title: 'STUDIOS701',
                      subtitle: 'Medya Çözümleri',
                      assetPath: 'assets/logos/studios701.png',
                    ),
                    _buildServiceCard(
                      title: 'CANVAS701',
                      subtitle: 'Sanat Galerisi',
                      assetPath: 'assets/logos/Canvas701-Logo.png',
                    ),
                    _buildServiceCard(
                      title: 'MARKET701',
                      subtitle: 'E-Ticaret',
                      assetPath: 'assets/logos/market701.png',
                    ),
                    _buildServiceCard(
                      title: '35 WEB',
                      subtitle: 'Web Tasarım',
                      assetPath: 'assets/logos/35webtasarımizmir.png',
                    ),
                    _buildServiceCard(
                      title: 'ATÖLYE',
                      subtitle: 'Butik Tasarım',
                      assetPath: 'assets/logos/webtasarımatolye.png',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Canvas701Spacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String subtitle,
    String? assetPath,
    IconData? icon,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(Canvas701Spacing.md),
      decoration: BoxDecoration(
        color: Canvas701Colors.surface,
        borderRadius: BorderRadius.circular(Canvas701Radius.lg),
        boxShadow: const [Canvas701Shadows.card],
        border: Border.all(color: Canvas701Colors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: assetPath != null
                  ? Image.asset(
                      assetPath,
                      fit: BoxFit.contain,
                    )
                  : Icon(icon, size: 40, color: color ?? Canvas701Colors.primary),
            ),
          ),
          const SizedBox(height: Canvas701Spacing.sm),
          Text(
            title,
            style: Canvas701Typography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: Canvas701Colors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  subtitle,
                  style: Canvas701Typography.bodySmall.copyWith(
                    color: Canvas701Colors.textTertiary,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: Canvas701Colors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
