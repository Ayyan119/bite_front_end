import 'package:bite_front_end/core/theme/app_colors.dart';
import 'package:bite_front_end/core/theme/app_radius.dart';
import 'package:bite_front_end/core/widgets/bite_fade_slide.dart';
import 'package:bite_front_end/features/chat/data/models/chat_session_response_model.dart';
import 'package:bite_front_end/features/chat/presentation/providers/active_chat_provider.dart';
import 'package:bite_front_end/features/chat/presentation/providers/chat_sessions_provider.dart';
import 'package:bite_front_end/features/chat/presentation/widgets/animated_delete_button.dart';
import 'package:bite_front_end/features/chat/presentation/widgets/delete_confirmation_dialog.dart';
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
    final sessions = sessionsState.value ?? [];

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
      child: Drawer(
        backgroundColor: Colors.white,
        elevation: 16,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.secondary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.history_rounded,
                            color: AppColors.secondary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chat History',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Saved AI conversations',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (sessions.isNotEmpty)
                          AnimatedDeleteButton(
                            size: 34,
                            tooltip: 'Clear all history',
                            activeColor: const Color(0xFFEF4444),
                            onPressed: () async {
                              final confirm = await DeleteConfirmationDialog.show(
                                context: context,
                                title: 'Clear All History?',
                                message:
                                    'This will permanently remove all ${sessions.length} saved AI chat sessions.',
                                confirmText: 'Clear All',
                              );
                              if (confirm == true) {
                                await ref
                                    .read(chatSessionsProvider.notifier)
                                    .clearAllSessions();
                                ref
                                    .read(activeChatNotifierProvider.notifier)
                                    .startNewSession();
                              }
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.secondary, Color(0xFFFF7700)],
                        ),
                        borderRadius: AppRadius.pillBorder,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
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
                        icon: const Icon(
                          Icons.add_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'New Conversation',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.pillBorder,
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: sessionsState.when(
                    data: (sessionList) {
                      if (sessionList.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 44,
                                  color: Color(0xFF94A3B8),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'No past conversations',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14.0,
                          vertical: 14.0,
                        ),
                        itemCount: sessionList.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final session = sessionList[index];
                          final isSelected =
                              activeChatState.activeSessionId == session.id;

                          return BiteFadeSlide(
                            key: ValueKey('fade_slide_${session.id}'),
                            delay: Duration(milliseconds: index * 30),
                            child: _buildSessionTile(
                              context: context,
                              ref: ref,
                              session: session,
                              isSelected: isSelected,
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.secondary,
                        ),
                      ),
                    ),
                    error: (err, stack) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Failed to load sessions: $err',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionTile({
    required BuildContext context,
    required WidgetRef ref,
    required ChatSessionResponseModel session,
    required bool isSelected,
  }) {
    final title = session.title.isNotEmpty
        ? session.title
        : 'Chat Conversation';

    return Dismissible(
      key: ValueKey('dismissible_${session.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        final confirm = await DeleteConfirmationDialog.show(
          context: context,
          title: 'Delete Conversation?',
          message: 'Are you sure you want to delete "$title"?',
          confirmText: 'Delete',
        );
        return confirm ?? false;
      },
      onDismissed: (direction) {
        ref.read(chatSessionsProvider.notifier).deleteSession(session.id);
        if (isSelected) {
          ref.read(activeChatNotifierProvider.notifier).startNewSession();
        }
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEF4444).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
            SizedBox(width: 6),
            Icon(Icons.delete_forever_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF7ED) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.secondary.withValues(alpha: 0.4)
                : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.secondary.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          dense: true,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.secondary.withValues(alpha: 0.15)
                  : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSelected
                  ? Icons.auto_awesome_rounded
                  : Icons.chat_bubble_outline_rounded,
              size: 16,
              color: isSelected ? AppColors.secondary : const Color(0xFF64748B),
            ),
          ),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
              color: isSelected ? AppColors.secondary : const Color(0xFF0F172A),
            ),
          ),
          subtitle: Text(
            _formatDate(session.updatedAt),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94A3B8),
            ),
          ),
          trailing: AnimatedDeleteButton(
            tooltip: 'Delete session',
            onPressed: () async {
              final confirm = await DeleteConfirmationDialog.show(
                context: context,
                title: 'Delete Conversation?',
                message: 'Are you sure you want to delete "$title"?',
                confirmText: 'Delete',
              );
              if (confirm == true) {
                ref
                    .read(chatSessionsProvider.notifier)
                    .deleteSession(session.id);
                if (isSelected) {
                  ref
                      .read(activeChatNotifierProvider.notifier)
                      .startNewSession();
                }
              }
            },
          ),
          onTap: () {
            ref
                .read(activeChatNotifierProvider.notifier)
                .loadSession(session.id);
            if (onSessionSelected != null) {
              onSessionSelected!();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
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
