import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';

import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/plots_provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/provider/shared_preferences.dart';
import 'package:soiltrack_mobile/theme/theme.dart';
import 'package:soiltrack_mobile/core/router/app_router.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await SupabaseConfig().initialize();
  await LanguagePreferences.init();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  bool _fcmInitialized = false;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFCM();
    });
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_notification');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'soiltrack_channel',
      'SoilTrack Notifications',
      description: 'Channel for SoilTrack notifications',
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _initFCM() async {
    if (_fcmInitialized) return;
    _fcmInitialized = true;

    try {
      await _initNotifications();
      print('🔔 Initializing Firebase Cloud Messaging...');
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      print('🔐 Notification permission: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        final token = await FirebaseMessaging.instance.getToken();
        print(token != null
            ? '✅ FCM Token: $token'
            : '❌ Failed to get FCM token (null)');

        if (token != null) {
          await ref.read(soilDashboardProvider.notifier).saveDeviceToken(token);
        }
      } else {
        print('❌ Notification permission denied');
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        print('📥 Foreground notification: ${message.notification?.title}');

        final notification = message.notification;
        final android = message.notification?.android;

        if (notification != null && android != null) {
          await flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'soiltrack_channel',
                'SoilTrack Notifications',
                channelDescription: 'Channel for SoilTrack notifications',
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
                icon: '@drawable/ic_notification',
              ),
            ),
          );
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('🚪 App opened from notification: ${message.data}');
      });
    } catch (e) {
      print('❌ Error during FCM init: $e');
    }
  }

  void _initDeepLinks() async {
    try {
      final Uri? initialUri = await _appLinks.uriLinkStream.first;
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }

      _sub = _appLinks.uriLinkStream.listen(
        (Uri uri) {
          _handleDeepLink(uri);
        },
        onError: (err) {
          debugPrint('AppLinks Error: $err');
        },
      );
    } catch (e) {
      debugPrint('Failed to get initial link: $e');
    }
  }

  void _handleDeepLink(Uri uri) {
    final token = uri.queryParameters['token'] ?? '';
    final email = uri.queryParameters['email'] ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = ref.read(routerProvider);
      router.go('/reset-password?token=$token&email=$email');
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.read(routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'SoilTrack',
      theme: lightTheme,
      routerConfig: router,
    );
  }
}
