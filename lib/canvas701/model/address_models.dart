class AddAddressRequest {
  final String userToken;
  final String addressTitle;
  final String userFirstName;
  final String userLastName;
  final String addressPhone;
  final String addressEmail;
  final String address;
  final int addressCityID;
  final int addressDistrictID;
  final int addressType; // 1: Bireysel, 2: Kurumsal
  final String invoiceAddress;
  final String? identityNumber;
  final String? realCompanyName;
  final String? taxNumber;
  final String? taxAdministration;
  final String postalCode;

  AddAddressRequest({
    required this.userToken,
    required this.addressTitle,
    required this.userFirstName,
    required this.userLastName,
    required this.addressPhone,
    required this.addressEmail,
    required this.address,
    required this.addressCityID,
    required this.addressDistrictID,
    required this.addressType,
    required this.invoiceAddress,
    this.identityNumber,
    this.realCompanyName,
    this.taxNumber,
    this.taxAdministration,
    required this.postalCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken,
      'addressTitle': addressTitle,
      'userFirstName': userFirstName,
      'userLastName': userLastName,
      'addressPhone': addressPhone,
      'addressEmail': addressEmail,
      'address': address,
      'addressCityID': addressCityID,
      'addressDistrictID': addressDistrictID,
      'addressType': addressType,
      'invoiceAddress': invoiceAddress,
      'identityNumber': identityNumber ?? '',
      'realCompanyName': realCompanyName ?? '',
      'taxNumber': taxNumber ?? '',
      'taxAdministration': taxAdministration ?? '',
      'postalCode': postalCode,
    };
  }
}

class UpdateAddressRequest extends AddAddressRequest {
  final int addressID;

  UpdateAddressRequest({
    required this.addressID,
    required super.userToken,
    required super.addressTitle,
    required super.userFirstName,
    required super.userLastName,
    required super.addressPhone,
    required super.addressEmail,
    required super.address,
    required super.addressCityID,
    required super.addressDistrictID,
    required super.addressType,
    required super.invoiceAddress,
    super.identityNumber,
    super.realCompanyName,
    super.taxNumber,
    super.taxAdministration,
    required super.postalCode,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['addressID'] = addressID;
    return json;
  }
}

class DeleteAddressRequest {
  final String userToken;
  final int addressID;

  DeleteAddressRequest({required this.userToken, required this.addressID});

  Map<String, dynamic> toJson() {
    return {'userToken': userToken, 'addressID': addressID};
  }
}

class AddAddressResponse {
  final bool error;
  final bool success;
  final AddAddressData? data;
  final String? errorMessage;

  AddAddressResponse({
    required this.error,
    required this.success,
    this.data,
    this.errorMessage,
  });

  factory AddAddressResponse.fromJson(Map<String, dynamic> json) {
    return AddAddressResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null ? AddAddressData.fromJson(json['data']) : null,
      errorMessage: json['error_message'],
    );
  }
}

class AddAddressData {
  final String status;
  final String message;

  AddAddressData({required this.status, required this.message});

  factory AddAddressData.fromJson(Map<String, dynamic> json) {
    return AddAddressData(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

class City {
  final String cityName;
  final int cityNo;

  City({required this.cityName, required this.cityNo});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(cityName: json['cityName'] ?? '', cityNo: json['cityNo'] ?? 0);
  }
}

class CityResponse {
  final bool error;
  final bool success;
  final CityData? data;

  CityResponse({required this.error, required this.success, this.data});

  factory CityResponse.fromJson(Map<String, dynamic> json) {
    return CityResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null ? CityData.fromJson(json['data']) : null,
    );
  }
}

class CityData {
  final List<City> cities;

  CityData({required this.cities});

  factory CityData.fromJson(Map<String, dynamic> json) {
    return CityData(
      cities: json['cities'] != null
          ? (json['cities'] as List).map((i) => City.fromJson(i)).toList()
          : [],
    );
  }
}

class District {
  final String districtName;
  final int districtNo;

