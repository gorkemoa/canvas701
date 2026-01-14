class UserResponse {
  final bool error;
  final bool success;
  final UserData? data;
  final String? errorMessage;

  UserResponse({
    required this.error,
    required this.success,
    this.data,
    this.errorMessage,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
      errorMessage: json['error_message'],
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

class UpdateUserResponse {
  final bool error;
  final bool success;
  final UpdateUserData? data;
  final String? errorMessage;

  UpdateUserResponse({
    required this.error,
    required this.success,
    this.data,
    this.errorMessage,
  });

  factory UpdateUserResponse.fromJson(Map<String, dynamic> json) {
    return UpdateUserResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null ? UpdateUserData.fromJson(json['data']) : null,
      errorMessage: json['error_message'],
    );
  }
}

class UpdateUserData {
  final String status;
  final String message;

  UpdateUserData({required this.status, required this.message});

  factory UpdateUserData.fromJson(Map<String, dynamic> json) {
    return UpdateUserData(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

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

class UpdatePasswordResponse {
  final bool error;
  final bool success;
  final UpdatePasswordData? data;
  final String? errorMessage;

  UpdatePasswordResponse({
    required this.error,
    required this.success,
    this.data,
    this.errorMessage,
  });

  factory UpdatePasswordResponse.fromJson(Map<String, dynamic> json) {
    return UpdatePasswordResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null
          ? UpdatePasswordData.fromJson(json['data'])
          : null,
      errorMessage: json['error_message'],
    );
  }
}

class UpdatePasswordData {
  final String status;
  final String message;

  UpdatePasswordData({required this.status, required this.message});

  factory UpdatePasswordData.fromJson(Map<String, dynamic> json) {
    return UpdatePasswordData(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

class CommonResponse {
  final bool error;
  final bool success;
  final String message;

  CommonResponse({
    required this.error,
    required this.success,
    required this.message,
  });

  factory CommonResponse.fromJson(Map<String, dynamic> json) {
    String msg = '';
    if (json['data'] != null && json['data']['message'] != null) {
      msg = json['data']['message'];
    } else if (json['message'] != null) {
      msg = json['message'];
    }
    return CommonResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      message: msg,
    );
  }
}

class UserCommentsResponse {
  final bool error;
  final bool success;
  final UserCommentsData? data;

  UserCommentsResponse({
    required this.error,
    required this.success,
    this.data,
  });

  factory UserCommentsResponse.fromJson(Map<String, dynamic> json) {
    return UserCommentsResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null ? UserCommentsData.fromJson(json['data']) : null,
    );
  }
}

class UserCommentsData {
  final int totalItems;
  final String emptyMessage;
  final List<UserComment> comments;

  UserCommentsData({
    required this.totalItems,
    required this.emptyMessage,
    required this.comments,
  });

  factory UserCommentsData.fromJson(Map<String, dynamic> json) {
    return UserCommentsData(
      totalItems: json['totalItems'] ?? 0,
      emptyMessage: json['emptyMessage'] ?? '',
      comments: (json['comments'] as List<dynamic>?)
              ?.map((e) => UserComment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class UserComment {
  final int userID;
  final int commentID;
  final int productID;
  final String userName;
  final bool showName;
  final String commentDesc;
  final int commentRating;
  final int commentLike;
  final int commentDislike;
  final String productTitle;
  final String productImage;
  final String commentDate;
  final String commentApproval;

  UserComment({
    required this.userID,
    required this.commentID,
    required this.productID,
    required this.userName,
    required this.showName,
    required this.commentDesc,
    required this.commentRating,
    required this.commentLike,
    required this.commentDislike,
    required this.productTitle,
    required this.productImage,
    required this.commentDate,
    required this.commentApproval,
  });

  factory UserComment.fromJson(Map<String, dynamic> json) {
    return UserComment(
      userID: json['userID'] ?? 0,
      commentID: json['commentID'] ?? 0,
      productID: json['productID'] ?? 0,
      userName: json['userName'] ?? '',
      showName: json['showName'] ?? false,
      commentDesc: json['commentDesc'] ?? '',
      commentRating: json['commentRating'] ?? 0,
      commentLike: json['commentLike'] ?? 0,
      commentDislike: json['commentDislike'] ?? 0,
      productTitle: json['productTitle'] ?? '',
      productImage: json['productImage'] ?? '',
      commentDate: json['commentDate'] ?? '',
      commentApproval: json['commentApproval'] ?? '',
    );
  }
}
