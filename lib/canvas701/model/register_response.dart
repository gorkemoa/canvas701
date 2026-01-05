class RegisterResponse {
  final bool error;
  final bool success;
  final String? successMessage;
  final String? errorMessage;
  final RegisterData? data;

  RegisterResponse({
    required this.error,
    required this.success,
    this.successMessage,
    this.errorMessage,
    this.data,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      successMessage: json['success_message'],
      errorMessage: json['error_message'],
      data: json['data'] != null ? RegisterData.fromJson(json['data']) : null,
    );
  }
}

class RegisterData {
  final int? userID;
  final String? userToken;
  final String? codeToken;
  final String? message;

  RegisterData({
    this.userID,
    this.userToken,
    this.codeToken,
    this.message,
  });

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      userID: json['userID'],
      userToken: json['userToken'],
      codeToken: json['codeToken'],
      message: json['message'] ?? json['error_message'],
    );
  }
}
