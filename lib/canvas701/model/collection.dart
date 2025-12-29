/// Canvas701 Koleksiyon Modeli
class Collection {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? thumbnailUrl;
  final int productCount;
  final bool isFeatured;
  final int sortOrder;

  const Collection({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.thumbnailUrl,
    this.productCount = 0,
    this.isFeatured = false,
    this.sortOrder = 0,
  });

  Collection copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? thumbnailUrl,
    int? productCount,
    bool? isFeatured,
    int? sortOrder,
  }) {
    return Collection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      productCount: productCount ?? this.productCount,
      isFeatured: isFeatured ?? this.isFeatured,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

/// Canvas701 Kategori Modeli
class Category {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? imageUrl;
  final String? parentId;
  final int productCount;
  final int sortOrder;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.imageUrl,
    this.parentId,
    this.productCount = 0,
    this.sortOrder = 0,
  });

  /// Alt kategori mi?
  bool get isSubcategory => parentId != null;

  Category copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    String? imageUrl,
    String? parentId,
    int? productCount,
    int? sortOrder,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      parentId: parentId ?? this.parentId,
      productCount: productCount ?? this.productCount,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
