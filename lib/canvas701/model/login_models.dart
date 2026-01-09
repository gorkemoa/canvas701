class LoginRequest {
  final String userEmail;
  final String userPassword;

  LoginRequest({required this.userEmail, required this.userPassword});

  Map<String, dynamic> toJson() {
    return {'userEmail': userEmail, 'userPassword': userPassword};
  }
}

class SocialLoginRequest {
  final String platform;
  final String deviceID;
  final String devicePlatform;
  final String version;
  final String? accessToken;
  final String? idToken;

  SocialLoginRequest({
    required this.platform,
    required this.deviceID,
    required this.devicePlatform,
    required this.version,
    this.accessToken,
    this.idToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'deviceID': deviceID,
      'devicePlatform': devicePlatform,
      'version': version,
      'accessToken': accessToken,
      'idToken': idToken,
    };
  }
}

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

class RegisterRequest {
  final String userFirstname;
  final String userLastname;
  final String userEmail;
  final String userPassword;
  final String version;
  final String platform;

  RegisterRequest({
    required this.userFirstname,
    required this.userLastname,
    required this.userEmail,
    required this.userPassword,
    required this.version,
    required this.platform,
  });

  Map<String, dynamic> toJson() {
    return {
      'userFirstname': userFirstname,
      'userLastname': userLastname,
      'userEmail': userEmail,
      'userPassword': userPassword,
      'version': version,
      'platform': platform,
    };
  }
}

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

  RegisterData({this.userID, this.userToken, this.codeToken, this.message});

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      userID: json['userID'],
      userToken: json['userToken'],
      codeToken: json['codeToken'],
      message: json['message'] ?? json['error_message'],
    );
  }
}

class CodeCheckRequest {
  final String code;
  final String codeToken;

  CodeCheckRequest({required this.code, required this.codeToken});

  Map<String, dynamic> toJson() {
    return {'code': code, 'codeToken': codeToken};
  }
}

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

  CodeCheckData({this.passToken, this.message});

  factory CodeCheckData.fromJson(Map<String, dynamic> json) {
    return CodeCheckData(
      passToken: json['passToken'],
      message: json['message'] ?? json['error_message'],
    );
  }
}

class ResendCodeRequest {
  final String userToken;

  ResendCodeRequest({required this.userToken});

  Map<String, dynamic> toJson() {
    return {'userToken': userToken};
  }
}

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
      message:
          json['message'] ?? json['error_message'] ?? json['success_message'],
      data: json['data'] != null ? ResendCodeData.fromJson(json['data']) : null,
    );
  }
}

class ResendCodeData {
  final String? codeToken;

  ResendCodeData({this.codeToken});

  factory ResendCodeData.fromJson(Map<String, dynamic> json) {
    return ResendCodeData(codeToken: json['codeToken']);
  }
}

class ForgotPasswordRequest {
  final String userEmail;

  ForgotPasswordRequest({required this.userEmail});

  Map<String, dynamic> toJson() {
    return {'userEmail': userEmail};
  }
}

class ForgotPasswordResponse {
  final bool error;
  final bool success;
  final String? message;
  final ForgotPasswordData? data;

  ForgotPasswordResponse({
    required this.error,
    required this.success,
    this.message,
    this.data,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      message: json['message'] ?? json['error_message'],
      data:
          json['data'] != null ? ForgotPasswordData.fromJson(json['data']) : null,
    );
  }
}

class ForgotPasswordData {
  final int? userID;
  final String? userEmail;
  final String? codeToken;

  ForgotPasswordData({this.userID, this.userEmail, this.codeToken});

  factory ForgotPasswordData.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordData(
      userID: json['userID'],
      userEmail: json['userEmail'],
      codeToken: json['codeToken'],
    );
  }
}

class ForgotPasswordUpdateRequest {
  final String passToken;
  final String password;
  final String passwordAgain;

  ForgotPasswordUpdateRequest({
    required this.passToken,
    required this.password,
    required this.passwordAgain,
  });

  Map<String, dynamic> toJson() {
    return {
      'passToken': passToken,
      'password': password,
      'passwordAgain': passwordAgain,
    };
  }
}

class ForgotPasswordUpdateResponse {
  final bool error;
  final bool success;
  final String? message;

  ForgotPasswordUpdateResponse({
    required this.error,
    required this.success,
    this.message,
  });

  factory ForgotPasswordUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordUpdateResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      message: json['message'] ??
          json['error_message'] ??
          (json['data'] != null ? json['data']['message'] : null),
    );
  }
}
