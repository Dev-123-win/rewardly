import 'package:flutter/material.dart';

/// Notification badge widget that displays unread notification count
/// 
/// This widget shows a red badge with the count of unread notifications.
/// It's typically used on navigation icons or app bar items.
/// 
/// Example:
/// ```dart
/// Stack(
///   children: [
///     Icon(Icons.notifications),
///     NotificationBadge(count: 5),
///   ],
/// )
/// ```
class NotificationBadge extends StatelessWidget {
  /// Number of unread notifications
  final int count;

  /// Badge size (default: 20)
  final double size;

  /// Badge color (default: error red)
  final Color color;

  /// Text color (default: white)
  final Color textColor;

  /// Font size (default: 10)
  final double fontSize;

  /// Show animation on update
  final bool animate;

  const NotificationBadge({
    required this.count,
    this.size = 20,
    this.color = const Color(0xFFEF4444),
    this.textColor = Colors.white,
    this.fontSize = 10,
    this.animate = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show badge if count is 0
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    // Format count (show 9+ for counts > 9)
    final displayCount = count > 99 ? '99+' : count.toString();

    return Positioned(
      right: -8,
      top: -8,
      child: animate
          ? ScaleTransition(
              scale: AlwaysStoppedAnimation(1.0),
              child: _buildBadge(displayCount),
            )
          : _buildBadge(displayCount),
    );
  }

  Widget _buildBadge(String displayCount) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          displayCount,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Animated notification badge that pulses when count changes
class AnimatedNotificationBadge extends StatefulWidget {
  /// Number of unread notifications
  final int count;

  /// Badge size (default: 20)
  final double size;

  /// Badge color (default: error red)
  final Color color;

  /// Text color (default: white)
  final Color textColor;

  /// Font size (default: 10)
  final double fontSize;

  const AnimatedNotificationBadge({
    required this.count,
    this.size = 20,
    this.color = const Color(0xFFEF4444),
    this.textColor = Colors.white,
    this.fontSize = 10,
    super.key,
  });

  @override
  State<AnimatedNotificationBadge> createState() =>
      _AnimatedNotificationBadgeState();
}

class _AnimatedNotificationBadgeState extends State<AnimatedNotificationBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _previousCount = 0;

  @override
  void initState() {
    super.initState();
    _previousCount = widget.count;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(AnimatedNotificationBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != _previousCount && widget.count > 0) {
      _controller.forward(from: 0.0);
      _previousCount = widget.count;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show badge if count is 0
    if (widget.count <= 0) {
      return const SizedBox.shrink();
    }

    // Format count (show 9+ for counts > 9)
    final displayCount = widget.count > 99 ? '99+' : widget.count.toString();

    return Positioned(
      right: -8,
      top: -8,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              displayCount,
              style: TextStyle(
                color: widget.textColor,
                fontSize: widget.fontSize,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

/// Dot badge for simple notification indicator (no count)
class DotNotificationBadge extends StatelessWidget {
  /// Badge size (default: 12)
  final double size;

  /// Badge color (default: error red)
  final Color color;

  /// Show animation
  final bool animate;

  const DotNotificationBadge({
    this.size = 12,
    this.color = const Color(0xFFEF4444),
    this.animate = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: -4,
      top: -4,
      child: animate
          ? ScaleTransition(
              scale: AlwaysStoppedAnimation(1.0),
              child: _buildDot(),
            )
          : _buildDot(),
    );
  }

  Widget _buildDot() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}

/// Badge wrapper that can be placed on any widget
class BadgeWrapper extends StatelessWidget {
  /// The widget to place the badge on
  final Widget child;

  /// Number of unread notifications
  final int count;

  /// Badge size (default: 20)
  final double badgeSize;

  /// Badge color (default: error red)
  final Color badgeColor;

  /// Show dot instead of count
  final bool showDot;

  /// Animate badge
  final bool animate;

  const BadgeWrapper({
    required this.child,
    required this.count,
    this.badgeSize = 20,
    this.badgeColor = const Color(0xFFEF4444),
    this.showDot = false,
    this.animate = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (showDot)
          DotNotificationBadge(
            size: badgeSize,
            color: badgeColor,
            animate: animate,
          )
        else if (animate)
          AnimatedNotificationBadge(
            count: count,
            size: badgeSize,
            color: badgeColor,
          )
        else
          NotificationBadge(
            count: count,
            size: badgeSize,
            color: badgeColor,
            animate: false,
          ),
      ],
    );
  }
}
