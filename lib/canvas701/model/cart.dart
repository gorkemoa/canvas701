import 'product.dart';

/// Sepet Modeli
class Cart {
  final List<CartItem> items;

  const Cart({
    this.items = const [],
  });

  /// Sepet boş mu?
  bool get isEmpty => items.isEmpty;

  /// Sepetteki toplam ürün sayısı
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Sepet tutarı (indirimler dahil)
  double get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);

  /// Kargo ücreti
  double get shippingCost => 0; // Canvas701'de ücretsiz kargo

  /// Toplam tutar
  double get total => subtotal + shippingCost;

  /// Sepete ürün ekle
  Cart addItem(CartItem newItem) {
    final existingIndex = items.indexWhere(
      (item) => item.productId == newItem.productId && item.sizeId == newItem.sizeId,
    );

    if (existingIndex >= 0) {
      // Varolan ürünün miktarını artır
      final updatedItems = List<CartItem>.from(items);
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + newItem.quantity,
      );
      return Cart(items: updatedItems);
    }

    return Cart(items: [...items, newItem]);
  }

  /// Sepetten ürün çıkar
  Cart removeItem(String productId, String sizeId) {
    return Cart(
      items: items.where((item) => !(item.productId == productId && item.sizeId == sizeId)).toList(),
    );
  }

  /// Ürün miktarını güncelle
  Cart updateQuantity(String productId, String sizeId, int quantity) {
    if (quantity <= 0) {
      return removeItem(productId, sizeId);
    }

    final updatedItems = items.map((item) {
      if (item.productId == productId && item.sizeId == sizeId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    return Cart(items: updatedItems);
  }

  /// Sepeti temizle
  Cart clear() => const Cart();
}

/// Sepet Ürün Modeli
class CartItem {
  final String productId;
  final String productCode;
  final String productName;
  final String productImage;
  final String sizeId;
  final String sizeName;
  final double unitPrice;
  final int quantity;

  const CartItem({
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.productImage,
    required this.sizeId,
    required this.sizeName,
    required this.unitPrice,
    this.quantity = 1,
  });

  /// Toplam fiyat
  double get totalPrice => unitPrice * quantity;

  CartItem copyWith({
    String? productId,
    String? productCode,
    String? productName,
    String? productImage,
    String? sizeId,
    String? sizeName,
    double? unitPrice,
    int? quantity,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productCode: productCode ?? this.productCode,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      sizeId: sizeId ?? this.sizeId,
      sizeName: sizeName ?? this.sizeName,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }

  /// Product'tan CartItem oluştur
  factory CartItem.fromProduct(Product product, ProductSize size, {int quantity = 1}) {
    return CartItem(
      productId: product.id,
      productCode: product.code,
      productName: product.name,
      productImage: product.thumbnail,
      sizeId: size.id,
      sizeName: size.displaySize,
      unitPrice: size.price,
      quantity: quantity,
    );
  }
}
