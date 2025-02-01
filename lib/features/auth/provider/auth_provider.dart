import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthState {
  final User? user;
  final String userName;
  final bool isAuthenticated;
  final bool isLoggingIn;
  final bool isRegistering;

  AuthState({
    this.user,
    this.userName = '',
    this.isAuthenticated = false,
    this.isLoggingIn = false,
    this.isRegistering = false,
  });

  AuthState copyWith({
    User? user,
    String? userName,
    bool? isAuthenticated,
    bool? isLoggingIn,
    bool? isRegistering,
  }) {
    return AuthState(
      user: user ?? this.user,
      userName: userName ?? this.userName,
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
          .select('userName')
          .eq('userId', userId)
          .single();

      state = state.copyWith(
          userName: userRecord['userName'], isAuthenticated: true);
    } catch (e) {
      print('Error fetching user name: $e');
    }
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoggingIn: true);
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _fetchUserName(response.user!.id);
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

  Future<void> signUp(String email, String password, String username) async {
    state = state.copyWith(isRegistering: true);
    try {
      final existingUser = await supabase
          .from('users')
          .select()
          .eq('userEmail', email)
          .maybeSingle();

      if (existingUser != null) {
        print('User already exists');
        return;
      }

      final response =
          await supabase.auth.signUp(email: email, password: password);

      if (response.user != null) {
        await supabase.from('users').insert({
          'userId': response.user!.id,
          'userEmail': email,
          'userName': username
        });
      }
    } catch (e) {
      print('Error signing up: $e');
    } finally {
      state = state.copyWith(isRegistering: false);
    }
  }

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      state = state.copyWith(isAuthenticated: false);
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(() => AuthNotifier());
