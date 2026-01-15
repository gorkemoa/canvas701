import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import '../view/product/product_detail_page.dart';
import '../view/profile/profile_page.dart';
import '../model/product_models.dart';
import 'product_service.dart';

/// Deep Link Service - Universal Links (iOS) ve App Links (Android) için
///
/// Desteklenen URL'ler:
/// - https://www.canvas701.com/product/{id}
/// - https://www.canvas701.com/profile/{username}
class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  GlobalKey<NavigatorState>? _navigatorKey;
  Uri? _pendingUri;

  /// Deep Link servisini başlatır
  void init(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;

    // App kapalıyken link ile açılırsa
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        debugPrint('🔗 DeepLinkService: Initial link received: $uri');
        _handleUri(uri);
      }
    });

    // App açıkken link gelirse
    _sub = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('🔗 DeepLinkService: Stream link received: $uri');
      _handleUri(uri);
    });

    debugPrint('✅ DeepLinkService: Initialized');
  }

  /// Bekleyen bir link varsa ve navigator hazırsa işle
  void checkPendingLink() {
    if (_pendingUri != null && _navigatorKey?.currentState != null) {
      final uri = _pendingUri!;
      _pendingUri = null;
      _handleUri(uri);
    }
  }

  /// URI'yi işler ve uygun sayfaya yönlendirir
  void _handleUri(Uri uri) {
    debugPrint('🔗 DeepLinkService: Handling URI: $uri');
    
    final navigator = _navigatorKey?.currentState;
    if (navigator == null) {
      debugPrint('⚠️ DeepLinkService: Navigator not ready, saving URI: $uri');
      _pendingUri = uri;
      return;
    }

    // Path segmentlerini veya host'u komut olarak kullan
    String? command;
    List<String> args = [];

    if (uri.scheme == 'canvas701') {
      // canvas701://product/123 -> host: product, path: /123
      command = uri.host;
      args = uri.pathSegments;
    } else {
      // https://www.canvas701.com/product/123 -> pathSegments: [product, 123]
      if (uri.pathSegments.isNotEmpty) {
        command = uri.pathSegments.first;
        args = uri.pathSegments.sublist(1);
      }
    }

    if (command == null) {
      debugPrint('⚠️ DeepLinkService: No command found in URI');
      return;
    }

    switch (command) {
      case 'product':
      case 'kanvas-tablolar':
        _handleProductDeepLink(args, navigator);
        break;

      case 'profile':
        _handleProfileDeepLink(args, navigator);
        break;

      default:
        debugPrint('⚠️ DeepLinkService: Unknown path: $command');
        navigator.pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  /// Product deep link handler
  void _handleProductDeepLink(List<String> args, NavigatorState navigator) async {
    final productId = args.isNotEmpty ? args.first : null;

    if (productId == null) {
      debugPrint('⚠️ DeepLinkService: Product ID/Slug not found');
      return;
    }

    debugPrint('🔗 DeepLinkService: Navigating to product: $productId');

    try {
      final productService = ProductService();
      
      // Eğer productId rakam değilse (slug ise) direkt detay çekemeyebiliriz
      // Ama mevcut API int bekliyor.
      final id = int.tryParse(productId);
      if (id == null) {
         debugPrint('❌ DeepLinkService: Product ID is not an integer (Slug logic not implemented yet): $productId');
         // Burada slug ile ürün arama API'si gerekebilir veya hata gösterilebilir
         return;
      }

      final response = await productService.getProductDetail(id);

      if (response.success && response.data?.product != null) {
        final apiProduct = response.data!.product!;
        
        double parsePrice(String price) {
          return double.tryParse(price.replaceAll('.', '').replaceAll(',', '.')) ?? 0.0;
        }

        final product = Product(
          id: apiProduct.productID.toString(),
          code: apiProduct.productCode,
          name: apiProduct.productName,
          description: apiProduct.cleanedDescription,
          price: parsePrice(apiProduct.productPrice),
          discountPrice: apiProduct.productPriceDiscount.isNotEmpty 
              ? parsePrice(apiProduct.productPriceDiscount) 
              : null,
          images: apiProduct.galleries.isNotEmpty 
              ? apiProduct.galleries.map((g) => g.img).toList() 
              : [apiProduct.productImage],
          thumbnailUrl: apiProduct.productImage,
          collectionId: '',
          tableType: apiProduct.productTableType,
          categoryIds: apiProduct.categories != null 
              ? [apiProduct.categories!.id.toString()] 
              : [],
          availableSizes: apiProduct.sizes.map((s) => ProductSize(
            id: s.sizeID.toString(),
            name: s.sizeName,
            tableType: s.sizeTableType,
            width: 0,
            height: 0,
            price: parsePrice(s.sizePrice),
          )).toList(),
          isFavorite: apiProduct.isFavorite,
          createdAt: DateTime.now(),
        );

        navigator.push(
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ DeepLinkService: Error: $e');
    }
  }

  /// Profile deep link handler
  void _handleProfileDeepLink(List<String> args, NavigatorState navigator) {
    navigator.push(
      MaterialPageRoute(
        builder: (_) => const ProfilePage(),
      ),
    );
  }

  /// Servisi temizle
  void dispose() {
    _sub?.cancel();
    debugPrint('🔗 DeepLinkService: Disposed');
  }
}
