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
        body: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isSmallScreen = screenWidth < 600;

            final horizontalPadding = isSmallScreen ? 16.0 : 32.0;
            final verticalSpacing = isSmallScreen ? 12.0 : 20.0;
            final titleFontSize = isSmallScreen ? 22.0 : 28.0;
            final subtitleFontSize = isSmallScreen ? 18.0 : 22.0;
            final bodyFontSize = isSmallScreen ? 15.0 : 17.0;

            return SingleChildScrollView(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Rewardly',
                    style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    'Welcome to Rewardly, your ultimate destination for earning rewards and having fun!',
                    style: TextStyle(fontSize: bodyFontSize),
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    'Our Mission',
                    style: TextStyle(fontSize: subtitleFontSize, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'At Rewardly, our mission is to provide a platform where users can easily earn virtual coins by engaging in various activities, such as watching ads, playing exciting games like Tic-Tac-Toe and Minesweeper, and inviting friends through our referral program. We believe in making earning rewards an enjoyable and accessible experience for everyone.',
                    style: TextStyle(fontSize: bodyFontSize),
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    'What We Offer',
                    style: TextStyle(fontSize: subtitleFontSize, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    '•   **Earn Coins:** Watch short advertisements, play engaging mini-games, and participate in daily challenges to accumulate virtual coins.',
                    style: TextStyle(fontSize: bodyFontSize),
                  ),
                  Text(
                    '•   **Referral Program:** Share your unique referral code with friends and earn bonus coins when they join and start using Rewardly.',
                    style: TextStyle(fontSize: bodyFontSize),
                  ),
                  Text(
                    '•   **Exciting Games:** Test your skills with classic games like Tic-Tac-Toe and Minesweeper, with more games coming soon!',
                    style: TextStyle(fontSize: bodyFontSize),
                  ),
                  Text(
                    '•   **Redeem Rewards:** Exchange your hard-earned coins for a variety of exciting rewards and prizes.',
                    style: TextStyle(fontSize: bodyFontSize),
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    'Our Vision',
                    style: TextStyle(fontSize: subtitleFontSize, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'We envision a world where everyone has the opportunity to earn valuable rewards simply by doing what they enjoy. We are committed to continuously improving Rewardly, adding new features, games, and reward options to keep your experience fresh and rewarding.',
                    style: TextStyle(fontSize: bodyFontSize),
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    'Contact Us',
                    style: TextStyle(fontSize: subtitleFontSize, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'Have questions, feedback, or suggestions? We\'d love to hear from you!',
                    style: TextStyle(fontSize: bodyFontSize),
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'Email: support@rewardly.com',
                    style: TextStyle(fontSize: bodyFontSize),
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'Website: www.rewardly.com (Coming Soon)',
                    style: TextStyle(fontSize: bodyFontSize),
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    'Thank you for being a part of the Rewardly community!',
                    style: TextStyle(fontSize: bodyFontSize, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
