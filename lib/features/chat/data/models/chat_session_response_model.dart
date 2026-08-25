class ChatRequestModel {
  final String message;
  final String? conversationId;
  final String? clientTimezone;

  const ChatRequestModel({
    required this.message,
    this.conversationId,
    this.clientTimezone,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'message': message};
    if (conversationId != null) map['conversation_id'] = conversationId;
    if (clientTimezone != null) map['client_timezone'] = clientTimezone;
    return map;
  }

  factory ChatRequestModel.fromJson(Map<String, dynamic> json) {
    return ChatRequestModel(
      message: json['message'] as String? ?? '',
      conversationId: json['conversation_id'] as String?,
      clientTimezone: json['client_timezone'] as String?,
    );
  }
}

class CreateSessionRequestModel {
  final String title;

  const CreateSessionRequestModel({required this.title});

  Map<String, dynamic> toJson() => {'title': title};

  factory CreateSessionRequestModel.fromJson(Map<String, dynamic> json) {
    return CreateSessionRequestModel(title: json['title'] as String? ?? '');
  }
}

class ChatSessionResponseModel {
  final String id;
  final String userId;
  final String title;
  final String createdAt;
  final String updatedAt;
  final int messageCount;

  const ChatSessionResponseModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messageCount,
  });

  factory ChatSessionResponseModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionResponseModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      messageCount: (json['message_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'message_count': messageCount,
    };
  }
}
