// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/core/utils/toast_service.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/features/device_registration/controller/device_controller.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider.dart';
import 'package:soiltrack_mobile/widgets/filled_button.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class ConfigurationScreen extends ConsumerStatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  ConsumerState<ConfigurationScreen> createState() =>
      _ConfigurationScreenState();
}

class _ConfigurationScreenState extends ConsumerState<ConfigurationScreen> {
  late DeviceController deviceController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      deviceController = DeviceController(context, ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceState = ref.watch(deviceProvider);
    final authState = ref.watch(authProvider);
    final isEsp32Connecting = deviceState.isConnecting;
    final isSaving = deviceState.isSaving;
    final macAddress = deviceState.macAddress;
    final isSetupComplete = authState.isSetupComplete;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isEsp32Connecting)
                Column(
                  children: [
                    LoadingAnimationWidget.progressiveDots(
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 100,
                    ),
                    const TextGradient(
                      text: 'Please wait while we are connecting your device.',
                      fontSize: 32,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              if (!isEsp32Connecting && isSaving)
                Column(
                  children: [
                    LoadingAnimationWidget.progressiveDots(
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 100,
                    ),
                    const TextGradient(
                      text: 'Setting up your application and account.',
                      fontSize: 28,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              if (!isEsp32Connecting && !isSaving) ...[
                if (isSetupComplete)
                  const TextGradient(
                    text: 'Sync your account with your device',
                    fontSize: 30,
                    textAlign: TextAlign.center,
                  ),
                if (!isSetupComplete)
                  const TextGradient(
                    text: 'Ready to setup your application and account?',
                    fontSize: 30,
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 10.0),
                Text(
                  'This may take a few minutes. Ensure your device is connected to an stable internet connection.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontSize: 12, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20.0),
                FilledCustomButton(
                  buttonText: 'Continue',
                  onPressed: () async {
                    final isOnline =
                        await deviceController.hasInternetConnection();
                    if (!isOnline) {
                      NotifierHelper.showErrorToast(
                          context, 'No internet connection');
                      return;
                    }

                    ref.read(deviceProvider.notifier).saveToDatabase(context);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
