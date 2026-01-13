class SpecialsResponse {
  final bool error;
  final bool success;
  final SpecialsData? data;

  SpecialsResponse({
    required this.error,
    required this.success,
    this.data,
  });

  factory SpecialsResponse.fromJson(Map<String, dynamic> json) {
    return SpecialsResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null ? SpecialsData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'error': error,
      'success': success,
      'data': data?.toJson(),
    };
  }
}

class SpecialsData {
  final List<String> images;

  SpecialsData({
    required this.images,
  });

  factory SpecialsData.fromJson(Map<String, dynamic> json) {
    return SpecialsData(
      images: List<String>.from(json['images'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'images': images,
    };
  }
}
