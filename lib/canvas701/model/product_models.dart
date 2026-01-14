/// Canvas701 Ürün Modeli
class Product {
  final String id;
  final String code; // örn: C701-118
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final List<String> images;
  final String? thumbnailUrl;
  final String collectionId;
  final String tableType;
  final List<String> categoryIds;
  final List<ProductSize> availableSizes;
  final bool isNew;
  final bool isBestseller;
  final bool isAvailable;
  final bool isFavorite;
  final DateTime createdAt;

  const Product({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.images,
    this.thumbnailUrl,
    required this.collectionId,
    required this.tableType,
    required this.categoryIds,
    required this.availableSizes,
    this.isNew = false,
    this.isBestseller = false,
    this.isAvailable = true,
    this.isFavorite = false,
    required this.createdAt,
  });

  factory Product.fromApi(ApiProduct apiProduct) {
    double parsePrice(String price) {
      return double.tryParse(price.replaceAll('.', '').replaceAll(',', '.')) ??
          0.0;
    }

    return Product(
      id: apiProduct.productID.toString(),
      code: apiProduct.productCode,
      name: apiProduct.productName,
      description: '', // Listede açıklama gelmiyor
      price: parsePrice(apiProduct.productPriceOriginal),
      discountPrice: apiProduct.isDiscount
          ? parsePrice(apiProduct.productPrice)
          : null,
      images: [apiProduct.productImage],
      thumbnailUrl: apiProduct.productImage,
      collectionId: '',
      tableType: '', // API listesinde gelmiyor, sadece detayda var
      categoryIds: [],
      availableSizes: [
        ProductSize(
          id: 'default',
          name: '50x70 cm',
          tableType: '',
          width: 50,
          height: 70,
          price: parsePrice(apiProduct.productPrice),
        ),
      ],
      isBestseller: false,
      isNew: false,
      isFavorite: apiProduct.isFavorite,
      createdAt: DateTime.now(),
    );
  }

  /// İndirimli mi?
  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  /// İndirim yüzdesi
  int get discountPercentage {
    if (!hasDiscount) return 0;
    return ((price - discountPrice!) / price * 100).round();
  }

  /// Görüntülenecek fiyat
  double get displayPrice => discountPrice ?? price;

  /// Ana görsel URL
  String get mainImage => images.isNotEmpty ? images.first : '';

  /// Thumbnail veya ana görsel
  String get thumbnail => thumbnailUrl ?? mainImage;

