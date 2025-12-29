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
  final List<String> categoryIds;
  final List<ProductSize> availableSizes;
  final bool isNew;
  final bool isBestseller;
  final bool isAvailable;
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
    required this.categoryIds,
    required this.availableSizes,
    this.isNew = false,
    this.isBestseller = false,
    this.isAvailable = true,
    required this.createdAt,
  });

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
    List<String>? categoryIds,
    List<ProductSize>? availableSizes,
    bool? isNew,
    bool? isBestseller,
    bool? isAvailable,
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
      categoryIds: categoryIds ?? this.categoryIds,
      availableSizes: availableSizes ?? this.availableSizes,
      isNew: isNew ?? this.isNew,
      isBestseller: isBestseller ?? this.isBestseller,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Ürün Boyut Seçenekleri
class ProductSize {
  final String id;
  final String name; // örn: "50x70 cm"
  final int width; // cm
  final int height; // cm
  final double price; // Bu boyut için fiyat

  const ProductSize({
    required this.id,
    required this.name,
    required this.width,
    required this.height,
    required this.price,
  });

  /// Boyut gösterimi
  String get displaySize => '${width}x$height cm';
}
