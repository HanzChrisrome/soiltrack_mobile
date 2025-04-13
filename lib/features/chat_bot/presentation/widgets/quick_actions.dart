import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/chat_bot/provider/chatbot_provider.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';

class QuickActions extends ConsumerWidget {
  final String quickPrompt;
  const QuickActions({super.key, required this.quickPrompt});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatbotNotifier = ref.read(chatbotProvider.notifier);

    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        chatbotNotifier.sendMessage(quickPrompt);
      },
      child: DynamicContainer(
        backgroundColor: theme.colorScheme.primary,
        borderColor: theme.colorScheme.onSurface.withOpacity(0.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              quickPrompt,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 18,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.3,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
