import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/chat_bot/provider/chatbot_provider.dart';
import 'package:soiltrack_mobile/features/crops_registration/provider/crops_provider.dart';
import 'package:soiltrack_mobile/features/home/provider/hardware_provider/soil_sensors_provider.dart';
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
      await fetchRelatedData(true);
    } else {
      state = state.copyWith(isAuthenticated: false);
    }
  }

  Future<void> fetchUserRecord(String userId) async {
    try {
      final userRecord = await supabase.from('users').select('''
      user_fname,
      user_lname,
      user_email,
      user_municipality,
      user_province,
      user_barangay
    ''').eq('user_id', userId).single();

      final userIotDevice = await supabase
          .from('iot_device')
          .select(
            'mac_address',
          )
          .eq('user_id', userId);

      final macAddress =
          userIotDevice.isNotEmpty ? userIotDevice.first['mac_address'] : '';

      state = state.copyWith(
          userId: userId,
          userName: userRecord['user_fname'],
          userLastName: userRecord['user_lname'],
          userEmail: userRecord['user_email'],
          userCity: userRecord['user_province'],
          userProvince: userRecord['user_municipality'],
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
        NotifierHelper.showLoadingToast(context, 'Fetching your data');
        await initializeAuth();

        if (state.macAddress == null && state.macAddress!.isEmpty) {
          NotifierHelper.showErrorToast(
              context, 'No device found. Please register a device.');
          state = state.copyWith(isAuthenticated: false);
          return;
        }

        NotifierHelper.closeToast(context);
        state = state.copyWith(
          user: response.user,
          isAuthenticated: true,
          failedAttempts: 0,
          lockoutTime: null,
        );
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

  Future<void> signUp(
    BuildContext context,
    String email,
    String password,
    String firstName,
    String lastName,
    String municipality,
    String city,
    String barangay,
  ) async {
    state = state.copyWith(isRegistering: true);
    NotifierHelper.showLoadingToast(context, 'Signing up...');
    try {
      final existingUser = await supabase
          .from('users')
          .select()
          .eq('user_email', email)
          .maybeSingle();

      if (existingUser != null) {
        state = state.copyWith(userEmail: email, userPassword: password);
        return;
      }

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo:
            'https://soiltrack-server.onrender.com/auth/verify-email',
      );

      if (response.user != null) {
        await supabase.from('users').insert({
          'user_id': response.user!.id,
          'user_email': email,
          'user_fname': firstName,
          'user_lname': lastName,
          'user_municipality': municipality,
          'user_province': city,
          'user_barangay': barangay,
        });
      }

      state = state.copyWith(userEmail: email, userPassword: password);
    } catch (e) {
      String errorMessage = e.toString();
      if (e is AuthException) {
        errorMessage = e.message;
      }
      NotifierHelper.closeToast(context);
      throw (errorMessage);
    } finally {
      state = state.copyWith(isRegistering: false);
      NotifierHelper.closeToast(context);
    }
  }

  Future<void> requestResetPassword(BuildContext context,
      [String? email]) async {
    final emailToUse = email ?? state.userEmail;

    if (emailToUse == null || emailToUse.isEmpty) {
      NotifierHelper.showErrorToast(context, 'Email is required.');
      return;
    }

    try {
      state = state.copyWith(isRequestingChange: true);

      NotifierHelper.showLoadingToast(context, 'Requesting reset link');
      await supabase.auth.resetPasswordForEmail(emailToUse,
          redirectTo: 'soiltrack://reset-password');

      NotifierHelper.showSuccessToast(
          context, 'Password reset link sent to your email.');
    } catch (e) {
      NotifierHelper.showErrorToast(context, 'Error: ${e.toString()}');
    } finally {
      state = state.copyWith(isRequestingChange: false);
    }
  }

  Future<void> changePassword(
    BuildContext context,
    String newPassword,
    String email, [
    String? token,
  ]) async {
    try {
      NotifierHelper.showLoadingToast(context, 'Changing password');

      if (state.isAuthenticated) {
        await supabase.auth.updateUser(UserAttributes(password: newPassword));
      } else {
        await supabase.auth
            .verifyOTP(email: email, type: OtpType.recovery, token: token);
        await supabase.auth.updateUser(UserAttributes(password: newPassword));
      }

      NotifierHelper.closeToast(context);
      context.go('/password-changed');
    } catch (e) {
      if (e is AuthException && e.message.contains('expired')) {
        NotifierHelper.showErrorToast(context, 'Your reset link has expired.');
      } else {
        NotifierHelper.showErrorToast(context, 'Error: ${e.toString()}');
      }
    }
  }

  Future<void> fetchRelatedData(bool isInitialLoad) async {
    final sensorNotifier = ref.read(sensorsProvider.notifier);
    final weatherNotifier = ref.read(weatherProvider.notifier);
    final cropsNotifier = ref.read(cropProvider.notifier);
    final chatbotNotifier = ref.read(chatbotProvider.notifier);

    await sensorNotifier.fetchSensors();
    await weatherNotifier.fetchWeather();
    await chatbotNotifier.fetchConversations();
    await cropsNotifier.fetchAllCrops();
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

  Future<void> tryToSignIn(
      BuildContext context, String email, String password) async {
    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (state.isRegistering || !state.isSetupComplete) {
        context.go('/setup');
      } else {
        context.go('/home');
      }
    } catch (e) {
      if (e is AuthException) {
        if (e.message.contains('Email not confirmed')) {
          NotifierHelper.showErrorToast(
              context, 'Email not confirmed, check your inbox.');
        } else {
          NotifierHelper.showErrorToast(context, e.message);
        }
      } else {
        NotifierHelper.showErrorToast(context, 'An unexpected error occurred.');
        print('Error: $e');
      }
    }
  }

  Future<void> resendEmailVerification(
      BuildContext context, String email, String password) async {
    try {
      NotifierHelper.showLoadingToast(
          context, 'Resending verification email...');
      await supabase.auth.signUp(password: password, email: email);
      NotifierHelper.showSuccessToast(context, 'Verification email resent!');
    } catch (e) {
      NotifierHelper.logError(e);
    }
  }

  Future<void> saveDeviceToken(String token) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    await supabase.from("users").upsert({
      'user_id': userId,
      'device_token': token,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id');
  }

  void updateCurrentStep(int step) {
    state = state.copyWith(currentRegistrationStep: step);
  }
}

final authProvider =
    NotifierProvider<AuthNotifier, UserAuthState>(() => AuthNotifier());
