import 'package:flutter/material.dart';

class OfferProScreen extends StatelessWidget {
  const OfferProScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40), // Space for status bar
            Text(
              'OfferPro',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Text(
              'Explore various offers and earn big rewards!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 30),
            // Placeholder for offer list
            Container(
              height: 400,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Center(
                child: Text(
                  'Offers List Placeholder',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.orange.shade700),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Implement logic to refresh offers or navigate to a specific offer
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Refreshing Offers!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
              child: Text('Refresh Offers', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
