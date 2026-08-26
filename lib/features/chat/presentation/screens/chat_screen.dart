import 'package:bite_front_end/core/theme/app_colors.dart';
import 'package:bite_front_end/core/widgets/bite_blur_app_bar.dart';
import 'package:bite_front_end/core/widgets/bite_fade_slide.dart';
import 'package:bite_front_end/features/auth/presentation/providers/auth_provider.dart';
import 'package:bite_front_end/features/chat/data/models/chat_message_response_model.dart';
import 'package:bite_front_end/features/home/presentation/providers/home_tab_provider.dart';
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
  final FocusNode _inputFocusNode = FocusNode();

  @override
  void dispose() {
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _focusInput() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _inputFocusNode.requestFocus();
      }
    });
  }

  void _unfocusInput() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).unfocus();
        _inputFocusNode.unfocus();
      }
    });
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 768;

        if (isWideScreen) {
          return Scaffold(
            backgroundColor: AppColors.lightBackground,
            body: Row(
              children: [
                SizedBox(
                  width: 280,
                  child: ChatSessionsDrawer(
                    onNewChatPressed: _focusInput,
                    onSessionSelected: _unfocusInput,
                  ),
                ),
                const VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Color(0xFFE2E8F0),
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
            ),
          );
        }

        return _buildChatContent(
          context: context,
          activeChatState: activeChatState,
          isStreaming: isStreaming,
          showDrawerButton: true,
        );
      },
    );
  }

  Widget _buildChatContent({
    required BuildContext context,
    required ActiveChatState activeChatState,
    required bool isStreaming,
    required bool showDrawerButton,
  }) {
    final allMessages = [...activeChatState.messages];
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final bottomInset = isKeyboardOpen ? 0.0 : (isMobile ? 86.0 : 0.0);
    final hasStreamingResponse =
        activeChatState.currentStreamingResponse.isNotEmpty;
    final hasStatusMessage =
        activeChatState.statusMessage != null &&
        activeChatState.statusMessage!.isNotEmpty;
    final extraItemCount = hasStreamingResponse
        ? 1
        : (hasStatusMessage ? 1 : 0);

    final authState = ref.watch(authNotifierProvider);
    final displayName = authState.valueOrNull?.displayName ?? '';
    final userInitial = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : '👤';

    final topPadding =
        kToolbarHeight + 14.0 + MediaQuery.of(context).padding.top + 16.0;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      extendBodyBehindAppBar: true,
      drawer: showDrawerButton
          ? ChatSessionsDrawer(
              onNewChatPressed: _focusInput,
              onSessionSelected: _unfocusInput,
            )
          : null,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: kToolbarHeight + 14.0,
        flexibleSpace: const BiteBlurAppBarBackground(),
        titleSpacing: 4,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.secondary,
              size: 20,
            ),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                'AI Nutrition Assistant',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        leading: showDrawerButton
            ? Builder(
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withValues(
                                alpha: 0.15,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.history_rounded,
                            color: AppColors.secondary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : null,
        actions: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            icon: const Icon(Icons.add_rounded, color: AppColors.secondary),
            tooltip: 'New Chat',
            onPressed: () {
              ref.read(activeChatNotifierProvider.notifier).startNewSession();
              _focusInput();
            },
          ),
          GestureDetector(
            onTap: () {
              ref.read(homeTabIndexProvider.notifier).state = 3;
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12, left: 4),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  userInitial,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                if (activeChatState.errorMessage != null)
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFFEF2F2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
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
                            style: const TextStyle(
                              fontSize: 12,
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
                          !hasStreamingResponse &&
                          !hasStatusMessage
                      ? BiteFadeSlide(child: _buildEmptyState(context))
                      : NotificationListener<ScrollNotification>(
                          onNotification: (scrollNotification) {
                            if (scrollNotification is ScrollStartNotification) {
                              FocusScope.of(context).unfocus();
                            }
                            return false;
                          },
                          child: ListView.builder(
                            controller: _scrollController,
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: EdgeInsets.only(
                              top: topPadding,
                              bottom: isMobile
                                  ? (isKeyboardOpen ? 120.0 : 210.0)
                                  : 140.0,
                            ),
                            itemCount: allMessages.length + extraItemCount,
                            itemBuilder: (context, index) {
                              if (index < allMessages.length) {
                                return ChatBubble(message: allMessages[index]);
                              }

                              if (hasStreamingResponse) {
                                final streamingMsg = ChatMessageResponseModel(
                                  id: 'streaming_temp',
                                  sessionId:
                                      activeChatState.activeSessionId ?? '',
                                  role: 'assistant',
                                  content:
                                      activeChatState.currentStreamingResponse,
                                  createdAt: DateTime.now().toIso8601String(),
                                );

                                return ChatBubble(
                                  message: streamingMsg,
                                  isStreaming: true,
                                );
                              } else {
                                return SseStatusBanner(
                                  statusMessage: activeChatState.statusMessage!,
                                );
                              }
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),

          // Enhanced Floating Action Button for New Chat (positioned bottom-right above input box)
          Positioned(
            right: 20,
            bottom: bottomInset + (isMobile ? 82.0 : 76.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Material(
                color: Colors.transparent,
                child: Tooltip(
                  message: 'New Chat',
                  child: InkWell(
                    onTap: () {
                      ref
                          .read(activeChatNotifierProvider.notifier)
                          .startNewSession();
                      _focusInput();
                    },
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.secondary, Color(0xFFFF7700)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: Colors.white, width: 2.0),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.45),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add_comment_rounded,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ChatInputBar(
              focusNode: _inputFocusNode,
              isStreaming: isStreaming,
              bottomInset: bottomInset,
              onSend: (prompt) {
                ref
                    .read(activeChatNotifierProvider.notifier)
                    .sendMessage(prompt);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final topPadding =
        kToolbarHeight + 14.0 + MediaQuery.of(context).padding.top + 16.0;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Align(
        alignment: const Alignment(0, -0.2),
        child: NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollStartNotification) {
              FocusScope.of(context).unfocus();
            }
            return false;
          },
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              top: topPadding,
              bottom: isMobile ? 180.0 : 120.0,
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 540),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF7ED),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 44,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'How can I help with your nutrition today?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ask for calorie advice, log a meal in plain text, or check your daily macro targets.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 8,
                    runSpacing: 10,
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
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(BuildContext context, String text) {
    return ActionChip(
      avatar: const Icon(
        Icons.flash_on_rounded,
        size: 14,
        color: AppColors.secondary,
      ),
      label: Text(text),
      labelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F172A),
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
      ),
      onPressed: () {
        ref.read(activeChatNotifierProvider.notifier).sendMessage(text);
      },
    );
  }
}
