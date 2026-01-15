import 'product_models.dart';

class CampaignResponse {
  final bool error;
  final bool success;
  final CampaignData? data;

  CampaignResponse({
    required this.error,
    required this.success,
    this.data,
  });

  factory CampaignResponse.fromJson(Map<String, dynamic> json) {
    return CampaignResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null ? CampaignData.fromJson(json['data']) : null,
    );
  }
}

class CampaignDetailResponse {
  final bool error;
  final bool success;
  final CampaignDetailData? data;

  CampaignDetailResponse({
    required this.error,
    required this.success,
    this.data,
  });

  factory CampaignDetailResponse.fromJson(Map<String, dynamic> json) {
    return CampaignDetailResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null ? CampaignDetailData.fromJson(json['data']) : null,
    );
  }
}

class CampaignData {
  final List<ApiCampaign> campaigns;

  CampaignData({required this.campaigns});

  factory CampaignData.fromJson(Map<String, dynamic> json) {
    return CampaignData(
      campaigns: (json['campaigns'] as List? ?? [])
          .map((i) => ApiCampaign.fromJson(i))
          .toList(),
    );
  }
}

class CampaignDetailData {
  final ApiCampaign campaign;

  CampaignDetailData({required this.campaign});

  factory CampaignDetailData.fromJson(Map<String, dynamic> json) {
    return CampaignDetailData(
      campaign: ApiCampaign.fromJson(json['campaign'] ?? {}),
    );
  }
}

class ApiCampaign {
  final int campID;
  final String campTitle;
  final String campDesc;
  final String campStartDate;
  final String campEndDate;
  final int campDiscountType;
  final int campDiscount;
  final String campImage;
  final List<ApiProduct> products;

  ApiCampaign({
    required this.campID,
    required this.campTitle,
    required this.campDesc,
    required this.campStartDate,
    required this.campEndDate,
    required this.campDiscountType,
    required this.campDiscount,
    required this.campImage,
    this.products = const [],
  });

  factory ApiCampaign.fromJson(Map<String, dynamic> json) {
    return ApiCampaign(
      campID: json['campID'] ?? 0,
      campTitle: json['campTitle'] ?? '',
      campDesc: json['campDesc'] ?? '',
      campStartDate: json['campStartDate'] ?? '',
      campEndDate: json['campEndDate'] ?? '',
      campDiscountType: json['campDiscountType'] ?? 0,
      campDiscount: json['campDiscount'] ?? 0,
      campImage: json['campImage'] ?? '',
      products: (json['products'] as List? ?? [])
          .map((i) => ApiProduct.fromJson(i))
          .toList(),
    );
  }
}
