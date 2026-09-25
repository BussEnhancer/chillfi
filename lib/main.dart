import 'package:chillfi/core/providers/auth_provider.dart';
import 'package:chillfi/core/services/api_service.dart';
import 'package:chillfi/core/providers/cart_provider.dart';
import 'package:chillfi/core/providers/product_provider.dart';
import 'package:chillfi/core/providers/wishlist_provider.dart';
import 'package:chillfi/features/intro/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> _initNotifications() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  await _localNotifications.initialize(
    const InitializationSettings(android: androidSettings, iOS: iosSettings),
  );
  // One named, high-importance channel for order updates (also the default for background FCM).
  await _localNotifications
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(
        'chillfi_channel', 'Order updates',
        description: 'Order, shipping and delivery updates from ChillFi',
        importance: Importance.high,
      ));

  FirebaseMessaging.onMessage.listen((message) {
    final notification = message.notification;
    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails('chillfi_channel', 'Order updates', importance: Importance.high, priority: Priority.high),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  });
  // Permission is requested in context (Notification permission screen), not at cold start.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fonts ship with the app (assets/fonts, SIL OFL) — never downloaded at runtime.
  GoogleFonts.config.allowRuntimeFetching = false;
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(['Poppins'], await rootBundle.loadString('assets/fonts/OFL.txt'));
  });

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Firebase (push notifications) is optional for the app to function — a
  // missing/misconfigured native config (e.g. no GoogleService-Info.plist on
  // iOS) must not prevent the rest of the app (browsing, cart, checkout, etc.,
  // none of which depend on Firebase) from launching.
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await _initNotifications();
  } catch (e) {
    debugPrint('Firebase/notifications init error: $e');
  }

  // DEBUG-ONLY test hook: seeds a session for emulator E2E tests when built with
  // --dart-define=DEV_ACCESS_TOKEN=<jwt>. Compiled out of release builds (kDebugMode const).
  const devToken = String.fromEnvironment('DEV_ACCESS_TOKEN');
  if (kDebugMode && devToken.isNotEmpty) {
    await ApiService().saveTokens(devToken, 'dev-no-refresh');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'CHILLFI',
            theme: ThemeData(
              useMaterial3: true,
              scaffoldBackgroundColor: Colors.white,
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
