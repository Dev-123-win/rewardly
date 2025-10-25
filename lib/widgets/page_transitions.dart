import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

class FadePageRoute<T> extends PageRoute<T> {
  FadePageRoute({
    required this.child,
    this.duration = DesignSystem.durationNormal,
  });

  final Widget child;
  final Duration duration;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  bool get opaque => false;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }
}

class SlidePageRoute<T> extends PageRoute<T> {
  SlidePageRoute({
    required this.child,
    this.duration = DesignSystem.durationNormal,
    this.direction = SlideDirection.rightToLeft,
  });

  final Widget child;
  final Duration duration;
  final SlideDirection direction;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  bool get opaque => false;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    Offset beginOffset;
    switch (direction) {
      case SlideDirection.rightToLeft:
        beginOffset = const Offset(1, 0);
        break;
      case SlideDirection.leftToRight:
        beginOffset = const Offset(-1, 0);
        break;
      case SlideDirection.bottomToTop:
        beginOffset = const Offset(0, 1);
        break;
      case SlideDirection.topToBottom:
        beginOffset = const Offset(0, -1);
        break;
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: beginOffset,
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
      child: child,
    );
  }
}

class ScalePageRoute<T> extends PageRoute<T> {
  ScalePageRoute({
    required this.child,
    this.duration = DesignSystem.durationNormal,
  });

  final Widget child;
  final Duration duration;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;

  @override
  bool get opaque => false;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOut),
      ),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

enum SlideDirection {
  rightToLeft,
  leftToRight,
  bottomToTop,
  topToBottom,
}
