import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/shimmer_loading.dart';
import '../../providers/user_data_provider.dart';
import 'earn_coins_screen.dart';
import 'referral_screen.dart';
import 'profile_screen.dart';
import 'withdraw_screen.dart';
import 'tic_tac_toe_game_screen.dart';
import 'minesweeper_game_screen.dart';
import 'spin_wheel_game_screen.dart';
import '../../logger_service.dart';
import '../../models/auth_result.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 2; // Set Home as initial selected index

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
    return items;
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
      child: Container(
        color: Colors.white, // White background for home content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Custom Header Section
            Container(
              padding: const EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0, bottom: 20.0),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor, // Use primary color for header background
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30.0)),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(26, 0, 0, 0),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity, // Ensure the column takes full available width
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                      Expanded( // Wrap the inner Row with Expanded
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Color.fromARGB((255 * 0.2).round(), 255, 255, 255),
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Hello, ${authResult?.uid?.split('@')[0] ?? 'User'}!', // Using uid as a fallback for display
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis, // Handle long names
                            ),
                          ),
                          ],
                        ),
                      ),
                        IconButton(
                          icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                          onPressed: () {
                            // TODO: Implement notification logic
                            LoggerService.info('Notifications icon tapped');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Centralized Balance Card
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = 0; // Navigate to WithdrawScreen
                        });
                      },
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 8.0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Balance',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '₹${totalBalanceINR.toStringAsFixed(2)}',
                                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 36,
                                    ),
                                  ),
                                  Text(
                                    '($coins coins)',
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.black54),
                                  ),
                                ],
                              ),
                              Icon(Icons.account_balance_wallet, color: Theme.of(context).primaryColor, size: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Quick Actions Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 100, // Height for horizontal quick action cards
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  _buildQuickActionCard(
                    context,
                    icon: Icons.videocam,
                    label: 'Watch Ads',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const EarnCoinsScreen()));
                    },
                  ),
                  const SizedBox(width: 15),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.person_add,
                    label: 'Invite Friends',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ReferralScreen()));
                    },
                  ),
                  const SizedBox(width: 15),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.redeem,
                    label: 'Redeem Coins',
                    onTap: () {
                      setState(() {
                        _selectedIndex = 0; // Navigate to WithdrawScreen
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Main Offer Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Explore & Earn',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildOfferCard(
                    context,
                    title: 'Spin & Win',
                    subtitle: 'Try your luck!',
                    imagePath: 'assets/coin.png', // Using coin image for now
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SpinWheelGameScreen()));
                    },
                  ),
                  _buildOfferCard(
                    context,
                    title: 'Tic Tac Toe',
                    subtitle: 'Play against NPC!',
                    imagePath: 'assets/tic_tac_toe.png',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const TicTacToeGameScreen()));
                    },
                  ),
                  _buildOfferCard(
                    context,
                    title: 'Minesweeper',
                    subtitle: 'Find the mines!',
                    imagePath: 'assets/minesweeper.png',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const MinesweeperGameScreen()));
                    },
                  ),
                  // The "Watch Ads" card is now in Quick Actions, so it's removed from here.
                  // Add more offer cards here as needed
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Container(
          width: 120, // Fixed width for quick action cards
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(13, 0, 0, 0),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfferCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // Solid white background
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(13, 0, 0, 0),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                height: 60, // Adjusted image size
                width: 60,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
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

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
