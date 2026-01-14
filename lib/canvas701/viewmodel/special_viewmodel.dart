import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/special_service.dart';
import '../services/general_service.dart';
import '../services/address_service.dart';
import '../services/token_manager.dart';
import '../model/special_models.dart';
import '../model/size_model.dart';
import '../model/address_models.dart';
import '../model/type_model.dart';
import '../theme/canvas701_theme_data.dart';
import '../view/widgets/image_filter_sheet.dart';
import 'profile_viewmodel.dart';

class SpecialViewModel extends ChangeNotifier {
  final SpecialService _specialService = SpecialService();
  final GeneralService _generalService = GeneralService();
  final AddressService _addressService = AddressService();
  final TokenManager _tokenManager = TokenManager();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSizesLoading = false;
  bool get isSizesLoading => _isSizesLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Onboarding
  bool _showOnboarding = false;
  bool get showOnboarding => _showOnboarding;
  List<String> _onboardingImages = [];
  List<String> get onboardingImages => _onboardingImages;

  // Sizes from API
  List<CanvasSize> _availableSizes = [];
  List<CanvasSize> get availableSizes => _availableSizes;

  // Product Types from API
  List<ProductType> _productTypes = [];
  List<ProductType> get productTypes => _productTypes;

  // Form Fields
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Selected Variants (Size + Image)
  final List<SelectedVariantData> _selectedVariants = [SelectedVariantData()];
  List<SelectedVariantData> get selectedVariants => _selectedVariants;

  // Saved Addresses
  List<UserAddress> _userAddresses = [];
  List<UserAddress> get userAddresses => _userAddresses;
  UserAddress? _selectedUserAddress;
  UserAddress? get selectedUserAddress => _selectedUserAddress;

  SpecialViewModel() {
    _prefillFromProfile();
    fetchSizes();
    fetchProductTypes();
    checkOnboarding();
    fetchUserAddresses();
  }

  Future<void> fetchUserAddresses() async {
    try {
      final response = await _addressService.getUserAddresses();
      if (response.success) {
        _userAddresses = response.addresses;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching user addresses: $e');
    }
  }

  void selectAddress(UserAddress? address) {
    _selectedUserAddress = address;
    if (address != null) {
      firstNameController.text = address.addressFirstName;
      lastNameController.text = address.addressLastName;
      phoneController.text = address.addressPhone;
      emailController.text = address.addressEmail;
      // API'den gelen literal \n karakterlerini gerçek alt satıra dönüştürüyoruz
      final formattedAddress = address.address.replaceAll('\\n', '\n');
      addressController.text = '${address.addressDistrict} / ${address.addressCity} (${address.postalCode})\n$formattedAddress';
    } else {
      _prefillFromProfile();
      addressController.text = '';
    }
    notifyListeners();
  }

  Future<void> checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final isDismissed = prefs.getBool('special_onboarding_dismissed') ?? false;
    
    if (!isDismissed) {
      final response = await _generalService.getSpecials();
      if (response.success && response.data != null && response.data!.images.isNotEmpty) {
        _onboardingImages = response.data!.images;
        _showOnboarding = true;
        notifyListeners();
      }
    }
  }

