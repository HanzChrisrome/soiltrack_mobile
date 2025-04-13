import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/core/router/app_router.dart';
import 'package:soiltrack_mobile/features/chat_bot/presentation/widgets/quick_actions.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';
import 'package:soiltrack_mobile/widgets/text_field.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Container(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: theme.colorScheme.primary,
                  surfaceTintColor: Colors.transparent,
                  pinned: true,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_outlined,
                        color: Colors.green),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.history, color: Colors.green),
                      onPressed: () {
                        context.pushNamed('chat-history');
                      },
                    ),
                  ],
                ),
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        _noChatsYet(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Chat Input Field
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  color: theme.colorScheme.primary,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFieldWidget(
                          label: 'Enter your text here',
                          controller: controller,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: () {
                            // Send action here
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noChatsYet(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hey, Hanz \nHow can I help you?',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 30,
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.w500,
            letterSpacing: -1.2,
            height: 1.1,
          ),
        ),
        DividerWidget(verticalHeight: 5),
        Text(
          '[ QUICK ACTIONS ]',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 12,
            color: theme.colorScheme.onSurface,
            letterSpacing: 0.2,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 20),
        QuickActions(
          quickPrompt: 'How do I improve soil fertility naturally?',
        ),
        QuickActions(
            quickPrompt: 'What are the best practices for soil conservation?'),
      ],
    );
  }
}
