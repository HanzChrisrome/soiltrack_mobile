// ignore_for_file: avoid_print

import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/provider/soil_sensors_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthState {
  final User? user;
  final String? userName;
  final String? userLastName;
  final String? userEmail;
  final bool isAuthenticated;
  final bool isLoggingIn;
  final bool isRegistering;

  AuthState({
    this.user,
    this.userName,
    this.userLastName,
    this.userEmail,
    this.isAuthenticated = false,
    this.isLoggingIn = false,
    this.isRegistering = false,
  });

  AuthState copyWith({
    User? user,
    String? userName,
    String? userLastName,
    String? userEmail,
    bool? isAuthenticated,
    bool? isLoggingIn,
    bool? isRegistering,
  }) {
    return AuthState(
      user: user ?? this.user,
      userName: userName ?? this.userName,
      userLastName: userLastName ?? this.userLastName,
      userEmail: userEmail ?? this.userEmail,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoggingIn: isLoggingIn ?? this.isLoggingIn,
      isRegistering: isRegistering ?? this.isRegistering,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    final session = supabase.auth.currentSession;
    if (session != null) {
      _fetchUserName(session.user.id);
      return AuthState(
        user: session.user,
        isAuthenticated: true,
      );
    }

    return AuthState(isAuthenticated: false);
  }

  void _fetchUserName(String userId) async {
    try {
      final userRecord = await supabase
          .from('users')
          .select('user_fname, user_lname, user_email')
          .eq('user_id', userId)
          .single();

      state = state.copyWith(
          userName: userRecord['user_fname'],
          userLastName: userRecord['user_lname'],
          userEmail: userRecord['user_email'],
          isAuthenticated: true);

      print('User name: ${state.userName}');
    } catch (e) {
      print('Error fetching user name: $e');
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
        _fetchUserName(response.user!.id);
        print('User: ${response.user}');

        dashboardNotifier.fetchUserPlots();
        dashboardNotifier.fetchUserPlotData();
        sensorNotifier.fetchSensors();

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
      await supabase.auth.signOut();
      state = state.copyWith(isAuthenticated: false, user: null, userName: '');
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(() => AuthNotifier());
