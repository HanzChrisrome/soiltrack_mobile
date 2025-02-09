import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/features/device_registration/controller/device_controller.dart';
import 'package:soiltrack_mobile/features/device_registration/presentation/widgets/steps_widget.dart';

class SetupScreen extends ConsumerWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceController = DeviceController(context, ref);
    final authState = ref.watch(authProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.logout_outlined),
          onPressed: () {
            authState.signOut();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.satellite_outlined,
                size: 120.0,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(height: 20.0),
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
                    'Register your SoilTracker',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 25, letterSpacing: -1.3, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 5.0),
              Text(
                'Register your device to start monitoring real-time soil nutrient. By linking your sensor with our application, to gain valuable insights into soil health.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      letterSpacing: -0.4,
                    ),
              ),
              const SizedBox(height: 20.0),
              const Divider(
                color: Color.fromARGB(255, 201, 201, 201),
                thickness: 1.0,
              ),
              const SizedBox(height: 20.0),
              const StepsWidget(
                  step: '1',
                  title: 'Scan available SoilTracker Device.',
                  description:
                      'Make sure your internet connection is turned on to connect to the device.'),
              const SizedBox(height: 20.0),
              const StepsWidget(
                  step: '2',
                  title: 'Connect SoilTracker to your Wi-Fi.',
                  description:
                      'You must connect SoilTracker to your internet connection'),
              const SizedBox(height: 40.0),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    deviceController.requestPermissionAndNavigate();
                  },
                  icon: Icon(
                    Icons.play_arrow,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  label: Text(
                    'Begin Setup',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
