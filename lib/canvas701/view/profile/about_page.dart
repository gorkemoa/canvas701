import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/canvas701_theme_data.dart';
import '../../viewmodel/about_viewmodel.dart';
import '../../model/about_info_model.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AboutViewModel>().fetchAboutInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Canvas701Colors.background,
      appBar: AppBar(
        title: const Text('Hakkımızda', style: TextStyle(fontSize: 18,color: Canvas701Colors.background)),
        backgroundColor: Canvas701Colors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Canvas701Colors.background),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AboutViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Canvas701Colors.primary));
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(viewModel.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.fetchAboutInfo(),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          final info = viewModel.aboutInfo;
          if (info == null) {
            return const Center(child: Text('Bilgi bulunamadı.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/Canvas701-Logo.png',
                    height: 60,
                  ),
                ),
                const SizedBox(height: 32),
                _buildSectionTitle('Bize Ulaşın'),
                _buildContactCard(info),
                const SizedBox(height: 32),
                _buildSectionTitle('Sosyal Medya'),
                _buildSocialSection(info),
                const SizedBox(height: 32),
                _buildSectionTitle('Hakkımızda'),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Canvas701Colors.surface,
                    borderRadius: Canvas701Radius.cardRadius,
                    boxShadow: [Canvas701Shadows.subtle],
                  ),
                  child: Text(
                    _cleanHtml(info.contactAboutDesc),
                    style: Canvas701Typography.bodyMedium.copyWith(height: 1.6),
                  ),
                ),
                const SizedBox(height: 48),
                Center(
                  child: Text(
                    '© 2026 Office701. Tüm hakları saklıdır.',
                    style: Canvas701Typography.bodySmall,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: Canvas701Typography.labelMedium.copyWith(
          color: Canvas701Colors.textSecondary,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildContactCard(AboutInfoData info) {
    return Container(
      decoration: BoxDecoration(
        color: Canvas701Colors.surface,
        borderRadius: Canvas701Radius.cardRadius,
        boxShadow: [Canvas701Shadows.subtle],
      ),
      child: Column(
        children: [
          _buildContactItem(
            icon: Icons.location_on_outlined,
            title: 'Adres',
            subtitle: info.contactAddress,
            onTap: () {},
          ),
          const Divider(height: 1, indent: 60, color: Canvas701Colors.divider),
          _buildContactItem(
            icon: Icons.phone_outlined,
            title: 'Telefon',
            subtitle: info.contactPhone,
            onTap: () => _launchUrl('tel:${info.contactPhone}'),
          ),
          const Divider(height: 1, indent: 60, color: Canvas701Colors.divider),
          _buildContactItem(
            icon: Icons.email_outlined,
            title: 'E-posta',
            subtitle: info.contactEmail,
            onTap: () => _launchUrl('mailto:${info.contactEmail}'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Canvas701Colors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Canvas701Colors.primary, size: 24),
      ),
      title: Text(title, style: Canvas701Typography.labelMedium),
      subtitle: Text(
        subtitle,
        style: Canvas701Typography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right, color: Canvas701Colors.textTertiary, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildSocialSection(AboutInfoData info) {
    return Row(
      children: [
        if (info.contactFacebook.isNotEmpty)
          _buildSocialButton(
            icon: Icons.facebook,
            color: const Color(0xFF1877F2),
            onTap: () => _launchUrl(info.contactFacebook),
          ),
        if (info.contactInstagram.isNotEmpty)
          _buildSocialButton(
            icon: Icons.camera_alt_outlined,
            color: const Color(0xFFE4405F),
            onTap: () => _launchUrl(info.contactInstagram),
          ),
        if (info.contactTwitter.isNotEmpty)
          _buildSocialButton(
            icon: Icons.alternate_email,
            color: const Color(0xFF1DA1F2),
            onTap: () => _launchUrl(info.contactTwitter),
          ),
        if (info.contactLinkedin.isNotEmpty)
          _buildSocialButton(
            icon: Icons.business,
            color: const Color(0xFF0077B5),
            onTap: () => _launchUrl(info.contactLinkedin),
          ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bağlantı açılamadı.')),
        );
      }
    }
  }

  String _cleanHtml(String html) {
    if (html.isEmpty) return '';
    return html
        .replaceAll('<p>', '')
        .replaceAll('</p>', '\n\n')
        .replaceAll('<br>', '\n')
        .replaceAll('<br />', '\n')
        .replaceAll('<em>', '')
        .replaceAll('</em>', '')
        .replaceAll('<strong>', '')
        .replaceAll('</strong>', '')
        .replaceAll('&bull;', '•')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&ccedil;', 'ç')
        .replaceAll('&Ccedil;', 'Ç')
        .replaceAll('&ouml;', 'ö')
        .replaceAll('&Ouml;', 'Ö')
        .replaceAll('&uuml;', 'ü')
        .replaceAll('&Uuml;', 'Ü')
        .replaceAll('&eth;', 'ğ')
        .replaceAll('&ETH;', 'Ğ')
        .replaceAll('&thorn;', 'ş')
        .replaceAll('&THORN;', 'Ş')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();
  }
}
