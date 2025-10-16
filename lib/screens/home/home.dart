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
import 'read_and_earn_screen.dart'; // New import for Read & Earn
import '../../logger_service.dart';
import '../../models/auth_result.dart';
import '../../widgets/custom_button.dart'; // Ensure CustomButton is imported

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
                      color: Colors.black.withOpacity(0.1),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)), // Smoother corners
                        elevation: 0.0, // No elevation
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
                    startColor: Colors.orange.shade400,
                    endColor: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 15),
                  _buildQuickActionCard(
                    context,
                    icon: Icons.person_add,
                    label: 'Invite Friends',
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ReferralScreen()));
                    },
                    startColor: Colors.blue.shade400,
                    endColor: Colors.blue.shade700,
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
                    startColor: Colors.green.shade400,
                    endColor: Colors.green.shade700,
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
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildLargeOfferCard(
                          context,
                          title: 'Spin & Win',
                          subtitle: 'Try your luck!',
                          imagePath: 'assets/coin.png',
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const SpinWheelGameScreen()));
                          },
                          startColor: Colors.deepPurple.shade400,
                          endColor: Colors.deepPurple.shade700,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildLargeOfferCard(
                          context,
                          title: 'Watch & Earn',
                          subtitle: 'Get coins by watching ads!',
                          imagePath: 'assets/watch_ads.png',
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const EarnCoinsScreen()));
                          },
                          startColor: Colors.purple.shade400,
                          endColor: Colors.purple.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildSuperOfferCard(
                    context,
                    title: 'Read & Earn',
                    subtitle: 'Earn Upto 100k',
                    imagePath: 'assets/coin.png', // Placeholder image
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ReadAndEarnScreen()));
                    },
                    startColor: Colors.orange.shade400,
                    endColor: Colors.orange.shade700,
                    buttonText: 'Start Reading',
                  ),
                  const SizedBox(height: 15),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [
                      _buildOfferCard(
                        context,
                        title: 'Tic Tac Toe',
                        subtitle: 'Play against NPC!',
                        imagePath: 'assets/tic_tac_toe.png',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const TicTacToeGameScreen()));
                        },
                        startColor: Colors.red.shade400,
                        endColor: Colors.red.shade700,
                      ),
                      _buildOfferCard(
                        context,
                        title: 'Minesweeper',
                        subtitle: 'Find the mines!',
                        imagePath: 'assets/minesweeper.png',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const MinesweeperGameScreen()));
                        },
                        startColor: Colors.teal.shade400,
                        endColor: Colors.teal.shade700,
                      ),
                      // Add more offer cards here as needed
                    ],
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

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color startColor,
    required Color endColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0.0, // Remove default elevation
        color: Colors.transparent, // Make card transparent to show container's decoration
        child: Container(
          width: 120, // Fixed width for quick action cards
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25.0), // More rounded corners
            boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Subtle shadow
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Colors.white), // White icons for contrast
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600), // White text for contrast
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLargeOfferCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String imagePath,
    required VoidCallback onTap,
    required Color startColor,
    required Color endColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0.0,
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: Container(
          height: 180, // Height for large offer cards
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: Image.asset(
                  imagePath,
                  height: 80,
                  width: 80,
                  fit: BoxFit.contain,
                  color: Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuperOfferCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String imagePath,
    required VoidCallback onTap,
    required Color startColor,
    required Color endColor,
    required String buttonText,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0.0,
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: Container(
          height: 100, // Height for super offer card
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Image.asset(
                  imagePath,
                  height: 50,
                  width: 50,
                  fit: BoxFit.contain,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: CustomButton(
                  text: buttonText,
                  onPressed: onTap,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  startColor: Colors.white,
                  endColor: Colors.white,
                  textStyle: TextStyle(color: startColor, fontWeight: FontWeight.bold),
                ),
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
    required Color startColor,
    required Color endColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0.0, // Remove default elevation
        color: Colors.transparent, // Make card transparent to show container's decoration
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.0), // More rounded corners
            boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Subtle shadow
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
                color: Colors.white, // Tint image white for better contrast on gradient
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold), // White text for contrast
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70), // Lighter white for subtitle
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
