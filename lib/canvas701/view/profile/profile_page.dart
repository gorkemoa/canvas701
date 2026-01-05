import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/canvas701_theme_data.dart';
import '../../../core/widgets/app_mode_switcher.dart';
import '../../api/auth_service.dart';
import '../../viewmodel/profile_viewmodel.dart';
import '../login_page.dart';
import '../code_verification_page.dart';
import 'profile_info_page.dart';
import 'change_password_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isCheckingAuth = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = await AuthService().getToken();
    if (mounted) {
      setState(() {
        _isLoggedIn = token != null;
        _isCheckingAuth = false;
      });
      if (_isLoggedIn) {
        context.read<ProfileViewModel>().fetchUser();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return const Scaffold(
        backgroundColor: Canvas701Colors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isLoggedIn) {
      return _buildGuestView();
    }

    return Scaffold(
      backgroundColor: Canvas701Colors.background,
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          debugPrint('--- ProfilePage BUILD: isLoading=${viewModel.isLoading}, hasUser=${viewModel.user != null}, error=${viewModel.errorMessage} ---');
          if (viewModel.isLoading && viewModel.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              const SliverAppBar(
                floating: true,
                pinned: true,
                backgroundColor: Canvas701Colors.primary,
                elevation: 0,
                toolbarHeight: 45,
                titleSpacing: 0,
                automaticallyImplyLeading: false,
                title: AppModeSwitcher(),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    if (viewModel.user != null && viewModel.user!.isApproved == false)
                      _buildVerificationBanner(context, viewModel.user!.userEmail),
                    _buildHeader(viewModel),
                    const SizedBox(height: 10),
                    _buildMenuSection(
                      title: 'Siparişlerim',
                      items: [
                        _MenuItem(icon: Icons.shopping_bag_outlined, title: 'Tüm Siparişlerim', onTap: () {}),
                        _MenuItem(icon: Icons.local_shipping_outlined, title: 'Kargom Nerede?', onTap: () {}),
                        _MenuItem(icon: Icons.assignment_return_outlined, title: 'İade Taleplerim', onTap: () {}),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildMenuSection(
                      title: 'Hesabım',
                      items: [
                        _MenuItem(
                          icon: Icons.person_outline,
                          title: 'Kişisel Bilgilerim',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ProfileInfoPage()),
                            );
                          },
                        ),
                        _MenuItem(
                          icon: Icons.lock_outline,
                          title: 'Şifre Değiştir',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
                            );
                          },
                        ),
                        _MenuItem(icon: Icons.location_on_outlined, title: 'Adres Bilgilerim', onTap: () {}),
                        _MenuItem(icon: Icons.payment_outlined, title: 'Kayıtlı Kartlarım', onTap: () {}),
                        _MenuItem(icon: Icons.notifications_none_outlined, title: 'Duyuru Tercihlerim', onTap: () {}),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildMenuSection(
                      title: 'Destek',
                      items: [
                        _MenuItem(icon: Icons.help_outline, title: 'Yardım Merkezi', onTap: () {}),
                        _MenuItem(icon: Icons.chat_bubble_outline, title: 'Canlı Destek', onTap: () {}),
                        _MenuItem(icon: Icons.info_outline, title: 'Hakkımızda', onTap: () {}),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextButton(
                        onPressed: () async {
                          await AuthService().logout();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                              (route) => false,
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Canvas701Colors.error,
                          backgroundColor: Canvas701Colors.surface,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Canvas701Colors.divider),
                          ),
                        ),
                        child: const Text('Çıkış Yap', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Versiyon 1.0.0',
                      style: Canvas701Typography.bodySmall.copyWith(color: Canvas701Colors.textTertiary),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGuestView() {
    return Scaffold(
      backgroundColor: Canvas701Colors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Canvas701Colors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 80,
                  color: Canvas701Colors.primary,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Profilinizi görüntülemek için giriş yapın',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Canvas701Colors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Siparişlerinizi takip etmek ve avantajlardan yararlanmak için hesabınıza giriş yapın.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Canvas701Colors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Canvas701Colors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Giriş Yap',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Register sayfasına yönlendirilebilir
                },
                child: const Text(
                  'Henüz hesabınız yok mu? Kayıt Ol',
                  style: TextStyle(color: Canvas701Colors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationBanner(BuildContext context, String email) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Canvas701Colors.error.withOpacity(0.1),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Canvas701Colors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hesabınız Onaylanmamış',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Canvas701Colors.error,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Lütfen e-posta adresinizi doğrulayın.',
                  style: TextStyle(
                    color: Canvas701Colors.error.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CodeVerificationPage(email: email),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Canvas701Colors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('Doğrula', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ProfileViewModel viewModel) {
    final user = viewModel.user;
    
    if (!viewModel.isLoading && user == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              const Text('Kullanıcı bilgileri yüklenemedi.'),
              TextButton(
                onPressed: () => viewModel.fetchUser(),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Canvas701Colors.surface,
        border: Border(bottom: BorderSide(color: Canvas701Colors.divider)),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Canvas701Colors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: user?.profilePhoto.isNotEmpty == true
                ? ClipOval(child: Image.network(user!.profilePhoto, fit: BoxFit.cover))
                : const Icon(Icons.person, size: 40, color: Canvas701Colors.primary),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user?.userFullname ?? '',
                      style: Canvas701Typography.headlineSmall,
                    ),
                    if (user?.isApproved == true) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.verified,
                        color: Canvas701Colors.info,
                        size: 18,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user?.userEmail ?? '',
                  style: Canvas701Typography.bodyMedium.copyWith(color: Canvas701Colors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileInfoPage()),
              );
            },
            icon: const Icon(Icons.edit_outlined, color: Canvas701Colors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection({required String title, required List<_MenuItem> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            title,
            style: Canvas701Typography.titleMedium.copyWith(color: Canvas701Colors.textSecondary),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: Canvas701Colors.surface,
            border: Border.symmetric(horizontal: BorderSide(color: Canvas701Colors.divider)),
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              return Column(
                children: [
                  items[index],
                  if (index < items.length - 1)
                    const Divider(height: 1, color: Canvas701Colors.divider, indent: 64),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Canvas701Colors.textPrimary, size: 22),
      title: Text(title, style: Canvas701Typography.bodyLarge),
      trailing: const Icon(Icons.chevron_right, color: Canvas701Colors.textTertiary, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      dense: true,
    );
  }
}
