import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../remote_config_service.dart';
import '../../user_service.dart';
import '../../shared/shimmer_loading.dart';
import '../../providers/user_data_provider.dart';
import 'admin_panel.dart';
import 'earn_coins_screen.dart';
import 'referral_screen.dart';
import 'profile_screen.dart';
import 'withdraw_screen.dart';
// Removed import for play_game_screen.dart
import 'spin_wheel_game_screen.dart'; // New import for Spin Wheel Game
import 'tic_tac_toe_game_screen.dart'; // New import for Tic Tac Toe Game
import 'minesweeper_game_screen.dart'; // New import for Minesweeper Game
// Removed imports for AquaBlastScreen, OfferProScreen, ReadAndEarnScreen, DailyStreamScreen, EmptyScreen

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 2; // Set Home as initial selected index
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final user = Provider.of<User?>(context, listen: false);
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);

    if (user != null) {
      bool admin = false;
      if (userDataProvider.userData != null) {
        admin = userDataProvider.userData!['isAdmin'] ?? false;
      } else {
        admin = await UserService().isAdmin(user.uid);
      }
      if (mounted) {
        setState(() {
          _isAdmin = admin;
        });
      }
    }
  }

  List<Widget> _buildScreens() {
    return [
      Consumer<UserDataProvider>(
        builder: (context, userDataProvider, _) => userDataProvider.userData == null
            ? const _LoadingPlaceholder()
            : const WithdrawScreen(), // Index 0 (Redeem)
      ),
      Consumer<UserDataProvider>(
        builder: (context, userDataProvider, _) => userDataProvider.userData == null
            ? const _LoadingPlaceholder()
            : const ReferralScreen(), // Index 1 (Invite)
      ),
      _buildHomePageContent(), // Index 2 (Home)
      Consumer<UserDataProvider>(
        builder: (context, userDataProvider, _) => userDataProvider.userData == null
            ? const _LoadingPlaceholder()
            : const ProfileScreen(), // Index 3 (Profile)
      ),
      if (_isAdmin) const AdminPanel(), // Index 4 (Admin)
    ];
  }

  List<BottomNavigationBarItem> _buildNavBarItems() {
    List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.redeem),
        label: 'Redeem',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_add),
        label: 'Invite',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];
    if (_isAdmin) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user == null) {
      return const HomeScreenLoading();
    }

    final userDataProvider = Provider.of<UserDataProvider>(context);
    if (userDataProvider.userData == null) {
      return const HomeScreenLoading();
    }

    Map<String, dynamic> userData = (userDataProvider.userData!.data() as Map<String, dynamic>?) ?? {};
    int coins = userData['coins'] ?? 0;
    double totalBalanceINR = coins / 1000.0; // 1000 coins = 1 INR

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // White AppBar background
        title: Text(
          user.email ?? 'Rewardly App',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87, fontSize: 16.0),
        ),
        elevation: 1.0, // Subtle shadow
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = 0; // Navigate to WithdrawScreen
              });
            },
            child: Card(
              color: Colors.grey[100], // Light grey card
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 2.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet, color: Theme.of(context).primaryColor, size: 18), // Primary color icon
                    const SizedBox(width: 6),
                    Text(
                      'Total Balance\n₹${totalBalanceINR.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black87, fontSize: 12.0),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildScreens()[_selectedIndex],
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
    );
  }

  Widget _buildHomePageContent() {
    final user = Provider.of<User?>(context);
    final userDataProvider = Provider.of<UserDataProvider>(context);

    if (user == null || userDataProvider.userData == null) {
      return const HomeScreenLoading();
    }

    Map<String, dynamic> userData = (userDataProvider.userData!.data() as Map<String, dynamic>?) ?? {};
    int coins = userData['coins'] ?? 0;

    return SingleChildScrollView(
      child: Container(
        color: Colors.white, // White background for home content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Available Coins',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black54),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade100, // Light yellow background
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(25),
                            blurRadius: 8,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.amber.shade700, // Background for coin icon
                            child: Image.asset('assets/coin.png', height: 30, width: 30), // Coin icon
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: (coins / 1000).toStringAsFixed(2),
                                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                        color: Colors.black87,
                                        fontFamily: 'Poppins', // Using existing font
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          const Shadow(
                                            offset: Offset(1.0, 1.0),
                                            blurRadius: 2.0,
                                            color: Colors.black38,
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'k',
                                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                        color: Colors.black87,
                                        fontFamily: 'Poppins', // Using existing font
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          const Shadow(
                                            offset: Offset(1.0, 1.0),
                                            blurRadius: 2.0,
                                            color: Colors.black38,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Coins',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black54, fontFamily: 'Lato'), // Using existing font
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Offer Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildOfferCard(
                    context,
                    title: 'Tic Tac Toe',
                    subtitle: 'Play against NPC!',
                    imagePath: 'assets/tic_tac_toe.png', // Updated to imagePath
                    startColor: const Color(0xFF4CAF50), // Green
                    endColor: const Color(0xFF8BC34A), // Light Green
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const TicTacToeGameScreen()));
                    },
                  ),
                  _buildOfferCard(
                    context,
                    title: 'Play Game!',
                    subtitle: 'Spin & Win!',
                    imagePath: 'assets/spin_the_wheel.png', // Updated to imagePath
                    startColor: const Color(0xFF8B008B), // DarkMagenta
                    endColor: const Color(0xFFBA55D3), // MediumPurple
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SpinWheelGameScreen()));
                    },
                  ),
                  _buildOfferCard(
                    context,
                    title: 'Watch Ads',
                    subtitle: 'Earn Upto ${RemoteConfigService().coinsPerAd} coins per ad',
                    imagePath: 'assets/watch_ads.png', // Updated to imagePath
                    startColor: Colors.green,
                    endColor: Colors.lightGreen,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const EarnCoinsScreen()));
                    },
                  ),
                  _buildOfferCard(
                    context,
                    title: 'Minesweeper',
                    subtitle: 'Find the mines!',
                    imagePath: 'assets/minesweeper.png', // Updated to minesweeper.png
                    startColor: Colors.blueGrey,
                    endColor: Colors.blueGrey.shade300,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const MinesweeperGameScreen()));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String imagePath, // Changed from IconData to String imagePath
    required Color startColor,
    required Color endColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        clipBehavior: Clip.antiAlias, // Clip content to card shape
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            gradient: LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover, // Ensure image covers the entire card
                ),
              ),
              // Text content with semi-transparent background
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(102), // Semi-transparent background for text (0.4 * 255 = 102)
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreenLoading extends StatelessWidget {
  const HomeScreenLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
