class ProductListRequest {
  final String? userToken;
  final int catID;
  final String typeKey;
  final String sortKey;
  final String searchText;
  final int page;

  ProductListRequest({
    this.userToken,
    this.catID = 0,
    this.typeKey = '',
    this.sortKey = '',
    this.searchText = '',
    this.page = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken ?? '',
      'catID': catID,
      'typeKey': typeKey,
      'sortKey': sortKey,
      'searchText': searchText,
      'page': page,
    };
  }
}
