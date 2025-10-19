import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class ReferralRulesWidget extends StatelessWidget {
  const ReferralRulesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Center(
          child: Text(
            'Learn more about how it works.',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.deepPurple.shade400, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        _buildRuleItem(
          context,
          icon: HugeIcons.strokeRoundedCoins01,
          title: 'What I will get?',
          description: 'Get 50% lifetime commission of your friends referral rewards.',
        ),
        const SizedBox(height: 15),
        _buildRuleItem(
          context,
          icon: HugeIcons.strokeRoundedCoinbase,
          title: 'What will my friends get?',
          description: 'Your friend will get signup bonus upon joining.',
        ),
        const SizedBox(height: 15),
        _buildRuleItem(
          context,
          icon: HugeIcons.strokeRoundedGift,
          title: 'What are terms of invites?',
          description: 'Your friends need to get some coins either by playing game or finishing tasks or answering surveys.',
        ),
      ],
    );
  }

  Widget _buildRuleItem(BuildContext context, {required dynamic icon, required String title, required String description}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50.withAlpha(128),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade100,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Center(
              child: HugeIcon(icon: icon, size: 30, color: Colors.deepPurple.shade400),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
