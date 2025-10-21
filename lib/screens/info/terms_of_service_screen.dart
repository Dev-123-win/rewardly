import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Terms of Service'),
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
                    'Terms of Service for Rewardly App',
                    style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    'Last updated: September 29, 2025',
                    style: TextStyle(fontSize: bodyFontSize - 2, fontStyle: FontStyle.italic),
                  ),
                  SizedBox(height: verticalSpacing * 1.5),
                  Text(
                    '1. Acceptance of Terms',
                    style: TextStyle(fontSize: subtitleFontSize, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'By accessing or using the Rewardly mobile application (the "App"), you agree to be bound by these Terms of Service ("Terms"). If you do not agree to these Terms, do not use our App.',
                    style: TextStyle(fontSize: bodyFontSize),
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    '2. Changes to Terms',
                    style: TextStyle(fontSize: subtitleFontSize, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'We reserve the right to modify or replace these Terms at any time. We will provide notice of any changes by posting the new Terms on this page. Your continued use of the App after any such changes constitutes your acceptance of the new Terms.',
                    style: TextStyle(fontSize: bodyFontSize),
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    '3. Account Registration',
                    style: TextStyle(fontSize: subtitleFontSize, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'You must be at least 13 years old to create an account. You agree to provide accurate and complete information during registration. You are responsible for maintaining the confidentiality of your account and password.',
                    style: TextStyle(fontSize: bodyFontSize),
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    '4. One Account Per Device Policy',
                    style: TextStyle(fontSize: subtitleFontSize, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'To ensure fair play and prevent fraud, Rewardly enforces a strict "one account per device" policy. Attempting to create or use multiple accounts on a single device may result in the suspension or termination of all associated accounts and forfeiture of any earned rewards.',
                    style: TextStyle(fontSize: bodyFontSize),
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    '5. Earning and Redeeming Rewards',
                    style: TextStyle(fontSize: subtitleFontSize, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'Rewardly allows you to earn virtual coins through various activities (e.g., watching ads, playing games, referrals). These coins have no real-world value and can only be redeemed for rewards offered within the App. Rewardly reserves the right to modify the value of coins, the types of activities that earn coins, and the available rewards at any time without prior notice.',
                    style: TextStyle(fontSize: bodyFontSize),
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    '6. Prohibited Activities',
                    style: TextStyle(fontSize: subtitleFontSize, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'You agree not to engage in any of the following prohibited activities:',
                    style: TextStyle(fontSize: bodyFontSize),
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'a) Fraudulent activity, including but not limited to using bots, scripts, or any automated means to earn coins or manipulate the App.',
                    style: TextStyle(fontSize: bodyFontSize),
                  ),
                  Text(
                    'b) Creating multiple accounts on a single device.',
                    style: TextStyle(fontSize: bodyFontSize),
                  ),
                  Text(
                    'c) Attempting to gain unauthorized access to the App or its related systems.',
                    style: TextStyle(fontSize: bodyFontSize),
                  ),
                  Text(
                    'd) Distributing malware or other harmful code.',
                    style: TextStyle(fontSize: bodyFontSize),
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    '7. Termination',
                    style: TextStyle(fontSize: subtitleFontSize, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'We may terminate or suspend your account immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach these Terms. Upon termination, your right to use the App will immediately cease.',
                    style: TextStyle(fontSize: bodyFontSize),
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    '8. Disclaimer of Warranties',
                    style: TextStyle(fontSize: subtitleFontSize, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'The App is provided on an "AS IS" and "AS AVAILABLE" basis. We make no warranties, expressed or implied, regarding the operation or availability of the App, or the information, content, and materials included therein.',
                    style: TextStyle(fontSize: bodyFontSize),
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    '9. Limitation of Liability',
                    style: TextStyle(fontSize: subtitleFontSize, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'In no event shall Rewardly, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from your access to or use of or inability to access or use the Service.',
                    style: TextStyle(fontSize: bodyFontSize),
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    '10. Governing Law',
                    style: TextStyle(fontSize: subtitleFontSize, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'These Terms shall be governed and construed in accordance with the laws of [Your Country/State], without regard to its conflict of law provisions.',
                    style: TextStyle(fontSize: bodyFontSize),
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    '11. Contact Us',
                    style: TextStyle(fontSize: subtitleFontSize, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'If you have any questions about these Terms of Service, please contact us:',
                    style: TextStyle(fontSize: bodyFontSize),
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'By email: support@rewardly.com',
                    style: TextStyle(fontSize: bodyFontSize),
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
