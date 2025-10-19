import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart'; // Added share_plus import
import '../../providers/user_data_provider.dart';
import '../../shared/shimmer_loading.dart';
import 'referral_rules_widget.dart'; // Import the new widget
import 'referral_history_screen.dart'; // Import the referral history screen
import 'package:hugeicons/hugeicons.dart';

class ReferralScreenLoading extends StatelessWidget {
  const ReferralScreenLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
        title: ShimmerLoading.rectangular(height: 24, width: 120),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            ShimmerLoading.circular(width: 120, height: 120),
            const SizedBox(height: 30),
            ShimmerLoading.rectangular(height: 28, width: 250),
            const SizedBox(height: 15),
            ShimmerLoading.rectangular(height: 18, width: 300),
            const SizedBox(height: 40),
            ShimmerLoading.rectangular(height: 22, width: 180),
            const SizedBox(height: 10),
            ShimmerLoading.rectangular(height: 60, width: double.infinity),
            const SizedBox(height: 30),
            ShimmerLoading.rectangular(height: 50, width: double.infinity),
          ],
        ),
      ),
    ));
  }
}

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);

    if (userDataProvider.isLoading) {
      return const ReferralScreenLoading();
    }

    final userData = userDataProvider.userData;

    if (userData == null) {
      return const ReferralScreenLoading();
    }

    final data = userData.data() as Map<String, dynamic>?;
    final referralCode = data?['referralCode'] as String? ?? 'N/A';
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'We Share More.\nWe Earn More.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20), // Add some spacing after the title
            Text(
              'Invite your Friends, Win Rewards!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.deepPurple,
                fontFamily: 'Calinastiya', // Apply custom font
                fontWeight: FontWeight.bold,
                fontSize: 28, // Reduced font size
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Refer and Win. Share with Friends, Unlock Exciting Rewards!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 30),
            Image.asset(
              'assets/referral.png', // Use the provided image
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),
            Text(
              'Copy your referral code', // Rephrased text
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: referralCode));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Referral code copied to clipboard!')),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25.0),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      referralCode,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.deepPurple, letterSpacing: 2, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    HugeIcon(icon: HugeIcons.strokeRoundedCopy01, color: Colors.deepPurple.shade400, size: 24),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Share.share('Join Rewardly and earn rewards! Use my referral code: $referralCode'); // FIX: Using Share.share
              },
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedShare01, color: Colors.white, size: 24),
              label: Text(
                'Share with Friends',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
              ),
            ),
            const ReferralRulesWidget(), // Add the new referral rules widget
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReferralHistoryScreen()),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.lightBlue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Here is your\nReferral earning',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Multiply Your Rewards\nWith Referrals! Refer, E...',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedTime01,
                          size: 60,
                          color: Colors.deepPurple.shade400,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Click Here\nTo See You...',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blue.shade700, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
