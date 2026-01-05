class UpdatePasswordRequest {
  final String userToken;
  final String currentPassword;
  final String password;
  final String passwordAgain;

  UpdatePasswordRequest({
    required this.userToken,
    required this.currentPassword,
    required this.password,
    required this.passwordAgain,
  });

  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken,
      'currentPassword': currentPassword,
      'password': password,
      'passwordAgain': passwordAgain,
    };
  }
}
