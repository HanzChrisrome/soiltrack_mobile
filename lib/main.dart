import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseConfig().initialize();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.read(routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'SoilTrack',
      theme: lightTheme,
      routerConfig: router,
    );
  }
}
