import 'package:flutter/material.dart';

class DailyStreamScreen extends StatelessWidget {
  const DailyStreamScreen({super.key});

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
              'Daily Stream',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Text(
              'Watch daily streams and earn exciting rewards!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 30),
            // Placeholder for stream content
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Center(
                child: Text(
                  'Live Stream Placeholder',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.red.shade700),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Implement stream watching logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Starting Daily Stream!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
              child: Text('Watch Stream', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
