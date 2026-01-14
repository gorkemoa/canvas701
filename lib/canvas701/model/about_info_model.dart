class AboutInfoResponse {
  final bool error;
  final bool success;
  final AboutInfoData? data;

  AboutInfoResponse({
    required this.error,
    required this.success,
    this.data,
  });

  factory AboutInfoResponse.fromJson(Map<String, dynamic> json) {
    return AboutInfoResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null ? AboutInfoData.fromJson(json['data']) : null,
    );
  }
}

class AboutInfoData {
  final String contactAddress;
  final String contactPhone;
  final String contactEmail;
  final String contactEmail2;
  final String contactEmail3;
  final String contactFacebook;
  final String contactTwitter;
  final String contactInstagram;
  final String contactLinkedin;
  final String contactAboutDesc;

  AboutInfoData({
    required this.contactAddress,
    required this.contactPhone,
    required this.contactEmail,
    required this.contactEmail2,
    required this.contactEmail3,
    required this.contactFacebook,
    required this.contactTwitter,
    required this.contactInstagram,
    required this.contactLinkedin,
    required this.contactAboutDesc,
  });

  factory AboutInfoData.fromJson(Map<String, dynamic> json) {
    return AboutInfoData(
      contactAddress: json['contactAddress'] ?? '',
      contactPhone: json['contactPhone'] ?? '',
      contactEmail: json['contactEmail'] ?? '',
      contactEmail2: json['contactEmail2'] ?? '',
      contactEmail3: json['contactEmail3'] ?? '',
      contactFacebook: json['contactFacebook'] ?? '',
      contactTwitter: json['contactTwitter'] ?? '',
      contactInstagram: json['contactInstagram'] ?? '',
      contactLinkedin: json['contactLinkedin'] ?? '',
      contactAboutDesc: json['contactAboutDesc'] ?? '',
    );
  }
}
