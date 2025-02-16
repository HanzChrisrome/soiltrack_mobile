// router_notifier.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref ref;
  bool? isSetupCompleted;

  RouterNotifier(this.ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
    _loadSetupStatus();
  }

  Future<void> _loadSetupStatus() async {
    final prefs = await SharedPreferences.getInstance();
    isSetupCompleted = prefs.getBool('device_setup_completed') ?? false;
    print('Setup status: $isSetupCompleted');
    notifyListeners();
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = ref.read(authProvider);
    final isAuth = authState.isAuthenticated;
    final isLoggingIn = state.matchedLocation == '/login';
    final isRegistering = state.matchedLocation == '/login/register';

    if (isSetupCompleted == null) return null;

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
