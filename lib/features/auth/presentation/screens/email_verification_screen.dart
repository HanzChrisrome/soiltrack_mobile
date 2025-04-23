import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/features/auth/controller/auth_controller.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/widgets/filled_button.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  Timer? _timer;
  int _cooldownSeconds = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startCooldown() {
    setState(() {
      _cooldownSeconds = 30; // Cooldown of 30 seconds
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          _cooldownSeconds--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Check if small screen
    final bool isSmallDevice = screenHeight < 700 || screenWidth < 360;

    // Set values based on device size
    final double logoWidth = isSmallDevice ? 120 : 150;
    final double titleFontSize = isSmallDevice ? 32 : 35;
    final double subtitleFontSize = isSmallDevice ? 13 : 15;
    final double bottomPadding = isSmallDevice ? 20 : 40;
    final double mainSpacing = isSmallDevice ? 10 : 20;
    final double buttonSpacing = isSmallDevice ? 20 : 30;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background/email_verification.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 5,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                context.pop();
              },
            ),
          ),
          Positioned(
            bottom: bottomPadding,
            left: 25,
            right: 25,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo/DARK HORIZONTAL.png',
                  width: logoWidth,
                ),
                SizedBox(height: mainSpacing),
                TextGradient(
                  text: 'Verify your Email Address to proceed.',
                  fontSize: titleFontSize,
                  textAlign: TextAlign.center,
                  letterSpacing: -2.5,
                ),
                const SizedBox(height: 5),
                Text(
                  'Check your email for the verification link.',
                  style: TextStyle(
                    color: Color.fromARGB(255, 122, 122, 122),
                    fontSize: subtitleFontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: buttonSpacing),
                FilledCustomButton(
                  buttonText: 'Continue',
                  onPressed: () {
                    authNotifier.tryToSignIn(
                      context,
                      authState.userEmail as String,
                      authState.userPassword as String,
                    );
                  },
                  height: isSmallDevice ? 40 : null,
                  fontSize: isSmallDevice ? 14 : null,
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the email? ",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    _cooldownSeconds == 0
                        ? GestureDetector(
                            onTap: () {
                              authNotifier.resendEmailVerification(
                                context,
                                authState.userEmail as String,
                                authState.userPassword as String,
                              );
                              startCooldown();
                            },
                            child: Text(
                              "Resend",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          )
                        : Text(
                            "Resend in ${_cooldownSeconds}s",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
