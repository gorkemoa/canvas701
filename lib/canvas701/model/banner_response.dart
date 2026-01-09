class BannerResponse {
  final bool? error;
  final bool? success;
  final BannerData? data;

  BannerResponse({this.error, this.success, this.data});

  factory BannerResponse.fromJson(Map<String, dynamic> json) {
    return BannerResponse(
      error: json['error'],
      success: json['success'],
      data: json['data'] != null ? BannerData.fromJson(json['data']) : null,
    );
  }
}

class BannerData {
  final List<ApiBanner>? banners;

  BannerData({this.banners});

  factory BannerData.fromJson(Map<String, dynamic> json) {
    return BannerData(
      banners: json['banners'] != null
          ? (json['banners'] as List).map((i) => ApiBanner.fromJson(i)).toList()
          : null,
    );
  }
}

class ApiBanner {
  final String? postTitle;
  final String? postExcerpt;
  final String? postLink;
  final String? postDeeplinkKey;
  final String? postDeeplinkValue;
  final String? postMainImage;
  final String? postThumbImage;

  ApiBanner({
    this.postTitle,
    this.postExcerpt,
    this.postLink,
    this.postDeeplinkKey,
    this.postDeeplinkValue,
    this.postMainImage,
    this.postThumbImage,
  });

  factory ApiBanner.fromJson(Map<String, dynamic> json) {
    return ApiBanner(
      postTitle: json['postTitle'],
      postExcerpt: json['postExcerpt'],
      postLink: json['postLink'],
      postDeeplinkKey: json['postDeeplinkKey'],
      postDeeplinkValue: json['postDeeplinkValue'],
      postMainImage: json['postMainImage'],
      postThumbImage: json['postThumbImage'],
    );
  }
}
