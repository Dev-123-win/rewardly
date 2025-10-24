# Text Messages from SpinWheelGameScreen

## SnackBar Messages:
- 'No spins left! Watch an ad or wait for free spins.'
- 'Ad watched! Spin again!'
- 'Failed to show ad. Spin consumed.'
- 'You earned $coins coins!'
- 'Failed to update coins. Please try again.'
- 'You earned 2 spins!'
- 'You have reached the daily limit for ad spins (10 ads).'
- 'Failed to show rewarded ad. Try again.'

## Dialog/Modal Messages:
### Win Dialog:
- 'Congratulations!' (title for winning)
- 'You won ${reward.coins} coins!' (content for winning)
- 'Better luck next time!' (title for losing)
- 'You landed on "0" coins.' (content for losing)
- 'Spin Again' (button text)

### Ad Reward Dialog:
- 'Watch an Ad!' (title)
- 'Watch a short ad to get another spin!' (content)
- 'Watch Ad' (button text)

## UI Text:
- 'Lucky Spin' (AppBar title)
- 'Available Spins: $totalSpins' (Dynamic text for available spins)
- 'Spin to Win!' (Button text)
- 'Watch Ad for Spin!' (Button text)

## Wheel Reward Texts:
- '50'
- '100'
- '150'
- '500'
- '0'

# Text Messages from TicTacToeGameScreen

## SnackBar Messages:
- 'You earned $coins coins!'
- 'Failed to update coins. Please try again.'
- 'Failed to show rewarded ad. Try again.'

## Dialog/Modal Messages:
### Game Result Dialog:
- 'You Win!' (title for winning)
- 'Congratulations! You earned $rewardCoins coins.' (content for winning)
- 'You Lose!' (title for losing)
- 'Better luck next time.' (content for losing)
- 'It\'s a Draw!' (title for draw)
- 'You earned $rewardCoins coins for a draw.' (content for draw)
- 'Claim Coins' (button text for win)
- 'Watch Ad for ${rewardCoins * 2} Coins' (button text for win/draw)
- 'Play Again' (button text for lose/draw)

### Difficulty Settings Dialog:
- 'Select Difficulty' (title)
- 'EASY' (difficulty option)
- 'MEDIUM' (difficulty option)
- 'HARD' (difficulty option)
- 'Cancel' (button text)

## UI Text:
- 'Tic Tac Toe' (AppBar title)
- 'Current Player: ' (Player indicator text)
- 'Computer is thinking...' (Loading text)
- 'START NEW GAME' (Button text)

# Text Messages from EarnCoinsScreen

## SnackBar Messages:
- 'You earned $_coinsPerAd coins!'
- 'Failed to show rewarded ad. Try again.'

## UI Text:
- 'Watch & Earn Coins' (AppBar title)
- 'Earn $_coinsPerAd Coins' (Card title)
- 'Locked' (Status text for locked ad card)
- 'Watch Ad' (Status text for unlocked ad card)
- 'Waiting... $_secondsRemaining s' (Status text for ad card with active timer)
- 'Watched' (Status text for watched ad card)

# Text Messages from ReadAndEarnScreen

## SnackBar Messages:
- 'You returned too early! No reward.'
- 'Error loading page: ${error.description}'
- 'You claimed ${_currentReadTask!.coins} coins!'
- 'Failed to show ad. Coins awarded directly.'

## Dialog/Modal Messages:
### Task Completed Modal:
- 'Task Completed!' (title)
- 'You earned ${_currentReadTask!.coins} coins!' (content)
- 'Claim Coins' (button text)

## UI Text:
- 'Web View' (AppBar title when webview is active)
- 'Read & Earn' (AppBar title when webview is not active)
- 'Read for 1 Minute' (Example task title)
- 'Read for 2 Minutes' (Example task title)
- 'Read for 3 Minutes' (Example task title)
- 'Start Reading' (Button text)
- 'Reading... ${_secondsRemaining ~/ 60}:${(_secondsRemaining % 60).toString().padLeft(2, '0')}' (Status text while reading)
- 'Earn ${_currentReadTask!.coins} Coins' (Card text)

# Text Messages from ReferralScreen

## SnackBar Messages:
- 'Referral code copied to clipboard!'

## UI Text:
- 'We Share More.\nWe Earn More.' (Title)
- 'Invite your Friends, Win Rewards!' (Subtitle)
- 'Refer and Win. Share with Friends, Unlock Exciting Rewards!' (Body text)
- 'Your Invite Code' (Referral code label)
- 'N/A' (Default referral code)
- 'Refer Now' (Button text)
- 'Here is your\nReferral earning' (Referral earning card title)
- 'Multiply Your Rewards\nWith Referrals! Refer, E...' (Referral earning card subtitle)
- 'Click Here\nTo See You...' (Referral earning card button text)

# Text Messages from WithdrawScreen

## SnackBar Messages:
- 'Auto-Withdrawal setup coming soon!'
- 'You need at least $_minWithdrawalCoins coins to withdraw.'
- 'Please fill all bank details.'
- 'Please enter your UPI ID.'
- 'Please select a withdrawal method.'
- 'Submitting withdrawal request...'
- 'Withdrawal request submitted successfully!'
- '$errorMessage' (Error message from withdrawal service)

