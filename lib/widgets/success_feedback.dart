import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

class SuccessFeedback extends StatefulWidget {
  final String message;
  final Duration duration;
  final VoidCallback? onDismiss;
  final Color? backgroundColor;
  final IconData? icon;

  const SuccessFeedback({
    required this.message,
    this.duration = const Duration(seconds: 2),
    this.onDismiss,
    this.backgroundColor,
    this.icon,
    super.key,
  });

  @override
  State<SuccessFeedback> createState() => _SuccessFeedbackState();
}

class _SuccessFeedbackState extends State<SuccessFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: DesignSystem.durationNormal,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward().then((_) {
      Future.delayed(widget.duration, () {
        if (mounted) {
          _controller.reverse().then((_) {
            widget.onDismiss?.call();
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.all(DesignSystem.spacing4),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? DesignSystem.success,
          borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
          boxShadow: [DesignSystem.shadowLarge],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.icon ?? Icons.check_circle,
              color: Colors.white,
              size: 24,
            ),
            SizedBox(width: DesignSystem.spacing3),
            Expanded(
              child: Text(
                widget.message,
                style: DesignSystem.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
