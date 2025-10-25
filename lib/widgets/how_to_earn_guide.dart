import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../design_system/design_system.dart';
import '../design_system/app_icons.dart';

class HowToEarnGuide extends StatelessWidget {
  const HowToEarnGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(DesignSystem.spacing4),
      padding: EdgeInsets.all(DesignSystem.spacing5),
      decoration: BoxDecoration(
        color: DesignSystem.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
        border: Border.all(
          color: DesignSystem.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: DesignSystem.primary,
                size: AppIcons.sizeMedium,
              ),
              SizedBox(width: DesignSystem.spacing3),
              Text(
                'How to Earn Coins',
                style: DesignSystem.headlineMedium.copyWith(
                  color: DesignSystem.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSystem.spacing4),
          _buildEarnMethod(
            icon: AppIcons.spinWheel,
            title: 'Spin & Win',
            description: 'Get free spins daily or watch ads for bonus spins',
            coins: '50-500',
          ),
          SizedBox(height: DesignSystem.spacing3),
          _buildEarnMethod(
            icon: AppIcons.earn,
            title: 'Watch Ads',
            description: 'Watch short video ads and earn coins instantly',
            coins: '10-50',
          ),
          SizedBox(height: DesignSystem.spacing3),
          _buildEarnMethod(
            icon: AppIcons.invite,
            title: 'Refer Friends',
            description: 'Invite friends and earn bonus coins per referral',
            coins: '100+',
          ),
          SizedBox(height: DesignSystem.spacing3),
          _buildEarnMethod(
            icon: AppIcons.help,
            title: 'Play Games',
            description: 'Win coins by playing Tic Tac Toe and Minesweeper',
            coins: '25-100',
          ),
        ],
      ),
    );
  }

  Widget _buildEarnMethod({
    required List<List<dynamic>> icon,
    required String title,
    required String description,
    required String coins,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: DesignSystem.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
          ),
          child: Center(
            child: HugeIcon(
              icon: icon,
              size: AppIcons.sizeSmall,
              color: DesignSystem.primary,
            ),
          ),
        ),
        SizedBox(width: DesignSystem.spacing3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: DesignSystem.titleMedium.copyWith(
                  color: DesignSystem.textPrimary,
                ),
              ),
              SizedBox(height: DesignSystem.spacing1),
              Text(
                description,
                style: DesignSystem.bodySmall.copyWith(
                  color: DesignSystem.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: DesignSystem.spacing3,
            vertical: DesignSystem.spacing2,
          ),
          decoration: BoxDecoration(
            color: DesignSystem.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
          ),
          child: Text(
            '+$coins',
            style: DesignSystem.labelMedium.copyWith(
              color: DesignSystem.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