## UI Text:
- 'Your Current Balance' (Balance label)
- '₹${totalBalanceINR.toStringAsFixed(2)}' (Dynamic total balance in INR)
- '($currentCoins coins)' (Dynamic current coins)
- 'Withdrawal Goal: $_minWithdrawalCoins coins (₹${(_minWithdrawalCoins / 1000).toStringAsFixed(2)})' (Withdrawal goal text)
- '${((currentCoins / _minWithdrawalCoins.toDouble()) * 100).toStringAsFixed(0)}% towards your goal' (Progress text)
- 'Choose Withdrawal Method' (Section title)
- 'Withdraw to Bank' (Bank withdrawal method label)
- 'Withdraw to UPI' (UPI withdrawal method label)
- 'Enter Bank Account Details' (Bank details input section title)
- 'Bank Account Number' (Bank account number input label)
- 'e.g., 1234567890' (Bank account number hint)
- 'IFSC Code' (IFSC code input label)
- 'e.g., HDFC0001234' (IFSC code hint)
- 'Account Holder Name' (Account holder name input label)
- 'e.g., John Doe' (Account holder name hint)
- 'Enter UPI Details' (UPI details input section title)
- 'UPI ID' (UPI ID input label)
- 'e.g., yourname@bank' (UPI ID hint)
- 'Save these details for future withdrawals' (Checkbox label)
- 'Initiate Withdrawal' (Withdrawal button text)
- 'Set Up Auto-Withdrawal' (Auto-withdrawal button text)
- 'Recent Activity' (Recent activity section title)
- 'Error loading activity: ${snapshot.error}' (Error loading activity)
- 'No recent activity.' (No activity message)
- 'Withdrawal of $amount coins' (Activity item title)
- 'Method: ${method.toUpperCase()}' (Activity item method)
- 'PENDING' (Status text)
- 'SUCCESS' (Status text)
- 'FAILED' (Status text)
- 'UNKNOWN' (Status text)

# Text Messages from Home Screen

## Bottom Navigation Bar:
- 'Redeem'
- 'Invite'
- 'Home'
- 'Profile'

## Header Section:
- 'Hello, User!'
- 'Total Balance'
- '₹${totalBalanceINR.toStringAsFixed(2)}' (Dynamic total balance in INR)
- '($coins coins)' (Dynamic current coins)

## Quick Actions Section:
- 'Quick Actions' (Section title)
- 'Watch Ads' (Quick action card label)
- 'Invite Friends' (Quick action card label)
- 'Redeem Coins' (Quick action card label)

## Explore & Earn Section:
- 'Explore & Earn' (Section title)
- 'Spin & Win' (Large offer card title)
- 'Try your luck!' (Large offer card subtitle)
- 'Watch & Earn' (Large offer card title)
- 'Get coins by watching ads!' (Large offer card subtitle)
- 'Read & Earn' (Super offer card title)
- 'Earn Upto 100k' (Super offer card subtitle)
- 'Start Reading' (Super offer card button text)
- 'Tic Tac Toe' (Offer card title)
- 'Play against NPC!' (Offer card subtitle)
- 'Minesweeper' (Offer card title)
- 'Find the mines!' (Offer card subtitle)

# Text Messages from Sign In Screen

## SnackBar Messages:
- 'An unknown error occurred.' (Default error message)
- '$error' (Dynamic error message)

## UI Text:
- 'Welcome Back' (Title)
- 'Sign in to your account to continue' (Subtitle)
- 'Email Address' (Email input label)
- 'Enter your email' (Email input hint)
- 'Enter an email' (Email validation message)
- 'Password' (Password input label)
- 'Enter your password' (Password input hint)
- 'Enter a password 6+ chars long' (Password validation message)
- 'Forgot Password?' (Forgot password button text)
- 'Login to Your Account' (Login button text)
- 'Loading Rewardly...' (Loading text)

# Text Messages from Register Screen

## SnackBar Messages:
- 'You must agree to the Terms & Conditions and Privacy Policy and confirm you are 18+'
- 'Registration successful! Please log in.'
- '$error' (Dynamic error message)

## UI Text:
- 'Create Account' (Title)
- 'Join thousands earning with our platform' (Subtitle)
- 'Email Address' (Email input label)
- 'Enter your email' (Email input hint)
- 'Enter an email' (Email validation message)
- 'Password' (Password input label)
- 'Create a strong password' (Password input hint)
- 'Enter a password 6+ chars long' (Password validation message)
- 'Referral Code (Optional)' (Referral code input label)
- 'Enter referral code if you have one' (Referral code input hint)
- 'Using a referral code gives you and your friend bonus credits' (Referral info text)
- 'I agree to the ' (Terms and privacy text part 1)
- 'Terms of Service' (Terms of Service link text)
- ' and ' (Terms and privacy text part 2)
- 'Privacy Policy' (Privacy Policy link text)
- '. I confirm that I am at least 18 Years old.' (Terms and privacy text part 3)
- 'Create Account' (Register button text)

# Text Messages from Forgot Password Screen

## SnackBar Messages:
- 'An unknown error occurred.' (Default error message)
- 'Password reset email sent to $email' (Success message)
- '$error' (Dynamic error message)

## UI Text:
- 'Reset Password' (Title)
- 'Enter your email and we\'ll send you a reset link' (Subtitle)
- 'Email' (Email input label)
- 'Enter your email' (Email input hint)
- 'Enter an email' (Email validation message)
- 'Send Reset Link' (Button text)
- 'Back to Sign In' (Button text)
