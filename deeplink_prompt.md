https://www.canvas701.com/ alan adı için Flutter tarafında yapılması gerekenler aşağıdadır. Backend tarafı hazırsa, senin işin iOS + Android deep link yakalama ve yönlendirmedir.

1) Flutter tarafı (ortak – zorunlu)
Paket
dependencies:
  app_links: ^6.1.1

Universal / App Link dinleme servisi (net ve stabil yapı)
import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  void init(GlobalKey<NavigatorState> navigatorKey) {
    // App kapalıyken link ile açılırsa
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleUri(uri, navigatorKey);
      }
    });

    // App açıkken link gelirse
    _sub = _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri, navigatorKey);
    });
  }

  void _handleUri(Uri uri, GlobalKey<NavigatorState> navigatorKey) {
    // Örnek:
    // https://www.canvas701.com/product/123
    // https://www.canvas701.com/profile/gorkem

    if (uri.pathSegments.isEmpty) return;

    switch (uri.pathSegments.first) {
      case 'product':
        final id = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
        if (id != null) {
          navigatorKey.currentState?.pushNamed(
            '/product',
            arguments: id,
          );
        }
        break;

      case 'profile':
        final username = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;
        if (username != null) {
          navigatorKey.currentState?.pushNamed(
            '/profile',
            arguments: username,
          );
        }
        break;

      default:
        navigatorKey.currentState?.pushNamed('/');
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}


main.dart:

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    DeepLinkService.instance.init(navigatorKey);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      routes: {
        '/': (_) => HomePage(),
        '/product': (_) => ProductDetailPage(),
        '/profile': (_) => ProfilePage(),
      },
    );
  }
}

2) ANDROID (çok kritik)
android/app/src/main/AndroidManifest.xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />

    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />

    <data
        android:scheme="https"
        android:host="www.canvas701.com" />
</intent-filter>


Şart:
Backend’in https://www.canvas701.com/.well-known/assetlinks.json dosyasını doğru yayınlamış olması gerekir.
SHA-256 fingerprint Play Console’daki App Signing ile birebir olmalı.

3) iOS (en çok hata burada olur)
ios/Runner/Info.plist
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>canvas701</string>
    </array>
  </dict>
</array>

<key>NSUserActivityTypes</key>
<array>
  <string>NSUserActivityTypeBrowsingWeb</string>
</array>

ios/Runner/Runner.entitlements
<key>com.apple.developer.associated-domains</key>
<array>
  <string>applinks:www.canvas701.com</string>
</array>

Apple tarafı backend kontrolü (zorunlu)

Backend şunu yayınlamış olmalı:

https://www.canvas701.com/.well-known/apple-app-site-association


JSON

Content-Type: application/json

.json uzantısı YOK

Cache yok / CDN bozmuyor

Örnek:

{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAMID.com.canvas701.app",
        "paths": [ "*" ]
      }
    ]
  }
}

4) Test etme (bunu yapmadan “olmuyor” deme)
iOS

Safari’ye yaz:

https://www.canvas701.com/product/123


App açılmalı

Açılmıyorsa AASA dosyası bozuktur

Android
adb shell am start \
 -a android.intent.action.VIEW \
 -d "https://www.canvas701.com/product/123"