  District({required this.districtName, required this.districtNo});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      districtName: json['districtName'] ?? '',
      districtNo: json['districtNo'] ?? 0,
    );
  }
}

class UserAddress {
  final int userId;
  final int addressId;
  final String addressFirstName;
  final String addressLastName;
  final String addressName;
  final String addressTitle;
  final int addressTypeId;
  final String addressType;
  final String addressPhone;
  final String addressEmail;
  final String addressCity;
  final int cityId;
  final int districtId;
  final String addressDistrict;
  final String address;
  final String invoiceAddress;
  final String identityNumber;
  final String realCompanyName;
  final String taxNumber;
  final String taxAdministration;
  final String postalCode;

  UserAddress({
    required this.userId,
    required this.addressId,
    required this.addressFirstName,
    required this.addressLastName,
    required this.addressName,
    required this.addressTitle,
    required this.addressTypeId,
    required this.addressType,
    required this.addressPhone,
    required this.addressEmail,
    required this.addressCity,
    required this.cityId,
    required this.districtId,
    required this.addressDistrict,
    required this.address,
    required this.invoiceAddress,
    required this.identityNumber,
    required this.realCompanyName,
    required this.taxNumber,
    required this.taxAdministration,
    required this.postalCode,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      userId: json['userID'] ?? 0,
      addressId: json['addressID'] ?? 0,
      addressFirstName: json['addressfirstName'] ?? '',
      addressLastName: json['addresslastName'] ?? '',
      addressName: json['addressName'] ?? '',
      addressTitle: json['addressTitle'] ?? '',
      addressTypeId: json['addressTypeID'] ?? 0,
      addressType: json['addressType'] ?? '',
      addressPhone: json['addressPhone'] ?? '',
      addressEmail: json['addressEmail'] ?? '',
      addressCity: json['addressCity'] ?? '',
      cityId: json['cityID'] ?? 0,
      districtId: json['districtID'] ?? 0,
      addressDistrict: json['addressDistrict'] ?? '',
      address: json['address'] ?? '',
      invoiceAddress: json['invoiceAddress'] ?? '',
      identityNumber: json['identityNumber'] ?? '',
      realCompanyName: json['realCompanyName'] ?? '',
      taxNumber: json['taxNumber'] ?? '',
      taxAdministration: json['taxAdministration'] ?? '',
      postalCode: json['postalCode'] ?? '',
    );
  }
}

class UserAddressesResponse {
  final bool error;
  final bool success;
  final List<UserAddress> addresses;
  final String? errorMessage;
  final int totalItems;
  final String emptyMessage;

  UserAddressesResponse({
    required this.error,
    required this.success,
    required this.addresses,
    this.errorMessage,
    required this.totalItems,
    required this.emptyMessage,
  });

  factory UserAddressesResponse.fromJson(Map<String, dynamic> json) {
    List<UserAddress> addresses = [];
    int totalItems = 0;
    String emptyMessage = '';

    if (json['data'] != null) {
      totalItems = json['data']['totalItems'] ?? 0;
      emptyMessage = json['data']['emptyMessage'] ?? '';
      if (json['data']['addresses'] != null) {
        addresses = (json['data']['addresses'] as List)
            .map((i) => UserAddress.fromJson(i))
            .toList();
      }
    }

    return UserAddressesResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      addresses: addresses,
      errorMessage: json['error_message'],
      totalItems: totalItems,
      emptyMessage: emptyMessage,
    );
  }
}

class DistrictResponse {
  final bool error;
  final bool success;
  final DistrictData? data;

  DistrictResponse({required this.error, required this.success, this.data});

  factory DistrictResponse.fromJson(Map<String, dynamic> json) {
    return DistrictResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null ? DistrictData.fromJson(json['data']) : null,
    );
  }
}

class DistrictData {
  final List<District> districts;

  DistrictData({required this.districts});

  factory DistrictData.fromJson(Map<String, dynamic> json) {
    return DistrictData(
      districts: json['districts'] != null
          ? (json['districts'] as List)
                .map((i) => District.fromJson(i))
                .toList()
          : [],
    );
  }
}
