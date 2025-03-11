import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/features/auth/controller/auth_controller.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/widgets/filled_button.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class EmailVerificationScreen extends ConsumerWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final registerController = AuthController(ref, context);

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
            top: 40, // Adjust as needed
            left: 5, // Adjust as needed
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                context.pop();
              },
            ),
          ),
          Positioned(
            bottom: 60,
            left: 25,
            right: 25,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo/DARK HORIZONTAL.png',
                  width: 150,
                ),
                const SizedBox(height: 20),
                const TextGradient(
                  text: 'Verify your Email Address to proceed.',
                  fontSize: 35,
                  textAlign: TextAlign.center,
                  letterSpacing: -2.5,
                ),
                const SizedBox(height: 5),
                const Text(
                  'Check your email for the verification link.',
                  style: TextStyle(
                    color: Color.fromARGB(255, 122, 122, 122),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 30),
                FilledCustomButton(
                  buttonText: 'Continue',
                  onPressed: () {
                    registerController.signIn(authState.userEmail as String,
                        authState.userPassword as String);
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Didn't receive the email? ",
                        style: Theme.of(context).textTheme.bodyMedium),
                    GestureDetector(
                      onTap: () {
                        context.push('/login');
                      },
                      child: Text(
                        "Resend",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
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
