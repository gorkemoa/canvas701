class UpdateUserResponse {
  final bool error;
  final bool success;
  final UpdateUserData? data;
  final String? errorMessage;

  UpdateUserResponse({
    required this.error,
    required this.success,
    this.data,
    this.errorMessage,
  });

  factory UpdateUserResponse.fromJson(Map<String, dynamic> json) {
    return UpdateUserResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null ? UpdateUserData.fromJson(json['data']) : null,
      errorMessage: json['error_message'],
    );
  }
}

class UpdateUserData {
  final String status;
  final String message;

  UpdateUserData({
    required this.status,
    required this.message,
  });

  factory UpdateUserData.fromJson(Map<String, dynamic> json) {
    return UpdateUserData(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
    );
  }
}
