import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/canvas701_theme_data.dart';
import '../../viewmodel/address_viewmodel.dart';
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
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.addresses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final address = viewModel.addresses[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Canvas701Colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Canvas701Colors.divider),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            child: Icon(
                              address.addressTypeId == 2
                                  ? Icons.business
                                  : Icons.home,
                              color: Canvas701Colors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  address.addressTitle,
                                  style: Canvas701Typography.titleMedium,
                                ),
                                Text(
                                  address.addressType,
                                  style: Canvas701Typography.bodySmall.copyWith(
                                    color: Canvas701Colors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Canvas701Colors.background,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Canvas701Colors.divider,
                              ),
                            ),
                            child: Text(
                              '${address.addressFirstName} ${address.addressLastName}',
                              style: Canvas701Typography.bodySmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Canvas701Colors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: 16,
                            color: Canvas701Colors.textTertiary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            address.addressPhone,
                            style: Canvas701Typography.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.mail_outline,
                            size: 16,
                            color: Canvas701Colors.textTertiary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            address.addressEmail,
                            style: Canvas701Typography.bodyMedium,
                          ),
                        ],
                      ),
                      if (address.addressTypeId == 1 &&
                          address.identityNumber.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.badge_outlined,
                              size: 16,
                              color: Canvas701Colors.textTertiary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'TC: ${address.identityNumber}',
                              style: Canvas701Typography.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                      if (address.addressTypeId == 2) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.business_outlined,
                              size: 16,
                              color: Canvas701Colors.textTertiary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                address.realCompanyName,
                                style: Canvas701Typography.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const SizedBox(width: 24),
                            Text(
                              '${address.taxAdministration} / ${address.taxNumber}',
                              style: Canvas701Typography.bodySmall,
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Canvas701Colors.background,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${address.addressDistrict} / ${address.addressCity}',
                                  style: Canvas701Typography.bodyMedium
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Canvas701Colors.surface,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: Canvas701Colors.divider,
                                    ),
                                  ),
                                  child: Text(
                                    address.postalCode,
                                    style: Canvas701Typography.bodySmall
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Canvas701Colors.textSecondary,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              address.address,
                              style: Canvas701Typography.bodyMedium.copyWith(
                                color: Canvas701Colors.textSecondary,
                              ),
                            ),
                            if (address.invoiceAddress.isNotEmpty &&
                                address.invoiceAddress != address.address) ...[
                              const Divider(height: 16),
                              Text(
                                'Fatura Adresi:',
                                style: Canvas701Typography.bodySmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                address.invoiceAddress,
                                style: Canvas701Typography.bodySmall.copyWith(
                                  color: Canvas701Colors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
