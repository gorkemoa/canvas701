import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/canvas701_theme_data.dart';
import '../../../core/widgets/app_mode_switcher.dart';
import '../../api/auth_service.dart';
import '../../viewmodel/profile_viewmodel.dart';
import '../login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().fetchUser();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    _buildHeader(viewModel),
                    const SizedBox(height: 20),
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
                        _MenuItem(icon: Icons.person_outline, title: 'Kişisel Bilgilerim', onTap: () {}),
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
                          minimumSize: const Size(double.infinity, 50),
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
                Text(
                  user?.userFullname ?? '',
                  style: Canvas701Typography.headlineSmall,
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
            onPressed: () {},
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
            children: items,
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
