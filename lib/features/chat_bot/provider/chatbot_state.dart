import 'package:freezed_annotation/freezed_annotation.dart';

part 'chatbot_state.freezed.dart';

@freezed
class ChatBotState with _$ChatBotState {
  factory ChatBotState({
    @Default([]) List<Map<String, dynamic>> userConversations,
    @Default(false) bool isLoading,
    @Default(0) int currentConversationId,
  }) = _ChatBotState;
}
