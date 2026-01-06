import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../theme/canvas701_theme_data.dart';
import '../../viewmodel/add_address_viewmodel.dart';
import '../../model/address_models.dart';

class AddAddressPage extends StatelessWidget {
  final UserAddress? initialAddress;
  const AddAddressPage({super.key, this.initialAddress});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddAddressViewModel()..initialize(initialAddress),
      child: _AddAddressView(initialAddress: initialAddress),
    );
  }
}

class _AddAddressView extends StatefulWidget {
  final UserAddress? initialAddress;
  const _AddAddressView({this.initialAddress});

  @override
  State<_AddAddressView> createState() => _AddAddressViewState();
}

class _AddAddressViewState extends State<_AddAddressView> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _titleController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressDetailController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _companyNameController;
  late final TextEditingController _taxNumberController;
  late final TextEditingController _taxOfficeController;
  late final TextEditingController _invoiceAddressController;
  late final TextEditingController _identityNumberController;

  @override
  void initState() {
    super.initState();
    final addr = widget.initialAddress;
    _titleController = TextEditingController(text: addr?.addressTitle ?? '');
    _firstNameController = TextEditingController(
      text: addr?.addressFirstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: addr?.addressLastName ?? '',
    );
    _phoneController = TextEditingController(text: addr?.addressPhone ?? '');
    _emailController = TextEditingController(text: addr?.addressEmail ?? '');
    _addressDetailController = TextEditingController(text: addr?.address ?? '');
    _postalCodeController = TextEditingController(text: addr?.postalCode ?? '');
    _companyNameController = TextEditingController(
      text: addr?.realCompanyName ?? '',
    );
    _taxNumberController = TextEditingController(text: addr?.taxNumber ?? '');
    _taxOfficeController = TextEditingController(
      text: addr?.taxAdministration ?? '',
    );
    _invoiceAddressController = TextEditingController(
      text: addr?.invoiceAddress ?? '',
    );
    _identityNumberController = TextEditingController(
      text: addr?.identityNumber ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressDetailController.dispose();
    _postalCodeController.dispose();
    _companyNameController.dispose();
    _taxNumberController.dispose();
    _taxOfficeController.dispose();
    _invoiceAddressController.dispose();
    _identityNumberController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<AddAddressViewModel>();

    // Validate dropdowns
    if (viewModel.selectedCityId == null ||
        viewModel.selectedDistrictId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen İl ve İlçe seçiniz.')),
      );
      return;
    }

    final response = await viewModel.submitAddress(
      title: _titleController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      phone: _phoneController.text,
      email: _emailController.text,
      addressDetail: _addressDetailController.text,
      postalCode: _postalCodeController.text,
      companyName: viewModel.addressType == 2
          ? _companyNameController.text
          : null,
      taxNumber: viewModel.addressType == 2 ? _taxNumberController.text : null,
      taxOffice: viewModel.addressType == 2 ? _taxOfficeController.text : null,
      invoiceAddress: viewModel.addressType == 2
          ? _invoiceAddressController.text
          : null,
      identityNumber: viewModel.addressType == 1
          ? _identityNumberController.text
          : null,
    );

    if (context.mounted) {
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              viewModel.isEditMode
                  ? 'Adres başarıyla güncellendi.'
                  : 'Adres başarıyla eklendi.',
            ),
            backgroundColor: Canvas701Colors.success,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.errorMessage ??
                  response.data?.message ??
                  'Bir hata oluştu.',
            ),
            backgroundColor: Canvas701Colors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddAddressViewModel>();

    return Scaffold(
      backgroundColor: Canvas701Colors.background,
      appBar: AppBar(
        title: Text(
          viewModel.isEditMode ? 'Adresi Düzenle' : 'Yeni Adres Ekle',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Canvas701Colors.primary,
        foregroundColor: Colors.white, // geri ikon + title
        iconTheme: const IconThemeData(
          color: Colors.white, // geri ikon kesin beyaz
        ),
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Canvas701Colors.surface,
          border: Border(top: BorderSide(color: Canvas701Colors.divider)),
        ),
        child: SafeArea(
          // iOS bottom handle safe area
          child: ElevatedButton(
            onPressed: viewModel.isLoading ? null : () => _submit(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Canvas701Colors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: viewModel.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Kaydet', style: Canvas701Typography.button),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Adres Tipi'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTypeOption(
                      label: 'Bireysel',
                      isSelected: viewModel.addressType == 1,
                      onTap: () => viewModel.setAddressType(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTypeOption(
                      label: 'Kurumsal',
                      isSelected: viewModel.addressType == 2,
                      onTap: () => viewModel.setAddressType(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Adres Başlığı'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _titleController,
                label: 'Başlık (Ev, İş vb.)',
                hint: 'Adres başlığı giriniz',
                validationMsg: 'Başlık zorunludur',
              ),

              const SizedBox(height: 24),

              if (viewModel.addressType == 1) ...[
                _buildSectionTitle('Kimlik Bilgileri'),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _identityNumberController,
                  label: 'TC Kimlik No',
                  hint: 'TC Kimlik Numaranızı giriniz',
                  keyboardType: TextInputType.number,
                  validationMsg: 'TC Kimlik No zorunludur',
                ),
                const SizedBox(height: 24),
              ],

              _buildSectionTitle('İletişim Bilgileri'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _firstNameController,
                      label: 'Ad',
                      hint: 'Adınız',
                      validationMsg: 'Ad zorunludur',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _lastNameController,
                      label: 'Soyad',
                      hint: 'Soyadınız',
                      validationMsg: 'Soyad zorunludur',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Telefon',
                hint: '(555) 000 00 00',
                keyboardType: TextInputType.phone,
                validationMsg: 'Telefon zorunludur',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'E-posta',
                hint: 'ornek@mail.com',
                keyboardType: TextInputType.emailAddress,
                validationMsg: 'E-posta zorunludur',
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('Adres Detayları'),
              const SizedBox(height: 12),

              // Dropdowns
              // Pickers
              if (viewModel.isCitiesLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                _buildPickerField(
                  label: 'İl',
                  value: viewModel.selectedCityId != null
                      ? viewModel.cities
                            .firstWhere(
                              (c) => c.cityNo == viewModel.selectedCityId,
                              orElse: () => City(cityNo: -1, cityName: ''),
                            )
                            .cityName
                      : 'İl Seçiniz',
                  onTap: () => _showCityPicker(viewModel),
                  enabled: viewModel.cities.isNotEmpty,
                ),

              const SizedBox(height: 16),

              if (viewModel.isDistrictsLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                _buildPickerField(
                  label: 'İlçe',
                  value: viewModel.selectedDistrictId != null
                      ? viewModel.districts
                            .firstWhere(
                              (d) =>
                                  d.districtNo == viewModel.selectedDistrictId,
                              orElse: () =>
                                  District(districtNo: -1, districtName: ''),
                            )
                            .districtName
                      : 'İlçe Seçiniz',
                  onTap: () => _showDistrictPicker(viewModel),
                  enabled:
                      viewModel.selectedCityId != null &&
                      viewModel.districts.isNotEmpty,
                ),

              const SizedBox(height: 16),
              _buildTextField(
                controller: _addressDetailController,
                label: 'Adres',
                hint: 'Cadde, sokak, kapı no...',
                maxLines: 3,
                validationMsg: 'Adres zorunludur',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _postalCodeController,
                label: 'Posta Kodu',
                hint: '34000',
                keyboardType: TextInputType.number,
                validationMsg: 'Posta kodu zorunludur',
              ),

              if (viewModel.addressType == 2) ...[
                const SizedBox(height: 24),
                _buildSectionTitle('Fatura Bilgileri'),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _companyNameController,
                  label: 'Şirket Adı',
                  hint: 'Şirket tam ünvanı',
                  validationMsg: 'Şirket adı zorunludur',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _taxOfficeController,
                  label: 'Vergi Dairesi',
                  hint: 'Vergi dairesi',
                  validationMsg: 'Vergi dairesi zorunludur',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _taxNumberController,
                  label: 'Vergi Numarası',
                  hint: 'Vergi numarası',
                  keyboardType: TextInputType.number,
                  validationMsg: 'Vergi numarası zorunludur',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _invoiceAddressController,
                  label: 'Fatura Adresi',
                  hint: 'Fatura adresi farklı ise giriniz',
                  maxLines: 2,
                  validationMsg: 'Alan zorunludur',
                ),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Canvas701Typography.titleMedium.copyWith(
        color: Canvas701Colors.textSecondary,
      ),
    );
  }

  Widget _buildTypeOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Canvas701Colors.primary.withOpacity(0.1)
              : Canvas701Colors.surface,
          border: Border.all(
            color: isSelected
                ? Canvas701Colors.primary
                : Canvas701Colors.divider,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Canvas701Colors.primary
                : Canvas701Colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? validationMsg,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Canvas701Typography.bodySmall.copyWith(
            color: Canvas701Colors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: Canvas701Typography.bodyLarge,
          validator: validationMsg != null
              ? (value) => value == null || value.isEmpty ? validationMsg : null
              : null,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Canvas701Colors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Canvas701Colors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Canvas701Colors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Canvas701Colors.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Canvas701Colors.error),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPickerField({
    required String label,
    required String value,
    required VoidCallback onTap,
    required bool enabled,
    IconData icon = Icons.keyboard_arrow_down,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Canvas701Typography.bodySmall.copyWith(
            color: Canvas701Colors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: enabled
                  ? Canvas701Colors.surface
                  : Canvas701Colors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Canvas701Colors.divider),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: Canvas701Typography.bodyLarge.copyWith(
                      color: value.isEmpty || value.contains('Seçiniz')
                          ? Canvas701Colors.textTertiary
                          : Canvas701Colors.textPrimary,
                    ),
                  ),
                ),
                Icon(icon, size: 20, color: Canvas701Colors.textTertiary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showCityPicker(AddAddressViewModel viewModel) async {
    if (viewModel.cities.isEmpty) return;

    int selectedIndex = 0;
    if (viewModel.selectedCityId != null) {
      selectedIndex = viewModel.cities.indexWhere(
        (c) => c.cityNo == viewModel.selectedCityId,
      );
      if (selectedIndex == -1) selectedIndex = 0;
    }

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // Use StatefulBuilder to manage local state within the bottom sheet
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: 300,
              decoration: const BoxDecoration(
                color: Canvas701Colors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  _buildPickerHeader(
                    title: 'İl Seçin',
                    onDone: () {
                      viewModel.setCity(viewModel.cities[selectedIndex].cityNo);
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 40,
                      scrollController: FixedExtentScrollController(
                        initialItem: selectedIndex,
                      ),
                      onSelectedItemChanged: (index) {
                        setModalState(() {
                          selectedIndex = index;
                        });
                      },
                      children: viewModel.cities
                          .map(
                            (c) => Center(
                              child: Text(
                                c.cityName,
                                style: Canvas701Typography.bodyLarge,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showDistrictPicker(AddAddressViewModel viewModel) async {
    if (viewModel.districts.isEmpty) return;

    int selectedIndex = 0;
    if (viewModel.selectedDistrictId != null) {
      selectedIndex = viewModel.districts.indexWhere(
        (d) => d.districtNo == viewModel.selectedDistrictId,
      );
      if (selectedIndex == -1) selectedIndex = 0;
    }

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: 300,
              decoration: const BoxDecoration(
                color: Canvas701Colors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  _buildPickerHeader(
                    title: 'İlçe Seçin',
                    onDone: () {
                      viewModel.setDistrict(
                        viewModel.districts[selectedIndex].districtNo,
                      );
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 40,
                      scrollController: FixedExtentScrollController(
                        initialItem: selectedIndex,
                      ),
                      onSelectedItemChanged: (index) {
                        setModalState(() {
                          selectedIndex = index;
                        });
                      },
                      children: viewModel.districts
                          .map(
                            (d) => Center(
                              child: Text(
                                d.districtName,
                                style: Canvas701Typography.bodyLarge,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPickerHeader({
    required String title,
    required VoidCallback onDone,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Canvas701Colors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Canvas701Typography.titleMedium),
          CupertinoButton(
            onPressed: onDone,
            child: const Text(
              'Bitti',
              style: TextStyle(
                color: Canvas701Colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
