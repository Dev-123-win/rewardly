import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('About Us'),
        ),
        body: const SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Rewardly',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Welcome to Rewardly, your ultimate destination for earning rewards and having fun!',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Our Mission',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'At Rewardly, our mission is to provide a platform where users can easily earn virtual coins by engaging in various activities, such as watching ads, playing exciting games like Tic-Tac-Toe and Minesweeper, and inviting friends through our referral program. We believe in making earning rewards an enjoyable and accessible experience for everyone.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'What We Offer',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '•   **Earn Coins:** Watch short advertisements, play engaging mini-games, and participate in daily challenges to accumulate virtual coins.',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '•   **Referral Program:** Share your unique referral code with friends and earn bonus coins when they join and start using Rewardly.',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '•   **Exciting Games:** Test your skills with classic games like Tic-Tac-Toe and Minesweeper, with more games coming soon!',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '•   **Redeem Rewards:** Exchange your hard-earned coins for a variety of exciting rewards and prizes.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Our Vision',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'We envision a world where everyone has the opportunity to earn valuable rewards simply by doing what they enjoy. We are committed to continuously improving Rewardly, adding new features, games, and reward options to keep your experience fresh and rewarding.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Contact Us',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Have questions, feedback, or suggestions? We\'d love to hear from you!',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Email: support@rewardly.com',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Website: www.rewardly.com (Coming Soon)',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Thank you for being a part of the Rewardly community!',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    ));
  }
}
