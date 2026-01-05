class UpdateUserRequest {
  final String userToken;
  final String userFirstname;
  final String userLastname;
  final String userEmail;
  final String userBirthday;
  final String userPhone;
  final String userAddress;
  final String userGender;
  final String profilePhoto;

  UpdateUserRequest({
    required this.userToken,
    required this.userFirstname,
    required this.userLastname,
    required this.userEmail,
    required this.userBirthday,
    required this.userPhone,
    required this.userAddress,
    required this.userGender,
    required this.profilePhoto,
  });

  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken,
      'userFirstname': userFirstname,
      'userLastname': userLastname,
      'userEmail': userEmail,
      'userBirthday': userBirthday,
      'userPhone': userPhone,
      'userAddress': userAddress,
      'userGender': userGender,
      'profilePhoto': profilePhoto,
    };
  }
}
