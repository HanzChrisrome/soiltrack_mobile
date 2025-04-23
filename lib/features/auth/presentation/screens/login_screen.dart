import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/features/auth/controller/auth_controller.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/widgets/text_field.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  int _calculateRemainingSeconds(DateTime? lockoutTime) {
    if (lockoutTime == null) return 0;
    final secondsLeft = lockoutTime.difference(DateTime.now()).inSeconds;
    return secondsLeft > 0 ? secondsLeft : 0;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final loginController = AuthController(ref, context);

    final lockoutTime = authState.lockoutTime;
    final remainingSeconds = _calculateRemainingSeconds(lockoutTime);
    final bool isLockedOut = remainingSeconds > 0;

    double lockoutProgress = 0;
    if (isLockedOut) {
      const totalLockoutDuration = 60;
      lockoutProgress =
          (totalLockoutDuration - remainingSeconds) / totalLockoutDuration;
      if (lockoutProgress < 0) lockoutProgress = 0;
      if (lockoutProgress > 1) lockoutProgress = 1;
    }

    // Get screen size
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    double topPadding =
        keyboardHeight > 0 ? screenHeight * 0.06 : screenHeight * 0.15;

    double bottomPadding = keyboardHeight > 0 ? 300.0 : screenHeight * 0.1;

    // Dynamic font sizes based on screen width
    double textFieldFontSize = screenWidth * 0.04;
    double buttonFontSize = screenWidth * 0.04;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 0),
            top: keyboardHeight > 0 ? topPadding : screenHeight * 0.1,
            bottom: keyboardHeight > 0 ? bottomPadding : screenHeight * 0.1,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (keyboardHeight == 0)
                  Image.asset(
                    'assets/logo/DARK HORIZONTAL.png',
                    width: screenWidth * 0.5, // Dynamic width
                  ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06), // Dynamic padding
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextGradient(
                        text: 'Sign in to \nyour Account',
                        fontSize: keyboardHeight > 0 ? 40 : 45,
                        textAlign: TextAlign.center,
                        heightSpacing: 1,
                        letterSpacing: -2.5,
                      ),
                      const SizedBox(height: 10),
                      TextFieldWidget(
                        label: 'Username or Email',
                        controller: emailController,
                        prefixIcon: Icons.person,
                        fontSize: textFieldFontSize,
                      ),
                      TextFieldWidget(
                        label: 'Password',
                        controller: passwordController,
                        isPasswordField: true,
                        prefixIcon: Icons.lock,
                        fontSize: textFieldFontSize,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical:
                                    screenHeight * 0.01), // Dynamic padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            backgroundColor: isLockedOut
                                ? Colors.grey
                                : Theme.of(context).colorScheme.onPrimary,
                          ),
                          onPressed: authState.isLoggingIn || isLockedOut
                              ? null
                              : () {
                                  loginController.signIn(
                                    emailController.text,
                                    passwordController.text,
                                  );
                                },
                          child: authState.isLoggingIn
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                  ),
                                )
                              : Text(
                                  isLockedOut
                                      ? "Locked (${remainingSeconds}s)"
                                      : "Sign in",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontSize: buttonFontSize,
                                      ),
                                ),
                        ),
                      ),
                      if (MediaQuery.of(context).viewInsets.bottom == 0)
                        TextButton(
                          onPressed: () {
                            context.pushNamed('forgot-password');
                          },
                          child: Text(
                            'Forgot Password?',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontSize:
                                      screenWidth * 0.04, // Dynamic font size
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
              bottom: screenHeight * 0.05, // Dynamic bottom padding
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: screenWidth * 0.04, // Dynamic font size
                        ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.pushNamed('get-started');
                    },
                    child: Text(
                      "Get Started",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: screenWidth * 0.04, // Dynamic font size
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
