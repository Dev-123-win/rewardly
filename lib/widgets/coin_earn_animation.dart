import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

class CoinEarnAnimation extends StatefulWidget {
  final int coins;
  final VoidCallback onComplete;
  final Offset position;

  const CoinEarnAnimation({
    required this.coins,
    required this.onComplete,
    this.position = const Offset(0, 0),
    super.key,
  });

  @override
  State<CoinEarnAnimation> createState() => _CoinEarnAnimationState();
}

class _CoinEarnAnimationState extends State<CoinEarnAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _floatController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _floatAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: DesignSystem.durationNormal,
    );

    _floatController = AnimationController(
      vsync: this,
      duration: DesignSystem.durationSlow,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _floatAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -100),
    ).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeOut),
    );

    _scaleController.forward().then((_) {
      _floatController.forward().then((_) {
        widget.onComplete();
      });
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: SlideTransition(
        position: _floatAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: DesignSystem.accent,
                  shape: BoxShape.circle,
                  boxShadow: [DesignSystem.shadowLarge],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/coin.png',
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
              SizedBox(height: DesignSystem.spacing2),
              Text(
                '+${widget.coins}',
                style: DesignSystem.headlineLarge.copyWith(
                  color: DesignSystem.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
