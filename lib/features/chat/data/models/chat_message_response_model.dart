class ChatMessageResponseModel {
  final String id;
  final String sessionId;
  final String role;
  final String content;
  final String createdAt;

  const ChatMessageResponseModel({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory ChatMessageResponseModel.fromJson(Map<String, dynamic> json) {
    final rawRole =
        (json['role'] ??
                json['sender'] ??
                json['type'] ??
                json['author'] ??
                json['speaker'] ??
                json['role_type'] ??
                json['sender_type'] ??
                json['message_type'] ??
                '')
            .toString()
            .toLowerCase();

    final bool isUserExplicit =
        rawRole == 'user' ||
        rawRole == 'human' ||
        json['is_user'] == true ||
        json['is_human'] == true;

    final bool isAssistant =
        !isUserExplicit &&
        (rawRole.contains('assistant') ||
            rawRole.contains('bot') ||
            rawRole.contains('ai') ||
            rawRole.contains('system') ||
            rawRole.contains('model') ||
            rawRole.contains('agent') ||
            rawRole.contains('server') ||
            json['is_assistant'] == true ||
            json['is_bot'] == true ||
            json['is_ai'] == true);

    final normalizedRole = isAssistant ? 'assistant' : 'user';

    final contentVal =
        json['content'] ??
        json['text'] ??
        json['message'] ??
        json['response'] ??
        json['answer'] ??
        json['reply'] ??
        json['output'] ??
        json['output_text'] ??
        json['body'] ??
        '';

    return ChatMessageResponseModel(
      id:
          json['id']?.toString() ??
          json['_id']?.toString() ??
          'msg_${DateTime.now().millisecondsSinceEpoch}',
      sessionId:
          json['session_id']?.toString() ??
          json['sessionId']?.toString() ??
          json['conversation_id']?.toString() ??
          json['conversationId']?.toString() ??
          '',
      role: normalizedRole,
      content: contentVal.toString(),
      createdAt:
          json['created_at']?.toString() ??
          json['createdAt']?.toString() ??
          json['timestamp']?.toString() ??
          json['time']?.toString() ??
          '',
    );
  }

  static List<ChatMessageResponseModel> parseList(dynamic rawData) {
    if (rawData == null) return [];
    List<dynamic> rawList = [];

    if (rawData is List) {
      rawList = rawData;
    } else if (rawData is Map<String, dynamic>) {
      if (rawData['messages'] is List) {
        rawList = rawData['messages'] as List;
      } else if (rawData['data'] is List) {
        rawList = rawData['data'] as List;
      } else if (rawData['history'] is List) {
        rawList = rawData['history'] as List;
      } else if (rawData['conversation'] is List) {
        rawList = rawData['conversation'] as List;
      } else if (rawData['chat_messages'] is List) {
        rawList = rawData['chat_messages'] as List;
      } else if (rawData['items'] is List) {
        rawList = rawData['items'] as List;
      } else if (rawData['results'] is List) {
        rawList = rawData['results'] as List;
      } else if (rawData['session'] is Map &&
          rawData['session']['messages'] is List) {
        rawList = rawData['session']['messages'] as List;
      }
    }

    final List<ChatMessageResponseModel> results = [];

    for (final item in rawList) {
      if (item is! Map<String, dynamic>) continue;

      final sessionId =
          item['session_id']?.toString() ??
          item['sessionId']?.toString() ??
          item['conversation_id']?.toString() ??
          item['conversationId']?.toString() ??
          '';

      final createdAt =
          item['created_at']?.toString() ??
          item['createdAt']?.toString() ??
          item['timestamp']?.toString() ??
          item['time']?.toString() ??
          '';

      final id = item['id']?.toString() ?? item['_id']?.toString() ?? '';

      // Check for Q&A pair format in single JSON object (e.g. {prompt: "...", response: "..."})
      final userText =
          item['prompt'] ??
          item['user_message'] ??
          item['question'] ??
          item['user_input'];
      final aiText =
          item['response'] ??
          item['assistant_message'] ??
          item['ai_response'] ??
          item['answer'] ??
          item['bot_response'] ??
          item['output'];

      if (userText != null &&
          aiText != null &&
          item['content'] == null &&
          item['role'] == null) {
        results.add(
          ChatMessageResponseModel(
            id: id.isNotEmpty ? '${id}_user' : 'user_${results.length}',
            sessionId: sessionId,
            role: 'user',
            content: userText.toString(),
            createdAt: createdAt,
          ),
        );
        results.add(
          ChatMessageResponseModel(
            id: id.isNotEmpty ? '${id}_ai' : 'ai_${results.length}',
            sessionId: sessionId,
            role: 'assistant',
            content: aiText.toString(),
            createdAt: createdAt,
          ),
        );
      } else {
        results.add(ChatMessageResponseModel.fromJson(item));
      }
    }

    return results;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'role': role,
      'content': content,
      'created_at': createdAt,
    };
  }
}
