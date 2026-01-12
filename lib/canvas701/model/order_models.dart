/// Sipariş API Modelleri
/// GetUserOrders ve GetOrderStatusList endpoint'leri için request ve response modelleri

// ==================== ORDER STATUS MODELS ====================

/// GetOrderStatusList API Response
class OrderStatusListResponse {
  final bool error;
  final bool success;
  final List<OrderStatusModel> statusList;

  OrderStatusListResponse({
    required this.error,
    required this.success,
    required this.statusList,
  });

  bool get isSuccess => success && !error;

  factory OrderStatusListResponse.fromJson(Map<String, dynamic> json) {
    return OrderStatusListResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      statusList:
          (json['data'] as List<dynamic>?)
              ?.map((e) => OrderStatusModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Sipariş durum modeli
class OrderStatusModel {
  final int statusID;
  final String statusName;
  final String statusColor;
  final bool isCancelableReturn;

  OrderStatusModel({
    required this.statusID,
    required this.statusName,
    required this.statusColor,
    required this.isCancelableReturn,
  });

  factory OrderStatusModel.fromJson(Map<String, dynamic> json) {
    return OrderStatusModel(
      statusID: json['statusID'] ?? 0,
      statusName: json['statusName'] ?? '',
      statusColor: json['statusColor'] ?? '',
      isCancelableReturn: json['isCancelableReturn'] ?? false,
    );
  }
}

// ==================== ORDER RESPONSE MODELS ====================

/// GetUserOrders API Response
class UserOrdersResponse {
  final bool error;
  final bool success;
  final UserOrdersData? data;

  UserOrdersResponse({required this.error, required this.success, this.data});

  bool get isSuccess => success && !error && data != null;
  String get message => data?.emptyMessage ?? 'Bir hata oluştu';
  List<UserOrder> get orders => data?.orders ?? [];
  int get totalOrders => data?.totalOrders ?? 0;

  factory UserOrdersResponse.fromJson(Map<String, dynamic> json) {
    return UserOrdersResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null ? UserOrdersData.fromJson(json['data']) : null,
    );
  }
}

/// Sipariş listesi data objesi
class UserOrdersData {
  final String emptyMessage;
  final int totalOrders;
  final List<UserOrder> orders;

  UserOrdersData({
    required this.emptyMessage,
    required this.totalOrders,
    required this.orders,
  });

  factory UserOrdersData.fromJson(Map<String, dynamic> json) {
    return UserOrdersData(
      emptyMessage: json['emptyMessage'] ?? '',
      totalOrders: json['totalOrders'] ?? 0,
      orders:
          (json['orders'] as List<dynamic>?)
              ?.map((e) => UserOrder.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Tek sipariş modeli
class UserOrder {
  final int orderID;
  final String orderCode;
  final String orderAmount;
  final String orderCargoAmount;
  final String orderDiscount;
  final String orderDesc;
  final String orderPayment;
  final String orderStatus;
  final String orderStatusText;
  final String orderCargo;
  final String orderCargoLogo;
  final String orderTrackingNo;
  final String orderTrackingLink;
  final String orderDate;
  final String orderInvoice;
  final bool isCanceled;
  final int totalProduct;
  final List<OrderProduct> products;

  UserOrder({
    required this.orderID,
    required this.orderCode,
    required this.orderAmount,
    required this.orderCargoAmount,
    required this.orderDiscount,
    required this.orderDesc,
    required this.orderPayment,
    required this.orderStatus,
    required this.orderStatusText,
    required this.orderCargo,
    required this.orderCargoLogo,
    required this.orderTrackingNo,
    required this.orderTrackingLink,
    required this.orderDate,
    required this.orderInvoice,
    required this.isCanceled,
    required this.totalProduct,
    required this.products,
  });

  /// Sipariş teslim edildi mi?
  bool get isDelivered => orderStatus.toLowerCase().contains('teslim edildi');

  /// Sipariş takip edilebilir mi?
  bool get canTrack =>
      orderTrackingNo.isNotEmpty && orderTrackingLink.isNotEmpty;

  factory UserOrder.fromJson(Map<String, dynamic> json) {
    return UserOrder(
      orderID: json['orderID'] ?? 0,
      orderCode: json['orderCode'] ?? '',
      orderAmount: json['orderAmount'] ?? '',
      orderCargoAmount: json['orderCargoAmount'] ?? '',
      orderDiscount: json['orderDiscount'] ?? '',
      orderDesc: json['orderDesc'] ?? '',
      orderPayment: json['orderPayment'] ?? '',
      orderStatus: json['orderStatus'] ?? '',
      orderStatusText: json['orderStatusText'] ?? '',
      orderCargo: json['orderCargo'] ?? '',
      orderCargoLogo: json['orderCargoLogo'] ?? '',
      orderTrackingNo: json['orderTrackingNo'] ?? '',
      orderTrackingLink: json['orderTrackingLink'] ?? '',
      orderDate: json['orderDate'] ?? '',
      orderInvoice: json['orderInvoice'] ?? '',
      isCanceled: json['isCanceled'] ?? false,
      totalProduct: json['totalProduct'] ?? 0,
      products:
          (json['products'] as List<dynamic>?)
              ?.map((e) => OrderProduct.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Sipariş ürün modeli
class OrderProduct {
  final int productID;
  final String productName;
  final String productVariants;
  final String productImage;
  final int productStatus;
  final String productStatusText;
  final int productQuantity;
  final int productCancelQuantity;
  final int productCurrentQuantity;
  final String productPrice;
  final String productCargoAmount;
  final String productCancelDate;
  final bool productIsCanceled;
  final String productCancelDesc;
  final bool isCustomTable;

  OrderProduct({
    required this.productID,
    required this.productName,
    required this.productVariants,
    required this.productImage,
    required this.productStatus,
    required this.productStatusText,
    required this.productQuantity,
    required this.productCancelQuantity,
    required this.productCurrentQuantity,
    required this.productPrice,
    required this.productCargoAmount,
    required this.productCancelDate,
    required this.productIsCanceled,
    required this.productCancelDesc,
    required this.isCustomTable,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      productID: json['productID'] ?? 0,
      productName: json['productName'] ?? '',
      productVariants: json['productVariants'] ?? '',
      productImage: json['productImage'] ?? '',
      productStatus: json['productStatus'] ?? 0,
      productStatusText: json['productStatusText'] ?? '',
      productQuantity: json['productQuantity'] ?? 0,
      productCancelQuantity: json['productCancelQuantity'] ?? 0,
      productCurrentQuantity: json['productCurrentQuantity'] ?? 0,
      productPrice: json['productPrice'] ?? '',
      productCargoAmount: json['productCargoAmount'] ?? '',
      productCancelDate: json['productCancelDate'] ?? '',
      productIsCanceled: json['productIsCanceled'] ?? false,
      productCancelDesc: json['productCancelDesc'] ?? '',
      isCustomTable: json['isCustomTable'] ?? false,
    );
  }
}

// ==================== ORDER DETAIL MODELS ====================

/// GetOrder API Response
class UserOrderDetailResponse {
  final bool error;
  final bool success;
  final UserOrderDetail? data;

  UserOrderDetailResponse({
    required this.error,
    required this.success,
    this.data,
  });

  bool get isSuccess => success && !error && data != null;

  factory UserOrderDetailResponse.fromJson(Map<String, dynamic> json) {
    return UserOrderDetailResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null ? UserOrderDetail.fromJson(json['data']) : null,
    );
  }
}

/// Sipariş detay modeli
class UserOrderDetail {
  final int orderID;
  final String orderCode;
  final String orderInstallment;
  final String orderCartTotal;
  final String orderDiscount;
  final String orderCargoAmount;
  final String orderGrandAmount;
  final String orderDesc;
  final String orderPaymentType;
  final String orderStatus;
  final String orderStatusText;
  final String orderDate;
  final String orderInvoice;
  final String orderCargo;
  final String orderCargoLogo;
  final String orderTrackingNo;
  final String orderTrackingLink;
  final bool isCanceled;
  final bool isCancelable;
  final bool isCargo;
  final bool isRating;
  final int totalProduct;
  final List<OrderDetailProduct> products;
  final OrderAddress? shippingAddress;
  final OrderAddress? billingAddress;
  final String salesAgreement;

  UserOrderDetail({
    required this.orderID,
    required this.orderCode,
    required this.orderInstallment,
    required this.orderCartTotal,
    required this.orderDiscount,
    required this.orderCargoAmount,
    required this.orderGrandAmount,
    required this.orderDesc,
    required this.orderPaymentType,
    required this.orderStatus,
    required this.orderStatusText,
    required this.orderDate,
    required this.orderInvoice,
    required this.orderCargo,
    required this.orderCargoLogo,
    required this.orderTrackingNo,
    required this.orderTrackingLink,
    required this.isCanceled,
    required this.isCancelable,
    required this.isCargo,
    required this.isRating,
    required this.totalProduct,
    required this.products,
    this.shippingAddress,
    this.billingAddress,
    required this.salesAgreement,
  });

  factory UserOrderDetail.fromJson(Map<String, dynamic> json) {
    return UserOrderDetail(
      orderID: json['orderID'] ?? 0,
      orderCode: json['orderCode'] ?? '',
      orderInstallment: json['orderInstallment'] ?? '',
      orderCartTotal: json['orderCartTotal'] ?? '',
      orderDiscount: json['orderDiscount'] ?? '',
      orderCargoAmount: json['orderCargoAmount'] ?? '',
      orderGrandAmount: json['orderGrandAmount'] ?? '',
      orderDesc: json['orderDesc'] ?? '',
      orderPaymentType: json['orderPaymentType'] ?? '',
      orderStatus: json['orderStatus'] ?? '',
      orderStatusText: json['orderStatusText'] ?? '',
      orderDate: json['orderDate'] ?? '',
      orderInvoice: json['orderInvoice'] ?? '',
      orderCargo: json['orderCargo'] ?? '',
      orderCargoLogo: json['orderCargoLogo'] ?? '',
      orderTrackingNo: json['orderTrackingNo'] ?? '',
      orderTrackingLink: json['orderTrackingLink'] ?? '',
      isCanceled: json['isCanceled'] ?? false,
      isCancelable: json['isCancelable'] ?? false,
      isCargo: json['isCargo'] ?? false,
      isRating: json['isRating'] ?? false,
      totalProduct: json['totalProduct'] ?? 0,
      products:
          (json['products'] as List<dynamic>?)
              ?.map((e) => OrderDetailProduct.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      shippingAddress: json['shippingAddress'] != null
          ? OrderAddress.fromJson(json['shippingAddress'])
          : null,
      billingAddress: json['billingAddress'] != null
          ? OrderAddress.fromJson(json['billingAddress'])
          : null,
     
      salesAgreement: json['salesAgreement'] ?? '',
    );
  }
}

/// Detay sayfasındaki ürün modeli
class OrderDetailProduct {
  final int productID;
  final String productName;
  final String productVariants;
  final String productImage;
  final String productStatus;
  final String productStatusText;
  final int productQuantity;
  final int productCancelQuantity;
  final int productCurrentQuantity;
  final String productPrice;
  final String productNotes;
  final String productCancelDesc;
  final String productCancelDate;
  final bool isCanceled;
  final bool isCommented;
  final bool isCustomTable;

  OrderDetailProduct({
    required this.productID,
    required this.productName,
    required this.productVariants,
    required this.productImage,
    required this.productStatus,
    required this.productStatusText,
    required this.productQuantity,
    required this.productCancelQuantity,
    required this.productCurrentQuantity,
    required this.productPrice,
    required this.productNotes,
    required this.productCancelDesc,
    required this.productCancelDate,
    required this.isCanceled,
    required this.isCommented,
    required this.isCustomTable,
  });

  factory OrderDetailProduct.fromJson(Map<String, dynamic> json) {
    return OrderDetailProduct(
      productID: json['productID'] ?? 0,
      productName: json['productName'] ?? '',
      productVariants: json['productVariants'] ?? '',
      productImage: json['productImage'] ?? '',
      productStatus: json['productStatus'] ?? '',
      productStatusText: json['productStatusText'] ?? '',
      productQuantity: json['productQuantity'] ?? 0,
      productCancelQuantity: json['productCancelQuantity'] ?? 0,
      productCurrentQuantity: json['productCurrentQuantity'] ?? 0,
      productPrice: json['productPrice'] ?? '',
      productNotes: json['productNotes'] ?? '',
      productCancelDesc: json['productCancelDesc'] ?? '',
      productCancelDate: json['productCancelDate'] ?? '',
      isCanceled: json['isCanceled'] ?? false,
      isCommented: json['isCommented'] ?? false,
      isCustomTable: json['isCustomTable'] ?? false,
    );
  }
}

/// Adres modeli
class OrderAddress {
  final String addressTitle;
  final String addressName;
  final String addressType; // Bireysel / Kurumsal
  final String addressPhone;
  final String addressEmail;
  final String addressCity;
  final String addressDistrict;
  final String address;
  final String identityNumber;
  final String realCompanyName;
  final String taxNumber;
  final String taxAdministration;

  OrderAddress({
    required this.addressTitle,
    required this.addressName,
    required this.addressType,
    required this.addressPhone,
    required this.addressEmail,
    required this.addressCity,
    required this.addressDistrict,
    required this.address,
    required this.identityNumber,
    required this.realCompanyName,
    required this.taxNumber,
    required this.taxAdministration,
  });

  factory OrderAddress.fromJson(Map<String, dynamic> json) {
    return OrderAddress(
      addressTitle: json['addressTitle'] ?? '',
      addressName: json['addressName'] ?? '',
      addressType: json['addressType'] ?? '',
      addressPhone: json['addressPhone'] ?? '',
      addressEmail: json['addressEmail'] ?? '',
      addressCity: json['addressCity'] ?? '',
      addressDistrict: json['addressDistrict'] ?? '',
      address: json['address'] ?? '',
      identityNumber: json['identityNumber'] ?? '',
      realCompanyName: json['realCompanyName'] ?? '',
      taxNumber: json['taxNumber'] ?? '',
      taxAdministration: json['taxAdministration'] ?? '',
    );
  }
}


 