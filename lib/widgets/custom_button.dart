import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart'; // Import HugeIcons
import 'animated_tap.dart'; // Import AnimatedTap

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? startColor;
  final Color? endColor;
  final double? width;
  final double? height;
  final double borderRadius;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final dynamic hugeIcon; // Change type to dynamic to accept HugeIconData
  final List<BoxShadow>? boxShadow; // Add boxShadow parameter

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.startColor,
    this.endColor,
    this.width,
    this.height,
    this.borderRadius = 10.0,
    this.textStyle,
    this.padding,
    this.hugeIcon, // Use hugeIcon
    this.boxShadow, // Initialize boxShadow
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
        width: widget.width,
        height: widget.height ?? 50.0,
        padding: widget.padding,
        decoration: BoxDecoration(
          gradient: LinearGradient( // Use a specific gradient for the button
            colors: widget.startColor != null && widget.endColor != null
                ? [widget.startColor!, widget.endColor!]
                : [
                    const Color(0xFF6200EE), // Deep Purple
                    const Color(0xFFBB86FC), // Light Purple
                  ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: widget.boxShadow ?? [ // Use provided boxShadow or default
            BoxShadow(
              color: (widget.startColor ?? const Color(0xFF6200EE)).withAlpha((255 * 0.3).round()), // Shadow matching the button color
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.hugeIcon != null) // Use hugeIcon
                HugeIcon( // Use HugeIcon widget
                  icon: widget.hugeIcon!,
                  color: Colors.white,
                  size: 20,
                ),
              if (widget.hugeIcon != null) const SizedBox(width: 8), // Use hugeIcon
              Text(
                widget.text,
                style: widget.textStyle ??
                    Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
