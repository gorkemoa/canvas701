import '../model/model.dart';

/// Canvas701.com'dan çekilen gerçek veriler
/// Base URL: https://www.canvas701.com
class Canvas701Data {
  Canvas701Data._();

  /// Base URL
  static const String baseUrl = 'https://www.canvas701.com';

  /// Görsel URL oluştur
  static String imageUrl(String slug) => '$baseUrl/upload/images/$slug.jpg';

  /// Ürün URL oluştur
  static String productUrl(String slug) => '$baseUrl/$slug';

  /// Kategori URL oluştur
  static String categoryUrl(String slug) => '$baseUrl/kanvas-tablolar/$slug';

  /// Kategoriler - Artık API'den geliyor
  static const List<Category> categories = [];

  static const List<ProductSize> defaultSizes = [
    ProductSize(id: '1', name: '30x45', width: 30, height: 45, price: 299.90),
    ProductSize(id: '2', name: '40x60', width: 40, height: 60, price: 399.90),
    ProductSize(id: '3', name: '50x70', width: 50, height: 70, price: 449.90),
    ProductSize(id: '4', name: '60x90', width: 60, height: 90, price: 549.90),
    ProductSize(id: '5', name: '70x100', width: 70, height: 100, price: 649.90),
  ];

  /// Artık API kullanılıyor
  static List<Product> get bestsellers => [];
  static List<Product> get newArrivals => [];
  static List<Product> get luxuryProducts => [];
  static List<Product> get ataturkProducts => [];
  static List<Product> get allProducts => [];

  /// Koleksiyonlar
  static const List<Collection> collections = [];

  /// Toplam ürün sayısı (Canvas701.com'dan)
  static const int totalProductCount = 1388;
}
