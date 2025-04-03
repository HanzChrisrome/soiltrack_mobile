import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/core/utils/validators.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/widgets/bottom_dialog.dart';
import 'package:soiltrack_mobile/widgets/filled_button.dart';
import 'package:soiltrack_mobile/widgets/text_field.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen(
      {super.key, required this.token, required this.email});

  final String token;
  final String email;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextGradient(
                text: 'Create new Password',
                fontSize: 42,
                heightSpacing: 1,
                textAlign: TextAlign.left,
                letterSpacing: -1.7,
              ),
              SizedBox(height: 10),
              Text('Enter a new password to reset your account',
                  style: Theme.of(context).textTheme.bodyLarge),
              SizedBox(height: 10),
              TextFieldWidget(
                label: 'Enter new password',
                controller: passwordController,
                isPasswordField: true,
                prefixIcon: Icons.lock,
              ),
              TextFieldWidget(
                label: 'Enter your password again',
                controller: confirmPasswordController,
                isPasswordField: true,
                prefixIcon: Icons.lock,
              ),
              SizedBox(height: 10),
              FilledCustomButton(
                buttonText: 'Reset Password',
                onPressed: () {
                  if (passwordController.text !=
                      confirmPasswordController.text) {
                    NotifierHelper.showErrorToast(
                        context, 'Passwords do not match');
                    return;
                  }

                  final validationResult =
                      Validators.validatePassword(passwordController.text);
                  if (validationResult != null && validationResult.isNotEmpty) {
                    NotifierHelper.showErrorToast(context, validationResult);
                    return;
                  }

                  if (authState.isAuthenticated) {
                    showCustomBottomSheet(
                      context: context,
                      title: 'Change Password',
                      description:
                          'Are you sure you want to change your password? By clicking proceed you will be changing your password.',
                      icon: Icons.arrow_forward_ios_outlined,
                      buttonText: 'Proceed',
                      onPressed: authState.isRegistering
                          ? null
                          : () {
                              authNotifier.changePassword(context,
                                  passwordController.text, widget.email);
                              Navigator.of(context).pop();
                            },
                    );
                  } else {
                    authNotifier.changePassword(context,
                        passwordController.text, widget.email, widget.token);
                  }
                },
              ),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () {
                    if (authState.isAuthenticated) {
                      context.go('/home');
                    } else {
                      context.go('/login');
                    }
                  },
                  child: Text(
                    'Change your mind? Go back to home',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
