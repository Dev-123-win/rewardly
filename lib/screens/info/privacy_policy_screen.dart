import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy for Rewardly App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Last updated: September 29, 2025',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 24),
            Text(
              '1. Introduction',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Welcome to Rewardly! This Privacy Policy describes how Rewardly ("we," "us," or "our") collects, uses, and discloses your information when you use our mobile application (the "App").',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '2. Information We Collect',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'We collect various types of information in connection with the services we provide, including:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'a) Personal Information: When you register for an account, we may collect personal information such as your email address. If you choose to participate in certain features, we may also collect your name, profile picture, and other contact information.',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'b) Device Information: We collect information about the device you use to access our App, including device ID, operating system, and mobile network information. This is used to enforce our "one account per device" policy and for security purposes.',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'c) Usage Data: We collect information about your activity on the App, such as coins earned, ads watched, games played, and features used. This helps us improve our services and personalize your experience.',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'd) Referral Information: If you use a referral code or refer others, we collect information related to these referrals to award bonuses.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '3. How We Use Your Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'We use the information we collect for various purposes, including:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'a) To Provide and Maintain Our Service: Including managing your account, providing customer support, and processing transactions.',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'b) To Improve Our Service: We use data to understand how our App is used, identify trends, and develop new features.',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'c) For Security and Fraud Prevention: To protect the integrity of our App and prevent fraudulent activities, including enforcing our "one account per device" policy.',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'd) For Personalization: To tailor your experience, such as showing relevant ads and game recommendations.',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'e) For Communication: To send you updates, security alerts, and support messages.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '4. Disclosure of Your Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'We may share your information in the following situations:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'a) With Service Providers: We may share your information with third-party vendors to monitor and analyze the use of our Service, such as Firebase for analytics and crash reporting, and Google AdMob for advertising.',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'b) For Business Transfers: In connection with any merger, sale of company assets, financing, or acquisition of all or a portion of our business to another company.',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'c) With Affiliates: We may share your information with our affiliates, in which case we will require those affiliates to honor this Privacy Policy.',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'd) With Your Consent: We may disclose your personal information for any other purpose with your consent.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '5. Security of Your Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'The security of your Personal Information is important to us, but remember that no method of transmission over the Internet, or method of electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your Personal Information, we cannot guarantee its absolute security.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '6. Children\'s Privacy',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Our Service does not address anyone under the age of 13. We do not knowingly collect personally identifiable information from anyone under the age of 13. If you are a parent or guardian and you are aware that your child has provided us with Personal Information, please contact us. If we become aware that we have collected Personal Information from anyone under the age of 13 without verification of parental consent, we take steps to remove that information from our servers.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '7. Changes to This Privacy Policy',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page. You are advised to review this Privacy Policy periodically for any changes. Changes to this Privacy Policy are effective when they are posted on this page.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '8. Contact Us',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'If you have any questions about this Privacy Policy, please contact us:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'By email: support@rewardly.com',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
