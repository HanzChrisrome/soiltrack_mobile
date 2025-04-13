import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/widgets/filled_button.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class ChatBotScreen extends ConsumerWidget {
  const ChatBotScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userFirstName = ref.watch(authProvider).userName;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background/ai_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: SafeArea(
              child: GestureDetector(
                onTap: () {
                  context.pop(); // go_router back
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
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
                TextGradient(
                  text: 'Hello $userFirstName, \nI am ready to help you!',
                  fontSize: 35,
                  textAlign: TextAlign.center,
                  letterSpacing: -2.5,
                  heightSpacing: 1.1,
                ),
                const SizedBox(height: 5),
                const Text(
                  'Meet our SoilTrack AI.',
                  style: TextStyle(
                    color: Color.fromARGB(255, 122, 122, 122),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 20),
                FilledCustomButton(
                  buttonText: 'Get Started',
                  onPressed: () {
                    context.push('/chat-screen');
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
