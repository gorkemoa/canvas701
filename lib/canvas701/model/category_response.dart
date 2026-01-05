class CategoryResponse {
  final bool error;
  final bool success;
  final CategoryData? data;

  CategoryResponse({
    required this.error,
    required this.success,
    this.data,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null ? CategoryData.fromJson(json['data']) : null,
    );
  }
}

class CategoryData {
  final List<ApiCategory> categories;

  CategoryData({required this.categories});

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      categories: (json['categories'] as List? ?? [])
          .map((e) => ApiCategory.fromJson(e))
          .toList(),
    );
  }
}

class ApiCategory {
  final int catID;
  final String catName;
  final String catMainImage;
  final String catThumbImage;
  final String catThumbImage1;
  final String catThumbImage2;

  ApiCategory({
    required this.catID,
    required this.catName,
    required this.catMainImage,
    required this.catThumbImage,
    required this.catThumbImage1,
    required this.catThumbImage2,
  });

  factory ApiCategory.fromJson(Map<String, dynamic> json) {
    return ApiCategory(
      catID: json['catID'] ?? 0,
      catName: json['catName'] ?? '',
      catMainImage: json['catMainImage'] ?? '',
      catThumbImage: json['catThumbImage'] ?? '',
      catThumbImage1: json['catThumbImage1'] ?? '',
      catThumbImage2: json['catThumbImage2'] ?? '',
    );
  }
}
