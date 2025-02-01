// ignore_for_file: use_build_context_synchronously, unrelated_type_equality_checks

import 'package:soiltrack_mobile/core/utils/toast_service.dart';
import 'package:soiltrack_mobile/core/utils/validators.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

class AuthController {
  final WidgetRef ref;
  final BuildContext context;

  AuthController(this.ref, this.context);

  Future<void> signIn(String email, String password) async {
    final authNotifier = ref.read(authProvider.notifier);

    if (email.isEmpty || password.isEmpty) {
      ToastService.showToast(
          context: context,
          message: 'Email and password are required',
          type: ToastificationType.error);
      return;
    }

    try {
      await authNotifier.signIn(email, password);
    } catch (e) {
      ToastService.showToast(
          context: context,
          message: e.toString(),
          type: ToastificationType.error);
    }
  }

  Future<void> signUp(
    String userName,
    String email,
    String password,
    String confirmPassword,
  ) async {
    final authNotifier = ref.read(authProvider.notifier);

    if (email.isEmpty || password.isEmpty || userName.isEmpty) {
      ToastService.showToast(
          context: context,
          message: 'Incomplete input fields!',
          type: ToastificationType.error);
      return;
    }

    if (Validators.validateEmail(email) != null) {
      ToastService.showToast(
        context: context,
        message: Validators.validateEmail(email)!,
        type: ToastificationType.error,
      );
      return; // Exit the method
    }

    if (password != confirmPassword) {
      ToastService.showToast(
          context: context,
          message: 'Passwords do not match!',
          type: ToastificationType.error);
      return;
    }

    if (Validators.validatePassword(password) != null) {
      ToastService.showToast(
          context: context,
          message: Validators.validatePassword(password).toString(),
          type: ToastificationType.error);
      return;
    }

    try {
      await authNotifier.signUp(email, password, userName);
      ToastService.showToast(
          context: context,
          message: 'Account created successfully!',
          description: 'Please check your email to verify your account.',
          type: ToastificationType.success);
    } catch (e) {
      ToastService.showToast(
          context: context,
          message: e.toString(),
          type: ToastificationType.error);
    }
  }
}
