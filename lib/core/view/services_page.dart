import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../canvas701/theme/canvas701_theme_data.dart';
import '../../canvas701/view/main_navigation_page.dart';
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
      'description':
          'Yazılım, Tasarım ve Strateji ile İşinizi Geleceğe Taşıyoruz.',
      'image':
          'https://office701.com/upload/2017/06/oynandi-shutterstock-448051108.jpg',
      'url': 'https://office701.com',
    },
    {
      'title': 'STUDIOS701',
      'subtitle': 'Yaratıcı Medya Çözümleri',
      'description': 'Prodüksiyon, 3D Tasarım ve Kast Hizmetleri.',
      'image':
          'https://office701.com/upload/2017/05/oynanmis-shutterstock-365367170.jpg',
      'url': 'https://studios701.com',
    },
    {
      'title': 'MARKET701',
      'subtitle': 'Sanatın Dijital Pazarı',
      'description': 'Binlerce Kanvas Tablo ve Dekorasyon Ürünleri.',
      'image':
          'https://www.market701.com/upload/2023/02/asker-ataturk-2-logolu.jpg',
      'url': 'https://market701.com',
    },
    {
      'title': 'WEB TASARIM ATOLYE',
      'subtitle': 'Butik Tasarım Deneyimi',
      'description': 'Markanıza Özel Yenilikçi Web Çözümleri.',
      'image':
          'http://www.webtasarimatolye.com/upload/2019/02/bg1_1350_885.jpg',
      'url': 'https://webtasarimatolye.com',
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

  Future<void> _showRedirectDialog(String url) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF3AAE81)),
            SizedBox(width: 10),
            Text('Bilgilendirme'),
          ],
        ),
        content: const Text(
          'Web sitemize yönlendiriliyorsunuz. Devam etmek istiyor musunuz?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _launchUrl(url);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3AAE81),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Devam Et'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Canvas701Colors.background,
      body: Column(
        children: [
          Container(
            color: Canvas701Colors.primary,
            child: const SafeArea(
              bottom: false,
              child: AppModeSwitcher(
                isBack: true,
                
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Section (Carousel) with Curved Bottom
                  Stack(
                    children: [
                      SizedBox(
                        height: 250,
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
                            return GestureDetector(
                              onTap: () => _showRedirectDialog(banner['url']!),
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(banner['image']!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.6),
                                        Colors.transparent,
                                      ],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(
                                    Canvas701Spacing.lg,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        banner['subtitle']!,
                                        style: Canvas701Typography
                                            .headlineMedium
                                            .copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        banner['description']!,
                                        style: Canvas701Typography.bodySmall
                                            .copyWith(
                                              color: Colors.white.withOpacity(
                                                0.9,
                                              ),
                                            ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ), // Space for indicator
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Page Indicator Overlay
                      Positioned(
                        bottom: 30,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(_banners.length, (index) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: _currentPage == index ? 30 : 8,
                                height: 6,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _currentPage == index
                                      ? const Color(
                                          0xFF3AAE81,
                                        ) // Turkcell Yellow
                                      : Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                      // Curved Bottom Overlay
                      Positioned(
                        bottom: -10,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Canvas701Colors.background,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.elliptical(300, 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: Canvas701Spacing.md),

                  // Grid Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Canvas701Spacing.md,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: Canvas701Spacing.xl),
                        Row(
                          children: [
                            Expanded(
                              child: _buildLargeServiceCard(
                                assetPath: 'assets/logos/office701.png',
                                onTap: () => _showRedirectDialog('https://office701.com'),
                              ),
                            ),
                            const SizedBox(width: Canvas701Spacing.md),
                            Expanded(
                              child: _buildLargeServiceCard(
                                assetPath: 'assets/logos/studios701.png',
                                onTap: () => _showRedirectDialog('https://studios701.com'),
                              ),
                            ),
                          ],
                        ),

                        // DÜZELTME: Araya kontrollü, küçük bir boşluk ekledik (sm veya 10.0 kullanabilirsin)
                        const SizedBox(height: Canvas701Spacing.md),

                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),

                          // DÜZELTME: GridView'in kendi varsayılan boşluğunu sıfırladık
                          padding: EdgeInsets.zero,

                          crossAxisCount: 2,
                          mainAxisSpacing: Canvas701Spacing.md,
                          crossAxisSpacing: Canvas701Spacing.md,
                          childAspectRatio: 1.8,
                          children: [
                            _buildSmallServiceCard(
                              assetPath:
                                  'https://office701.b-cdn.net/canvas701/logo/canvas701-new-logo-black.png',
                              onTap: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MainNavigationPage(),
                                  ),
                                  (route) => false,
                                );
                              },
                            ),
                            _buildSmallServiceCard(
                              assetPath: 'assets/logos/market701.png',
                              onTap: () => _showRedirectDialog('https://market701.com'),
                            ),
                            _buildSmallServiceCard(
                              assetPath: 'assets/logos/35webtasarımizmir.png',
                              onTap: () => _showRedirectDialog('https://35webtasarimizmir.com'),
                            ),
                            _buildSmallServiceCard(
                              assetPath: 'assets/logos/webtasarımatolye.png',
                              onTap: () => _showRedirectDialog('https://webtasarimatolye.com'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Canvas701Spacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeServiceCard({
    required String assetPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(Canvas701Spacing.lg),
        decoration: BoxDecoration(
          color: Canvas701Colors.surface,
          borderRadius: BorderRadius.circular(Canvas701Radius.lg),
          border: Border.all(
            color: Colors.black.withOpacity(0.09),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
            child: assetPath.startsWith('http')
                ? Image.network(assetPath, fit: BoxFit.contain)
                : Image.asset(assetPath, fit: BoxFit.contain)),
      ),
    );
  }

  Widget _buildSmallServiceCard({
    required String assetPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(Canvas701Spacing.md),
        decoration: BoxDecoration(
          color: Canvas701Colors.surface,
          borderRadius: BorderRadius.circular(Canvas701Radius.lg),
          border: Border.all(
            color: Colors.black.withOpacity(0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
            child: assetPath.startsWith('http')
                ? Image.network(assetPath, fit: BoxFit.contain)
                : Image.asset(assetPath, fit: BoxFit.contain)),
      ),
    );
  }
}
