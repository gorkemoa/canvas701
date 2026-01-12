class CouponResponse {
  final bool error;
  final bool success;
  final CouponData? data;
  final String? message;

  CouponResponse({
    required this.error,
    required this.success,
    this.data,
    this.message,
  });

  factory CouponResponse.fromJson(Map<String, dynamic> json) {
    return CouponResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null ? CouponData.fromJson(json['data']) : null,
      message: json['data'] != null ? json['data']['message'] : null,
    );
  }
}

class CouponData {
  final String emptyMessage;
  final int totalItems;
  final List<Coupon> coupons;

  CouponData({
    required this.emptyMessage,
    required this.totalItems,
    required this.coupons,
  });

  factory CouponData.fromJson(Map<String, dynamic> json) {
    return CouponData(
      emptyMessage: json['emptyMessage'] ?? '',
      totalItems: json['totalItems'] ?? 0,
      coupons: (json['coupons'] as List? ?? [])
          .map((e) => Coupon.fromJson(e))
          .toList(),
    );
  }
}

class Coupon {
  final int couponID;
  final String couponCode;
  final String couponType;
  final int couponRepeat;
  final String couponDesc;
  final String couponDiscountType;
  final int couponDiscount;
  final String minBasketAmount;
  final List<int> couponProducts;
  final String couponStatusName;
  final String couponStatus;
  final String couponStartDate;
  final String couponEndDate;
  final bool isUsed;
  final int usageCount;

  Coupon({
    required this.couponID,
    required this.couponCode,
    required this.couponType,
    required this.couponRepeat,
    required this.couponDesc,
    required this.couponDiscountType,
    required this.couponDiscount,
    required this.minBasketAmount,
    required this.couponProducts,
    required this.couponStatusName,
    required this.couponStatus,
    required this.couponStartDate,
    required this.couponEndDate,
    required this.isUsed,
    required this.usageCount,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      couponID: json['couponID'] ?? 0,
      couponCode: json['couponCode'] ?? '',
      couponType: json['couponType'] ?? '',
      couponRepeat: json['couponRepeat'] ?? 0,
      couponDesc: json['couponDesc'] ?? '',
      couponDiscountType: json['couponDiscountType'] ?? '',
      couponDiscount: json['couponDiscount'] ?? 0,
      minBasketAmount: json['minBasketAmount'] ?? '',
      couponProducts: (json['couponProducts'] as List? ?? [])
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .where((e) => e != 0)
          .toList(),
      couponStatusName: json['couponStatusName'] ?? '',
      couponStatus: json['couponStatus'] ?? '',
      couponStartDate: json['couponStartDate'] ?? '',
      couponEndDate: json['couponEndDate'] ?? '',
      isUsed: json['isUsed'] ?? false,
      usageCount: json['usageCount'] ?? 0,
    );
  }
}
