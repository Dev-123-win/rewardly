import 'package:flutter/material.dart';

class AuthCard extends StatelessWidget {
  final Widget child;

  const AuthCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0), // Adjusted margin for better fit
        elevation: 16.0, // Even more pronounced shadow for depth
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0), // Even softer, more modern rounded corners
        ),
        // Removed direct color and shadowColor to use BoxDecoration for gradient
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surfaceContainerHighest, // Use a subtle gradient
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((255 * 0.2).round()), // More prominent shadow for the card
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(35.0), // Increased padding for content
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                child,
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
