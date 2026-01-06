import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import '../../theme/canvas701_theme_data.dart';
import '../../viewmodel/profile_viewmodel.dart';
import '../../model/user_models.dart';

class ProfileInfoPage extends StatefulWidget {
  const ProfileInfoPage({super.key});

  @override
  State<ProfileInfoPage> createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _birthdayController;
  late TextEditingController _addressController;
  String _selectedGender = 'Belirtilmemiş';
  String? _base64Image;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    final user = context.read<ProfileViewModel>().user;
    _firstNameController = TextEditingController(text: user?.userFirstname);
    _lastNameController = TextEditingController(text: user?.userLastname);
    _emailController = TextEditingController(text: user?.userEmail);
    _phoneController = TextEditingController(text: user?.userPhone);
    _birthdayController = TextEditingController(text: user?.userBirthday);
    _addressController = TextEditingController(text: '');
    final userGender = user?.userGender;
    if (userGender != null &&
        ['Erkek', 'Kadın', 'Belirtilmemiş'].contains(userGender)) {
      _selectedGender = userGender;
    } else {
      _selectedGender = 'Belirtilmemiş';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Canvas701Colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Canvas701Colors.primary,
              ),
              title: const Text('Galeriden Seç'),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: Canvas701Colors.primary,
              ),
              title: const Text('Fotoğraf Çek'),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      _cropImage(image.path);
    }
  }

  Future<void> _cropImage(String path) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Fotoğrafı Düzenle',
          toolbarColor: Canvas701Colors.primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          activeControlsWidgetColor: Canvas701Colors.primary,
        ),
        IOSUiSettings(
          title: 'Fotoğrafı Düzenle',
          cancelButtonTitle: 'Vazgeç',
          doneButtonTitle: 'Bitti',
          aspectRatioLockEnabled: true,
          resetButtonHidden: false,
          rotateButtonsHidden: false,
          rotateClockwiseButtonHidden: false,
        ),
      ],
    );

    if (croppedFile != null) {
      final bytes = await croppedFile.readAsBytes();
      setState(() {
        _selectedImage = File(croppedFile.path);
        _base64Image = base64Encode(bytes);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<ProfileViewModel>();
    final user = viewModel.user;
    if (user == null) return;

    final request = UpdateUserRequest(
      userToken: user.userToken,
      userFirstname: _firstNameController.text,
      userLastname: _lastNameController.text,
      userEmail: _emailController.text,
      userBirthday: _birthdayController.text,
      userPhone: _phoneController.text,
      userAddress: _addressController.text,
      userGender: _selectedGender,
      profilePhoto: _base64Image ?? '',
    );

    final response = await viewModel.updateUser(request);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.data?.message ??
                (response.success ? 'Profil güncellendi' : 'Hata oluştu'),
          ),
          backgroundColor: response.success
              ? Canvas701Colors.success
              : Canvas701Colors.error,
        ),
      );
      if (response.success) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Canvas701Colors.background,
      appBar: AppBar(
        title: const Text(
          'Kişisel Bilgilerim',
          style: Canvas701Typography.titleLarge,
        ),
        backgroundColor: Canvas701Colors.surface,
        foregroundColor: Canvas701Colors.textPrimary,
        elevation: 0,
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Kaydet',
              style: TextStyle(
                color: Canvas701Colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Canvas701Colors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Canvas701Colors.divider,
                              width: 2,
                            ),
                          ),
                          child: _selectedImage != null
                              ? ClipOval(
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : (viewModel.user?.profilePhoto.isNotEmpty == true
                                    ? ClipOval(
                                        child: Image.network(
                                          viewModel.user!.profilePhoto,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Canvas701Colors.primary,
                                      )),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Canvas701Colors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Temel Bilgiler'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _firstNameController,
                    label: 'Ad',
                    hint: 'Adınızı giriniz',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _lastNameController,
                    label: 'Soyad',
                    hint: 'Soyadınızı giriniz',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'E-posta',
                    hint: 'E-posta adresinizi giriniz',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('İletişim ve Diğer'),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Telefon',
                    hint: 'Telefon numaranızı giriniz',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildPickerField(
                    label: 'Doğum Tarihi',
                    value: _birthdayController.text.isEmpty
                        ? 'GG.AA.YYYY'
                        : _birthdayController.text,
                    onTap: _showBirthdayPicker,
                    icon: Icons.calendar_today_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildPickerField(
                    label: 'Cinsiyet',
                    value: _selectedGender,
                    onTap: _showGenderPicker,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Adres',
                    hint: 'Adresinizi giriniz',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
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
          ),
        ),
      ],
    );
  }

  Widget _buildPickerField({
    required String label,
    required String value,
    required VoidCallback onTap,
    required IconData icon,
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Canvas701Colors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Canvas701Colors.divider),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Canvas701Colors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value,
                    style: Canvas701Typography.bodyLarge.copyWith(
                      color: value.contains('.') || !value.contains('G')
                          ? Canvas701Colors.textPrimary
                          : Canvas701Colors.textTertiary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: Canvas701Colors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showGenderPicker() async {
    final List<String> genders = ['Erkek', 'Kadın', 'Belirtilmemiş'];
    int selectedIndex = genders.indexOf(_selectedGender);
    if (selectedIndex == -1) selectedIndex = 2;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Canvas701Colors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _buildPickerHeader(
              title: 'Cinsiyet Seçin',
              onDone: () => Navigator.pop(context),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                scrollController: FixedExtentScrollController(
                  initialItem: selectedIndex,
                ),
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedGender = genders[index];
                  });
                },
                children: genders
                    .map(
                      (g) => Center(
                        child: Text(g, style: Canvas701Typography.bodyLarge),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showBirthdayPicker() async {
    final List<String> turkishMonths = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];

    int selectedDay = 1;
    int selectedMonth = 1;
    int selectedYear = DateTime.now().year - 20;

    try {
      if (_birthdayController.text.isNotEmpty) {
        final parts = _birthdayController.text.split('.');
        if (parts.length == 3) {
          selectedDay = int.parse(parts[0]);
          selectedMonth = int.parse(parts[1]);
          selectedYear = int.parse(parts[2]);
        }
      }
    } catch (_) {}

    final int currentYear = DateTime.now().year;
    final List<int> years = List.generate(
      currentYear - 1900 + 1,
      (i) => 1900 + i,
    );

    int getDaysInMonth(int month, int year) {
      return DateTime(year, month + 1, 0).day;
    }

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final daysInMonth = getDaysInMonth(selectedMonth, selectedYear);
            if (selectedDay > daysInMonth) {
              selectedDay = daysInMonth;
            }

            return Container(
              height: 350,
              decoration: const BoxDecoration(
                color: Canvas701Colors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  _buildPickerHeader(
                    title: 'Doğum Tarihi Seçin',
                    onDone: () {
                      setState(() {
                        _birthdayController.text =
                            "${selectedDay.toString().padLeft(2, '0')}.${selectedMonth.toString().padLeft(2, '0')}.$selectedYear";
                      });
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        // Day picker
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 40,
                            scrollController: FixedExtentScrollController(
                              initialItem: selectedDay - 1,
                            ),
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                selectedDay = index + 1;
                              });
                            },
                            children: List.generate(
                              daysInMonth,
                              (i) => Center(
                                child: Text(
                                  '${i + 1}',
                                  style: Canvas701Typography.bodyLarge,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Month picker (Turkish)
                        Expanded(
                          flex: 1,
                          child: CupertinoPicker(
                            itemExtent: 40,
                            scrollController: FixedExtentScrollController(
                              initialItem: selectedMonth - 1,
                            ),
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                selectedMonth = index + 1;
                              });
                            },
                            children: turkishMonths
                                .map(
                                  (m) => Center(
                                    child: Text(
                                      m,
                                      style: Canvas701Typography.bodyLarge,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        // Year picker
                        Expanded(
                          flex: 1,
                          child: CupertinoPicker(
                            itemExtent: 40,
                            scrollController: FixedExtentScrollController(
                              initialItem: years.indexOf(selectedYear),
                            ),
                            onSelectedItemChanged: (index) {
                              setModalState(() {
                                selectedYear = years[index];
                              });
                            },
                            children: years
                                .map(
                                  (y) => Center(
                                    child: Text(
                                      '$y',
                                      style: Canvas701Typography.bodyLarge,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
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
