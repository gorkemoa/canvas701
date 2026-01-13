import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/special_service.dart';
import '../services/general_service.dart';
import '../services/token_manager.dart';
import '../model/special_models.dart';
import '../model/size_model.dart';
import 'profile_viewmodel.dart';

class SpecialViewModel extends ChangeNotifier {
  final SpecialService _specialService = SpecialService();
  final GeneralService _generalService = GeneralService();
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

  // Form Fields
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Selected Variants (Size + Image)
  final List<SelectedVariantData> _selectedVariants = [SelectedVariantData()];
  List<SelectedVariantData> get selectedVariants => _selectedVariants;

  SpecialViewModel() {
    _prefillFromProfile();
    fetchSizes();
    checkOnboarding();
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
      notifyListeners();
    }
  }

  Future<void> pickImage(int index) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        _selectedVariants[index].image = image;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void updateSize(int index, String sizeTitle) {
    _selectedVariants[index].sizeTitle = sizeTitle;
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
        if (variantData.image != null && variantData.sizeTitle != null) {
          final base64Image = await _fileToBase64(variantData.image!);
          if (base64Image != null) {
            variants.add(SpecialVariant(
              variant: variantData.sizeTitle!,
              image: base64Image,
            ));
          }
        }
      }

      if (variants.isEmpty) {
        throw Exception('Lütfen en az bir görsel yükleyin ve boyut seçin');
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
  XFile? image;

  SelectedVariantData({this.sizeTitle, this.image});
}
