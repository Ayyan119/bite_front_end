import 'package:bite_front_end/core/theme/app_colors.dart';
import 'package:bite_front_end/core/theme/app_radius.dart';
import 'package:bite_front_end/features/chat/data/models/chat_session_response_model.dart';
import 'package:bite_front_end/features/chat/presentation/providers/active_chat_provider.dart';
import 'package:bite_front_end/features/chat/presentation/providers/chat_sessions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ChatSessionsDrawer extends ConsumerWidget {
  final VoidCallback? onSessionSelected;

  const ChatSessionsDrawer({super.key, this.onSessionSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsState = ref.watch(chatSessionsProvider);
    final activeChatState = ref.watch(activeChatNotifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.forum_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Chat Sessions',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref
                            .read(activeChatNotifierProvider.notifier)
                            .startNewSession();
                        if (onSessionSelected != null) {
                          onSessionSelected!();
                        } else {
                          Navigator.of(context).maybePop();
                        }
                      },
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text('New Chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.pillBorder,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: sessionsState.when(
                data: (sessions) {
                  if (sessions.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 48,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextMuted,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No past conversations',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 8.0,
                    ),
                    itemCount: sessions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      final isSelected =
                          activeChatState.activeSessionId == session.id;

                      return _buildSessionTile(
                        context: context,
                        ref: ref,
                        session: session,
                        isSelected: isSelected,
                        isDark: isDark,
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Failed to load sessions: $err',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTile({
    required BuildContext context,
    required WidgetRef ref,
    required ChatSessionResponseModel session,
    required bool isSelected,
    required bool isDark,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected
          ? (isDark
                ? AppColors.primaryDark.withValues(alpha: 0.3)
                : AppColors.primaryContainer)
          : Colors.transparent,
      borderRadius: AppRadius.mdBorder,
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
        dense: true,
        leading: Icon(
          Icons.chat_bubble_outline_rounded,
          size: 20,
          color: isSelected
              ? AppColors.primary
              : (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextMuted),
        ),
        title: Text(
          session.title.isNotEmpty ? session.title : 'Chat Conversation',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? AppColors.primary
                : (isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary),
          ),
        ),
        subtitle: Text(
          _formatDate(session.updatedAt),
          style: theme.textTheme.labelSmall?.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextMuted,
            fontSize: 10,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded, size: 18),
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextMuted,
          onPressed: () {
            ref.read(chatSessionsProvider.notifier).deleteSession(session.id);
            if (isSelected) {
              ref.read(activeChatNotifierProvider.notifier).startNewSession();
            }
          },
        ),
        onTap: () {
          ref.read(activeChatNotifierProvider.notifier).loadSession(session.id);
          if (onSessionSelected != null) {
            onSessionSelected!();
          } else {
            Navigator.of(context).maybePop();
          }
        },
      ),
    );
  }

  String _formatDate(String isoString) {
    if (isoString.isEmpty) return '';
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('MMM d, h:mm a').format(date.toLocal());
    } catch (_) {
      return '';
    }
  }
}
