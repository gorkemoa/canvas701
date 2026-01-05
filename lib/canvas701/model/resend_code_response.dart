class ResendCodeResponse {
  final bool error;
  final bool success;
  final String? successMessage;
  final String? message;
  final ResendCodeData? data;

  ResendCodeResponse({
    required this.error,
    required this.success,
    this.successMessage,
    this.message,
    this.data,
  });

  factory ResendCodeResponse.fromJson(Map<String, dynamic> json) {
    return ResendCodeResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      successMessage: json['success_message'],
      message: json['message'] ?? json['error_message'] ?? json['success_message'],
      data: json['data'] != null ? ResendCodeData.fromJson(json['data']) : null,
    );
  }
}

class ResendCodeData {
  final String? codeToken;

  ResendCodeData({this.codeToken});

  factory ResendCodeData.fromJson(Map<String, dynamic> json) {
    return ResendCodeData(
      codeToken: json['codeToken'],
    );
  }
}
