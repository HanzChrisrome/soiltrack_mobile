import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';
import 'package:soiltrack_mobile/features/chat_bot/provider/chatbot_state.dart';
import 'package:soiltrack_mobile/features/chat_bot/service/chatbot_service.dart';
import 'package:soiltrack_mobile/features/home/service/ai_service.dart';

class ChatBotNotifier extends Notifier<ChatBotState> {
  final ChatbotService chatbotService = ChatbotService();
  final AiService aiService = AiService();

  @override
  ChatBotState build() {
    return ChatBotState();
  }

  Future<void> fetchConversations() async {
    final userId = ref.watch(authProvider).userId;
    try {
      final conversations = await chatbotService.getConverstaions(userId!);
      state = state.copyWith(userConversations: conversations);
    } catch (e) {
      NotifierHelper.logError(e.toString());
    }
  }

  Future<void> sendMessage(String message) async {
    final userId = ref.watch(authProvider).userId;
    int conversationId = state.currentConversationId;
    NotifierHelper.logMessage('Saving message: $message');

    try {
      if (state.currentConversationId == 0) {
        conversationId = await chatbotService.createConversationGroup(
            'Sample Name', userId!);
        state = state.copyWith(currentConversationId: conversationId);
      }

      final aiResponseRaw = await aiService.getChatbotResponse(
        message,
        temperature: 0.8,
        maxTokens: 500,
      );

      final aiContent = aiResponseRaw['choices'][0]['message']['content'];
      NotifierHelper.logMessage('AI Response: $aiContent');

      await chatbotService.saveMessage(message, aiContent, conversationId);
    } catch (e) {
      NotifierHelper.logError(e.toString());
    }
  }
}

final chatbotProvider =
    NotifierProvider<ChatBotNotifier, ChatBotState>(() => ChatBotNotifier());
