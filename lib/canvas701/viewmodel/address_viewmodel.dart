import 'package:flutter/material.dart';
import '../services/address_service.dart';
import '../model/address_models.dart';

class AddressViewModel extends ChangeNotifier {
  final AddressService _addressService = AddressService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<UserAddress> _addresses = [];
  List<UserAddress> get addresses => _addresses;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AddressViewModel() {
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _addressService.getUserAddresses();
      if (response.success) {
        _addresses = response.addresses;
      } else {
        _errorMessage = response.errorMessage ?? 'Adresler yüklenemedi';
      }
    } catch (e) {
      _errorMessage = 'Hata: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAddress(int addressID) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _addressService.deleteAddress(addressID);
      if (response.success) {
        await fetchAddresses();
        return true;
      } else {
        _errorMessage = response.errorMessage ?? 'Adres silinemedi';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Silme hatası: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
