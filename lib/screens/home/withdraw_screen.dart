import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rewardly_app/shared/shimmer_loading.dart';
import 'package:rewardly_app/widgets/custom_button.dart';
import 'package:rewardly_app/providers/user_data_provider.dart';
import 'package:rewardly_app/withdrawal_service.dart';

enum WithdrawalMethod { bank, upi, none }

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _formKey = GlobalKey<FormState>();
  WithdrawalMethod _selectedMethod = WithdrawalMethod.none;
  bool _isLoading = false;
  final WithdrawalService _withdrawalService = WithdrawalService();

  // Controllers for Bank details
  final TextEditingController _bankAccountNumberController = TextEditingController();
  final TextEditingController _accountHolderNameController = TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();

  // Controllers for UPI details
  final TextEditingController _upiIdController = TextEditingController();
  final TextEditingController _confirmUpiIdController = TextEditingController();

  // Amount controller
  final TextEditingController _amountController = TextEditingController();

  final int _minWithdrawalCoins = 1000; // Example minimum withdrawal

  @override
  void dispose() {
    _bankAccountNumberController.dispose();
    _accountHolderNameController.dispose();
    _ifscCodeController.dispose();
    _upiIdController.dispose();
    _confirmUpiIdController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {Color backgroundColor = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  void _setAmountPercentage(int percentage, int currentCoins) {
    double amount = (currentCoins * percentage / 100).floorToDouble();
    _amountController.text = amount.toStringAsFixed(0);
  }

  Future<void> _submitWithdrawal() async {
    if (_formKey.currentState!.validate()) {
      final user = Provider.of<User?>(context, listen: false);
      final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
      final userData = userDataProvider.userData?.data() as Map<String, dynamic>?;
      final int currentCoins = userData?['coins'] ?? 0;

      if (user == null) {
        _showSnackBar('User not logged in.', backgroundColor: Colors.red);
        return;
      }

      final int amount = int.tryParse(_amountController.text) ?? 0;

      if (amount < _minWithdrawalCoins) {
        _showSnackBar('Minimum withdrawal is $_minWithdrawalCoins coins.', backgroundColor: Colors.red);
        return;
      }
      if (amount > currentCoins) {
        _showSnackBar('Insufficient coins.', backgroundColor: Colors.red);
        return;
      }

      String paymentMethodName = '';
      Map<String, dynamic> paymentDetails = {};

      if (_selectedMethod == WithdrawalMethod.bank) {
        paymentMethodName = 'Bank Transfer';
        paymentDetails = {
          'bankAccountNumber': _bankAccountNumberController.text,
          'accountHolderName': _accountHolderNameController.text,
          'ifscCode': _ifscCodeController.text,
        };
      } else if (_selectedMethod == WithdrawalMethod.upi) {
        paymentMethodName = 'UPI';
        paymentDetails = {
          'upiId': _upiIdController.text,
        };
      }

      // Show confirmation popup
      final bool? confirm = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Confirm Withdrawal'),
            content: Text('Withdraw $amount coins to $paymentMethodName?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );

      if (confirm == true) {
        setState(() {
          _isLoading = true;
        });

        String? error = await _withdrawalService.submitWithdrawal(
          uid: user.uid,
          amount: amount,
          paymentMethod: paymentMethodName,
          paymentDetails: paymentDetails,
        );

        setState(() {
          _isLoading = false;
        });

        if (error != null) {
          _showSnackBar(error, backgroundColor: Colors.red);
        } else {
          _showSnackBar('Withdrawal request submitted. Processing may take 24–48 hrs.');
          _resetForm();
        }
      }
    }
  }

  void _resetForm() {
    _bankAccountNumberController.clear();
    _accountHolderNameController.clear();
    _ifscCodeController.clear();
    _upiIdController.clear();
    _confirmUpiIdController.clear();
    _amountController.clear();
    setState(() {
      _selectedMethod = WithdrawalMethod.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final userDataProvider = Provider.of<UserDataProvider>(context);

    if (user == null || userDataProvider.userData == null) {
      return const _WithdrawScreenLoading();
    }

    Map<String, dynamic> userData = userDataProvider.userData!.data() as Map<String, dynamic>;
    int currentCoins = userData['coins'] ?? 0;
    double totalBalanceINR = currentCoins / 1000.0; // Assuming 1000 coins = 1 INR

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const SizedBox(height: 20), // Adjusted spacing from top
            // Available Balance Card
            Card(
              elevation: 6.0, // Increased elevation for more prominence
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)), // More rounded corners
              child: Container(
                padding: const EdgeInsets.all(25.0), // Increased padding
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.0),
                  gradient: LinearGradient(
                    colors: [Theme.of(context).primaryColor.withOpacity(0.8), Theme.of(context).primaryColor.withOpacity(0.5)], // Using primary color with opacity
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Balance',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white70, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.monetization_on, color: Colors.amber.shade300, size: 30),
                        const SizedBox(width: 10),
                        Text(
                          '₹${totalBalanceINR.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 32),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Minimum withdrawal: $_minWithdrawalCoins coins',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40), // Increased spacing
            Text(
              'Select Withdrawal Method',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
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
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  if (_selectedMethod == WithdrawalMethod.bank) ...[
                    TextFormField(
                      controller: _bankAccountNumberController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        labelText: 'Bank Account Number',
                        icon: Icons.account_balance_wallet,
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Enter account number' : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _accountHolderNameController,
                      decoration: _inputDecoration(
                        labelText: 'Account Holder Name',
                        icon: Icons.person,
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Enter account holder name' : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _ifscCodeController,
                      decoration: _inputDecoration(
                        labelText: 'IFSC Code',
                        icon: Icons.code,
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Enter IFSC code' : null,
                    ),
                    const SizedBox(height: 20),
                  ] else if (_selectedMethod == WithdrawalMethod.upi) ...[
                    TextFormField(
                      controller: _upiIdController,
                      decoration: _inputDecoration(
                        labelText: 'UPI ID (e.g., yourname@upi)',
                        icon: Icons.qr_code,
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Enter UPI ID' : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _confirmUpiIdController,
                      decoration: _inputDecoration(
                        labelText: 'Confirm UPI ID',
                        icon: Icons.qr_code,
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Confirm UPI ID';
                        if (val != _upiIdController.text) return 'UPI IDs do not match';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (_selectedMethod != WithdrawalMethod.none) ...[
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        labelText: 'Amount to Withdraw (Coins)',
                        icon: Icons.money,
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (int.tryParse(val) == null || int.parse(val) <= 0) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15), // Adjusted spacing
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildAmountButton('25%', () => _setAmountPercentage(25, currentCoins)),
                        _buildAmountButton('50%', () => _setAmountPercentage(50, currentCoins)),
                        _buildAmountButton('MAX', () => _setAmountPercentage(100, currentCoins)),
                      ],
                    ),
                    const SizedBox(height: 40), // Increased spacing
                    _isLoading
                        ? ShimmerLoading.rectangular(height: 55, width: double.infinity) // Adjusted height
                        : CustomButton(
                            text: _selectedMethod == WithdrawalMethod.bank
                                ? 'Withdraw to Bank Account'
                                : 'Withdraw via UPI',
                            onPressed: _submitWithdrawal,
                            startColor: Theme.of(context).primaryColor,
                            endColor: Theme.of(context).primaryColor.withOpacity(0.8),
                            height: 55, // Consistent button height
                            borderRadius: 12.0, // More rounded button
                          ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String labelText, required IconData icon}) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0), // More rounded input fields
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade700),
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
            color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.15) : Colors.white, // More prominent selected color
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

  Widget _buildAmountButton(String text, VoidCallback onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0), // Increased horizontal padding
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).primaryColor,
            side: BorderSide(color: Theme.of(context).primaryColor, width: 1.5), // Thicker border
            padding: const EdgeInsets.symmetric(vertical: 15), // Increased vertical padding
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // More rounded
            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), // Bolder text
          ),
          child: Text(text),
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
