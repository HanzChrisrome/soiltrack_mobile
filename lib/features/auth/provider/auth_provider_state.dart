import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_provider_state.freezed.dart';

@freezed
class UserAuthState with _$UserAuthState {
  factory UserAuthState({
    User? user,
    String? userId,
    String? userName,
    String? userLastName,
    String? userEmail,
    String? userPassword,
    String? macAddress,
    int? failedAttempts,
    DateTime? lockoutTime,
    @Default(false) bool isAuthenticated,
    @Default(false) bool isLoggingIn,
    @Default(false) bool isRegistering,
    @Default(false) bool isSetupComplete,
    @Default(false) bool isRequestingChange,
  }) = _UserAuthState;
}
