import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rewardly_app/ad_reward_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Import for loading indicator

class EarnCoinsScreen extends StatefulWidget {
  const EarnCoinsScreen({super.key});

  @override
  State<EarnCoinsScreen> createState() => _EarnCoinsScreenState();
}

class _EarnCoinsScreenState extends State<EarnCoinsScreen> {
  late AdRewardService _adRewardService;
  bool _isAdLoading = false; // State to manage loading indicator

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<User?>(context);
    _adRewardService = AdRewardService(user);
    _loadAd(); // Load ad when screen initializes or dependencies change
  }

  void _loadAd() async {
    if (!mounted) return; // Ensure widget is still in the tree
    setState(() {
      _isAdLoading = true;
    });
    await _adRewardService.loadRewardedAd();
    if (!mounted) return;
    setState(() {
      _isAdLoading = false;
    });
  }

  // Data for ad cards - 10 cards, each offering 100 coins
  final List<Map<String, dynamic>> _adOffers = List.generate(
    10,
    (index) => {'title': 'Watch an ad', 'points': 100},
  );

  void _watchAd(int points) {
    _adRewardService.showRewardedAd(
      onRewardEarned: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You earned $points points!')),
        );
        // Optionally, reload ads or update UI after reward
        _loadAd();
      },
      onAdFailedToLoad: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load ad. Please try again.')),
        );
        _loadAd(); // Try reloading ad
      },
      onAdFailedToShow: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to show ad. Please try again.')),
        );
        _loadAd(); // Try reloading ad
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Watch & Earn', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isAdLoading
          ? const Center(
              child: SpinKitCircle(
                color: Colors.deepPurple,
                size: 50.0,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _adOffers.length,
              itemBuilder: (context, index) {
                final offer = _adOffers[index];
                return _AdCard(
                  title: offer['title'],
                  points: offer['points'],
                  onWatchAd: () => _watchAd(offer['points']),
                );
              },
            ),
    );
  }
}

class _AdCard extends StatelessWidget {
  final String title;
  final int points;
  final VoidCallback onWatchAd;

  const _AdCard({
    required this.title,
    required this.points,
    required this.onWatchAd,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          gradient: LinearGradient(
            colors: [
              Colors.white.withAlpha((0.8 * 255).round()),
              Colors.white.withAlpha((0.5 * 255).round()),
              Colors.purple.withAlpha((0.1 * 255).round()), // Light purple hint
              Colors.yellow.withAlpha((0.1 * 255).round()), // Light yellow hint
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.monetization_on, color: Colors.green[700], size: 20),
                      const SizedBox(width: 5),
                      Text(
                        '$points Points',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.green[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onWatchAd,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen, // Green button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Watch Ad ($points Coins)',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
