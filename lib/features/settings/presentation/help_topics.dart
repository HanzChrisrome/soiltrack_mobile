import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/features/settings/presentation/widgets/accordion_widget.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/custom_accordion.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class HelpTopics extends ConsumerWidget {
  const HelpTopics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                leading: IconButton(
                  icon: Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Icon(Icons.arrow_back_ios_new_outlined,
                        color: Colors.green),
                  ),
                  onPressed: () {
                    context.go('/home?index=1');
                  },
                ),
                pinned: true,
              ),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    TextGradient(
                      text: 'How can\nwe help you?',
                      fontSize: 45,
                      heightSpacing: 1,
                      letterSpacing: -1.8,
                    ),
                    DividerWidget(verticalHeight: 5),
                    CustomAccordion(
                      titleText: 'How to use SoilTrack?',
                      content: const Text(
                        'SoilTrack is a mobile application that allows you to track and manage your soil data.',
                        style: TextStyle(fontSize: 16),
                      ),
                      icon: Icons.question_answer,
                      initiallyExpanded: true,
                    ),
                    CustomAccordion(
                      titleText: 'Soil data not updating?',
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'If your soil data is not updating, please check the following:',
                            style: TextStyle(fontSize: 16),
                          ),
                          DividerWidget(verticalHeight: 1),
                          const Text(
                            '• Ensure your internet connection is stable.',
                            style: TextStyle(fontSize: 16),
                          ),
                          const Text(
                            '• Verify that the sensor is properly connected.',
                            style: TextStyle(fontSize: 16),
                          ),
                          const Text(
                            '• Check for any power issues with the device.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      icon: Icons.question_answer,
                      initiallyExpanded: true,
                    ),
                    CustomAccordion(
                      titleText: 'The water pump is not turning on.',
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Possible causes might be moisture level threshold not set properly, faulty wiring, or power supply interruption.',
                            style: TextStyle(fontSize: 16),
                          ),
                          DividerWidget(verticalHeight: 1),
                          const Text(
                            '• Check if the minimum moisture threshold in the app is configured correctly.',
                            style: TextStyle(fontSize: 16),
                          ),
                          const Text(
                            '• Ensure all wires and valves are securely connected.',
                            style: TextStyle(fontSize: 16),
                          ),
                          const Text(
                            '• Confirm that the pump has power and is functioning independently. ',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      icon: Icons.question_answer,
                      initiallyExpanded: true,
                    ),
                    CustomAccordion(
                      titleText: 'It says it can not generate analysis.',
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'If it can not generate analysis, it means that the data is not sufficient.',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      icon: Icons.question_answer,
                      initiallyExpanded: false,
                    ),
                  ]),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
