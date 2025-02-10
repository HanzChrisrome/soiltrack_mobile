// router_notifier.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref ref;
  bool? isSetupCompleted; // Cached flag for setup completion

  RouterNotifier(this.ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
    _loadSetupStatus(); // Load setup status from cache
  }

  Future<void> _loadSetupStatus() async {
    final prefs = await SharedPreferences.getInstance();
    isSetupCompleted = prefs.getBool('device_setup_completed') ?? false;
    notifyListeners();
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = ref.read(authProvider);
    final isAuth = authState.isAuthenticated;
    final isLoggingIn = state.matchedLocation == '/login';
    final isRegistering = state.matchedLocation == '/register';

    if (isSetupCompleted == null) return null; // Wait for cache to load

    if (!isAuth && !isLoggingIn && !isRegistering) return '/login';

    if (isAuth) {
      if (isLoggingIn || isRegistering) {
        return isSetupCompleted! ? '/home' : '/setup';
      }

      if (state.matchedLocation == '/setup' && isSetupCompleted!) {
        return '/home';
      }
    }

    return null;
  }
}
