import 'package:flutter/material.dart';
import 'package:rewardly_app/widgets/animated_tap.dart'; // Import AnimatedTap

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? startColor;
  final Color? endColor;
  final double? width;
  final double? height;
  final double borderRadius;
  final TextStyle? textStyle;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.startColor,
    this.endColor,
    this.width,
    this.height,
    this.borderRadius = 10.0, // Changed default to 10.0 for consistency with image
    this.textStyle,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return AnimatedTap(
      onTap: widget.onPressed,
      child: Container(
        width: widget.width ?? double.infinity,
        height: widget.height ?? 50.0,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.startColor ?? const Color(0xFF8A2BE2), // Default purple
              widget.endColor ?? const Color(0xFFDA70D6), // Default pink/orchid
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: (widget.endColor ?? const Color(0xFFDA70D6)).withAlpha(102),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.text,
            style: widget.textStyle ??
                const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
    );
  }
}
