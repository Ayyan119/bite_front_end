import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/chat/presentation/providers/chat_sessions_provider.dart';
import '../../features/dashboard/presentation/providers/dashboard_provider.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';

/// Preloads critical app data (Dashboard summary, Chatbot session history, Profile metrics)
/// concurrently in the background during app startup for zero-wait tab transitions.
void preloadAppData(WidgetRef ref) {
  final now = DateTime.now();
  final todayStr = formatDateString(now);

  unawaited(
    Future.wait([
      // 1. Dashboard daily summary & 30-day analytics cache
      ref
          .read(dailyDashboardProvider(todayStr).future)
          .then((_) => null, onError: (_) => null),
      ref
          .read(historicalAnalyticsProvider(30).future)
          .then((_) => null, onError: (_) => null),

      // 2. Chatbot sessions history cache
      ref
          .read(chatSessionsProvider.future)
          .then((_) => null, onError: (_) => null),

      // 3. User profile & metabolic targets cache
      ref
          .read(profileNotifierProvider.future)
          .then((_) => null, onError: (_) => null),
    ]),
  );
}

/// Helper function to preload app data when using a ProviderContainer directly.
void preloadAppDataWithContainer(ProviderContainer container) {
  final now = DateTime.now();
  final todayStr = formatDateString(now);

  unawaited(
    Future.wait([
      container
          .read(dailyDashboardProvider(todayStr).future)
          .then((_) => null, onError: (_) => null),
      container
          .read(historicalAnalyticsProvider(30).future)
          .then((_) => null, onError: (_) => null),
      container
          .read(chatSessionsProvider.future)
          .then((_) => null, onError: (_) => null),
      container
          .read(profileNotifierProvider.future)
          .then((_) => null, onError: (_) => null),
    ]),
  );
}
