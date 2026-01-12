import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/canvas701_theme_data.dart';
import '../../viewmodel/profile_viewmodel.dart';
import '../../model/coupon_model.dart';

class CouponsPage extends StatefulWidget {
  const CouponsPage({super.key});

  @override
  State<CouponsPage> createState() => _CouponsPageState();
}

class _CouponsPageState extends State<CouponsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().fetchCoupons();
    });
  }

  void _copyCouponCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: Canvas701Spacing.sm),
            Text('Kupon kodu kopyalandı'),
          ],
        ),
        backgroundColor: Canvas701Colors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(Canvas701Spacing.md),
        shape: RoundedRectangleBorder(borderRadius: Canvas701Radius.buttonRadius),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Canvas701Colors.background,
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          return CustomScrollView(
            slivers: [
              // AppBar
              SliverAppBar(
                backgroundColor: Canvas701Colors.primary,
                pinned: true,
                elevation: 0,
                centerTitle: true,
                leading: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Canvas701Colors.background,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Kuponlarım',
                  style: TextStyle(color: Canvas701Colors.background, fontSize: 18, fontWeight: FontWeight.w600),
                  
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1),
                  child: Container(
                    color: Canvas701Colors.divider,
                    height: 1,
                  ),
                ),
              ),

              // Bilgi Banner
              SliverToBoxAdapter(child: _buildInfoBanner()),

              // Content
              if (viewModel.isLoading && viewModel.coupons.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: Canvas701Colors.primary),
                  ),
                )
              else if (viewModel.errorMessage != null && viewModel.coupons.isEmpty)
                SliverFillRemaining(child: _buildErrorState(viewModel))
              else if (viewModel.coupons.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: Canvas701Spacing.md),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildCouponCard(viewModel.coupons[index]),
                      childCount: viewModel.coupons.length,
                    ),
                  ),
                )
              else
                SliverFillRemaining(child: _buildEmptyState()),

              const SliverToBoxAdapter(child: SizedBox(height: Canvas701Spacing.xxl)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.all(Canvas701Spacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: Canvas701Spacing.md,
        vertical: Canvas701Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: Canvas701Colors.primary.withOpacity(0.08),
        borderRadius: Canvas701Radius.buttonRadius,
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer_outlined, color: Canvas701Colors.primary, size: 18),
          const SizedBox(width: Canvas701Spacing.sm),
          Expanded(
            child: Text(
              'Kuponlarınızı sepet sayfasında kullanabilirsiniz',
              style: Canvas701Typography.labelMedium.copyWith(
                color: Canvas701Colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ProfileViewModel viewModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Canvas701Spacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Canvas701Colors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: Canvas701Colors.error,
              ),
            ),
            const SizedBox(height: Canvas701Spacing.lg),
            const Text('Bir Hata Oluştu', style: Canvas701Typography.headlineSmall),
            const SizedBox(height: Canvas701Spacing.sm),
            Text(
              viewModel.errorMessage ?? 'Kuponlar yüklenirken bir hata oluştu',
              style: Canvas701Typography.bodyMedium.copyWith(
                color: Canvas701Colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Canvas701Spacing.xl),
            ElevatedButton.icon(
              onPressed: () => viewModel.fetchCoupons(),
              icon: const Icon(Icons.refresh),
              label: const Text('Tekrar Dene'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Canvas701Colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: Canvas701Spacing.xl,
                  vertical: Canvas701Spacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: Canvas701Radius.buttonRadius,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Canvas701Spacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Canvas701Colors.primary.withOpacity(0.1),
                    Canvas701Colors.primary.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_offer_outlined,
                size: 56,
                color: Canvas701Colors.primary,
              ),
            ),
            const SizedBox(height: Canvas701Spacing.xl),
            const Text('Kupon Bulunamadı', style: Canvas701Typography.headlineSmall),
            const SizedBox(height: Canvas701Spacing.sm),
            Text(
              'Henüz kullanabileceğiniz bir kuponunuz bulunmuyor.',
              style: Canvas701Typography.bodyMedium.copyWith(
                color: Canvas701Colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponCard(Coupon coupon) {
    final isActive = coupon.couponStatus == '1' && !coupon.isUsed;

    return Container(
      margin: const EdgeInsets.only(bottom: Canvas701Spacing.md),
      decoration: BoxDecoration(
        color: Canvas701Colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Canvas701Colors.primary.withOpacity(0.1) : Canvas701Colors.divider,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Opacity(
        opacity: isActive ? 1.0 : 0.6,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Sol Renk Çubuğu
                Container(
                  width: 6,
                  color: isActive ? Canvas701Colors.primary : Canvas701Colors.textTertiary,
                ),
                // İçerik
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    coupon.couponDiscountType == '%'
                                        ? '%${coupon.couponDiscount} İndirim'
                                        : '${coupon.couponDiscount} TL İndirim',
                                    style: Canvas701Typography.titleLarge.copyWith(
                                      color: isActive ? Canvas701Colors.primary : Canvas701Colors.textPrimary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    coupon.couponDesc.isNotEmpty 
                                        ? coupon.couponDesc 
                                        : '${coupon.minBasketAmount} ve üzeri alışverişlerde geçerli',
                                    style: Canvas701Typography.bodySmall.copyWith(
                                      color: Canvas701Colors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isActive)
                              TextButton(
                                onPressed: () => _copyCouponCode(coupon.couponCode),
                                style: TextButton.styleFrom(
                                  backgroundColor: Canvas701Colors.primary.withOpacity(0.05),
                                  foregroundColor: Canvas701Colors.primary,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                  minimumSize: const Size(0, 32),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(color: Canvas701Colors.primary.withOpacity(0.2)),
                                  ),
                                ),
                                child: const Text(
                                  'Kopyala',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              )
                            else if (coupon.isUsed)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Canvas701Colors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Kullanıldı',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Canvas701Colors.success,
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Canvas701Colors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Pasif',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Canvas701Colors.error,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, thickness: 0.5),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.confirmation_number_outlined, size: 14, color: Canvas701Colors.textTertiary),
                                const SizedBox(width: 4),
                                Text(
                                  coupon.couponCode,
                                  style: Canvas701Typography.labelMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 14, color: Canvas701Colors.textTertiary),
                                const SizedBox(width: 4),
                                Text(
                                  'Son Gün: ${coupon.couponEndDate.split(' ').first}',
                                  style: Canvas701Typography.labelSmall.copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


