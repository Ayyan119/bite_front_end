import 'package:flutter/foundation.dart';

@immutable
sealed class SseEvent {
  const SseEvent();
}

class SseStatusEvent extends SseEvent {
  final String status;
  final String message;

  const SseStatusEvent({required this.status, required this.message});
}

class SseTokenEvent extends SseEvent {
  final String content;

  const SseTokenEvent({required this.content});
}

class SseDoneEvent extends SseEvent {
  final String conversationId;
  final String status;

  const SseDoneEvent({required this.conversationId, required this.status});
}

class SseErrorEvent extends SseEvent {
  final String error;

  const SseErrorEvent({required this.error});
}
