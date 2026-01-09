import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../firebase_options.dart';
import 'navigation_service.dart';

/// Top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  developer.log('📬 Background message received', name: 'FCM');
}

/// Firebase Cloud Messaging service for handling push notifications
class FirebaseMessagingService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  /// Initialize Firebase Messaging
  static Future<void> initialize() async {
    try {
      developer.log('🚀 Initializing Firebase Messaging', name: 'FCM');

      // Register background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 1. Request notification permissions (iOS & Android 13+)
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      developer.log(
        '📱 Permission status: ${settings.authorizationStatus}',
        name: 'FCM',
      );

      // 2. iOS: Foreground presentation options
      if (Platform.isIOS) {
        await _firebaseMessaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // 3. Handle Foreground Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        developer.log('📨 Foreground message received', name: 'FCM');
        // Handle foreground message if needed (e.g. show in-app banner)
      });

      // 4. Handle notification taps (Background / Terminated)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageNavigation);

      RemoteMessage? initialMessage = await _firebaseMessaging
          .getInitialMessage();
      if (initialMessage != null) {
        developer.log(
          '🔔 App opened from terminated state via FCM',
          name: 'FCM',
        );
        Future.delayed(const Duration(milliseconds: 1000), () {
          _handleMessageNavigation(initialMessage);
        });
      }

      // 6. Token refresh and Token Log
      final token = await _firebaseMessaging.getToken();
      if (token != null) developer.log('🔑 FCM Token: $token', name: 'FCM');

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        developer.log('🔄 FCM Token refreshed: $newToken', name: 'FCM');
      });

      developer.log(
        '✅ Firebase Messaging initialization complete',
        name: 'FCM',
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ Error initializing FCM',
        name: 'FCM',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Subscribe to a topic using userId (String)
  static Future<void> subscribeToUserTopic(String userId) async {
    try {
      // Backend expects topic to be just the user ID string
      await _firebaseMessaging.subscribeToTopic(userId);
      developer.log('📌 Subscribed to topic: $userId', name: 'FCM');
    } catch (e) {
      developer.log('❌ Error subscribing to topic: $userId: $e', name: 'FCM');
    }
  }

  /// Unsubscribe from a topic
  static Future<void> unsubscribeFromUserTopic(String userId) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(userId);
      developer.log('📌 Unsubscribed from topic: $userId', name: 'FCM');
    } catch (e) {
      developer.log(
        '❌ Error unsubscribing from topic: $userId: $e',
        name: 'FCM',
      );
    }
  }

  static Future<String?> getToken() async =>
      await _firebaseMessaging.getToken();

  static void _handleMessageNavigation(RemoteMessage message) {
    _processNavigation(message.data, message.notification?.title);
  }

  static void _processNavigation(
    Map<String, dynamic> data,
    String? notificationTitle,
  ) {
    if (data.isEmpty) return;

    Map<String, dynamic> finalData = Map.from(data);

    // Parse nested keysandvalues if exists (as requested by user)
    if (finalData.containsKey('keysandvalues')) {
      try {
        String jsonStr = finalData['keysandvalues'].toString();

        // Malformed JSON sanitization: handles cases like "url": } by making it "url": null }
        // Also targets common trailing comma or missing value issues
        if (jsonStr.contains(': }') ||
            jsonStr.contains(':, }') ||
            jsonStr.contains(': }')) {
          jsonStr = jsonStr.replaceAll(RegExp(r':\s*}'), ': null}');
        }

        final nested = jsonDecode(jsonStr);
        if (nested is Map) {
          finalData.addAll(Map<String, dynamic>.from(nested));
        }
      } catch (e) {
        developer.log('❌ Error parsing keysandvalues JSON: $e', name: 'FCM');
        developer.log(
          '📦 Raw keysandvalues: ${finalData['keysandvalues']}',
          name: 'FCM',
        );
      }
    }

    final type = finalData['type'] as String? ?? '';
    // Use 'id' or 'type_id'
    final idValue = finalData['id'] ?? finalData['type_id'] ?? '0';
    final typeId = int.tryParse(idValue.toString()) ?? 0;
    final url = finalData['url'] as String?;
    final title = notificationTitle ?? finalData['title'] as String?;

    if (type.isNotEmpty || (url != null && url.isNotEmpty)) {
      developer.log(
        '🚀 FCM Navigating: $type (ID: $typeId, URL: $url)',
        name: 'FCM',
      );
      NavigationService().handleDeepLink(
        type: type,
        typeId: typeId,
        url: url,
        title: title,
      );
    }
  }
}