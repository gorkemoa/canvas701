class LoginResponse {
  final bool error;
  final bool success;
  final LoginData? data;
  final String? status200;
  final String? errorMessage;

  LoginResponse({
    required this.error,
    required this.success,
    this.data,
    this.status200,
    this.errorMessage,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
      status200: json['200'],
      errorMessage: json['error_message'],
    );
  }
}

class LoginData {
  final String status;
  final String message;
  final int? userID;
  final String? token;

  LoginData({
    required this.status,
    required this.message,
    this.userID,
    this.token,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      userID: json['userID'],
      token: json['token'],
    );
  }
}
