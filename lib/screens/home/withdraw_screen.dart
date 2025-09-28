import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rewardly_app/shared/shimmer_loading.dart';
import 'package:rewardly_app/providers/user_data_provider.dart';

enum WithdrawalMethod { bank, upi, none }

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  WithdrawalMethod _selectedMethod = WithdrawalMethod.none;
  final int _minWithdrawalCoins = 1000; // Example minimum withdrawal

  // Text editing controllers for withdrawal details
  final TextEditingController _bankAccountController = TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();
  final TextEditingController _accountHolderNameController = TextEditingController();
  final TextEditingController _upiIdController = TextEditingController();

  @override
  void dispose() {
    _bankAccountController.dispose();
    _ifscCodeController.dispose();
    _accountHolderNameController.dispose();
    _upiIdController.dispose();
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
              const SizedBox(height: 30),
              // Current Balance Display
              Center(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Your Current Balance',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '₹${totalBalanceINR.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 52,
                          ),
                        ),
                        Text(
                          '($currentCoins coins)',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Minimum Withdrawal Progress
              Container(
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.05 * 255).round()),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Withdrawal Goal: $_minWithdrawalCoins coins (₹${(_minWithdrawalCoins / 1000).toStringAsFixed(2)})',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: currentCoins / _minWithdrawalCoins.toDouble(),
                        backgroundColor: Colors.grey[300],
                        color: Theme.of(context).primaryColor,
                        minHeight: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${((currentCoins / _minWithdrawalCoins.toDouble()) * 100).toStringAsFixed(0)}% towards your goal',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Choose Withdrawal Method',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),
              // Withdrawal Method Selection
              Column(
                children: [
                  _buildMethodCard(
                    context,
                    method: WithdrawalMethod.bank,
                    icon: Icons.account_balance,
                    label: 'Withdraw to Bank',
                    isSelected: _selectedMethod == WithdrawalMethod.bank,
                    onTap: () {
                      setState(() {
                        _selectedMethod = WithdrawalMethod.bank;
                      });
                    },
                  ),
                  const SizedBox(height: 15), // Vertical spacing between cards
                  _buildMethodCard(
                    context,
                    method: WithdrawalMethod.upi,
                    icon: Icons.payment,
                    label: 'Withdraw to UPI',
                    isSelected: _selectedMethod == WithdrawalMethod.upi,
                    onTap: () {
                      setState(() {
                        _selectedMethod = WithdrawalMethod.upi;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40), // Increased spacing

              // Conditional Input Fields
              if (_selectedMethod == WithdrawalMethod.bank) _buildBankDetailsInput(context),
              if (_selectedMethod == WithdrawalMethod.upi) _buildUpiDetailsInput(context),

              const SizedBox(height: 40),

              // Withdraw Button
              if (_selectedMethod != WithdrawalMethod.none)
                Center(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: ElevatedButton(
                      onPressed: () => _processWithdrawal(currentCoins),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Initiate Withdrawal',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 40),
              // Set Up Auto-Withdrawal
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    // TODO: Implement auto-withdrawal setup logic
                    _showSnackBar('Auto-Withdrawal setup coming soon!');
                  },
                  icon: Icon(Icons.auto_mode, color: Theme.of(context).primaryColor),
                  label: Text(
                    'Set Up Auto-Withdrawal',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).primaryColor, decoration: TextDecoration.underline),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
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

  Widget _buildBankDetailsInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Bank Account Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _bankAccountController,
          decoration: InputDecoration(
            labelText: 'Bank Account Number',
            hintText: 'e.g., 1234567890',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            prefixIcon: const Icon(Icons.account_balance_wallet, color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _ifscCodeController,
          decoration: InputDecoration(
            labelText: 'IFSC Code',
            hintText: 'e.g., HDFC0001234',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            prefixIcon: const Icon(Icons.code, color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _accountHolderNameController,
          decoration: InputDecoration(
            labelText: 'Account Holder Name',
            hintText: 'e.g., John Doe',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            prefixIcon: const Icon(Icons.person, color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  Widget _buildUpiDetailsInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter UPI Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _upiIdController,
          decoration: InputDecoration(
            labelText: 'UPI ID',
            hintText: 'e.g., yourname@bank',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            prefixIcon: const Icon(Icons.qr_code, color: Colors.grey),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  void _processWithdrawal(int currentCoins) {
    if (currentCoins < _minWithdrawalCoins) {
      _showSnackBar('You need at least $_minWithdrawalCoins coins to withdraw.', backgroundColor: Colors.red);
      return;
    }

    String message = '';
    if (_selectedMethod == WithdrawalMethod.bank) {
      if (_bankAccountController.text.isEmpty ||
          _ifscCodeController.text.isEmpty ||
          _accountHolderNameController.text.isEmpty) {
        _showSnackBar('Please fill all bank details.', backgroundColor: Colors.red);
        return;
      }
      message = 'Bank Withdrawal Request:\n'
          'Account: ${_bankAccountController.text}\n'
          'IFSC: ${_ifscCodeController.text}\n'
          'Holder: ${_accountHolderNameController.text}\n'
          'Amount: ${currentCoins / 1000.0} INR';
    } else if (_selectedMethod == WithdrawalMethod.upi) {
      if (_upiIdController.text.isEmpty) {
        _showSnackBar('Please enter your UPI ID.', backgroundColor: Colors.red);
        return;
      }
      message = 'UPI Withdrawal Request:\n'
          'UPI ID: ${_upiIdController.text}\n'
          'Amount: ${currentCoins / 1000.0} INR';
    } else {
      _showSnackBar('Please select a withdrawal method.', backgroundColor: Colors.red);
      return;
    }

    _showSnackBar('Withdrawal request submitted!\n$message');
    // TODO: Integrate with actual WithdrawalService
    // Clear fields after submission
    _bankAccountController.clear();
    _ifscCodeController.clear();
    _accountHolderNameController.clear();
    _upiIdController.clear();
    setState(() {
      _selectedMethod = WithdrawalMethod.none; // Reset selection
    });
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: double.infinity, // Full width for list-type cards
        decoration: BoxDecoration(
          color: Colors.white, // Consistent background color
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
                      color: Color.fromARGB((255 * 0.05).round(), 0, 0, 0),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0), // Adjusted padding
          child: Row(
            children: [
              Icon(
                icon,
                size: 30, // Adjusted icon size
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade700,
              ),
              const SizedBox(width: 15), // Spacing between icon and text
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 16,
                    ),
              ),
              const Spacer(), // Pushes content to the left and right
              if (isSelected)
                Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 24),
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
