import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../model/address_models.dart';
import 'base_service.dart';
import 'token_manager.dart';

/// Adres CRUD işlemlerini yöneten servis
class AddressService extends BaseService {
  static final AddressService _instance = AddressService._internal();
  factory AddressService() => _instance;
  AddressService._internal();

  final TokenManager _tokenManager = TokenManager();

  /// Kullanıcının tüm adreslerini getir
  Future<UserAddressesResponse> getUserAddresses() async {
    final token = await _tokenManager.getAuthToken();
    
    if (token == null) {
      return UserAddressesResponse(
        error: true,
        success: false,
        addresses: [],
        errorMessage: 'Oturum bilgisi bulunamadı',
        totalItems: 0,
        emptyMessage: '',
      );
    }

    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.getUserAddresses}?userToken=$token',
    );

    logRequest('GET', url.toString(), null);

    try {
      final response = await http.get(url, headers: getHeaders());

      logResponse(response.statusCode, response.body);

      if (response.statusCode == 403) {
        await _tokenManager.clearAll();
        _tokenManager.redirectToLogin();
        return UserAddressesResponse(
          error: true,
          success: false,
          addresses: [],
          errorMessage: 'Oturum süresi doldu (403)',
          totalItems: 0,
          emptyMessage: '',
        );
      }

      final responseData = jsonDecode(response.body);
      return UserAddressesResponse.fromJson(responseData);
    } catch (e) {
      return UserAddressesResponse(
        error: true,
        success: false,
        addresses: [],
        errorMessage: e.toString(),
        totalItems: 0,
        emptyMessage: '',
      );
    }
  }

  /// Yeni adres ekle
  Future<AddAddressResponse> addAddress(AddAddressRequest request) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.addAddress}');

    logRequest('POST', url.toString(), request.toJson());

    try {
      final response = await http.post(
        url,
        headers: getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      logResponse(response.statusCode, response.body);

      if (response.statusCode == 403) {
        await _tokenManager.clearAll();
        _tokenManager.redirectToLogin();
        return AddAddressResponse(
          error: true,
          success: false,
          data: AddAddressData(status: 'error', message: 'Oturum süresi doldu (403)'),
        );
      }

      final responseData = jsonDecode(response.body);
      return AddAddressResponse.fromJson(responseData);
    } catch (e) {
      return AddAddressResponse(
        error: true,
        success: false,
        data: AddAddressData(status: 'error', message: e.toString()),
      );
    }
  }

  /// Adres güncelle
  Future<AddAddressResponse> updateAddress(UpdateAddressRequest request) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.updateAddress}');

    logRequest('PUT', url.toString(), request.toJson());

    try {
      final response = await http.put(
        url,
        headers: getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      logResponse(response.statusCode, response.body);

      if (response.statusCode == 403) {
        await _tokenManager.clearAll();
        _tokenManager.redirectToLogin();
        return AddAddressResponse(
          error: true,
          success: false,
          data: AddAddressData(status: 'error', message: 'Oturum süresi doldu (403)'),
        );
      }

      final responseData = jsonDecode(response.body);
      return AddAddressResponse.fromJson(responseData);
    } catch (e) {
      return AddAddressResponse(
        error: true,
        success: false,
        data: AddAddressData(status: 'error', message: e.toString()),
      );
    }
  }

  /// Adres sil
  Future<AddAddressResponse> deleteAddress(int addressID) async {
    final token = await _tokenManager.getAuthToken();
    
    if (token == null) {
      return AddAddressResponse(
        error: true,
        success: false,
        errorMessage: 'Oturum bilgisi bulunamadı',
      );
    }

    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.deleteAddress}');

    final request = DeleteAddressRequest(
      userToken: token,
      addressID: addressID,
    );

    logRequest('DELETE', url.toString(), request.toJson());

    try {
      final response = await http.delete(
        url,
        headers: getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      logResponse(response.statusCode, response.body);

      if (response.statusCode == 403) {
        await _tokenManager.clearAll();
        _tokenManager.redirectToLogin();
        return AddAddressResponse(
          error: true,
          success: false,
          data: AddAddressData(status: 'error', message: 'Oturum süresi doldu (403)'),
        );
      }

      final responseData = jsonDecode(response.body);
      return AddAddressResponse.fromJson(responseData);
    } catch (e) {
      return AddAddressResponse(
        error: true,
        success: false,
        data: AddAddressData(status: 'error', message: e.toString()),
      );
    }
  }
}
