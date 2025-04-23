import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/widgets/filled_button.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Check if small screen
    final bool isSmallDevice = screenHeight < 700 || screenWidth < 360;

    // Set values based on device size
    final double logoWidth = isSmallDevice ? 120 : 150;
    final double titleFontSize = isSmallDevice ? 26 : 35;
    final double subtitleFontSize = isSmallDevice ? 13 : 15;
    final double bottomPadding = isSmallDevice ? 30 : 60;
    final double mainSpacing = isSmallDevice ? 15 : 20;
    final double buttonSpacing = isSmallDevice ? 20 : 30;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background/get_started.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Foreground Content
          Positioned(
            bottom: bottomPadding,
            left: 25,
            right: 25,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/logo/DARK HORIZONTAL.png',
                    width: logoWidth,
                  ),
                  SizedBox(height: mainSpacing),
                  // Main Text
                  TextGradient(
                    text: 'Optimize your irrigation with real-time soil data.',
                    fontSize: titleFontSize,
                    textAlign: TextAlign.center,
                    letterSpacing: -2.5,
                  ),
                  const SizedBox(height: 5),
                  // Subtitle
                  Text(
                    'Smart farming starts here.',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 122, 122, 122),
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: buttonSpacing),
                  // Get Started Button
                  FilledCustomButton(
                    buttonText: 'Get Started',
                    onPressed: () {
                      context.push('/register');
                    },
                    height: isSmallDevice ? 45 : null,
                    fontSize: isSmallDevice ? 14 : null,
                  ),
                  SizedBox(height: 10),
                  // Already have account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () {
                          context.push('/login');
                        },
                        child: Text(
                          "Login",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
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
          ),
        ],
      ),
    );
  }
}
