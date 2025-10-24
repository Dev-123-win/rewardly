import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Import Lottie package

class ExitConfirmationOverlay extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onExit; // New: Callback for exiting the app

  const ExitConfirmationOverlay({
    super.key,
    required this.onCancel,
    required this.onExit, // New: Make onExit required
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7, // Match the height from Wrapper
      decoration: BoxDecoration(
        color: Colors.white, // White background as per image
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.15).round()),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Lottie.asset(
              'assets/lottie/ufo exit animation.json', // UFO Lottie animation
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 25),
            Text(
              'Exit the game?',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.black87, // Dark text for contrast on white
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Text(
              'Are you sure want to exit the game!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onExit, // Use the new onExit callback
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8A2BE2), // Purple color from image
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Exit'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onCancel, // Use the onCancel callback
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade700, // Grey color from image
                  backgroundColor: Colors.grey.shade200, // Light grey background for cancel
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: Theme.of(context).textTheme.titleLarge,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
