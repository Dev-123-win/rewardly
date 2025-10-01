import 'package:flutter/material.dart';
import 'package:rewardly_app/wrapper.dart'; // Assuming Wrapper is your main entry after onboarding

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingPages = [
    {
      'title': 'Welcome to Rewardly!',
      'description': 'Earn exciting rewards by engaging in fun activities.',
      'image': 'assets/AppLogo.png', // Use your app logo or a relevant image
    },
    {
      'title': 'Watch Ads, Earn Coins',
      'description': 'Accumulate virtual coins by watching short advertisements.',
      'image': 'assets/watch_ads.png', // Use a relevant image
    },
    {
      'title': 'Play Games, Win Big',
      'description': 'Test your skills with mini-games like Tic-Tac-Toe and Minesweeper.',
      'image': 'assets/tic_tac_toe.png', // Use a relevant image
    },
    {
      'title': 'Refer Friends, Get Bonuses',
      'description': 'Invite your friends and earn bonus coins when they join.',
      'image': 'assets/referral.png', // Use a relevant image
    },
    {
      'title': 'Redeem Your Rewards',
      'description': 'Exchange your coins for amazing prizes and exclusive offers.',
      'image': 'assets/coin.png', // Use a relevant image
    },
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _skipOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const Wrapper()),
    );
  }

  void _nextPage() {
    if (_currentPage < onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      _skipOnboarding(); // Last page, go to main app
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingPages.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return OnboardingPageContent(
                title: onboardingPages[index]['title']!,
                description: onboardingPages[index]['description']!,
                imagePath: onboardingPages[index]['image']!,
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingPages.length,
                      (index) => buildDot(index, context),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentPage != onboardingPages.length - 1)
                          TextButton(
                            onPressed: _skipOnboarding,
                            child: const Text('Skip', style: TextStyle(fontSize: 16)),
                          ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            _currentPage == onboardingPages.length - 1 ? 'Get Started' : 'Next',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 10,
      width: _currentPage == index ? 20 : 10,
      decoration: BoxDecoration(
        color: _currentPage == index ? Theme.of(context).primaryColor : Colors.grey,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

class OnboardingPageContent extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingPageContent({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: 200,
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontFamily: 'Lato',
            ),
          ),
        ],
      ),
    );
  }
}
