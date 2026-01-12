class SpecialTableRequest {
  final String userToken;
  final String userFirstname;
  final String userLastname;
  final String userPhone;
  final String userEmail;
  final String shipAddress;
  final List<SpecialVariant> variants;

  SpecialTableRequest({
    required this.userToken,
    required this.userFirstname,
    required this.userLastname,
    required this.userPhone,
    required this.userEmail,
    required this.shipAddress,
    required this.variants,
  });

  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken,
      'userFirstname': userFirstname,
      'userLastname': userLastname,
      'userPhone': userPhone,
      'userEmail': userEmail,
      'shipAddress': shipAddress,
      'varinats': variants.map((v) => v.toJson()).toList(),
    };
  }
}

class SpecialVariant {
  final String variant;
  final String image; // base64

  SpecialVariant({
    required this.variant,
    required this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'variant': variant,
      'image': image,
    };
  }
}

class SpecialTableResponse {
  final bool error;
  final bool success;
  final SpecialTableData? data;

  SpecialTableResponse({
    required this.error,
    required this.success,
    this.data,
  });

  factory SpecialTableResponse.fromJson(Map<String, dynamic> json) {
    return SpecialTableResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null ? SpecialTableData.fromJson(json['data']) : null,
    );
  }
}

class SpecialTableData {
  final String status;
  final String message;

  SpecialTableData({
    required this.status,
    required this.message,
  });

  factory SpecialTableData.fromJson(Map<String, dynamic> json) {
    return SpecialTableData(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
    );
  }
}
