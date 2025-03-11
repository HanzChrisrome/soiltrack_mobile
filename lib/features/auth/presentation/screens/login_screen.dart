// ignore_for_file: library_private_types_in_public_api

import 'package:soiltrack_mobile/features/auth/controller/auth_controller.dart';
import 'package:soiltrack_mobile/widgets/text_field.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final loginController = AuthController(ref, context);

    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    double topPadding = keyboardHeight > 0 ? 120.0 : 100.0;
    double bottomPadding = keyboardHeight > 0 ? 330.0 : 40.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 0), // No animation
            top: keyboardHeight > 0 ? topPadding : 70.0,
            bottom: keyboardHeight > 0 ? bottomPadding : 40.0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (keyboardHeight == 0)
                  Image.asset(
                    'assets/logo/DARK HORIZONTAL.png',
                    width: 150,
                  ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                            'Sign in to\nyour Account',
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
                      const SizedBox(height: 35.0),
                      TextFieldWidget(
                        label: 'Username or Email',
                        controller: emailController,
                        prefixIcon: Icons.person,
                      ),
                      TextFieldWidget(
                        label: 'Password',
                        controller: passwordController,
                        isPasswordField: true,
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
                              backgroundColor: authState.lockoutTime != null &&
                                      DateTime.now()
                                          .isBefore(authState.lockoutTime!)
                                  ? Colors.grey // Gray color when locked out
                                  : Theme.of(context).colorScheme.onPrimary,
                            ),
                            onPressed: authState.isLoggingIn ||
                                    (authState.lockoutTime != null &&
                                        DateTime.now()
                                            .isBefore(authState.lockoutTime!))
                                ? null
                                : () {
                                    loginController.signIn(emailController.text,
                                        passwordController.text);
                                  },
                            child: authState.isLoggingIn
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                      strokeWidth: 2.0,
                                    ),
                                  )
                                : Text(
                                    (authState.lockoutTime != null &&
                                            DateTime.now().isBefore(
                                                authState.lockoutTime!))
                                        ? "Locked (Try later)"
                                        : "Sign in",
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
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot Password?',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
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
          if (keyboardHeight == 0)
            Positioned(
              bottom: 50.0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium),
                  GestureDetector(
                    onTap: () {
                      context.pushNamed('get-started');
                    },
                    child: Text(
                      "Get Started",
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
