import 'package:bite_front_end/core/theme/app_colors.dart';
import 'package:bite_front_end/features/chat/data/models/chat_message_response_model.dart';
import 'package:bite_front_end/features/chat/presentation/providers/active_chat_provider.dart';
import 'package:bite_front_end/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:bite_front_end/features/chat/presentation/widgets/chat_input_bar.dart';
import 'package:bite_front_end/features/chat/presentation/widgets/chat_sessions_drawer.dart';
import 'package:bite_front_end/features/chat/presentation/widgets/sse_status_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeChatState = ref.watch(activeChatNotifierProvider);
    final isStreaming =
        activeChatState.streamStatus == StreamStatus.streaming ||
        activeChatState.streamStatus == StreamStatus.connecting;

    // Auto-scroll when messages update or streaming text changes
    ref.listen(activeChatNotifierProvider, (previous, next) {
      if (next.messages.length != (previous?.messages.length ?? 0) ||
          next.currentStreamingResponse !=
              (previous?.currentStreamingResponse ?? '')) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      drawer: const ChatSessionsDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth >= 768;

          if (isWideScreen) {
            return Row(
              children: [
                const SizedBox(width: 280, child: ChatSessionsDrawer()),
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.borderDark
                      : AppColors.borderLight,
                ),
                Expanded(
                  child: _buildChatContent(
                    context: context,
                    activeChatState: activeChatState,
                    isStreaming: isStreaming,
                    showDrawerButton: false,
                  ),
                ),
              ],
            );
          }

          return _buildChatContent(
            context: context,
            activeChatState: activeChatState,
            isStreaming: isStreaming,
            showDrawerButton: true,
          );
        },
      ),
    );
  }

  Widget _buildChatContent({
    required BuildContext context,
    required ActiveChatState activeChatState,
    required bool isStreaming,
    required bool showDrawerButton,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final allMessages = [...activeChatState.messages];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'AI Nutrition Assistant',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        leading: showDrawerButton
            ? Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_rounded),
            tooltip: 'New Chat',
            onPressed: () {
              ref.read(activeChatNotifierProvider.notifier).startNewSession();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (activeChatState.errorMessage != null)
            Container(
              width: double.infinity,
              color: AppColors.errorContainer,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      activeChatState.errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child:
                allMessages.isEmpty &&
                    activeChatState.currentStreamingResponse.isEmpty &&
                    activeChatState.statusMessage == null
                ? _buildEmptyState(context, isDark)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    itemCount:
                        allMessages.length +
                        (activeChatState.currentStreamingResponse.isNotEmpty
                            ? 1
                            : 0),
                    itemBuilder: (context, index) {
                      if (index < allMessages.length) {
                        return ChatBubble(message: allMessages[index]);
                      }

                      // Active streaming chunk bubble
                      final streamingMsg = ChatMessageResponseModel(
                        id: 'streaming_temp',
                        sessionId: activeChatState.activeSessionId ?? '',
                        role: 'assistant',
                        content: activeChatState.currentStreamingResponse,
                        createdAt: DateTime.now().toIso8601String(),
                      );

                      return ChatBubble(
                        message: streamingMsg,
                        isStreaming: true,
                      );
                    },
                  ),
          ),
          if (activeChatState.statusMessage != null)
            SseStatusBanner(statusMessage: activeChatState.statusMessage!),
          ChatInputBar(
            isStreaming: isStreaming,
            onSend: (prompt) {
              ref.read(activeChatNotifierProvider.notifier).sendMessage(prompt);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'How can I help with your nutrition today?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Ask for calorie advice, log a meal in plain text, or check your daily macro targets.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildSuggestionChip(
                  context,
                  'I ate 300g chicken biryani for lunch',
                ),
                _buildSuggestionChip(
                  context,
                  'What should my target protein intake be?',
                ),
                _buildSuggestionChip(
                  context,
                  'How many calories are in 2 bananas?',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(BuildContext context, String text) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ActionChip(
      label: Text(text),
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      onPressed: () {
        ref.read(activeChatNotifierProvider.notifier).sendMessage(text);
      },
    );
  }
}
