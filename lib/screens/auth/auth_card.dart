import 'package:flutter/material.dart';

class AuthCard extends StatelessWidget {
  final Widget child;

  const AuthCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20.0),
        elevation: 4.0, // Reduced elevation for a lighter feel
        color: Colors.white, // White background for the card
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Slightly less rounded corners
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              child,
            ],
          ),
        ),
      ),
    );
  }
}
