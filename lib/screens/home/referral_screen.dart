import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rewardly_app/providers/user_data_provider.dart';
// import 'package:share_plus/share_plus.dart'; // Removed share_plus import
import 'package:rewardly_app/shared/shimmer_loading.dart';

class ReferralScreenLoading extends StatelessWidget {
  const ReferralScreenLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Align(
              alignment: Alignment.topLeft,
              child: ShimmerLoading.circular(width: 40, height: 40),
            ),
            const SizedBox(height: 10),
            ShimmerLoading.circular(width: 150, height: 150),
            const SizedBox(height: 30),
            ShimmerLoading.rectangular(height: 24, width: double.infinity),
            const SizedBox(height: 15),
            ShimmerLoading.rectangular(height: 16, width: double.infinity),
            const SizedBox(height: 40),
            ShimmerLoading.rectangular(height: 20, width: 150),
            const SizedBox(height: 10),
            ShimmerLoading.rectangular(height: 60, width: double.infinity),
            const SizedBox(height: 30),
            ShimmerLoading.rectangular(height: 50, width: double.infinity),
          ],
        ),
      ),
    );
  }
}

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final userData = userDataProvider.userData;

    if (userData == null) {
      return const ReferralScreenLoading(); // Show loading indicator
    }

    final referralCode = userData['referral_code'] ?? 'Loading...';

    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar removed as per request
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Custom header to replace AppBar functionality
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(height: 10),
            Icon(
              Icons.people_alt_rounded,
              size: 150,
              color: Colors.deepPurple.shade300,
            ),
            const SizedBox(height: 30),
            Text(
              'Invite your friends and earn rewards!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black87),
            ),
            const SizedBox(height: 15),
            Text(
              'Share your referral code with your friends and you both will get 500 coins when they sign up!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 40),
            Text(
              'Your Referral Code',
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
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                child: Container(
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    border: Border.all(color: Colors.grey.withAlpha(51)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        referralCode,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.deepPurple, letterSpacing: 2),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.copy, color: Colors.deepPurple),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.share),
              label: Text('Share Now', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sharing functionality is currently disabled.')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
