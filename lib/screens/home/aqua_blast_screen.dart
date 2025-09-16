import 'package:flutter/material.dart';

class AquaBlastScreen extends StatelessWidget {
  const AquaBlastScreen({super.key});

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
              'Aqua Blast',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Text(
              'Dive into the Aqua Blast game and earn coins!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 30),
            // Placeholder for game content
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(color: Colors.blue.shade300),
              ),
              child: Center(
                child: Text(
                  'Game Area Placeholder',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.blue.shade700),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Implement game launch logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Launching Aqua Blast Game!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
              child: Text('Play Now', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
