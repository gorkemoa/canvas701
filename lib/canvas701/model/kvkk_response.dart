class KvkkResponse {
  final bool error;
  final bool success;
  final KvkkData? data;

  KvkkResponse({
    required this.error,
    required this.success,
    this.data,
  });

  factory KvkkResponse.fromJson(Map<String, dynamic> json) {
    return KvkkResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null ? KvkkData.fromJson(json['data']) : null,
    );
  }
}

class KvkkData {
  final int postID;
  final String postTitle;
  final String postContent;

  KvkkData({
    required this.postID,
    required this.postTitle,
    required this.postContent,
  });

  factory KvkkData.fromJson(Map<String, dynamic> json) {
    return KvkkData(
      postID: json['postID'] ?? 0,
      postTitle: json['postTitle'] ?? '',
      postContent: json['postContent'] ?? '',
    );
  }
}
