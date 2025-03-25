import 'dart:async';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/core/router/app_router.dart';
import 'package:uni_links/uni_links.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig().initialize();
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
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() async {
    Uri? initialUri = await getInitialUri();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }

    _sub = uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          _handleDeepLink(uri);
        }
      },
      onError: (err) {
        debugPrint('Error: $err');
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    debugPrint('🔗 Deep link received: $uri');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = ref.read(routerProvider);
      router.go('/reset-password');
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
