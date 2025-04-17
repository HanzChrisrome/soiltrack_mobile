import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/settings/settings_card.dart';
import 'package:soiltrack_mobile/features/home/presentation/widgets/settings/settings_item.dart';
import 'package:soiltrack_mobile/widgets/bottom_dialog.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';
import 'package:soiltrack_mobile/widgets/outline_button.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.watch(authProvider.notifier);

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
                DynamicContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextGradient(
                          text:
                              '${authState.userName} ${authState.userLastName}',
                          fontSize: 25),
                      const SizedBox(height: 1),
                      Text(
                        authState.userEmail?.toLowerCase() ?? '',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Colors.grey[700], fontSize: 15, height: 1.5),
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
                SettingsCard(
                  child: Column(
                    children: [
                      SettingsItem(
                        settingsText: 'Change Password',
                        settingsIcon: Icons.lock_outline,
                        onTap: () {
                          context.pushNamed('reset-password',
                              extra: authState.userEmail);
                        },
                      ),
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
                SettingsCard(
                  child: Column(
                    children: [
                      SettingsItem(
                        settingsText: 'Help Topics',
                        settingsIcon: Icons.help_center_outlined,
                        onTap: () {
                          context.pushNamed('help-topics');
                        },
                      ),
                      // DividerWidget(verticalHeight: 0),
                      // SettingsItem(
                      //     settingsText: 'Ask a Question',
                      //     settingsIcon: Icons.question_answer_outlined),
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
                      icon: Icons.logout,
                      buttonText: 'Sign out',
                      onPressed: () {
                        authNotifier.signOut(context);
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
