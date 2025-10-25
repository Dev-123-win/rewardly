import 'package:flutter/material.dart';
import '../../design_system/design_system.dart';

class OnboardingEnhanced extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingEnhanced({required this.onComplete, super.key});

  @override
  State<OnboardingEnhanced> createState() => _OnboardingEnhancedState();
}

class _OnboardingEnhancedState extends State<OnboardingEnhanced> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildOnboardingPage(
                    title: 'Welcome to Rewardly',
                    subtitle: 'Earn coins by playing games, watching ads, and more!',
                    icon: Icons.star,
                    color: DesignSystem.primary,
                  ),
                  _buildOnboardingPage(
                    title: 'Multiple Ways to Earn',
                    subtitle: 'Spin the wheel, play games, watch ads, read content, and refer friends.',
                    icon: Icons.trending_up,
                    color: DesignSystem.secondary,
                  ),
                  _buildOnboardingPage(
                    title: 'Withdraw Anytime',
                    subtitle: 'Convert your coins to real money via bank transfer or UPI.',
                    icon: Icons.account_balance_wallet,
                    color: DesignSystem.success,
                  ),
                  _buildOnboardingPage(
                    title: 'Refer & Earn More',
                    subtitle: 'Invite friends and earn bonus coins for every successful referral.',
                    icon: Icons.people,
                    color: DesignSystem.accent,
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(DesignSystem.spacing6),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (index) => Container(
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        margin: EdgeInsets.symmetric(horizontal: DesignSystem.spacing2),
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? DesignSystem.primary
                              : DesignSystem.outline,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: DesignSystem.spacing6),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < 3) {
                          _pageController.nextPage(
                            duration: DesignSystem.durationNormal,
                            curve: Curves.easeInOut,
                          );
                        } else {
                          widget.onComplete();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignSystem.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
                        ),
                      ),
                      child: Text(
                        _currentPage < 3 ? 'Next' : 'Get Started',
                        style: DesignSystem.titleLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 60, color: color),
        ),
        SizedBox(height: DesignSystem.spacing7),
        Text(
          title,
          style: DesignSystem.displaySmall.copyWith(
            color: DesignSystem.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: DesignSystem.spacing4),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: DesignSystem.spacing6),
          child: Text(
            subtitle,
            style: DesignSystem.bodyLarge.copyWith(
              color: DesignSystem.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
