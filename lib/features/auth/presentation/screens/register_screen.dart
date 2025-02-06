// ignore_for_file: library_private_types_in_public_api

import 'package:soiltrack_mobile/core/utils/validators.dart';
import 'package:soiltrack_mobile/features/auth/controller/auth_controller.dart';
import 'package:soiltrack_mobile/features/auth/presentation/widgets/text_field.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController userFname = TextEditingController();
  final TextEditingController userLname = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    userFname.dispose();
    userLname.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final registerController = AuthController(ref, context);

    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    double topPadding = 60;
    double bottomPadding = 320;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 0), // No animation
            top: keyboardHeight > 0 ? topPadding : 60.0,
            bottom: keyboardHeight > 0 ? bottomPadding : 40.0,
            left: 0,
            right: 0,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  if (keyboardHeight == 0)
                    Positioned(
                      child: Image.asset(
                        'assets/logo/DARK HORIZONTAL.png',
                        width: 150,
                      ),
                    ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24.0),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color.fromARGB(255, 9, 73, 14),
                              Color.fromARGB(255, 54, 201, 24)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              'Create an\nAccount',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                      fontSize: 52,
                                      letterSpacing: -3.5,
                                      height: 1,
                                      color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25.0),
                        TextFieldWidget(
                          label: 'Name',
                          controller: userFname,
                          validator: Validators.validateUsername,
                          prefixIcon: Icons.person,
                        ),
                        TextFieldWidget(
                          label: 'Last Name',
                          controller: userLname,
                          validator: Validators.validateUsername,
                          prefixIcon: Icons.person,
                        ),
                        TextFieldWidget(
                          label: 'Username or Email',
                          controller: emailController,
                          validator: Validators.validateEmail,
                          prefixIcon: Icons.email,
                        ),
                        TextFieldWidget(
                          label: 'Password',
                          controller: passwordController,
                          isPasswordField: true,
                          validator: Validators.validatePassword,
                          prefixIcon: Icons.lock,
                        ),
                        TextFieldWidget(
                          label: 'Confirm Password',
                          controller: confirmPasswordController,
                          isPasswordField: true,
                          validator: Validators.validatePassword,
                          prefixIcon: Icons.lock,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 13.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                backgroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                              ),
                              onPressed: authState.isRegistering
                                  ? null
                                  : () {
                                      registerController.signUp(
                                        userFname.text,
                                        userLname.text,
                                        emailController.text,
                                        passwordController.text,
                                        confirmPasswordController.text,
                                      );
                                    },
                              child: authState.isRegistering
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                        strokeWidth: 2.0,
                                      ),
                                    )
                                  : Text(
                                      'Sign up',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          if (keyboardHeight == 0)
            Positioned(
              bottom: 30.0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium),
                  GestureDetector(
                    onTap: () {
                      context.go('/login');
                    },
                    child: Text(
                      "Go back to login",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