  Future<void> completeOnboarding({bool dontShowAgain = false}) async {
    if (dontShowAgain) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('special_onboarding_dismissed', true);
    }
    _showOnboarding = false;
    notifyListeners();
  }

  Future<void> fetchSizes() async {
    _isSizesLoading = true;
    notifyListeners();
    try {
      final response = await _generalService.getSizes();
      if (response.success && response.data != null) {
        _availableSizes = response.data!.sizes;
        if (_availableSizes.isNotEmpty && _selectedVariants[0].sizeTitle == null) {
          _selectedVariants[0].sizeTitle = _availableSizes[0].sizeTitle;
        }
      }
    } catch (e) {
      debugPrint('Error fetching sizes: $e');
    } finally {
      _isSizesLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProductTypes() async {
    try {
      final response = await _generalService.getTypes();
      if (response.success && response.data != null) {
        _productTypes = response.data!.types;
        // İlk variant için varsayılan tip seç
        if (_productTypes.isNotEmpty && _selectedVariants[0].tableType == null) {
          _selectedVariants[0].tableType = _productTypes[0].typeName;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching product types: $e');
    }
  }

  void _prefillFromProfile() {
    final user = ProfileViewModel().user;
    if (user != null) {
      final names = user.userFullname.split(' ');
      if (names.isNotEmpty) {
        firstNameController.text = names[0];
        if (names.length > 1) {
          lastNameController.text = names.sublist(1).join(' ');
        }
      }
      phoneController.text = user.userPhone;
      emailController.text = user.userEmail;
    }
  }

  void addSlot() {
    if (_selectedVariants.length < 5) {
      final newSlot = SelectedVariantData();
      if (_availableSizes.isNotEmpty) {
        newSlot.sizeTitle = _availableSizes[0].sizeTitle;
      }
      if (_productTypes.isNotEmpty) {
        newSlot.tableType = _productTypes[0].typeName;
      }
      _selectedVariants.add(newSlot);
      notifyListeners();
    }
  }

  void removeSlot(int index) {
    if (_selectedVariants.length > 1) {
      _selectedVariants.removeAt(index);
      notifyListeners();
    } else {
      _selectedVariants[0] = SelectedVariantData();
      if (_availableSizes.isNotEmpty) {
        _selectedVariants[0].sizeTitle = _availableSizes[0].sizeTitle;
      }
      if (_productTypes.isNotEmpty) {
        _selectedVariants[0].tableType = _productTypes[0].typeName;
      }
      notifyListeners();
    }
  }

  Future<void> pickImage(int index, BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      if (image != null) {
        if (!context.mounted) return;
        await _processImage(index, image.path, context);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> editImage(int index, BuildContext context) async {
    final imagePath = _selectedVariants[index].image?.path;
    if (imagePath == null) return;
    await _processImage(index, imagePath, context);
  }

  Future<void> _processImage(int index, String path, BuildContext context) async {
    final croppedFile = await _cropImage(path);
    if (croppedFile != null) {
      if (!context.mounted) return;
      
      final filteredFile = await showCupertinoModalPopup<File>(
        context: context,
        barrierDismissible: false,
        builder: (context) => ImageFilterSheet(imageFile: File(croppedFile.path)),
      );

      if (filteredFile != null) {
        _selectedVariants[index].image = XFile(filteredFile.path);
        
        // Görselin boyutlarını al ve oranına göre tip seç
        final decodedImage = await decodeImageFromList(await filteredFile.readAsBytes());
        final width = decodedImage.width;
        final height = decodedImage.height;
        final ratio = width / height;

        String? detectedType;
        if ((ratio - 1).abs() < 0.1) {
          detectedType = 'Kare';
        } else {
          detectedType = 'Dikdörtgen';
        }

        // Eğer tespit edilen tip mevcut tipler arasında varsa seç
        if (_productTypes.any((t) => t.typeName == detectedType)) {
          _selectedVariants[index].tableType = detectedType;
        }
        
        notifyListeners();
      }
    }
  }

  Future<CroppedFile?> _cropImage(String path) async {
    return await ImageCropper().cropImage(
      sourcePath: path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Görseli Düzenle',
          toolbarColor: Canvas701Colors.primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          activeControlsWidgetColor: Canvas701Colors.primary,
        ),
        IOSUiSettings(
          title: 'Görseli Düzenle',
          aspectRatioLockEnabled: false,
          resetButtonHidden: false,
          rotateButtonsHidden: false,
          rotateClockwiseButtonHidden: false,
          cancelButtonTitle: 'Vazgeç',
          doneButtonTitle: 'Bitti',
        ),
      ],
    );
  }

  void updateSize(int index, String sizeTitle) {
    _selectedVariants[index].sizeTitle = sizeTitle;
    notifyListeners();
  }

  void updateType(int index, String typeName) {
    _selectedVariants[index].tableType = typeName;
    notifyListeners();
  }

  Future<String?> _fileToBase64(XFile file) async {
    try {
      final Uint8List bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      debugPrint('Error converting to base64: $e');
      return null;
    }
  }

  Future<SpecialTableResponse> submitSpecialTable() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _tokenManager.getUserToken();
      if (token == null) {
        throw Exception('Lütfen giriş yapın');
      }

      final List<SpecialVariant> variants = [];
      for (var variantData in _selectedVariants) {
        if (variantData.image != null && variantData.sizeTitle != null && variantData.tableType != null) {
          final base64Image = await _fileToBase64(variantData.image!);
          if (base64Image != null) {
            variants.add(SpecialVariant(
              variant: variantData.sizeTitle!,
              tableType: variantData.tableType!,
              image: base64Image,
            ));
          }
        }
      }

      if (variants.isEmpty) {
        throw Exception('Lütfen en az bir görsel yükleyin, boyut ve tablo tipi seçin');
      }

      if (firstNameController.text.isEmpty || lastNameController.text.isEmpty || phoneController.text.isEmpty || addressController.text.isEmpty) {
         throw Exception('Lütfen tüm zorunlu alanları doldurun');
      }

      final request = SpecialTableRequest(
        userToken: token,
        userFirstname: firstNameController.text,
        userLastname: lastNameController.text,
        userPhone: phoneController.text,
        userEmail: emailController.text,
        shipAddress: addressController.text,
        variants: variants,
      );

      final response = await _specialService.addSpecialTable(request);
      return response;
    } catch (e) {
      _errorMessage = e.toString().contains('Exception:') ? e.toString().split('Exception:')[1].trim() : e.toString();
      return SpecialTableResponse(
        error: true,
        success: false,
        data: SpecialTableData(status: 'error', message: _errorMessage!),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }
}

class SelectedVariantData {
  String? sizeTitle;
  String? tableType;
  XFile? image;

  SelectedVariantData({this.sizeTitle, this.tableType, this.image});
}
