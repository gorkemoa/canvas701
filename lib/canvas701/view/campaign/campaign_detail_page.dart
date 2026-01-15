import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/product_models.dart';
import '../../viewmodel/product_viewmodel.dart';
import '../../viewmodel/favorites_viewmodel.dart';
import '../../theme/canvas701_theme_data.dart';
import '../widgets/widgets.dart';
import '../product/product_detail_page.dart';

class CampaignDetailPage extends StatefulWidget {
  final int campaignId;
  final String title;

  const CampaignDetailPage({
    super.key,
    required this.campaignId,
    required this.title,
  });

  @override
  State<CampaignDetailPage> createState() => _CampaignDetailPageState();
}

class _CampaignDetailPageState extends State<CampaignDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductViewModel>().fetchCampaignDetail(widget.campaignId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Canvas701Colors.background,
      appBar: AppBar(
        title: Text(widget.title, style: Canvas701Typography.titleMedium.copyWith(color: Colors.white,fontSize: 18)),
        backgroundColor: Canvas701Colors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<ProductViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isCampaignDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final campaign = viewModel.selectedCampaign;
          if (campaign == null || campaign.products.isEmpty) {
            return const Center(child: Text('Kampanyaya ait ürün bulunamadı.'));
          }

          return CustomScrollView(
            slivers: [
              if (campaign.campImage.isNotEmpty)
                SliverToBoxAdapter(
                  child: Image.network(
                    campaign.campImage,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.fill,
                  ),
                ),
              if (campaign.campDesc.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(Canvas701Spacing.md),
                    child: Text(
                      _stripHtml(campaign.campDesc),
                      style: Canvas701Typography.bodyMedium,
                    ),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.all(Canvas701Spacing.md),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.5,
                    crossAxisSpacing: Canvas701Spacing.md,
                    mainAxisSpacing: Canvas701Spacing.md,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final apiProduct = campaign.products[index];
                      final product = Product.fromApi(apiProduct);
                      
                      return Consumer<FavoritesViewModel>(
                        builder: (context, favViewModel, _) {
                          final isFav = favViewModel.isFavorite(apiProduct.productID);
                          return ProductCard(
                            product: product,
                            isFavorite: isFav,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailPage(product: product),
                                ),
                              );
                            },
                            onFavorite: () {
                              favViewModel.toggleFavorite(apiProduct.productID);
                            },
                          );
                        },
                      );
                    },
                    childCount: campaign.products.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _stripHtml(String? htmlString) {
    if (htmlString == null || htmlString.isEmpty) return '';
    return htmlString
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&ccedil;', 'ç')
        .replaceAll('&Ccedil;', 'Ç')
        .replaceAll('&ouml;', 'ö')
        .replaceAll('&Ouml;', 'Ö')
        .replaceAll('&uuml;', 'ü')
        .replaceAll('&Uuml;', 'Ü')
        .replaceAll('&igrave;', 'i')
        .replaceAll('\r', '')
        .replaceAll('\n', '')
        .trim();
  }
}
