import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/provider/soil_sensors_provider.dart';
import 'package:soiltrack_mobile/provider/weather_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider_state.dart';

class AuthNotifier extends Notifier<UserAuthState> {
  @override
  UserAuthState build() {
    return UserAuthState();
  }

  Future<void> initializeAuth() async {
    final session = supabase.auth.currentSession;
    if (session != null) {
      await fetchUserRecord(session.user.id);
      await fetchRelatedData();
    } else {
      state = state.copyWith(isAuthenticated: false);
    }
  }

  Future<void> fetchUserRecord(String userId) async {
    try {
      final userRecord = await supabase.from('users').select('''
      user_fname,
      user_lname,
      user_email
    ''').eq('user_id', userId).single();

      final userIotDevice = await supabase
          .from('iot_device')
          .select(
            'mac_address',
          )
          .eq('user_id', userId);

      final macAddress =
          userIotDevice.isNotEmpty ? userIotDevice.first['mac_address'] : '';
      NotifierHelper.logMessage('User Device: $macAddress');

      state = state.copyWith(
          userId: userId,
          userName: userRecord['user_fname'],
          userLastName: userRecord['user_lname'],
          userEmail: userRecord['user_email'],
          macAddress: macAddress,
          isAuthenticated: true,
          isSetupComplete: macAddress.isNotEmpty);
    } catch (e) {
      NotifierHelper.logError(e);
    }
  }

  Future<void> signIn(
      BuildContext context, String email, String password) async {
    if (state.lockoutTime != null &&
        DateTime.now().isBefore(state.lockoutTime!)) {
      NotifierHelper.showErrorToast(
          context, 'Too many failed attempts. Try again later!');
      return;
    }

    try {
      state = state.copyWith(isLoggingIn: true);
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await fetchUserRecord(response.user!.id);
        await fetchRelatedData();
        state = state.copyWith(
          user: response.user,
          isAuthenticated: true,
          failedAttempts: 0,
          lockoutTime: null,
        );

        NotifierHelper.logMessage(
            'Device setup completed: ${state.isSetupComplete}');
        if (state.isRegistering || !state.isSetupComplete) {
          context.go('/setup');
        } else {
          context.go('/home');
        }
      }
    } catch (e) {
      NotifierHelper.logError(e);
      int newFailedAttempts = (state.failedAttempts ?? 0) + 1;
      DateTime? newLockoutTime;

      if (newFailedAttempts >= 3) {
        newLockoutTime = DateTime.now().add(Duration(minutes: 1));
        NotifierHelper.showErrorToast(
            context, 'Too many attempts. Locked for 1 minute');

        Future.delayed(Duration(minutes: 1), () {
          if (state.lockoutTime != null &&
              DateTime.now().isAfter(state.lockoutTime!)) {
            state = state.copyWith(failedAttempts: 0, lockoutTime: null);
          }
        });
      } else {
        NotifierHelper.showErrorToast(
            context, "Invalid credentials. Attempt $newFailedAttempts/3.");
      }

      state = state.copyWith(
        failedAttempts: newFailedAttempts,
        lockoutTime: newLockoutTime,
      );
    } finally {
      state = state.copyWith(isLoggingIn: false);
    }
  }

  Future<void> signUp(String email, String password, String firstName,
      String lastName, String municipality, String city) async {
    state = state.copyWith(isRegistering: true);
    try {
      final existingUser = await supabase
          .from('users')
          .select()
          .eq('user_email', email)
          .maybeSingle();

      if (existingUser != null) {
        NotifierHelper.logMessage('Saving user preferences');
        state = state.copyWith(userEmail: email, userPassword: password);
        return;
      }

      final response =
          await supabase.auth.signUp(email: email, password: password);

      if (response.user != null) {
        await supabase.from('users').insert({
          'user_id': response.user!.id,
          'user_email': email,
          'user_fname': firstName,
          'user_lname': lastName,
          'user_municipality': municipality,
          'user_city': city,
        });
      }

      state = state.copyWith(userEmail: email, userPassword: password);
    } catch (e) {
      String errorMessage = e.toString();
      if (e is AuthException) {
        errorMessage = e.message;
      }
      throw (errorMessage);
    } finally {
      state = state.copyWith(isRegistering: false);
    }
  }

  Future<void> fetchRelatedData() async {
    final sensorNotifier = ref.read(sensorsProvider.notifier);
    final soilDashboardNotifier = ref.read(soilDashboardProvider.notifier);
    final deviceNotifier = ref.read(deviceProvider.notifier);
    final weatherNotifier = ref.read(weatherProvider.notifier);

    await sensorNotifier.fetchSensors();
    await soilDashboardNotifier.fetchUserPlots();
    await weatherNotifier.fetchWeather('Baliuag');
    await deviceNotifier.checkDeviceStatus();
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await supabase.auth.signOut();
      state = UserAuthState();
      context.go('/login');
    } catch (e) {
      NotifierHelper.logError(e);
    }
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, UserAuthState>(() => AuthNotifier());
