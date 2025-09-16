import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rewardly_app/shared/shimmer_loading.dart';
import 'package:rewardly_app/widgets/custom_button.dart';
import 'package:rewardly_app/providers/user_data_provider.dart';
import 'package:rewardly_app/withdrawal_service.dart';

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _formKey = GlobalKey<FormState>();
  String _withdrawAmount = '';
  String _paymentMethod = 'PayPal'; // Default payment method
  bool _isLoading = false;
  final WithdrawalService _withdrawalService = WithdrawalService();
  final TextEditingController _paymentDetailsController = TextEditingController();

  @override
  void dispose() {
    _paymentDetailsController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _submitWithdrawal() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final user = Provider.of<User?>(context, listen: false);
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('User not logged in.');
        return;
      }

      final int amount = int.parse(_withdrawAmount);

      String? error = await _withdrawalService.submitWithdrawal(
        uid: user.uid,
        amount: amount,
        paymentMethod: _paymentMethod,
        paymentDetails: _paymentDetailsController.text,
      );

      if (error != null) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar(error);
        return;
      }

      setState(() {
        _isLoading = false;
        _withdrawAmount = '';
      });
      _showSnackBar('Withdrawal request submitted for $amount coins via $_paymentMethod!');
    }
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              'Redeem Your Coins',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Text(
              'You have $currentCoins coins available to redeem.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount to Withdraw',
                      prefixIcon: Icon(Icons.money, color: Theme.of(context).primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
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
                    onChanged: (val) {
                      setState(() => _withdrawAmount = val);
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: _paymentMethod,
                    decoration: InputDecoration(
                      labelText: 'Payment Method',
                      prefixIcon: Icon(Icons.payment, color: Theme.of(context).primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    items: <String>['PayPal', 'Bank Transfer', 'Crypto']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _paymentMethod = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: '$_paymentMethod Details (e.g., email, account number)',
                      prefixIcon: Icon(Icons.info, color: Theme.of(context).primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    controller: _paymentDetailsController,
                    validator: (val) => val!.isEmpty ? 'Please enter payment details' : null,
                  ),
                  const SizedBox(height: 30),
                  _isLoading
                      ? ShimmerLoading.rectangular(height: 50, width: double.infinity)
                      : CustomButton(
                          text: 'Submit Withdrawal',
                          onPressed: _submitWithdrawal,
                          startColor: Theme.of(context).primaryColor,
                          endColor: Theme.of(context).primaryColor.withAlpha((0.8 * 255).round()),
                        ),
                ],
              ),
            ),
          ],
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
            ShimmerLoading.rectangular(height: 28, width: 200),
            const SizedBox(height: 10),
            ShimmerLoading.rectangular(height: 16, width: 150),
            const SizedBox(height: 30),
            ShimmerLoading.rectangular(height: 50),
            const SizedBox(height: 20),
            ShimmerLoading.rectangular(height: 50),
            const SizedBox(height: 20),
            ShimmerLoading.rectangular(height: 50),
            const SizedBox(height: 30),
            ShimmerLoading.rectangular(height: 50),
          ],
        ),
      ),
    );
  }
}
