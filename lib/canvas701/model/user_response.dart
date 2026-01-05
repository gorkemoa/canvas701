class UserResponse {
  final bool error;
  final bool success;
  final UserData? data;

  UserResponse({
    required this.error,
    required this.success,
    this.data,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
    );
  }
}

class UserData {
  final User? user;

  UserData({this.user});

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class User {
  final int userID;
  final String userName;
  final String userFirstname;
  final String userLastname;
  final String userFullname;
  final String userEmail;
  final String userPhone;
  final String userGender;
  final String userBirthday;
  final String userToken;
  final String platform;
  final String userVersion;
  final String profilePhoto;
  final bool isApproved;

  User({
    required this.userID,
    required this.userName,
    required this.userFirstname,
    required this.userLastname,
    required this.userFullname,
    required this.userEmail,
    required this.userPhone,
    required this.userGender,
    required this.userBirthday,
    required this.userToken,
    required this.platform,
    required this.userVersion,
    required this.profilePhoto,
    required this.isApproved,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userID: json['userID'] ?? 0,
      userName: json['userName'] ?? '',
      userFirstname: json['userFirstname'] ?? '',
      userLastname: json['userLastname'] ?? '',
      userFullname: json['userFullname'] ?? '',
      userEmail: json['userEmail'] ?? '',
      userPhone: json['userPhone'] ?? '',
      userGender: json['userGender'] ?? '',
      userBirthday: json['userBirthday'] ?? '',
      userToken: json['userToken'] ?? '',
      platform: json['platform'] ?? '',
      userVersion: json['userVersion'] ?? '',
      profilePhoto: json['profilePhoto'] ?? '',
      isApproved: json['isApproved'] ?? false,
    );
  }
}
