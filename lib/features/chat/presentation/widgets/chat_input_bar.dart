import 'dart:ui';
import 'package:bite_front_end/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ChatInputBar extends StatefulWidget {
  final ValueChanged<String> onSend;
  final bool isStreaming;
  final double bottomInset;
  final FocusNode? focusNode;

  const ChatInputBar({
    super.key,
    required this.onSend,
    required this.isStreaming,
    this.bottomInset = 0.0,
    this.focusNode,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _internalFocusNode = FocusNode();
  bool _hasText = false;

  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasTextNow = _controller.text.trim().isNotEmpty;
      if (hasTextNow != _hasText) {
        setState(() {
          _hasText = hasTextNow;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _internalFocusNode.dispose();
    super.dispose();
  }

  void _handleSubmitted() {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.isStreaming) return;
    widget.onSend(text);
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _effectiveFocusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.only(
        left: 12.0,
        right: 12.0,
        bottom: widget.bottomInset + 8.0,
      ),
      child: SafeArea(
        top: false,
        bottom: widget.bottomInset == 0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.84),
                borderRadius: BorderRadius.circular(32.0),
                border: Border.all(
                  color: const Color(0xFFE2E8F0).withValues(alpha: 0.9),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 6.0),
                      child: TextField(
                        controller: _controller,
                        focusNode: _effectiveFocusNode,
                        enabled: true,
                        readOnly: widget.isStreaming,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _handleSubmitted(),
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          filled: false,
                          fillColor: Colors.transparent,
                          hintText: widget.isStreaming
                              ? 'AI assistant is typing...'
                              : 'Ask nutrition advice or log a meal...',
                          hintStyle: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: (_hasText && !widget.isStreaming)
                          ? _handleSubmitted
                          : null,
                      customBorder: const CircleBorder(),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: (_hasText && !widget.isStreaming)
                              ? const LinearGradient(
                                  colors: [
                                    AppColors.secondary,
                                    Color(0xFFFF7700),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: (_hasText && !widget.isStreaming)
                              ? null
                              : const Color(0xFFE2E8F0),
                          boxShadow: (_hasText && !widget.isStreaming)
                              ? [
                                  BoxShadow(
                                    color: AppColors.secondary.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: widget.isStreaming
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.secondary,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.arrow_upward_rounded,
                                  size: 22,
                                  color: _hasText
                                      ? Colors.white
                                      : const Color(0xFF94A3B8),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
