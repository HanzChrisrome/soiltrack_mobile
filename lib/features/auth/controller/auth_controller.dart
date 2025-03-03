// ignore_for_file: use_build_context_synchronously, unrelated_type_equality_checks

import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
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
      NotifierHelper.showErrorToast(context, 'Incomplete input fields!');
      return;
    }

    try {
      await authNotifier.signIn(email, password);
    } catch (e) {
      NotifierHelper.logError(e, context, e.toString());
    }
  }

  Future<void> signUp(
    String userFname,
    String userLname,
    String email,
    String password,
    String confirmPassword,
  ) async {
    final authNotifier = ref.read(authProvider.notifier);

    if (email.isEmpty ||
        password.isEmpty ||
        userFname.isEmpty ||
        userLname.isEmpty) {
      NotifierHelper.showErrorToast(context, 'Incomplete input fields!');
      return;
    }

    if (Validators.validateEmail(email) != null) {
      NotifierHelper.showErrorToast(context, Validators.validateEmail(email)!);
      return;
    }

    if (password != confirmPassword) {
      NotifierHelper.showErrorToast(context, 'Passwords do not match!');
      return;
    }

    if (Validators.validatePassword(password) != null) {
      NotifierHelper.showErrorToast(
          context, Validators.validatePassword(password).toString());
      return;
    }

    try {
      await authNotifier.signUp(email, password, userFname, userLname);
      ToastService.showToast(
          context: context,
          message: 'Account created successfully!',
          description: 'Please check your email to verify your account.',
          type: ToastificationType.success);
    } catch (e) {
      NotifierHelper.logError(e, context, e.toString());
    }
  }
}
