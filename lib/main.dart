import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:skypec/Design/AppTheme.dart';
import 'package:skypec/Global/GlobalValue.dart';
import 'package:skypec/Route/AppPages.dart';
import 'package:skypec/Route/AppRoutes.dart';
import 'package:skypec/firebase_options.dart';

String? _initialFcmToken;

// ⭐ Khai báo plugin local notification
final FlutterLocalNotificationsPlugin _localNoti =
    FlutterLocalNotificationsPlugin();

// ⭐ Android notification channel
const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);

// ⭐ Xử lý khi app bị kill và user nhấn notification
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('Background message: ${message.messageId}');
}

// ⭐ Xử lý điều hướng khi nhấn notification
void _handleNotificationTap(String? payload) {
  debugPrint('Notification tapped, payload: $payload');

  // Đợi navigation sẵn sàng
  WidgetsBinding.instance.addPostFrameCallback((_) {
    Get.toNamed(Routes.notify);
  });
}

// ⭐ Hiển thị local notification khi nhận FCM ở foreground
Future<void> _showLocalNotification(RemoteMessage message) async {
  final notification = message.notification;
  if (notification == null) return;

  const androidDetails = AndroidNotificationDetails(
    'high_importance_channel',
    'High Importance Notifications',
    channelDescription: 'This channel is used for important notifications.',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  const iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  const details = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  await _localNoti.show(
    notification.hashCode,
    notification.title,
    notification.body,
    details,
    payload: jsonEncode(message.data),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⭐ Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final messaging = FirebaseMessaging.instance;
  await messaging.setAutoInitEnabled(true);

  // ═══════════════════════════════════════════════════════════
  // ⭐ PERMISSION (iOS + Android 13+)
  // ═══════════════════════════════════════════════════════════
  try {
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('📱 Notification permission: ${settings.authorizationStatus}');
  } catch (e) {
    debugPrint('⚠️ Permission error: $e');
  }

  if (Platform.isIOS) {
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    // 🔥 Đợi APNS token sẵn sàng (quan trọng cho iOS)
    debugPrint('⏳ Waiting for APNS token...');
    await Future.delayed(const Duration(seconds: 5));
  }

  // ═══════════════════════════════════════════════════════════
  // ⭐ KHỞI TẠO LOCAL NOTIFICATION
  // ═══════════════════════════════════════════════════════════
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const initSettings = InitializationSettings(
    android: androidInit,
    iOS: iosInit,
  );

  await _localNoti.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (response) {
      // ⭐ User nhấn local notification → mở view Notify
      _handleNotificationTap(response.payload);
    },
  );

  // ⭐ Tạo Android channel
  await _localNoti
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_channel);

  // ═══════════════════════════════════════════════════════════
  // ⭐ LISTENERS
  // ═══════════════════════════════════════════════════════════

  // Foreground → show local notification
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Foreground message: ${message.messageId}');
    _showLocalNotification(message);
  });

  // Background → user nhấn → mở Notify
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    debugPrint('Message opened from background: ${message.messageId}');
    _handleNotificationTap(jsonEncode(message.data));
  });

  // App bị kill → user nhấn notification → mở app + mở Notify
  final initialMessage = await messaging.getInitialMessage();
  if (initialMessage != null) {
    debugPrint('Message opened from terminated: ${initialMessage.messageId}');
    Future.delayed(const Duration(milliseconds: 800), () {
      _handleNotificationTap(jsonEncode(initialMessage.data));
    });
  }

  // ═══════════════════════════════════════════════════════════
  // ⭐ LẤY FCM TOKEN (có retry cho iOS)
  // ═══════════════════════════════════════════════════════════
  bool tokenReceived = false;
  int maxRetries = 5;
  int retryCount = 0;

  while (!tokenReceived && retryCount < maxRetries) {
    try {
      debugPrint(
          '⏳ Getting FCM token (attempt ${retryCount + 1}/$maxRetries)...');

      _initialFcmToken = await messaging.getToken().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⚠️ Timeout getting FCM token');
          return '';
        },
      );

      if (_initialFcmToken != null && _initialFcmToken!.isNotEmpty) {
        tokenReceived = true;
        debugPrint('✅ FCM token: $_initialFcmToken');
      } else {
        debugPrint('⚠️ FCM token empty, retrying...');
      }
    } catch (e) {
      debugPrint('⚠️ Cannot get FCM token (attempt ${retryCount + 1}): $e');
      if (e.toString().contains('apns-token-not-set')) {
        debugPrint('⏳ APNS token not set yet, waiting 3 seconds...');
        await Future.delayed(const Duration(seconds: 3));
      }
    }
    retryCount++;

    if (!tokenReceived && retryCount < maxRetries) {
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  if (!tokenReceived) {
    debugPrint('⚠️ Could not get FCM token after $maxRetries attempts');
    _initialFcmToken = '';
  }

  // ⭐ Lưu token vào GlobalValue
  GlobalValue.getInstance().setFCMToken(_initialFcmToken ?? '');

  // ⭐ Lắng nghe token refresh
  FirebaseMessaging.instance.onTokenRefresh.listen((t) {
    debugPrint('🔄 FCM token refreshed: $t');
    GlobalValue.getInstance().setFCMToken(t);
  }).onError((error) {
    debugPrint('⚠️ Token refresh error: $error');
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SkyPec',
      theme: buildAppTheme(),
      initialRoute: Routes.splash,
      getPages: AppPages.routes,
    );
  }
}