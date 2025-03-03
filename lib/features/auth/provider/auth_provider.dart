// ignore_for_file: avoid_print

import 'package:shared_preferences/shared_preferences.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/provider/soil_sensors_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider_state.dart';

class AuthNotifier extends Notifier<UserAuthState> {
  @override
  UserAuthState build() {
    final session = supabase.auth.currentSession;
    if (session != null) {
      _fetchUserName(session.user.id);
      return UserAuthState(
        user: session.user,
        isAuthenticated: true,
      );
    }

    return UserAuthState(isAuthenticated: false);
  }

  Future<void> _fetchUserName(String userId) async {
    try {
      final userRecord = await supabase.from('users').select('''
      user_fname,
      user_lname,
      user_email,
    ''').eq('user_id', userId).maybeSingle();

      final userIotDevice = await supabase
          .from('iot_devices')
          .select(
            'mac_address',
          )
          .eq('user_id', userId)
          .maybeSingle();

      NotifierHelper.logMessage('User Device: $userIotDevice');

      state = state.copyWith(
          userName: userRecord?['user_fname'],
          userLastName: userRecord?['user_lname'],
          userEmail: userRecord?['user_email'],
          isAuthenticated: true);

      NotifierHelper.logMessage('User: ${state.userName}');
    } catch (e) {
      NotifierHelper.logError(e);
    }
  }

  Future<void> signIn(String email, String password) async {
    final dashboardNotifier = ref.read(soilDashboardProvider.notifier);
    final sensorNotifier = ref.read(sensorsProvider.notifier);

    state = state.copyWith(isLoggingIn: true);
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await Future.wait([
          _fetchUserName(response.user!.id),
          dashboardNotifier.fetchUserPlots(),
          sensorNotifier.fetchSensors(),
        ]);

        state = state.copyWith(user: response.user, isAuthenticated: true);
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (e is AuthException) {
        errorMessage = e.message;
      }
      throw (errorMessage);
    } finally {
      state = state.copyWith(isLoggingIn: false);
    }
  }

  Future<void> signUp(
      String email, String password, String firstName, String lastName) async {
    state = state.copyWith(isRegistering: true);
    try {
      final existingUser = await supabase
          .from('users')
          .select()
          .eq('user_email', email)
          .maybeSingle();

      if (existingUser != null) {
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
        });
      }
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

  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('mac_address');

      await supabase.auth.signOut();
      state = state.copyWith(isAuthenticated: false, user: null, userName: '');
    } catch (e) {
      NotifierHelper.logError(e);
    }
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, UserAuthState>(() => AuthNotifier());
