import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Privacy Policy'),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isSmallScreen = screenWidth < 600;

            final horizontalPadding = isSmallScreen ? 16.0 : 32.0;
            final verticalSpacing = isSmallScreen ? 12.0 : 20.0;
            return SingleChildScrollView(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privacy Policy for Rewardly App',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    'Last updated: September 29, 2025',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(fontStyle: FontStyle.italic),
                  ),
                  SizedBox(height: verticalSpacing * 1.5),
                  Text(
                    '1. Introduction',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'Welcome to Rewardly! This Privacy Policy describes how Rewardly ("we," "us," or "our") collects, uses, and discloses your information when you use our mobile application (the "App").',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    '2. Information We Collect',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'We collect various types of information in connection with the services we provide, including:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'a) Personal Information: When you register for an account, we may collect personal information such as your email address. If you choose to participate in certain features, we may also collect your name, profile picture, and other contact information.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    'b) Device Information: We collect information about the device you use to access our App, including device ID, operating system, and mobile network information. This is used to enforce our "one account per device" policy and for security purposes.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    'c) Usage Data: We collect information about your activity on the App, such as coins earned, ads watched, games played, and features used. This helps us improve our services and personalize your experience.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    'd) Referral Information: If you use a referral code or refer others, we collect information related to these referrals to award bonuses.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    '3. How We Use Your Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'We use the information we collect for various purposes, including:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'a) To Provide and Maintain Our Service: Including managing your account, providing customer support, and processing transactions.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    'b) To Improve Our Service: We use data to understand how our App is used, identify trends, and develop new features.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    'c) For Security and Fraud Prevention: To protect the integrity of our App and prevent fraudulent activities, including enforcing our "one account per device" policy.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    'd) For Personalization: To tailor your experience, such as showing relevant ads and game recommendations.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    'e) For Communication: To send you updates, security alerts, and support messages.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    '4. Disclosure of Your Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'We may share your information in the following situations:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'a) With Service Providers: We may share your information with third-party vendors to monitor and analyze the use of our Service, such as Firebase for analytics and crash reporting, and Google AdMob for advertising.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    'b) For Business Transfers: In connection with any merger, sale of company assets, financing, or acquisition of all or a portion of our business to another company.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    'c) With Affiliates: We may share your information with our affiliates, in which case we will require those affiliates to honor this Privacy Policy.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    'd) With Your Consent: We may disclose your personal information for any other purpose with your consent.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    '5. Security of Your Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'The security of your Personal Information is important to us, but remember that no method of transmission over the Internet, or method of electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your Personal Information, we cannot guarantee its absolute security.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    '6. Children\'s Privacy',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'Our Service does not address anyone under the age of 13. We do not knowingly collect personally identifiable information from anyone under the age of 13. If you are a parent or guardian and you are aware that your child has provided us with Personal Information, please contact us. If we become aware that we have collected Personal Information from anyone under the age of 13 without verification of parental consent, we take steps to remove that information from our servers.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    '7. Changes to This Privacy Policy',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page. You are advised to review this Privacy Policy periodically for any changes. Changes to this Privacy Policy are effective when they are posted on this page.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: verticalSpacing),
                  Text(
                    '8. Contact Us',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'If you have any questions about this Privacy Policy, please contact us:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: verticalSpacing * 0.5),
                  Text(
                    'By email: support@rewardly.com',
                    style: Theme.of(context).textTheme.bodyLarge,
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
