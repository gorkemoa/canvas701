class TypeListResponse {
  final bool error;
  final bool success;
  final TypeListData? data;

  TypeListResponse({
    required this.error,
    required this.success,
    this.data,
  });

  factory TypeListResponse.fromJson(Map<String, dynamic> json) {
    return TypeListResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null ? TypeListData.fromJson(json['data']) : null,
    );
  }
}

class TypeListData {
  final List<ProductType> types;

  TypeListData({required this.types});

  factory TypeListData.fromJson(Map<String, dynamic> json) {
    return TypeListData(
      types: (json['types'] as List? ?? [])
          .map((i) => ProductType.fromJson(i))
          .toList(),
    );
  }
}

class ProductType {
  final int typeID;
  final String typeName;

  ProductType({
    required this.typeID,
    required this.typeName,
  });

  factory ProductType.fromJson(Map<String, dynamic> json) {
    return ProductType(
      typeID: json['typeID'] ?? 0,
      typeName: json['typeName'] ?? '',
    );
  }
}
