import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/canvas701_theme_data.dart';
import '../../viewmodel/address_viewmodel.dart';
import '../../model/address_models.dart';
import 'add_address_page.dart';

class AddressPage extends StatelessWidget {
  const AddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddressViewModel(),
      child: const _AddressView(),
    );
  }
}

class _AddressView extends StatefulWidget {
  const _AddressView();

  @override
  State<_AddressView> createState() => _AddressViewState();
}

class _AddressViewState extends State<_AddressView> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddressViewModel>();

    return Scaffold(
      backgroundColor: Canvas701Colors.background,
      appBar: AppBar(
        title: const Text(
          'Adreslerim',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Canvas701Colors.primary,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAddressPage()),
          );
          // Refresh list when returning
          if (context.mounted) {
            context.read<AddressViewModel>().fetchAddresses();
          }
        },
        backgroundColor: Canvas701Colors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(viewModel.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.fetchAddresses(),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            )
          : viewModel.addresses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_off_outlined,
                    size: 64,
                    color: Canvas701Colors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Kayıtlı adresiniz bulunmamaktadır.',
                    style: Canvas701Typography.bodyLarge.copyWith(
                      color: Canvas701Colors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 130),
              itemCount: viewModel.addresses.length,

              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final address = viewModel.addresses[index];
                final isExpanded = _expandedIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_expandedIndex == index) {
                        _expandedIndex = null;
                      } else {
                        _expandedIndex = index;
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: Canvas701Colors.surface,
                      border: Border.all(
                        color: isExpanded
                            ? Canvas701Colors.primary.withOpacity(0.5)
                            : Canvas701Colors.divider.withOpacity(0.5),
                        width: isExpanded ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header Section
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 16, 8, 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title & Type
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          address.addressTypeId == 2
                                              ? Icons.business_rounded
                                              : Icons.home_rounded,
                                          color: isExpanded
                                              ? Canvas701Colors.primary
                                              : Canvas701Colors.textTertiary,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          address.addressTitle,
                                          style: Canvas701Typography.titleMedium
                                              .copyWith(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                                color: isExpanded
                                                    ? Canvas701Colors.primary
                                                    : Canvas701Colors
                                                          .textPrimary,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 1,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Canvas701Colors.background,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        address.addressType,
                                        style: Canvas701Typography.labelSmall
                                            .copyWith(
                                              color:
                                                  Canvas701Colors.textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Edit/Delete Menu
                              PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddAddressPage(
                                          initialAddress: address,
                                        ),
                                      ),
                                    );
                                    if (context.mounted) {
                                      context
                                          .read<AddressViewModel>()
                                          .fetchAddresses();
                                    }
                                  } else if (value == 'delete') {
                                    _showDeleteConfirmation(context, address);
                                  }
                                },
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Canvas701Colors.textTertiary,
                                ),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.edit_outlined,
                                          size: 20,
                                          color: Canvas701Colors.textPrimary,
                                        ),
                                        SizedBox(width: 12),
                                        Text('Düzenle'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline,
                                          size: 20,
                                          color: Canvas701Colors.error,
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Sil',
                                          style: TextStyle(
                                            color: Canvas701Colors.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Expansion Indicator
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Canvas701Colors.background.withOpacity(0.5),
                            border: Border(
                              top: BorderSide(
                                color: Canvas701Colors.divider.withOpacity(0.5),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: isExpanded
                                ? Canvas701Colors.primary
                                : Canvas701Colors.textTertiary,
                            size: 24,
                          ),
                        ),
                        // Expanded Content
                        AnimatedCrossFade(
                          firstChild: Container(height: 0),
                          secondChild: Column(
                            children: [
                              const Divider(height: 1, thickness: 0.5),
                              // Info Section
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    _buildInfoRow(
                                      Icons.person_outline_rounded,
                                      '${address.addressFirstName} ${address.addressLastName}',
                                    ),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                      Icons.phone_outlined,
                                      address.addressPhone,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                      Icons.mail_outline_rounded,
                                      address.addressEmail,
                                    ),
                                    if (address.addressTypeId == 1 &&
                                        address.identityNumber.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      _buildInfoRow(
                                        Icons.badge_outlined,
                                        'TC: ${address.identityNumber}',
                                      ),
                                    ],
                                    if (address.addressTypeId == 2) ...[
                                      const SizedBox(height: 8),
                                      _buildInfoRow(
                                        Icons.business_center_outlined,
                                        address.realCompanyName,
                                      ),
                                      const SizedBox(height: 8),
                                      _buildInfoRow(
                                        Icons.receipt_long_outlined,
                                        '${address.taxAdministration} / ${address.taxNumber}',
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // Address Box
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.fromLTRB(
                                  12,
                                  0,
                                  12,
                                  12,
                                ),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Canvas701Colors.background,
                                  border: Border.all(
                                    color: Canvas701Colors.divider.withOpacity(
                                      0.5,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 20,
                                          color: Canvas701Colors.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '${address.addressDistrict} / ${address.addressCity}',
                                            style: Canvas701Typography
                                                .bodyMedium
                                                .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: Canvas701Colors
                                                      .textPrimary,
                                                ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Canvas701Colors.surface,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            border: Border.all(
                                              color: Canvas701Colors.divider,
                                            ),
                                          ),
                                          child: Text(
                                            address.postalCode,
                                            style: Canvas701Typography
                                                .labelSmall
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Canvas701Colors
                                                      .textSecondary,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 28),
                                      child: Text(
                                        address.address,
                                        style: Canvas701Typography.bodyMedium
                                            .copyWith(
                                              color:
                                                  Canvas701Colors.textSecondary,
                                              height: 1.4,
                                            ),
                                      ),
                                    ),
                                    if (address.invoiceAddress.isNotEmpty &&
                                        address.invoiceAddress !=
                                            address.address) ...[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 28,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 12),
                                            const Divider(),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Fatura Adresi:',
                                              style: Canvas701Typography
                                                  .labelSmall
                                                  .copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    color: Canvas701Colors
                                                        .textPrimary,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              address.invoiceAddress,
                                              style: Canvas701Typography
                                                  .bodySmall
                                                  .copyWith(
                                                    color: Canvas701Colors
                                                        .textSecondary,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          crossFadeState: isExpanded
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 300),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Canvas701Colors.textTertiary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Canvas701Typography.bodyMedium.copyWith(
              color: Canvas701Colors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, UserAddress address) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Adresi Sil'),
        content: Text(
          '${address.addressTitle} başlıklı adresi silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog
              final success = await context
                  .read<AddressViewModel>()
                  .deleteAddress(address.addressId);

              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Adres başarıyla silindi.'),
                      backgroundColor: Canvas701Colors.success,
                    ),
                  );
                } else {
                  final error = context.read<AddressViewModel>().errorMessage;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error ?? 'Adres silinirken hata oluştu.'),
                      backgroundColor: Canvas701Colors.error,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Sil',
              style: TextStyle(color: Canvas701Colors.error),
            ),
          ),
        ],
      ),
    );
  }
}
