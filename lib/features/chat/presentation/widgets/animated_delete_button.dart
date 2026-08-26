import 'package:flutter/material.dart';

/// A sleek, animated delete button with micro-interactions, scale feedback,
/// and smooth hover/press color morphing.
class AnimatedDeleteButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String tooltip;
  final double size;
  final Color iconColor;
  final Color activeColor;

  const AnimatedDeleteButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'Delete',
    this.size = 36.0,
    this.iconColor = const Color(0xFF94A3B8),
    this.activeColor = const Color(0xFFEF4444),
  });

  @override
  State<AnimatedDeleteButton> createState() => _AnimatedDeleteButtonState();
}

class _AnimatedDeleteButtonState extends State<AnimatedDeleteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: -0.1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticIn));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          behavior: HitTestBehavior.opaque,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: child,
                ),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: _isHovered
                    ? widget.activeColor.withValues(alpha: 0.12)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isHovered
                      ? widget.activeColor.withValues(alpha: 0.35)
                      : Colors.transparent,
                  width: 1.2,
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: widget.activeColor.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    _isHovered
                        ? Icons.delete_forever_rounded
                        : Icons.delete_outline_rounded,
                    key: ValueKey<bool>(_isHovered),
                    size: widget.size * 0.52,
                    color: _isHovered ? widget.activeColor : widget.iconColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
