class FaqResponse {
  final bool? error;
  final bool? success;
  final FaqData? data;

  FaqResponse({
    this.error,
    this.success,
    this.data,
  });

  factory FaqResponse.fromJson(Map<String, dynamic> json) {
    return FaqResponse(
      error: json['error'],
      success: json['success'],
      data: json['data'] != null ? FaqData.fromJson(json['data']) : null,
    );
  }
}

class FaqData {
  final List<Faq>? faqs;

  FaqData({this.faqs});

  factory FaqData.fromJson(Map<String, dynamic> json) {
    return FaqData(
      faqs: json['faqs'] != null
          ? (json['faqs'] as List).map((i) => Faq.fromJson(i)).toList()
          : null,
    );
  }
}

class Faq {
  final String? faqTitle;
  final String? faqExcerpt;

  Faq({
    this.faqTitle,
    this.faqExcerpt,
  });

  factory Faq.fromJson(Map<String, dynamic> json) {
    return Faq(
      faqTitle: json['faqTitle'],
      faqExcerpt: json['faqExcerpt'],
    );
  }
}
