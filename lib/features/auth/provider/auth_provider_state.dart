import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_provider_state.freezed.dart';

@freezed
class UserAuthState with _$UserAuthState {
  factory UserAuthState({
    User? user,
    String? userName,
    String? userLastName,
    String? userEmail,
    String? macAddress,
    @Default(false) bool isAuthenticated,
    @Default(false) bool isLoggingIn,
    @Default(false) bool isRegistering,
  }) = _UserAuthState;
}
