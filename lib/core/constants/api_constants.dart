class ApiConstants {
  static const String baseUrl = 'http://13.51.160.123:8000/api/v1';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String devToken = '/auth/dev-token';

  // Meal endpoints
  static const String mealsAnalyze = '/meals/analyze';
  static const String mealsConfirm = '/meals/confirm';

  // Chat endpoints
  static const String chat = '/chat';
  static const String chatSessions = '/chat/sessions';
  static String chatSessionMessages(String sessionId) =>
      '/chat/sessions/$sessionId/messages';
  static String chatSessionDelete(String sessionId) =>
      '/chat/sessions/$sessionId';

  // Timeout settings
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
