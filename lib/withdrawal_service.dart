import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:rewardly_app/user_service.dart';

class WithdrawalService {
  final UserService _userService = UserService();

  Future<String?> submitWithdrawal({
    required String uid,
    required int amount,
    required String paymentMethod,
    required Map<String, dynamic> paymentDetails, // Changed to Map<String, dynamic>
  }) async {
    if (amount <= 0) {
      return 'Please enter a valid amount.';
    }

    final userData = await _userService.getUserData(uid).first;
    final int currentCoins = (userData.data() as Map<String, dynamic>)['coins'] ?? 0;

    if (amount > currentCoins) {
      return 'Insufficient coins.';
    }

    if (paymentDetails.isEmpty) {
      return 'Please enter payment details.'; // This check might need to be more specific now
    }

    // In a real application, you would store paymentDetails in Firestore
    // or send them to a backend for processing.
    // For this simulation, we'll just log them.
    debugPrint('Withdrawal Request:');
    debugPrint('  UID: $uid');
    debugPrint('  Amount: $amount coins');
    debugPrint('  Method: $paymentMethod');
    debugPrint('  Details: $paymentDetails');

    // Simulate withdrawal process
    await Future.delayed(const Duration(seconds: 2));

    // Deduct coins (in a real app, this would be after successful payment processing)
    await _userService.updateCoins(uid, -amount);

    return null; // No error
  }
}
