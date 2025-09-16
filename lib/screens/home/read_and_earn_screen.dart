import 'package:flutter/material.dart';

class ReadAndEarnScreen extends StatelessWidget {
  const ReadAndEarnScreen({super.key});

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
              'Read & Earn',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Text(
              'Read interesting articles and earn coins!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 30),
            // Placeholder for article list
            Container(
              height: 400,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.brown.shade100,
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(color: Colors.brown.shade300),
              ),
              child: Center(
                child: Text(
                  'Articles List Placeholder',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.brown.shade700),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Implement logic to load more articles or navigate to a specific article
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Loading More Articles!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
              child: Text('Read More', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
