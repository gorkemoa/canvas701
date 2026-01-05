class CodeCheckRequest {
  final String code;
  final String codeToken;

  CodeCheckRequest({
    required this.code,
    required this.codeToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'codeToken': codeToken,
    };
  }
}
