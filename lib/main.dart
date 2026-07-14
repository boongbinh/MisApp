import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:skypec/Design/AppTheme.dart';
import 'package:skypec/Global/GlobalValue.dart';
import 'package:skypec/Route/AppPages.dart';
import 'package:skypec/Route/AppRoutes.dart';
import 'package:skypec/firebase_options.dart';
// ... các import khác

String? _initialFcmToken; // lưu token để show sau khi runApp

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options:DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final messaging = FirebaseMessaging.instance;
  await messaging.setAutoInitEnabled(true);
//Trên iOS, cần xin notification permissions
  if (Platform.isIOS) {
    await messaging.requestPermission(alert: true, badge: true, sound: true);
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
  }
//Lấy token ban đầu của thiết bị (token này để server gửi push notification cho user cụ thể)
  _initialFcmToken = await messaging.getToken();
  debugPrint('FCM token (init): $_initialFcmToken');
  //Token được lưu vào một biến toàn cục
  GlobalValue.getInstance().setFCMToken(_initialFcmToken ?? '');

  FirebaseMessaging.instance.onTokenRefresh.listen((t) {
    debugPrint('FCM token (refresh): $t');
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
