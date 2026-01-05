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
