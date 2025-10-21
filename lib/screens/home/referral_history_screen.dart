import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class ReferralHistoryScreen extends StatelessWidget {
  const ReferralHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
          title: Text(
            'Referral',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isSmallScreen = screenWidth < 600;

            final horizontalPadding = isSmallScreen ? 20.0 : screenWidth * 0.1;
            final verticalSpacing = isSmallScreen ? 15.0 : 25.0;
            final titleFontSize = isSmallScreen ? 20.0 : 24.0;
            final subtitleFontSize = isSmallScreen ? 16.0 : 18.0;
            final iconSize = isSmallScreen ? 24.0 : 30.0;
            final cardPadding = isSmallScreen ? 15.0 : 20.0;
            final cardIconContainerSize = isSmallScreen ? 40.0 : 50.0;
            final emptyStateIconSize = isSmallScreen ? 80.0 : 100.0;
            final emptyStateTitleFontSize = isSmallScreen ? 20.0 : 24.0;
            final emptyStateMessageFontSize = isSmallScreen ? 14.0 : 16.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Statistics',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: titleFontSize),
                  ),
                  SizedBox(height: verticalSpacing),
                  _buildStatisticCard(
                    context,
                    icon: HugeIcons.strokeRoundedTime01,
                    value: '0',
                    description: 'Lifetime referral coins',
                    isSmallScreen: isSmallScreen,
                    iconSize: iconSize,
                    cardIconContainerSize: cardIconContainerSize,
                    cardPadding: cardPadding,
                    valueFontSize: subtitleFontSize,
                    descriptionFontSize: isSmallScreen ? 12.0 : 14.0,
                  ),
                  SizedBox(height: verticalSpacing * 0.75),
                  _buildStatisticCard(
                    context,
                    icon: HugeIcons.strokeRoundedUser,
                    value: '0',
                    description: 'Users referred',
                    isSmallScreen: isSmallScreen,
                    iconSize: iconSize,
                    cardIconContainerSize: cardIconContainerSize,
                    cardPadding: cardPadding,
                    valueFontSize: subtitleFontSize,
                    descriptionFontSize: isSmallScreen ? 12.0 : 14.0,
                  ),
                  SizedBox(height: verticalSpacing * 2),
                  Text(
                    'Referral History',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: titleFontSize),
                  ),
                  SizedBox(height: verticalSpacing),
                  Center(
                    child: Column(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedClipboard,
                          size: emptyStateIconSize,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: verticalSpacing),
                        Text(
                          'No Invites yet!',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: emptyStateTitleFontSize),
                        ),
                        SizedBox(height: verticalSpacing * 0.5),
                        Text(
                          'Please try again with another keywords or\nmaybe use generic term',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54, fontSize: emptyStateMessageFontSize),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatisticCard(
    BuildContext context, {
    required dynamic icon,
    required String value,
    required String description,
    required bool isSmallScreen,
    required double iconSize,
    required double cardIconContainerSize,
    required double cardPadding,
    required double valueFontSize,
    required double descriptionFontSize,
  }) {
    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50.withAlpha(128),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: cardIconContainerSize,
            height: cardIconContainerSize,
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: HugeIcon(icon: icon, color: Colors.deepPurple.shade400, size: iconSize),
          ),
          SizedBox(width: isSmallScreen ? 10 : 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: valueFontSize),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54, fontSize: descriptionFontSize),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
