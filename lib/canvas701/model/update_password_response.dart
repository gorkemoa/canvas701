class UpdatePasswordResponse {
  final bool error;
  final bool success;
  final UpdatePasswordData? data;

  UpdatePasswordResponse({
    required this.error,
    required this.success,
    this.data,
  });

  factory UpdatePasswordResponse.fromJson(Map<String, dynamic> json) {
    return UpdatePasswordResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null ? UpdatePasswordData.fromJson(json['data']) : null,
    );
  }
}

class UpdatePasswordData {
  final String status;
  final String message;

  UpdatePasswordData({
    required this.status,
    required this.message,
  });

  factory UpdatePasswordData.fromJson(Map<String, dynamic> json) {
    return UpdatePasswordData(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
    );
  }
}
