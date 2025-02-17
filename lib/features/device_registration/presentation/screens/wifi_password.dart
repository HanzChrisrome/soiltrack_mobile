import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/widgets/text_field.dart';
import 'package:soiltrack_mobile/features/device_registration/controller/device_controller.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider.dart';
import 'package:soiltrack_mobile/widgets/filled_button.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class WiFiPasswordScreen extends ConsumerStatefulWidget {
  const WiFiPasswordScreen({super.key});

  @override
  _WiFiPasswordScreenState createState() => _WiFiPasswordScreenState();
}

class _WiFiPasswordScreenState extends ConsumerState<WiFiPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final deviceState = ref.watch(deviceProvider);
    final deviceController = DeviceController(context, ref);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () {
            GoRouter.of(context).pop();
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
              TextGradient(
                  text:
                      'Enter the password for the internet Connection ${deviceState.selectedDeviceSSID}',
                  fontSize: 30),
              const SizedBox(height: 10),
              TextFieldWidget(
                  label: 'Enter WiFi Password',
                  controller: _passwordController,
                  isPasswordField: true),
              FilledCustomButton(
                buttonText: 'Continue',
                isLoading: deviceState.isConnecting,
                onPressed: () {
                  deviceController
                      .connectDeviceToWifi(_passwordController.text);
                },
                loadingText: 'Connecting...',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
