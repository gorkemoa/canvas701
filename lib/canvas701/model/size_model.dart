class SizeResponse {
  final bool error;
  final bool success;
  final SizeData? data;

  SizeResponse({
    required this.error,
    required this.success,
    this.data,
  });

  factory SizeResponse.fromJson(Map<String, dynamic> json) {
    return SizeResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null ? SizeData.fromJson(json['data']) : null,
    );
  }
}

class SizeData {
  final List<CanvasSize> sizes;

  SizeData({required this.sizes});

  factory SizeData.fromJson(Map<String, dynamic> json) {
    return SizeData(
      sizes: (json['sizes'] as List? ?? [])
          .map((i) => CanvasSize.fromJson(i))
          .toList(),
    );
  }
}

class CanvasSize {
  final String sizeTitle;
  final String sizePrice;

  CanvasSize({
    required this.sizeTitle,
    required this.sizePrice,
  });

  factory CanvasSize.fromJson(Map<String, dynamic> json) {
    return CanvasSize(
      sizeTitle: json['sizeTitle'] ?? '',
      sizePrice: json['sizePrice'] ?? '',
    );
  }
}
