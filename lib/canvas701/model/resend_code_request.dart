class ResendCodeRequest {
  final String userToken;

  ResendCodeRequest({
    required this.userToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken,
    };
  }
}
