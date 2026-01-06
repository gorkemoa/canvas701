class FilterListResponse {
  final bool error;
  final bool success;
  final FilterListData? data;

  FilterListResponse({
    required this.error,
    required this.success,
    this.data,
  });

  factory FilterListResponse.fromJson(Map<String, dynamic> json) {
    return FilterListResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null ? FilterListData.fromJson(json['data']) : null,
    );
  }
}

class FilterListData {
  final List<FilterItem> sorts;
  final List<FilterItem> types;

  FilterListData({
    required this.sorts,
    required this.types,
  });

  factory FilterListData.fromJson(Map<String, dynamic> json) {
    return FilterListData(
      sorts: (json['sorts'] as List?)
              ?.map((i) => FilterItem.fromJson(i))
              .toList() ??
          [],
      types: (json['types'] as List?)
              ?.map((i) => FilterItem.fromJson(i))
              .toList() ??
          [],
    );
  }
}

class FilterItem {
  final String key;
  final String value;

  FilterItem({
    required this.key,
    required this.value,
  });

  factory FilterItem.fromJson(Map<String, dynamic> json) {
    return FilterItem(
      key: json['key'] ?? '',
      value: json['value'] ?? '',
    );
  }
}
