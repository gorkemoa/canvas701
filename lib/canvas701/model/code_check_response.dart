class CodeCheckResponse {
  final bool error;
  final bool success;
  final String? successMessage;
  final String? errorMessage;
  final CodeCheckData? data;

  CodeCheckResponse({
    required this.error,
    required this.success,
    this.successMessage,
    this.errorMessage,
    this.data,
  });

  factory CodeCheckResponse.fromJson(Map<String, dynamic> json) {
    return CodeCheckResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      successMessage: json['success_message'],
      errorMessage: json['error_message'],
      data: json['data'] != null ? CodeCheckData.fromJson(json['data']) : null,
    );
  }
}

class CodeCheckData {
  final String? passToken;
  final String? message;

  CodeCheckData({
    this.passToken,
    this.message,
  });

  factory CodeCheckData.fromJson(Map<String, dynamic> json) {
    return CodeCheckData(
      passToken: json['passToken'],
      message: json['message'] ?? json['error_message'],
    );
  }
}
