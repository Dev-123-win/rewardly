import 'package:flutter/material.dart';
import '../../wrapper.dart'; // Assuming Wrapper is your main entry after onboarding
import 'package:image_loader_flutter/image_loader_flutter.dart';

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
    return SafeArea(
      child: Scaffold(
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
                              child: Text('Skip', style: Theme.of(context).textTheme.bodyLarge),
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
                              style: Theme.of(context).textTheme.bodyLarge,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isSmallScreen = screenWidth < 600;

        final imageSize = isSmallScreen ? 150.0 : 200.0;
        final verticalSpacing = isSmallScreen ? 30.0 : 40.0;
        final horizontalPadding = isSmallScreen ? 20.0 : 40.0;

        return Padding(
          padding: EdgeInsets.all(horizontalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ImageLoaderFlutterWidgets(
                image: imagePath,
                height: imageSize,
                width: imageSize,
                fit: BoxFit.contain,
                circle: false,
                radius: 0.0,
                onTap: false,
              ),
              SizedBox(height: verticalSpacing),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              SizedBox(height: verticalSpacing * 0.5),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }
}
