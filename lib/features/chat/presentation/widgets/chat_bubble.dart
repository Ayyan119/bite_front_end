import 'package:bite_front_end/core/theme/app_colors.dart';
import 'package:bite_front_end/core/theme/app_radius.dart';
import 'package:bite_front_end/features/chat/data/models/chat_message_response_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ParsedMessageContent {
  final List<String> actionSteps;
  final String cleanAnswer;

  const ParsedMessageContent({
    required this.actionSteps,
    required this.cleanAnswer,
  });
}

ParsedMessageContent parseMessageContent(String rawText) {
  if (rawText.isEmpty) {
    return const ParsedMessageContent(actionSteps: [], cleanAnswer: '');
  }

  final RegExp stepRegex = RegExp(
    r'^(?:(?:Retrieving|Searching|Calculating|Saving|Loading|Processing|Analyzing|Fetching|Updating)\b[^\.\n]*\.\.\.\s*)+',
    caseSensitive: false,
  );

  final match = stepRegex.firstMatch(rawText);
  if (match != null) {
    final stepsString = match.group(0)!;
    final cleanAnswer = rawText.substring(match.end).trim();

    final steps = stepsString
        .split('...')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map((s) => '$s...')
        .toList();

    return ParsedMessageContent(
      actionSteps: steps,
      cleanAnswer: cleanAnswer.isNotEmpty ? cleanAnswer : rawText,
    );
  }

  return ParsedMessageContent(actionSteps: const [], cleanAnswer: rawText);
}

class ChatBubble extends StatefulWidget {
  final ChatMessageResponseModel message;
  final bool isStreaming;

  const ChatBubble({
    super.key,
    required this.message,
    this.isStreaming = false,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool _isActionsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.role.toLowerCase() == 'user';
    final parsed = parseMessageContent(widget.message.content);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 14.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.84,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: isUser ? null : Colors.white,
          gradient: isUser
              ? const LinearGradient(
                  colors: [AppColors.secondary, Color(0xFFFF7700)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          border: isUser
              ? null
              : Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(22),
            topRight: const Radius.circular(22),
            bottomLeft: Radius.circular(isUser ? 22 : 6),
            bottomRight: Radius.circular(isUser ? 6 : 22),
          ),
          boxShadow: [
            BoxShadow(
              color: isUser
                  ? AppColors.secondary.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: AppRadius.pillBorder,
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 13,
                      color: AppColors.secondary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'BITE AI ASSISTANT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (isUser)
              SelectableText(
                widget.message.content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              )
            else ...[
              if (parsed.actionSteps.isNotEmpty)
                _buildActionStepsWidget(parsed.actionSteps),
              if (parsed.cleanAnswer.isNotEmpty) ...[
                if (parsed.actionSteps.isNotEmpty) const SizedBox(height: 8),
                _buildFormattedMarkdown(context, parsed.cleanAnswer),
              ] else if (widget.isStreaming) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        parsed.actionSteps.isNotEmpty
                            ? parsed.actionSteps.last
                            : 'Analyzing prompt...',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTimestamp(widget.message.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isUser
                        ? const Color(0xFFFFEDD5)
                        : const Color(0xFF94A3B8),
                  ),
                ),
                if (widget.isStreaming && !isUser) ...[
                  const SizedBox(width: 6),
                  const SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionStepsWidget(List<String> steps) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isActionsExpanded = !_isActionsExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.bolt_rounded,
                    size: 14,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${steps.length} System Action${steps.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _isActionsExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                ],
              ),
            ),
          ),
          if (_isActionsExpanded)
            Padding(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                bottom: 8,
                top: 2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: steps.map((step) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 12,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            step,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7C2D12),
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFormattedMarkdown(BuildContext context, String text) {
    const baseStyle = TextStyle(
      color: Color(0xFF0F172A),
      fontSize: 14,
      height: 1.45,
      fontWeight: FontWeight.w500,
    );

    final lines = text.split('\n');
    final List<Widget> widgets = [];

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        widgets.add(const SizedBox(height: 6));
        continue;
      }

      if (trimmed.startsWith('### ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 2),
            child: Text(
              trimmed.substring(4),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        );
      } else if (trimmed.startsWith('## ') || trimmed.startsWith('# ')) {
        final content = trimmed.replaceFirst(RegExp(r'^#+\s*'), '');
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.secondary,
              ),
            ),
          ),
        );
      } else if (trimmed.startsWith('* ') || trimmed.startsWith('- ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 2.0, bottom: 2.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: _parseInlineFormatting(
                      trimmed.substring(2),
                      baseStyle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: RichText(text: _parseInlineFormatting(line, baseStyle)),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  TextSpan _parseInlineFormatting(String text, TextStyle? baseStyle) {
    final List<InlineSpan> spans = [];
    final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');
    int lastMatchEnd = 0;

    for (final Match match in boldPattern.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: baseStyle?.copyWith(
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0F172A),
          ),
        ),
      );
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return TextSpan(style: baseStyle, children: spans);
  }

  String _formatTimestamp(String rawIso) {
    if (rawIso.isEmpty) return 'Just now';
    try {
      final parsed = DateTime.parse(rawIso);
      return DateFormat('h:mm a').format(parsed.toLocal());
    } catch (_) {
      return 'Just now';
    }
  }
}
