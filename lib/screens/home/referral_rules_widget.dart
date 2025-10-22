import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class ReferralRulesWidget extends StatelessWidget {
  const ReferralRulesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isSmallScreen = screenWidth < 600;

        final verticalSpacing = isSmallScreen ? 15.0 : 20.0;
        final horizontalMargin = isSmallScreen ? 10.0 : screenWidth * 0.05;
        final titleFontSize = isSmallScreen ? 18.0 : 22.0;
        final ruleTitleFontSize = isSmallScreen ? 16.0 : 18.0;
        final ruleDescriptionFontSize = isSmallScreen ? 12.0 : 14.0;
        final ruleIconSize = isSmallScreen ? 24.0 : 30.0;
        final ruleIconContainerSize = isSmallScreen ? 40.0 : 50.0;
        final ruleCardPadding = isSmallScreen ? 15.0 : 20.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: verticalSpacing * 2),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
                child: Text(
                  'How It Works.',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.deepPurple.shade400, fontWeight: FontWeight.bold, fontSize: titleFontSize),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: verticalSpacing),
            _buildRuleItem(
              context,
              icon: HugeIcons.strokeRoundedCoins01,
              title: 'Share Your Code',
              description: 'Send your unique code to friends via WhatsApp, social media, or direct message.',
              isSmallScreen: isSmallScreen,
              iconSize: ruleIconSize,
              iconContainerSize: ruleIconContainerSize,
              cardPadding: ruleCardPadding,
              titleFontSize: ruleTitleFontSize,
              descriptionFontSize: ruleDescriptionFontSize,
              horizontalMargin: horizontalMargin,
            ),
            SizedBox(height: verticalSpacing * 0.75),
            _buildRuleItem(
              context,
              icon: HugeIcons.strokeRoundedBitcoinBag,
              title: 'They Sign Up & Get Bonus',
              description: 'Your friend joins with your code and gets an instant 5k coins welcome bonus!',
              isSmallScreen: isSmallScreen,
              iconSize: ruleIconSize,
              iconContainerSize: ruleIconContainerSize,
              cardPadding: ruleCardPadding,
              titleFontSize: ruleTitleFontSize,
              descriptionFontSize: ruleDescriptionFontSize,
              horizontalMargin: horizontalMargin,
            ),
            SizedBox(height: verticalSpacing * 0.75),
            _buildRuleItem(
              context,
              icon: HugeIcons.strokeRoundedGift,
              title: 'You Both Earn!',
              description: 'Get ₹10 instantly or 10000 Coins Instantly!',
              isSmallScreen: isSmallScreen,
              iconSize: ruleIconSize,
              iconContainerSize: ruleIconContainerSize,
              cardPadding: ruleCardPadding,
              titleFontSize: ruleTitleFontSize,
              descriptionFontSize: ruleDescriptionFontSize,
              horizontalMargin: horizontalMargin,
            ),
          ],
        );
      },
    );
  }

  Widget _buildRuleItem(
    BuildContext context, {
    required dynamic icon,
    required String title,
    required String description,
    required bool isSmallScreen,
    required double iconSize,
    required double iconContainerSize,
    required double cardPadding,
    required double titleFontSize,
    required double descriptionFontSize,
    required double horizontalMargin,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50.withAlpha(128),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: iconContainerSize,
            height: iconContainerSize,
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade100,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: HugeIcon(icon: icon, size: iconSize, color: Colors.deepPurple.shade400),
            ),
          ),
          SizedBox(width: isSmallScreen ? 10 : 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: titleFontSize),
                ),
                SizedBox(height: isSmallScreen ? 3 : 5),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54, fontSize: descriptionFontSize),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
