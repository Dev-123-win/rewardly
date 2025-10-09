import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for DocumentSnapshot and Timestamp
import '../../shared/shimmer_loading.dart';
import '../../providers/user_data_provider.dart';
import '../../withdrawal_service.dart'; // Import WithdrawalService
import '../../models/auth_result.dart'; // Import AuthResult
import '../../user_service.dart'; // Import UserService

enum WithdrawalMethod { bank, upi, none }

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final WithdrawalService _withdrawalService = WithdrawalService(); // Instantiate WithdrawalService
  WithdrawalMethod _selectedMethod = WithdrawalMethod.none;
  final int _minWithdrawalCoins = 100000; // Minimum withdrawal: 100 INR (100 * 1000 coins/INR)

  // Text editing controllers for withdrawal details
  final TextEditingController _bankAccountController = TextEditingController();
  final TextEditingController _ifscCodeController = TextEditingController();
  final TextEditingController _accountHolderNameController = TextEditingController();
  final TextEditingController _upiIdController = TextEditingController();
  bool _saveDetails = false; // State for "Save details" checkbox

  @override
  void initState() {
    super.initState();
    // Listen for userDataProvider changes to load preferred details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPreferredDetails();
    });
  }

  @override
  void dispose() {
    _bankAccountController.dispose();
    _ifscCodeController.dispose();
    _accountHolderNameController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  void _loadPreferredDetails() {
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    final lastUsedMethod = userDataProvider.lastUsedWithdrawalMethod;

    if (lastUsedMethod != null) {
      setState(() {
        if (lastUsedMethod == 'bank') {
          _selectedMethod = WithdrawalMethod.bank;
          final bankDetails = userDataProvider.preferredBankDetails;
          if (bankDetails != null) {
            _bankAccountController.text = bankDetails['bankAccountNumber'] ?? '';
            _ifscCodeController.text = bankDetails['ifscCode'] ?? '';
            _accountHolderNameController.text = bankDetails['accountHolderName'] ?? '';
            _saveDetails = true; // Assume details are saved if pre-filled
          }
        } else if (lastUsedMethod == 'upi') {
          _selectedMethod = WithdrawalMethod.upi;
          final upiDetails = userDataProvider.preferredUpiDetails;
          if (upiDetails != null) {
            _upiIdController.text = upiDetails['upiId'] ?? '';
            _saveDetails = true; // Assume details are saved if pre-filled
          }
        }
      });
    }
  }

  void _showSnackBar(String message, {Color backgroundColor = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authResult = Provider.of<AuthResult?>(context);
    final userDataProvider = Provider.of<UserDataProvider>(context);

    if (authResult?.uid == null || userDataProvider.userData == null || userDataProvider.userData!.data() == null || userDataProvider.shardedUserService == null) {
      return const _WithdrawScreenLoading();
    }

    final String uid = authResult!.uid!;
    final UserService userService = userDataProvider.shardedUserService!;

    Map<String, dynamic> userData = userDataProvider.userData!.data() as Map<String, dynamic>;
    int currentCoins = userData['coins'] ?? 0;
    double totalBalanceINR = currentCoins / 1000.0; // Assuming 1000 coins = 1 INR

    return SafeArea(
      child: Scaffold(
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
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    width: double.infinity,
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
                            shadows: [
                              Shadow(
                                blurRadius: 5.0,
                                color: Colors.black.withOpacity(0.25),
                                offset: const Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '($currentCoins coins)',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black45),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Minimum Withdrawal Progress
              Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
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
                        _loadPreferredDetailsForMethod(WithdrawalMethod.bank);
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
                        _loadPreferredDetailsForMethod(WithdrawalMethod.upi);
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
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _processWithdrawal(currentCoins),
                      icon: const Icon(Icons.send, color: Colors.white),
                      label: Text(
                        'Initiate Withdrawal',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
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
              // Recent Activity Display
              _buildRecentActivityList(uid, userService),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildRecentActivityList(String uid, UserService userService) {
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: userService.getWithdrawalRequestsStream(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading activity: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No recent activity.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          );
        }

        final requests = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index].data() as Map<String, dynamic>;
            final int amount = request['amount'] ?? 0;
            final String method = request['paymentMethod'] ?? 'N/A';
            final String status = request['status'] ?? 'unknown';

            Color statusColor;
            IconData statusIcon;
            switch (status) {
              case 'pending':
                statusColor = Colors.orange;
                statusIcon = Icons.hourglass_empty;
                break;
              case 'success':
                statusColor = Colors.green;
                statusIcon = Icons.check_circle;
                break;
              case 'failed':
                statusColor = Colors.red;
                statusIcon = Icons.cancel;
                break;
              default:
                statusColor = Colors.grey;
                statusIcon = Icons.help_outline;
            }

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 4.0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 30),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Withdrawal of $amount coins',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Method: ${method.toUpperCase()}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          status.toUpperCase(),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                        ),
                        if (request['createdAt'] != null)
                          Text(
                            (request['createdAt'] as Timestamp).toDate().toLocal().toString().split(' ')[0],
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: const Icon(Icons.account_balance_wallet),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _ifscCodeController,
          decoration: InputDecoration(
            labelText: 'IFSC Code',
            hintText: 'e.g., HDFC0001234',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: const Icon(Icons.code),
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _accountHolderNameController,
          decoration: InputDecoration(
            labelText: 'Account Holder Name',
            hintText: 'e.g., John Doe',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: const Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 20),
        _buildSaveDetailsCheckbox(),
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: const Icon(Icons.qr_code),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        _buildSaveDetailsCheckbox(),
      ],
    );
  }

  Widget _buildSaveDetailsCheckbox() {
    return CheckboxListTile(
      title: const Text('Save these details for future withdrawals'),
      value: _saveDetails,
      onChanged: (bool? value) {
        setState(() {
          _saveDetails = value ?? false;
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _loadPreferredDetailsForMethod(WithdrawalMethod method) {
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    setState(() {
      _bankAccountController.clear();
      _ifscCodeController.clear();
      _accountHolderNameController.clear();
      _upiIdController.clear();
      _saveDetails = false; // Reset checkbox when switching methods

      if (method == WithdrawalMethod.bank) {
        final bankDetails = userDataProvider.preferredBankDetails;
        if (bankDetails != null) {
          _bankAccountController.text = bankDetails['bankAccountNumber'] ?? '';
          _ifscCodeController.text = bankDetails['ifscCode'] ?? '';
          _accountHolderNameController.text = bankDetails['accountHolderName'] ?? '';
          _saveDetails = true;
        }
      } else if (method == WithdrawalMethod.upi) {
        final upiDetails = userDataProvider.preferredUpiDetails;
        if (upiDetails != null) {
          _upiIdController.text = upiDetails['upiId'] ?? '';
          _saveDetails = true;
        }
      }
    });
  }

  void _processWithdrawal(int currentCoins) {
    if (currentCoins < _minWithdrawalCoins) {
      _showSnackBar('You need at least $_minWithdrawalCoins coins to withdraw.', backgroundColor: Colors.red);
      return;
    }

    if (_selectedMethod == WithdrawalMethod.bank) {
      if (_bankAccountController.text.isEmpty ||
          _ifscCodeController.text.isEmpty ||
          _accountHolderNameController.text.isEmpty) {
        _showSnackBar('Please fill all bank details.', backgroundColor: Colors.red);
        return;
      }
    } else if (_selectedMethod == WithdrawalMethod.upi) {
      if (_upiIdController.text.isEmpty) {
        _showSnackBar('Please enter your UPI ID.', backgroundColor: Colors.red);
        return;
      }
    } else {
      _showSnackBar('Please select a withdrawal method.', backgroundColor: Colors.red);
      return;
    }

    _showSnackBar('Submitting withdrawal request...', backgroundColor: Theme.of(context).primaryColor);

    final authResult = Provider.of<AuthResult?>(context, listen: false);
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    final String uid = authResult!.uid!; // User is guaranteed to be logged in at this point
    final String methodString = _selectedMethod == WithdrawalMethod.bank ? 'bank' : 'upi';
    final Map<String, dynamic> details = _selectedMethod == WithdrawalMethod.bank
        ? {
            'bankAccountNumber': _bankAccountController.text,
            'ifscCode': _ifscCodeController.text,
            'accountHolderName': _accountHolderNameController.text,
          }
        : {
            'upiId': _upiIdController.text,
          };

    // Save preferred details if checkbox is checked
    if (_saveDetails && userDataProvider.shardedUserService != null) {
      if (_selectedMethod == WithdrawalMethod.bank) {
        userDataProvider.shardedUserService!.savePreferredBankDetails(uid, details);
      } else if (_selectedMethod == WithdrawalMethod.upi) {
        userDataProvider.shardedUserService!.savePreferredUpiDetails(uid, details);
      }
      userDataProvider.shardedUserService!.updateLastUsedWithdrawalMethod(uid, methodString);
    }

    _withdrawalService.submitWithdrawal(
      uid: uid,
      amount: currentCoins,
      paymentMethod: methodString,
      paymentDetails: details,
    ).then((errorMessage) {
      if (errorMessage == null) {
        _showSnackBar('Withdrawal request submitted successfully!');
        // Clear fields after submission only if not saving details
        if (!_saveDetails) {
          _bankAccountController.clear();
          _ifscCodeController.clear();
          _accountHolderNameController.clear();
          _upiIdController.clear();
        }
        setState(() {
          _selectedMethod = WithdrawalMethod.none; // Reset selection
          _saveDetails = false; // Reset save details checkbox
        });
      } else {
        _showSnackBar(errorMessage, backgroundColor: Colors.red);
      }
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
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: double.infinity, // Full width for list-type cards
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
              width: isSelected ? 2.0 : 1.0,
            ),
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
      ),
    );
  }
}

class _WithdrawScreenLoading extends StatelessWidget {
  const _WithdrawScreenLoading();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
    ));
  }
}
