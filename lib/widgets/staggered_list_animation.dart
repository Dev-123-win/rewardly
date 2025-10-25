import 'package:flutter/material.dart';

/// Staggered list animation widget that animates list items with a delay
/// 
/// This widget provides a smooth fade-in and slide-up animation for list items,
/// with configurable delay between each item for a staggered effect.
/// 
/// Example:
/// ```dart
/// ListView.builder(
///   itemCount: items.length,
///   itemBuilder: (context, index) {
///     return StaggeredListAnimation(
///       delay: Duration(milliseconds: index * 100),
///       child: ListTile(title: Text(items[index])),
///     );
///   },
/// )
/// ```
class StaggeredListAnimation extends StatefulWidget {
  /// The widget to animate
  final Widget child;

  /// Delay before animation starts
  final Duration delay;

  /// Duration of the animation
  final Duration duration;

  /// Curve for the animation
  final Curve curve;

  /// Offset for slide animation (default: 20px down)
  final Offset offset;

  const StaggeredListAnimation({
    required this.child,
    this.delay = const Duration(milliseconds: 100),
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
    this.offset = const Offset(0, 20),
    super.key,
  });

  @override
  State<StaggeredListAnimation> createState() => _StaggeredListAnimationState();
}

class _StaggeredListAnimationState extends State<StaggeredListAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _slideAnimation = Tween<Offset>(begin: widget.offset, end: Offset.zero)
        .animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
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
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Staggered grid animation widget for grid layouts
/// 
/// Similar to StaggeredListAnimation but optimized for grid layouts
class StaggeredGridAnimation extends StatefulWidget {
  /// The widget to animate
  final Widget child;

  /// Delay before animation starts
  final Duration delay;

  /// Duration of the animation
  final Duration duration;

  /// Curve for the animation
  final Curve curve;

  /// Scale animation (default: 0.8 to 1.0)
  final double startScale;

  const StaggeredGridAnimation({
    required this.child,
    this.delay = const Duration(milliseconds: 100),
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
    this.startScale = 0.8,
    super.key,
  });

  @override
  State<StaggeredGridAnimation> createState() => _StaggeredGridAnimationState();
}

class _StaggeredGridAnimationState extends State<StaggeredGridAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _scaleAnimation = Tween<double>(begin: widget.startScale, end: 1.0)
        .animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
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
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Staggered container animation for complex layouts
/// 
/// Provides both fade and slide animations with customizable parameters
class StaggeredContainerAnimation extends StatefulWidget {
  /// The widget to animate
  final Widget child;

  /// Delay before animation starts
  final Duration delay;

  /// Duration of the animation
  final Duration duration;

  /// Curve for the animation
  final Curve curve;

  /// Offset for slide animation
  final Offset offset;

  /// Enable scale animation
  final bool enableScale;

  /// Start scale value (if enableScale is true)
  final double startScale;

  const StaggeredContainerAnimation({
    required this.child,
    this.delay = const Duration(milliseconds: 100),
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
    this.offset = const Offset(0, 20),
    this.enableScale = false,
    this.startScale = 0.9,
    super.key,
  });

  @override
  State<StaggeredContainerAnimation> createState() =>
      _StaggeredContainerAnimationState();
}

class _StaggeredContainerAnimationState extends State<StaggeredContainerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _slideAnimation = Tween<Offset>(begin: widget.offset, end: Offset.zero)
        .animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _scaleAnimation = Tween<double>(begin: widget.startScale, end: 1.0)
        .animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
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
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.enableScale
            ? ScaleTransition(
                scale: _scaleAnimation,
                child: widget.child,
              )
            : widget.child,
      ),
    );
  }
}
