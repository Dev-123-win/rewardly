import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../shared/shimmer_loading.dart';
import '../../providers/user_data_provider.dart';

enum WithdrawalMethod { bank, upi, none }

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  WithdrawalMethod _selectedMethod = WithdrawalMethod.none;
  final int _minWithdrawalCoins = 1000; // Example minimum withdrawal

  @override
  void dispose() {
    super.dispose();
  }

  void _showSnackBar(String message, {Color backgroundColor = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final userDataProvider = Provider.of<UserDataProvider>(context);

    if (user == null || userDataProvider.userData == null || userDataProvider.userData!.data() == null) {
      return const _WithdrawScreenLoading();
    }

    Map<String, dynamic> userData = userDataProvider.userData!.data() as Map<String, dynamic>;
    int currentCoins = userData['coins'] ?? 0;
    double totalBalanceINR = currentCoins / 1000.0; // Assuming 1000 coins = 1 INR

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20), // Adjusted spacing from top
              // Current Balance Display
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      '₹${totalBalanceINR.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 48,
                      ),
                    ),
                    Text(
                      'You have $currentCoins coins',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Minimum Withdrawal Progress
              Container(
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Minimum withdrawal: $_minWithdrawalCoins coins (₹${(_minWithdrawalCoins / 1000).toStringAsFixed(2)})',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: currentCoins / _minWithdrawalCoins.toDouble(),
                      backgroundColor: Colors.grey[300],
                      color: Theme.of(context).primaryColor,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Select Method',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Withdrawal Method Selection
              SizedBox(
                height: 120, // Increased height for method cards
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildMethodCard(
                      context,
                      method: WithdrawalMethod.bank,
                      icon: Icons.account_balance,
                      label: 'Bank',
                      isSelected: _selectedMethod == WithdrawalMethod.bank,
                      onTap: () {
                        setState(() {
                          _selectedMethod = WithdrawalMethod.bank;
                        });
                      },
                    ),
                    const SizedBox(width: 20), // Increased spacing between cards
                    _buildMethodCard(
                      context,
                      method: WithdrawalMethod.upi,
                      icon: Icons.payment,
                      label: 'UPI',
                      isSelected: _selectedMethod == WithdrawalMethod.upi,
                      onTap: () {
                        setState(() {
                          _selectedMethod = WithdrawalMethod.upi;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40), // Increased spacing
              // Set Up Auto-Withdrawal
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    // TODO: Implement auto-withdrawal setup logic
                    _showSnackBar('Auto-Withdrawal setup coming soon!');
                  },
                  child: Text(
                    'Set Up Auto-Withdrawal',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Placeholder for Recent Activity (no static content as per user's request)
              Center(
                child: Text(
                  'No recent activity.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildMethodCard(
    BuildContext context, {
    required WithdrawalMethod method,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: isSelected ? 10.0 : 5.0, // More distinct elevation
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0), // More rounded corners
          side: isSelected ? BorderSide(color: Theme.of(context).primaryColor, width: 3.0) : BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        child: Container(
          width: 130, // Slightly wider cards
          padding: const EdgeInsets.all(18.0), // Increased padding
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor.withAlpha((255 * 0.15).round()) : Colors.white, // More prominent selected color
            borderRadius: BorderRadius.circular(18.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 45, color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade700), // Larger icon
              const SizedBox(height: 12), // Increased spacing
              Text(
                label,
                style: Theme.of(context).textTheme.titleLarge?.copyWith( // Larger text
                      color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, // Bolder text
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _WithdrawScreenLoading extends StatelessWidget {
  const _WithdrawScreenLoading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            ShimmerLoading.rectangular(height: 150, width: double.infinity),
            const SizedBox(height: 30),
            ShimmerLoading.rectangular(height: 28, width: 200),
            const SizedBox(height: 20),
            Row(
              children: const [
                Expanded(child: ShimmerLoading.rectangular(height: 100, width: 120)),
                SizedBox(width: 15),
                Expanded(child: ShimmerLoading.rectangular(height: 100, width: 120)),
              ],
            ),
            const SizedBox(height: 30),
            ShimmerLoading.rectangular(height: 50),
            const SizedBox(height: 15),
            ShimmerLoading.rectangular(height: 50),
            const SizedBox(height: 15),
            ShimmerLoading.rectangular(height: 50),
            const SizedBox(height: 20),
            ShimmerLoading.rectangular(height: 50),
            const SizedBox(height: 10),
            Row(
              children: const [
                Expanded(child: ShimmerLoading.rectangular(height: 40)),
                SizedBox(width: 10),
                Expanded(child: ShimmerLoading.rectangular(height: 40)),
                SizedBox(width: 10),
                Expanded(child: ShimmerLoading.rectangular(height: 40)),
              ],
            ),
            const SizedBox(height: 30),
            ShimmerLoading.rectangular(height: 50),
          ],
        ),
      ),
    );
  }
}
