import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/widgets/filled_button.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background/get_started.png'),
                fit: BoxFit.cover,
              ),
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
                  text: 'Optimize your irrigation with real-time soil data.',
                  fontSize: 35,
                  textAlign: TextAlign.center,
                  letterSpacing: -2.5,
                ),
                const SizedBox(height: 5),
                const Text(
                  'Smart farming starts here.',
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
                  buttonText: 'Get Started',
                  onPressed: () {
                    context.push('/register');
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account? ",
                        style: Theme.of(context).textTheme.bodyMedium),
                    GestureDetector(
                      onTap: () {
                        context.push('/login');
                      },
                      child: Text(
                        "Login",
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
