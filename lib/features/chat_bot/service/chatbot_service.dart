import 'package:soiltrack_mobile/core/config/supabase_config.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';

class ChatbotService {
  Future<List<Map<String, dynamic>>> getConverstaions(String userId) async {
    try {
      final response = await supabase
          .from('grouped_conversations')
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

      return response;
    } catch (e) {
      NotifierHelper.logError('Error fetching conversations: $e');
      throw Exception('Failed to fetch conversations: $e');
    }
  }

  Future<int> createConversationGroup(String groupName, String userId) async {
    try {
      final response = await supabase
          .from('grouped_conversations')
          .insert({
            'conversation_name': groupName,
            'user_id': userId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return response['conversation_id'] as int;
    } catch (e) {
      NotifierHelper.logError('Error creating conversation group: $e');
      throw Exception('Failed to create conversation group: $e');
    }
  }

  Future<void> saveMessage(
      String message, String aiResponse, int conversationId) async {
    try {
      await supabase.from('ai_conversations').insert({
        'user_message': message,
        'ai_response': aiResponse,
        'conversation_id': conversationId,
      });
    } catch (e) {
      NotifierHelper.logError(e.toString());
      throw Exception('Failed to save message: $e');
    }
  }
}
