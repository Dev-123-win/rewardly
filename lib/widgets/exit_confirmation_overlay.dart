import 'dart:ui'; // For BackdropFilter
import 'package:flutter/material.dart';

class ExitConfirmationOverlay extends StatefulWidget {
  final VoidCallback onCancel;

  const ExitConfirmationOverlay({super.key, required this.onCancel});

  @override
  State<ExitConfirmationOverlay> createState() => _ExitConfirmationOverlayState();
}

class _ExitConfirmationOverlayState extends State<ExitConfirmationOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0), // Start from bottom
      end: Offset.zero, // Move to center
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blurred background
        GestureDetector(
          onTap: widget.onCancel, // Dismiss on tapping outside
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.black.withAlpha(77), // Dark overlay
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        // Animated exit confirmation card
        Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: _offsetAnimation,
            child: Card(
              margin: const EdgeInsets.all(20.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
              elevation: 10.0,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: widget.onCancel,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Press back again to exit',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    // You can add more information or buttons here if needed
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
