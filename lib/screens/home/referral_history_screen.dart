import 'package:flutter/material.dart';

class ReferralHistoryScreen extends StatelessWidget {
  const ReferralHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
          title: Text(
            'Referral',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Statistics',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildStatisticCard(
                context,
                icon: Icons.access_time, // Placeholder for clock icon
                value: '0',
                description: 'Lifetime referral coins',
              ),
              const SizedBox(height: 15),
              _buildStatisticCard(
                context,
                icon: Icons.people, // Placeholder for people icon
                value: '0',
                description: 'Users referred',
              ),
              const SizedBox(height: 40),
              Text(
                'Referral History',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    // Placeholder for the image of the clipboard
                    Image.asset(
                      'assets/coin.png', // Using coin.png as a placeholder
                      height: 100,
                      width: 100,
                      color: Colors.grey.shade400, // Tint the image to look like the original
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No Invites yet!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Please try again with another keywords or\nmaybe use generic term',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticCard(BuildContext context, {required IconData icon, required String value, required String description}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.deepPurple.shade400, size: 30),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
