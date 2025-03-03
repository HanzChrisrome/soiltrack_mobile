import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/settings/settings_card.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/settings/settings_item.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/widgets/bottom_dialog.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/outline_button.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.watch(authProvider.notifier);
    final deviceNotifier = ref.watch(deviceProvider.notifier);
    final soilDashboardNotifier = ref.read(soilDashboardProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TextGradient(text: 'Settings', fontSize: 33),
                const SizedBox(height: 20),
                SettingsCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey[400],
                        child: const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextGradient(
                              text:
                                  '${authState.userName} ${authState.userLastName}',
                              fontSize: 20),
                          const SizedBox(height: 1),
                          Text(
                            authState.userEmail!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                    color: Colors.grey[700],
                                    fontSize: 12,
                                    height: 1.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Account',
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Colors.grey[700],
                        fontSize: 16,
                        letterSpacing: -0.8,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 10),
                const SettingsCard(
                  child: Column(
                    children: [
                      SettingsItem(
                          settingsText: 'My Information',
                          settingsIcon: Icons.person_2_outlined),
                      DividerWidget(verticalHeight: 0),
                      SettingsItem(
                          settingsText: 'Change Password',
                          settingsIcon: Icons.lock_outline),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Help and Support',
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Colors.grey[700],
                        fontSize: 16,
                        letterSpacing: -0.8,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 10),
                const SettingsCard(
                  child: Column(
                    children: [
                      SettingsItem(
                          settingsText: 'Help Topics',
                          settingsIcon: Icons.help_center_outlined),
                      DividerWidget(verticalHeight: 0),
                      SettingsItem(
                          settingsText: 'Ask a Question',
                          settingsIcon: Icons.question_answer_outlined),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Device',
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: Colors.grey[700],
                        fontSize: 16,
                        letterSpacing: -0.8,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 5),
                SettingsCard(
                  child: Column(
                    children: [
                      SettingsItem(
                        settingsText: 'Device Information',
                        settingsIcon: Icons.device_unknown_outlined,
                        onTap: () {
                          soilDashboardNotifier.fetchUserPlots();
                        },
                      ),
                      const DividerWidget(verticalHeight: 0),
                      SettingsItem(
                        settingsText: 'Reset Device',
                        settingsIcon: Icons.reset_tv_rounded,
                        onTap: () {
                          showCustomBottomSheet(
                            context: context,
                            title: 'Reset Device?',
                            description:
                                "Resetting your device will disconnect it from the internet and remove all settings.",
                            icon: Icons.reset_tv_outlined,
                            buttonText: 'Reset',
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.pushNamed('wifi-scan');
                            },
                          );
                        },
                      ),
                      const DividerWidget(verticalHeight: 0),
                      SettingsItem(
                        settingsText: 'Check Sensors',
                        settingsIcon: Icons.wifi_outlined,
                        onTap: () {
                          showCustomBottomSheet(
                            context: context,
                            title: 'Check Sensors',
                            description:
                                'Are you sure you want to check the sensors?',
                            icon: Icons.reset_tv_outlined,
                            buttonText: 'Confirm',
                            onPressed: () {
                              Navigator.of(context).pop();
                              deviceNotifier.getSensorCount();
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                OutlineCustomButton(
                  iconData: Icons.logout,
                  buttonText: 'Sign out',
                  onPressed: () {
                    showCustomBottomSheet(
                      context: context,
                      title: 'Sign out?',
                      description: "Are you sure you want to sign out?",
                      icon: Icons.logout,
                      buttonText: 'Sign out',
                      onPressed: () {
                        authNotifier.signOut();
                      },
                    );
                  },
                ),
                const SizedBox(height: 90),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
