import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../shared/shimmer_loading.dart';
import '../../providers/user_data_provider.dart';
import '../../design_system/app_icons.dart';
import '../../screens/notifications/notification_center_screen.dart';
import '../../widgets/animated_tap.dart';
import 'earn_coins_screen.dart';
import 'referral_screen.dart';
import 'profile_screen.dart';
import 'withdraw_screen.dart';
import 'tic_tac_toe_game_screen.dart';
import 'minesweeper_game_screen.dart';
import 'spin_wheel_game_screen.dart';
import 'read_and_earn_screen.dart';
import '../../models/auth_result.dart';
import '../../widgets/custom_button.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  int _selectedIndex = 2; // Home tab

  @override
  void initState() {
    super.initState();
  }


  List<Widget> _buildScreens() {
    return [
      const WithdrawScreen(), // Index 0 (Redeem)
      const ReferralScreen(), // Index 1 (Invite)
      _buildHomePageContent(), // Index 2 (Home)
      const ProfileScreen(), // Index 3 (Profile)
    ];
  }

  List<BottomNavigationBarItem> _buildNavBarItems() {
    return [
      BottomNavigationBarItem(
        icon: HugeIcon(icon: AppIcons.redeem),
        label: 'Redeem',
      ),
      BottomNavigationBarItem(
        icon: HugeIcon(icon: AppIcons.invite),
        label: 'Invite',
      ),
      BottomNavigationBarItem(
        icon: HugeIcon(icon: AppIcons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: HugeIcon(icon: AppIcons.profile),
        label: 'Profile',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authResult = Provider.of<AuthResult?>(context);

    if (authResult?.uid == null) {
      return const HomeScreenLoading();
    }

    final userDataProvider = Provider.of<UserDataProvider>(context);
    if (userDataProvider.userData == null) {
      return const HomeScreenLoading();
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white, // Ensure consistent background
        body: Column(
          children: [
            Expanded(
            child: _buildScreens()[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _buildNavBarItems(),
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor, // Primary color for selected item
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    ));
  }

  Widget _buildHomePageContent() {
    final authResult = Provider.of<AuthResult?>(context);
    final userDataProvider = Provider.of<UserDataProvider>(context);

    if (authResult?.uid == null || userDataProvider.userData == null) {
      return const HomeScreenLoading();
    }

    int coins = (userDataProvider.userData!.data() as Map<String, dynamic>?)?['coins'] ?? 0;
    double totalBalanceINR = coins / 1000.0; // 1000 coins = 1 INR

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    AnimatedTap(
                      child: CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        child: HugeIcon(icon: AppIcons.profile, color: Theme.of(context).primaryColor, size: 28),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedIndex = 3;
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Hello, User!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.black),
                    ),
                  ],
                ),
                AnimatedTap(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: HugeIcon(
                        icon: AppIcons.notification,
                        color: Theme.of(context).primaryColor,
                        size: AppIcons.sizeMedium,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationCenterScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Coin Balance Card
            CustomButton(
              text: '₹${totalBalanceINR.toStringAsFixed(2)}  ($coins coins)',
              onPressed: () {
                setState(() {
                  _selectedIndex = 0;
                });
              },
              startColor: Theme.of(context).primaryColor,
              endColor: Theme.of(context).colorScheme.secondary,
              width: double.infinity,
              height: 60,
              borderRadius: 18,
              hugeIcon: AppIcons.redeem,
              textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 24),
            // Quick Actions
            Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Watch Ads',
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const EarnCoinsScreen()));
                    },
                    startColor: Colors.orange.shade400,
                    endColor: Colors.orange.shade700,
                    hugeIcon: AppIcons.earn,
                    textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Invite',
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ReferralScreen()));
                    },
                    startColor: Colors.blue.shade400,
                    endColor: Colors.blue.shade700,
                    hugeIcon: AppIcons.invite,
                    textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Redeem',
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                    startColor: Colors.green.shade400,
                    endColor: Colors.green.shade700,
                    hugeIcon: AppIcons.redeem,
                    textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Main Offers
            Text('Explore & Earn', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Spin & Win',
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SpinWheelGameScreen()));
                    },
                    startColor: Colors.deepPurple.shade400,
                    endColor: Colors.deepPurple.shade700,
                    hugeIcon: AppIcons.spinWheel,
                    textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Watch & Earn',
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const EarnCoinsScreen()));
                    },
                    startColor: Colors.purple.shade400,
                    endColor: Colors.purple.shade700,
                    hugeIcon: AppIcons.earn,
                    textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Read & Earn',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ReadAndEarnScreen()));
              },
              startColor: Colors.orange.shade400,
              endColor: Colors.orange.shade700,
              hugeIcon: AppIcons.copy,
              textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 32),
            // Games Section
            Text('Games', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Tic Tac Toe',
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const TicTacToeGameScreen()));
                    },
                    startColor: Colors.red.shade400,
                    endColor: Colors.red.shade700,
                    hugeIcon: AppIcons.ticTacToe,
                    textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Minesweeper',
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const MinesweeperGameScreen()));
                    },
                    startColor: Colors.teal.shade400,
                    endColor: Colors.teal.shade700,
                    hugeIcon: AppIcons.minesweeper,
                    textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Recent Activity (placeholder)
            Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black)),
            const SizedBox(height: 16),
            ShimmerLoading.rectangular(height: 60, width: double.infinity),
            const SizedBox(height: 8),
            ShimmerLoading.rectangular(height: 60, width: double.infinity),
          ],
        ),
      ),
    );
  }
}

class HomeScreenLoading extends StatelessWidget {
  const HomeScreenLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
        backgroundColor: Colors.white, // White AppBar background
        title: const ShimmerLoading.rectangular(height: 18, width: 150),
        actions: <Widget>[
          const ShimmerLoading.circular(width: 40, height: 40),
          const SizedBox(width: 10),
          const ShimmerLoading.rectangular(height: 40, width: 80),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white, // White background
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const ShimmerLoading.rectangular(height: 200, width: double.infinity),
                const SizedBox(height: 20),
                const ShimmerLoading.rectangular(height: 30, width: 150),
                const SizedBox(height: 10),
                const ShimmerLoading.rectangular(height: 18, width: 200),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const ShimmerLoading.rectangular(height: 56),
    ));
  }
}
