import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/canvas701_theme_data.dart';
import '../../viewmodel/general_viewmodel.dart';
import 'ticket/create_ticket_page.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<GeneralViewModel>().fetchFaqs();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Canvas701Colors.background,
      appBar: AppBar(
        title: const Text('Sıkça Sorulan Sorular', style: TextStyle(fontSize: 18 , color: Canvas701Colors.surface)),
        backgroundColor: Canvas701Colors.primary,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Canvas701Colors.surface),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Canvas701Colors.divider, height: 1),
        ),
      ),
      body: Consumer<GeneralViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.faqs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.faqs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.help_outline,
                    size: 64,
                    color: Canvas701Colors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Henüz soru bulunamadı.',
                    style: TextStyle(color: Canvas701Colors.textSecondary),
                  ),
                  TextButton(
                    onPressed: () => viewModel.fetchFaqs(),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final faq = viewModel.faqs[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 1),
                        color: Canvas701Colors.surface,
                        child: ExpansionTile(
                          shape: const Border(),
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          title: Text(
                            faq.faqTitle ?? '',
                            style: Canvas701Typography.titleMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          childrenPadding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: 20,
                          ),
                          expandedAlignment: Alignment.topLeft,
                          iconColor: Canvas701Colors.primary,
                          collapsedIconColor: Canvas701Colors.textTertiary,
                          children: [
                            Text(
                              faq.faqExcerpt ?? '',
                              style: Canvas701Typography.bodyMedium.copyWith(
                                color: Canvas701Colors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: viewModel.faqs.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Divider(color: Canvas701Colors.divider),
                      const SizedBox(height: 24),
                      const Text(
                        'Sorununuzu çözemediniz mi?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Canvas701Colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Size yardımcı olmamız için lütfen destek talebi oluşturun.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Canvas701Colors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateTicketPage(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Canvas701Colors.primary,
                          side: const BorderSide(color: Canvas701Colors.primary),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Destek Talebi Oluştur'),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
