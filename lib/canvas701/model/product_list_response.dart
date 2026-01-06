class ProductListResponse {
  final bool error;
  final bool success;
  final ProductListData? data;

  ProductListResponse({
    required this.error,
    required this.success,
    this.data,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null ? ProductListData.fromJson(json['data']) : null,
    );
  }
}

class ProductListData {
  final int page;
  final int pageSize;
  final int totalPages;
  final int totalItems;
  final bool hasNextPage;
  final String emptyMessage;
  final List<ApiProduct> products;

  ProductListData({
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.totalItems,
    required this.hasNextPage,
    required this.emptyMessage,
    required this.products,
  });

  factory ProductListData.fromJson(Map<String, dynamic> json) {
    return ProductListData(
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      totalItems: json['totalItems'] ?? 0,
      hasNextPage: json['hasNextPage'] ?? false,
      emptyMessage: json['emptyMessage'] ?? '',
      products: (json['products'] as List?)
              ?.map((p) => ApiProduct.fromJson(p))
              .toList() ??
          [],
    );
  }
}

class ApiProduct {
  final int productID;
  final String productCode;
  final String productName;
  final String productImage;
  final String productPrice;
  final String productPriceOriginal;
  final String productDiscountIcon;
  final bool isDiscount;
  final bool isFavorite;

  ApiProduct({
    required this.productID,
    required this.productCode,
    required this.productName,
    required this.productImage,
    required this.productPrice,
    required this.productPriceOriginal,
    required this.productDiscountIcon,
    required this.isDiscount,
    required this.isFavorite,
  });

  factory ApiProduct.fromJson(Map<String, dynamic> json) {
    return ApiProduct(
      productID: json['productID'] ?? 0,
      productCode: json['productCode'] ?? '',
      productName: json['productName'] ?? '',
      productImage: json['productImage'] ?? '',
      productPrice: json['productPrice'] ?? '',
      productPriceOriginal: json['productPriceOriginal'] ?? '',
      productDiscountIcon: json['productDiscountIcon'] ?? '',
      isDiscount: json['isDiscount'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}
