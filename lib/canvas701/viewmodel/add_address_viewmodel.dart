import 'package:flutter/material.dart';
import '../api/auth_service.dart';
import '../api/general_service.dart';
import '../model/address_models.dart';

class AddAddressViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final GeneralService _generalService = GeneralService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Form State
  int? _addressId;
  int _addressType = 1; // 1: Bireysel, 2: Kurumsal
  int get addressType => _addressType;
  bool get isEditMode => _addressId != null;

  // Dropdown Selections
  int? _selectedCityId;
  int? _selectedDistrictId;

  int? get selectedCityId => _selectedCityId;
  int? get selectedDistrictId => _selectedDistrictId;

  // Data
  List<City> _cities = [];
  List<City> get cities => _cities;

  List<District> _districts = [];
  List<District> get districts => _districts;

  // Initial Loading
  bool _isCitiesLoading = false;
  bool get isCitiesLoading => _isCitiesLoading;

  bool _isDistrictsLoading = false;
  bool get isDistrictsLoading => _isDistrictsLoading;

  AddAddressViewModel() {
    _fetchCities();
  }

  void initialize(UserAddress? address) {
    if (address == null) return;

    _addressId = address.addressId;
    _addressType = address.addressTypeId;
    _selectedCityId = address.cityId;
    _selectedDistrictId = address.districtId;

    if (_selectedCityId != null) {
      _fetchDistricts(_selectedCityId!);
    }
    notifyListeners();
  }

  Future<void> _fetchCities() async {
    _isCitiesLoading = true;
    notifyListeners();

    try {
      final response = await _generalService.getCities();
      if (response.success && response.data != null) {
        _cities = response.data!.cities;
      } else {
        _errorMessage = 'Şehirler yüklenemedi';
      }
    } catch (e) {
      _errorMessage = 'Şehirler yüklenirken hata oluştu: $e';
    } finally {
      _isCitiesLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchDistricts(int cityId) async {
    _isDistrictsLoading = true;
    _districts = [];
    // Reset district if we are changing city, but NOT if we are initializing
    if (!_isCitiesLoading && !isEditMode) {
      _selectedDistrictId = null;
    }
    notifyListeners();

    try {
      final response = await _generalService.getDistricts(cityId);
      if (response.success && response.data != null) {
        _districts = response.data!.districts;
      } else {
        _errorMessage = 'İlçeler yüklenemedi';
      }
    } catch (e) {
      _errorMessage = 'İlçeler yüklenirken hata oluştu: $e';
    } finally {
      _isDistrictsLoading = false;
      notifyListeners();
    }
  }

  void setAddressType(int type) {
    _addressType = type;
    notifyListeners();
  }

  void setCity(int? cityId) {
    if (_selectedCityId != cityId) {
      _selectedCityId = cityId;
      if (cityId != null) {
        _fetchDistricts(cityId);
      } else {
        _districts = [];
        _selectedDistrictId = null;
      }
      notifyListeners();
    }
  }

  void setDistrict(int? districtId) {
    _selectedDistrictId = districtId;
    notifyListeners();
  }

  Future<AddAddressResponse> submitAddress({
    required String title,
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String addressDetail,
    required String postalCode,
    String? companyName,
    String? taxNumber,
    String? taxOffice,
    String? invoiceAddress,
    String? identityNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Oturum bilgisi bulunamadı.');
      }

      String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
      if (cleanPhone.startsWith('0')) {
        cleanPhone = cleanPhone.substring(1);
      }

      String formattedPhone = cleanPhone;
      if (cleanPhone.length == 10) {
        // Format as (5xx) xxx xx xx
        formattedPhone =
            '(${cleanPhone.substring(0, 3)}) ${cleanPhone.substring(3, 6)} ${cleanPhone.substring(6, 8)} ${cleanPhone.substring(8, 10)}';
      }

      if (isEditMode) {
        final request = UpdateAddressRequest(
          addressID: _addressId!,
          userToken: token,
          addressTitle: title,
          userFirstName: firstName,
          userLastName: lastName,
          addressPhone: formattedPhone,
          addressEmail: email,
          address: addressDetail,
          addressCityID: _selectedCityId ?? 0,
          addressDistrictID: _selectedDistrictId ?? 0,
          addressType: _addressType,
          invoiceAddress:
              invoiceAddress ?? addressDetail, // Fallback to main address
          realCompanyName: companyName,
          taxNumber: taxNumber,
          taxAdministration: taxOffice,
          postalCode: postalCode,
          identityNumber: _addressType == 1 ? identityNumber : null,
        );
        final response = await _authService.updateAddress(request);
        if (!response.success) {
          _errorMessage = response.errorMessage ?? response.data?.message;
        }
        return response;
      } else {
        final request = AddAddressRequest(
          userToken: token,
          addressTitle: title,
          userFirstName: firstName,
          userLastName: lastName,
          addressPhone: formattedPhone,
          addressEmail: email,
          address: addressDetail,
          addressCityID: _selectedCityId ?? 0,
          addressDistrictID: _selectedDistrictId ?? 0,
          addressType: _addressType,
          invoiceAddress:
              invoiceAddress ?? addressDetail, // Fallback to main address
          realCompanyName: companyName,
          taxNumber: taxNumber,
          taxAdministration: taxOffice,
          postalCode: postalCode,
          identityNumber: _addressType == 1 ? identityNumber : null,
        );

        final response = await _authService.addAddress(request);

        if (!response.success) {
          _errorMessage = response.errorMessage ?? response.data?.message;
        }

        return response;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return AddAddressResponse(
        error: true,
        success: false,
        errorMessage: e.toString(),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
