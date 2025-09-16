import 'package:rewardly_app/user_service.dart';

class WithdrawalService {
  final UserService _userService = UserService();

  Future<String?> submitWithdrawal({
    required String uid,
    required int amount,
    required String paymentMethod,
    required String paymentDetails,
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
      return 'Please enter payment details.';
    }

    // Simulate withdrawal process
    await Future.delayed(const Duration(seconds: 2));

    // Deduct coins (in a real app, this would be after successful payment processing)
    await _userService.updateCoins(uid, -amount);

    return null; // No error
  }
}
