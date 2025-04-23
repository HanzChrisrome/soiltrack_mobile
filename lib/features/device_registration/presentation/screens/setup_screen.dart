import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/features/device_registration/controller/device_controller.dart';
import 'package:soiltrack_mobile/features/device_registration/presentation/widgets/steps_widget.dart';
import 'package:soiltrack_mobile/widgets/outline_button.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class SetupScreen extends ConsumerWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceController = DeviceController(context, ref);
    final authNotifier = ref.watch(authProvider.notifier);

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight <= 650 || screenWidth <= 360;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
        ),
        child: isSmallScreen
            ? Column(
                children: _buildContent(
                    context, deviceController, authNotifier, isSmallScreen),
              )
            : Column(
                children: _buildContent(
                    context, deviceController, authNotifier, isSmallScreen),
              ),
      ),
    );
  }

  List<Widget> _buildContent(BuildContext context,
      DeviceController deviceController, authNotifier, bool isSmallScreen) {
    return [
      SizedBox(height: isSmallScreen ? 40 : 80),

      // Logout button
      Center(
        child: GestureDetector(
          onTap: () {
            authNotifier.signOut(context);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20,
              ),
              const SizedBox(width: 5),
              Text(
                'Log Out',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
      const Spacer(),
      // Main title area
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: isSmallScreen ? 10 : null),
            Image.asset(
              'assets/logo/GREEN OUTLINE.png',
              height: isSmallScreen ? 60 : 100,
            ),
            SizedBox(height: isSmallScreen ? 10 : 30),
            TextGradient(
              text: 'Register your',
              fontSize:
                  isSmallScreen ? 36 : 45, // Slightly smaller for small screens
              letterSpacing: -2.5,
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextGradient(
                  text: 'Hardware',
                  fontSize: isSmallScreen ? 36 : 45,
                  letterSpacing: -2.5,
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Beta',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 350,
              child: Text(
                'Register your device to start monitoring real-time soil nutrient. By linking your sensor with our application, to gain valuable insights into soil health.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: isSmallScreen ? 13 : 15,
                      letterSpacing: -0.4,
                    ),
              ),
            ),
          ],
        ),
      ),

      const Spacer(),

      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StepsWidget(
              step: '1',
              title: 'Scan available SoilTracker Device.',
              description:
                  'Make sure your internet connection is turned on to connect to the device.',
            ),
            const SizedBox(height: 20),
            const StepsWidget(
              step: '2',
              title: 'Connect SoilTracker to your Wi-Fi.',
              description:
                  'You must connect SoilTracker to your internet connection',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlineCustomButton(
                buttonText: 'Begin Setup',
                iconData: Icons.play_arrow_outlined,
                onPressed: () {
                  deviceController.requestPermissionAndNavigate();
                },
              ),
            ),
          ],
        ),
      ),
    ];
  }
}