  Product copyWith({
    String? id,
    String? code,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    List<String>? images,
    String? thumbnailUrl,
    String? collectionId,
    String? tableType,
    List<String>? categoryIds,
    List<ProductSize>? availableSizes,
    bool? isNew,
    bool? isBestseller,
    bool? isAvailable,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      images: images ?? this.images,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      collectionId: collectionId ?? this.collectionId,
      tableType: tableType ?? this.tableType,
      categoryIds: categoryIds ?? this.categoryIds,
      availableSizes: availableSizes ?? this.availableSizes,
      isNew: id != null ? this.isNew : isNew ?? this.isNew,
      isBestseller: isBestseller ?? this.isBestseller,
      isAvailable: isAvailable ?? this.isAvailable,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Ürün Boyut Seçenekleri
class ProductSize {
  final String id;
  final String name; // örn: "50x70 cm"
  final String tableType; // örn: "Kare", "Dikdörtgen"
  final int width; // cm
  final int height; // cm
  final double price; // Bu boyut için fiyat

  const ProductSize({
    required this.id,
    required this.name,
    required this.tableType,
    required this.width,
    required this.height,
    required this.price,
  });

  /// Boyut gösterimi
  String get displaySize => name.isNotEmpty ? name : '${width}x$height cm';
}

class ProductDetailResponse {
  final bool error;
  final bool success;
  final ProductDetailData? data;
  final String? status200;

  ProductDetailResponse({
    required this.error,
    required this.success,
    this.data,
    this.status200,
  });

  factory ProductDetailResponse.fromJson(Map<String, dynamic> json) {
    return ProductDetailResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null
          ? ProductDetailData.fromJson(json['data'])
          : null,
      status200: json['200'],
    );
  }
}

class ProductDetailData {
  final ApiProductDetail? product;
  final List<ApiProduct> similarProducts;

  ProductDetailData({this.product, required this.similarProducts});

  factory ProductDetailData.fromJson(Map<String, dynamic> json) {
    return ProductDetailData(
      product: json['product'] != null
          ? ApiProductDetail.fromJson(json['product'])
          : null,
      similarProducts:
          (json['similarProducts'] as List?)
              ?.map((p) => ApiProduct.fromJson(p))
              .toList() ??
          [],
    );
  }
}

class ApiProductDetail {
  final int productID;
  final String productName;
  final String productExcerpt;
  final String productDescription;
  final String productImage;
  final String productFeaturedImage;
  final int productStock;
  final String productPrice;
  final String productCode;
  final String productLink;
  final String productPriceDiscount;
  final int productDiscountType;
  final String productDiscount;
  final String productDiscountIcon;
  final int totalComments;
  final String rating;
  final String cargoInfo;
  final String cargoDetail;
  final String productTableType;
  final bool isFavorite;
  final List<ApiProductGallery> galleries;
  final ApiProductCategory? categories;
  final List<ApiProductSize> sizes;

  String get cleanedDescription {
    if (productDescription.isEmpty) return '';
    return productDescription
        .replaceAll('<p>', '')
        .replaceAll('</p>', '\n\n')
        .replaceAll('<br>', '\n')
        .replaceAll('<br />', '\n')
        .replaceAll('<li>', '• ')
        .replaceAll('</li>', '\n')
        .replaceAll('&bull;', '•')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&lsquo;', "'")
        .replaceAll('&rsquo;', "'")
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"')
        .replaceAll('&ndash;', '–')
        .replaceAll('&mdash;', '—')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&Ouml;', 'Ö')
        .replaceAll('&ouml;', 'ö')
        .replaceAll('&Uuml;', 'Ü')
        .replaceAll('&uuml;', 'ü')
        .replaceAll('&Iuml;', 'İ')
        .replaceAll('&iuml;', 'i')
        .replaceAll('&Iota;', 'İ')
        .replaceAll('&iota;', 'i')
        .replaceAll('&Ccedil;', 'Ç')
        .replaceAll('&ccedil;', 'ç')
        .replaceAll('&Scedil;', 'Ş')
        .replaceAll('&scedil;', 'ş')
        .replaceAll('&Gbreve;', 'Ğ')
        .replaceAll('&gbreve;', 'ğ')
        .replaceAll('&icirc;', 'î')
        .replaceAll('&Icirc;', 'Î')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n') // Max 2 newlines
        .trim();
  }

  ApiProductDetail({
    required this.productID,
    required this.productName,
    required this.productExcerpt,
    required this.productDescription,
    required this.productImage,
    required this.productFeaturedImage,
    required this.productStock,
    required this.productCode,
    required this.productLink,
    required this.productPrice,
    required this.productPriceDiscount,
    required this.productDiscountType,
    required this.productDiscount,
    required this.productDiscountIcon,
    required this.totalComments,
    required this.rating,
    required this.cargoInfo,
    required this.cargoDetail,
    required this.productTableType,
    required this.isFavorite,
    required this.galleries,
    this.categories,
    required this.sizes,
  });

  factory ApiProductDetail.fromJson(Map<String, dynamic> json) {
    return ApiProductDetail(
      productID: json['productID'] ?? 0,
      productName: json['productName'] ?? '',
      productExcerpt: json['productExcerpt'] ?? '',
      productDescription: json['productDescription'] ?? '',
      productCode: json['productCode'] ?? '',
      productLink: json['productLink'] ?? '',
      productImage: json['productImage'] ?? '',
      productFeaturedImage: json['productFeaturedImage'] ?? '',
      productStock: json['productStock'] ?? 0,
      productPrice: json['productPrice'] ?? '',
      productPriceDiscount: json['productPriceDiscount'] ?? '',
      productDiscountType: json['productDiscountType'] ?? 0,
      productDiscount: json['productDiscount'] ?? '',
      productDiscountIcon: json['productDiscountIcon'] ?? '',
      totalComments: json['totalComments'] ?? 0,
      rating: json['rating'] ?? '0',
      cargoInfo: json['cargoInfo'] ?? '',
      cargoDetail: json['cargoDetail'] ?? '',
      productTableType: json['productTableType'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
      galleries:
          (json['galleries'] as List?)
              ?.map((g) => ApiProductGallery.fromJson(g))
              .toList() ??
          [],
      categories: json['categories'] != null
          ? ApiProductCategory.fromJson(json['categories'])
          : null,
      sizes:
          (json['sizes'] as List?)
              ?.map((s) => ApiProductSize.fromJson(s))
              .toList() ??
          [],
    );
  }
}

class ApiProductGallery {
  final String title;
  final String img;

  ApiProductGallery({required this.title, required this.img});

  factory ApiProductGallery.fromJson(Map<String, dynamic> json) {
    return ApiProductGallery(
      title: json['title'] ?? '',
      img: json['img'] ?? '',
    );
  }
}

class ApiProductCategory {
  final int id;
  final String name;

  ApiProductCategory({required this.id, required this.name});

  factory ApiProductCategory.fromJson(Map<String, dynamic> json) {
    return ApiProductCategory(id: json['id'] ?? 0, name: json['name'] ?? '');
  }
}

class ApiProductSize {
  final int sizeID;
  final String sizeName;
  final String sizeTableType;
  final String sizePrice;
  final String sizePriceDiscount;
  final int sizeDiscountType;
  final String sizeDiscount;
  final String sizeDiscountIcon;

  ApiProductSize({
    required this.sizeID,
    required this.sizeName,
    required this.sizeTableType,
    required this.sizePrice,
    required this.sizePriceDiscount,
    required this.sizeDiscountType,
    required this.sizeDiscount,
    required this.sizeDiscountIcon,
  });

  factory ApiProductSize.fromJson(Map<String, dynamic> json) {
    return ApiProductSize(
      sizeID: json['sizeID'] ?? 0,
      sizeName: json['sizeName'] ?? '',
      sizeTableType: json['sizeTableType'] ?? '',
      sizePrice: json['sizePrice'] ?? '',
      sizePriceDiscount: json['sizePriceDiscount'] ?? '',
      sizeDiscountType: json['sizeDiscountType'] ?? 0,
      sizeDiscount: json['sizeDiscount'] ?? '',
      sizeDiscountIcon: json['sizeDiscountIcon'] ?? '',
    );
  }
}

class ProductListRequest {
  final String? userToken;
  final List<int> catID;
  final String typeKey;
  final String sortKey;
  final String searchText;
  final int page;

  ProductListRequest({
    this.userToken,
    this.catID = const [],
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

class ProductListResponse {
  final bool error;
  final bool success;
  final ProductListData? data;

  ProductListResponse({required this.error, required this.success, this.data});

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    return ProductListResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null
          ? ProductListData.fromJson(json['data'])
          : null,
    );
  }
}

class ProductListData {
  final int page;
  final int pageSize;
  final int totalPages;
  final int totalItems;
  final bool hasNextPage;
  final String emptyMessage;
  final List<ApiProduct> products;

  ProductListData({
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.totalItems,
    required this.hasNextPage,
    required this.emptyMessage,
    required this.products,
  });

  factory ProductListData.fromJson(Map<String, dynamic> json) {
    return ProductListData(
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      totalItems: json['totalItems'] ?? 0,
      hasNextPage: json['hasNextPage'] ?? false,
      emptyMessage: json['emptyMessage'] ?? '',
      products:
          (json['products'] as List?)
              ?.map((p) => ApiProduct.fromJson(p))
              .toList() ??
          [],
    );
  }
}

class FavoriteListResponse {
  final bool error;
  final bool success;
  final FavoriteListData? data;

  FavoriteListResponse({
    required this.error,
    required this.success,
    this.data,
  });

  factory FavoriteListResponse.fromJson(Map<String, dynamic> json) {
    return FavoriteListResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      data: json['data'] != null ? FavoriteListData.fromJson(json['data']) : null,
    );
  }
}

class FavoriteListData {
  final int totalItems;
  final String emptyMessage;
  final List<ApiProduct> favoriteProducts;

  FavoriteListData({
    required this.totalItems,
    required this.emptyMessage,
    required this.favoriteProducts,
  });

  factory FavoriteListData.fromJson(Map<String, dynamic> json) {
    return FavoriteListData(
      totalItems: json['totalItems'] ?? 0,
      emptyMessage: json['emptyMessage'] ?? '',
      favoriteProducts: (json['favoriteProducts'] as List?)
              ?.map((p) => ApiProduct.fromJson(p))
              .toList() ??
          [],
    );
  }
}

class ApiProduct {
  final int productID;
  final String productCode;
  final String productName;
  final String productImage;
  final String productPrice;
  final String productPriceOriginal;
  final String productDiscountIcon;
  final bool isDiscount;
  final bool isFavorite;

  ApiProduct({
    required this.productID,
    required this.productCode,
    required this.productName,
    required this.productImage,
    required this.productPrice,
    required this.productPriceOriginal,
    required this.productDiscountIcon,
    required this.isDiscount,
    required this.isFavorite,
  });

  factory ApiProduct.fromJson(Map<String, dynamic> json) {
    return ApiProduct(
      productID: json['productID'] ?? 0,
      productCode: json['productCode'] ?? '',
      productName: json['productName'] ?? '',
      productImage: json['productImage'] ?? '',
      productPrice: json['productPrice'] ?? '',
      productPriceOriginal: json['productPriceOriginal'] ?? '',
      productDiscountIcon: json['productDiscountIcon'] ?? '',
      isDiscount: json['isDiscount'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
    );
  }
}

class AddDeleteFavoriteRequest {
  final String? userToken;
  final int productID;

  AddDeleteFavoriteRequest({
    this.userToken,
    required this.productID,
  });

  Map<String, dynamic> toJson() {
    return {
      'userToken': userToken ?? '',
      'productID': productID,
    };
  }
}

class AddDeleteFavoriteResponse {
  final bool error;
  final bool success;
  final String? message;

  AddDeleteFavoriteResponse({
    required this.error,
    required this.success,
    this.message,
  });

  factory AddDeleteFavoriteResponse.fromJson(Map<String, dynamic> json) {
    return AddDeleteFavoriteResponse(
      error: json['error'] ?? true,
      success: json['success'] ?? false,
      message: json['data']?['message'],
    );
  }
}
