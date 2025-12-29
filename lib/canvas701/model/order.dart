/// Sipariş Modeli
class Order {
  final String id;
  final String orderNumber;
  final List<OrderItem> items;
  final OrderAddress shippingAddress;
  final OrderAddress? billingAddress;
  final double subtotal;
  final double shippingCost;
  final double discount;
  final double total;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final String? trackingNumber;
  final String? trackingUrl;
  final DateTime createdAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.items,
    required this.shippingAddress,
    this.billingAddress,
    required this.subtotal,
    this.shippingCost = 0,
    this.discount = 0,
    required this.total,
    required this.status,
    required this.paymentMethod,
    this.trackingNumber,
    this.trackingUrl,
    required this.createdAt,
    this.shippedAt,
    this.deliveredAt,
  });

  /// Kargo takip edilebilir mi?
  bool get canTrack => trackingNumber != null && trackingUrl != null;

  /// İptal edilebilir mi?
  bool get canCancel =>
      status == OrderStatus.pending || status == OrderStatus.confirmed;

  /// İade edilebilir mi? (14 gün içinde)
  bool get canReturn {
    if (deliveredAt == null) return false;
    final daysSinceDelivery = DateTime.now().difference(deliveredAt!).inDays;
    return daysSinceDelivery <= 14;
  }
}

/// Sipariş Ürün Modeli
class OrderItem {
  final String productId;
  final String productCode;
  final String productName;
  final String productImage;
  final String sizeName;
  final double unitPrice;
  final int quantity;
  final double totalPrice;

  const OrderItem({
    required this.productId,
    required this.productCode,
    required this.productName,
    required this.productImage,
    required this.sizeName,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
  });
}

/// Sipariş Durumu
enum OrderStatus {
  pending('Beklemede'),
  confirmed('Onaylandı'),
  preparing('Hazırlanıyor'),
  shipped('Kargoya Verildi'),
  delivered('Teslim Edildi'),
  cancelled('İptal Edildi'),
  returned('İade Edildi');

  final String displayName;
  const OrderStatus(this.displayName);
}

/// Ödeme Yöntemi
enum PaymentMethod {
  creditCard('Kredi Kartı'),
  debitCard('Banka Kartı'),
  bankTransfer('Havale/EFT');

  final String displayName;
  const PaymentMethod(this.displayName);
}

/// Adres Modeli
class OrderAddress {
  final String fullName;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String district;
  final String postalCode;
  final String country;

  const OrderAddress({
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.district,
    required this.postalCode,
    this.country = 'Türkiye',
  });

  /// Tam adres
  String get fullAddress {
    final parts = [addressLine1];
    if (addressLine2 != null) parts.add(addressLine2!);
    parts.addAll([district, city, postalCode, country]);
    return parts.join(', ');
  }
}
