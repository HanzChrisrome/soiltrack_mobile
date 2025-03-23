// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authProvider.notifier);

    Future.microtask(() async {
      await authNotifier.initializeAuth();

      if (context.mounted) {
        final authState = ref.read(authProvider);
        final isAuth = authState.isAuthenticated;

        NotifierHelper.logMessage(
            'Setup Completed: ${authState.isSetupComplete}');

        if (!isAuth) {
          context.go('/get-started');
        } else if (!authState.isSetupComplete) {
          context.go('/setup');
        } else {
          context.go('/device-exists');
        }
      }
    });

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/background/background_splash.png',
            fit: BoxFit.cover,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo/soiltrack gradient.png',
                  height: 230,
                ),
                LoadingAnimationWidget.progressiveDots(
                    color: Theme.of(context).colorScheme.onPrimary, size: 70),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
