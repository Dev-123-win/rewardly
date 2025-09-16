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
      return const ReferralScreenLoading();
    }

    final referralCode = userData['referral_code'] ?? 'Loading...';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Invite Friends',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            Icon(
              Icons.card_giftcard, // Changed icon to something more referral-like
              size: 120,
              color: Colors.deepPurple.shade400,
            ),
            const SizedBox(height: 30),
            Text(
              'Share the love, earn rewards!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Text(
              'Invite your friends to Rewardly using your unique code and both of you will get 500 coins!',
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
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
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
                    Icon(Icons.copy, color: Colors.deepPurple.shade400),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.share, color: Colors.white),
              label: Text('Share Now', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sharing functionality is currently disabled.')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple.shade400,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                elevation: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
