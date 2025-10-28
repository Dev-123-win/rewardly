import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart'; // Import HugeIcons
import 'package:provider/provider.dart';
import '../../shared/shimmer_loading.dart';
import '../../providers/user_data_provider.dart';
import 'earn_coins_screen.dart';
import 'referral_screen.dart';
import 'profile_screen.dart';
import 'withdraw_screen.dart';
import 'tic_tac_toe_game_screen.dart';
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

class _HomeState extends State<Home> with TickerProviderStateMixin {
  int _selectedIndex = 2; // Set Home as initial selected index
  late AnimationController _coinAnimationController;
  late Animation<double> _coinAnimation;
  int _previousCoins = 0;

  @override
  void initState() {
    super.initState();
    _coinAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _coinAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_coinAnimationController);

    // Listen to UserDataProvider for coin changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
      _previousCoins = (userDataProvider.userData?.data() as Map<String, dynamic>?)?['coins'] as int? ?? 0;
      _coinAnimation = Tween<double>(begin: _previousCoins.toDouble(), end: _previousCoins.toDouble()).animate(_coinAnimationController);

      userDataProvider.addListener(_onCoinsChanged);
    });
  }

  void _onCoinsChanged() {
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    final newCoins = (userDataProvider.userData?.data() as Map<String, dynamic>?)?['coins'] as int? ?? 0;

    if (newCoins != _previousCoins) {
      _coinAnimation = Tween<double>(begin: _previousCoins.toDouble(), end: newCoins.toDouble()).animate(
        CurvedAnimation(parent: _coinAnimationController, curve: Curves.easeOut),
      );
      _coinAnimationController.forward(from: 0.0);
      _previousCoins = newCoins;
    }
  }

  @override
  void dispose() {
    _coinAnimationController.dispose();
    Provider.of<UserDataProvider>(context, listen: false).removeListener(_onCoinsChanged);
    super.dispose();
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
    ];
  }

  List<BottomNavigationBarItem> _buildNavBarItems() {
    List<BottomNavigationBarItem> items = [
      BottomNavigationBarItem(
        icon: HugeIcon(icon: HugeIcons.strokeRoundedGift),
        label: 'Redeem',
      ),
      BottomNavigationBarItem(
        icon: HugeIcon(icon: HugeIcons.strokeRoundedUserAdd01),
        label: 'Invite',
      ),
      BottomNavigationBarItem(
        icon: HugeIcon(icon: HugeIcons.strokeRoundedHome01),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: HugeIcon(icon: HugeIcons.strokeRoundedUser),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isSmallScreen = screenWidth < 600;
        final horizontalPadding = isSmallScreen ? 16.0 : 24.0;
        final headerTopPadding = isSmallScreen ? 40.0 : 60.0;
        final headerBottomPadding = isSmallScreen ? 20.0 : 30.0;
        final sectionTitleFontSize = isSmallScreen ? 20.0 : 24.0;
        final quickActionCardWidth = isSmallScreen ? 120.0 : 150.0;
        return SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Custom Header Section
                Container(
                  padding: EdgeInsets.only(top: headerTopPadding, left: horizontalPadding, right: horizontalPadding, bottom: headerBottomPadding),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((255 * 0.1).round()),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Color.fromARGB((255 * 0.2).round(), 255, 255, 255),
                                    child: HugeIcon(icon: HugeIcons.strokeRoundedUser, color: Theme.of(context).primaryColor, size: isSmallScreen ? 24 : 30),
                                  ),
                                  SizedBox(width: isSmallScreen ? 8 : 10),
                                  Expanded(
                                    child: Text(
                                      'Hello, User!',
                                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.black, fontSize: isSmallScreen ? 18 : 22),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: HugeIcon(icon: HugeIcons.strokeRoundedNotification01, color: Theme.of(context).primaryColor, size: isSmallScreen ? 24 : 28),
                              onPressed: () {
                                LoggerService.info('Notifications icon tapped');
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: isSmallScreen ? 15 : 20),
                        // Centralized Balance Card
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIndex = 0;
                            });
                          },
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                            elevation: 0.0,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 20 : 25, horizontal: isSmallScreen ? 15 : 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total Balance',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600], fontSize: isSmallScreen ? 16 : 18),
                                      ),
                                      SizedBox(height: isSmallScreen ? 3 : 5),
                                      Text(
                                        '₹${totalBalanceINR.toStringAsFixed(2)}',
                                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: isSmallScreen ? 30 : 36,
                                        ),
                                      ),
                                      AnimatedBuilder(
                                        animation: _coinAnimation,
                                        builder: (context, child) {
                                          return Text(
                                            '(${_coinAnimation.value.toInt()} coins)',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54, fontSize: isSmallScreen ? 12 : 14),
                                          );
                                        },
                                      ),
                                      SizedBox(height: isSmallScreen ? 10 : 15),
                                      CustomButton(
                                        text: 'Withdraw',
                                        onPressed: () {
                                          setState(() {
                                            _selectedIndex = 0; // Navigate to Withdraw screen
                                          });
                                        },
                                        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20 : 25, vertical: isSmallScreen ? 8 : 10),
                                        startColor: Colors.white, // Changed to white background
                                        endColor: Colors.white, // Changed to white background
                                        borderColor: Colors.blue.shade300, // Added light blue border
                                        borderWidth: 1.0, // Border width
                                        textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.green, fontSize: isSmallScreen ? 14 : 16), // Changed text color to green
                                      ),
                                    ],
                                  ),
                                  Image.asset(
                                    'assets/coin.png',
                                    height: isSmallScreen ? 35 : 40,
                                    width: isSmallScreen ? 35 : 40,
                                    fit: BoxFit.contain,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 15 : 20),
                // Quick Actions Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.black87, fontSize: sectionTitleFontSize),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 10 : 15),
                SizedBox(
                  height: isSmallScreen ? 90 : 110,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    children: [
                      _buildQuickActionCard(
                        context,
                        imagePath: 'assets/Invite friends.png', // Use image for Invite Friends
                        label: 'Invite Friends',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ReferralScreen()));
                        },
                        startColor: Colors.blue.shade400,
                        endColor: Colors.blue.shade700,
                        cardWidth: quickActionCardWidth,
                        imageSize: isSmallScreen ? 40 : 50, // Adjust image size
                        labelFontSize: isSmallScreen ? 12 : 14,
                      ),
                      SizedBox(width: isSmallScreen ? 10 : 15),
                      _buildQuickActionCard(
                        context,
                        imagePath: 'assets/DailyStreak.jpg', // Use image for Daily Streak
                        label: 'Daily Streak',
                        onTap: () {
                          // TODO: Implement Daily Streak functionality
                          LoggerService.info('Daily Streak tapped');
                        },
                        startColor: Colors.purple.shade400,
                        endColor: Colors.purple.shade700,
                        cardWidth: quickActionCardWidth,
                        imageSize: isSmallScreen ? 40 : 50, // Adjust image size
                        labelFontSize: isSmallScreen ? 12 : 14,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 20 : 30),
                // Play Games Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Text(
                    'Play Games',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.black87, fontSize: sectionTitleFontSize),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 10 : 15),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    children: [
                      _buildVisitAndEarnCard(
                        context,
                        title: 'VISIT & EARN',
                        subtitle: 'Visit To Earn Coins',
                        imagePath: 'assets/ReadAndEarn.png',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ReadAndEarnScreen()));
                        },
                        isSmallScreen: isSmallScreen,
                      ),
                      SizedBox(height: isSmallScreen ? 10 : 15),
                      Row(
                        children: [
                          Expanded(
                            child: _buildOfferCard(
                              context,
                              title: 'TIC TAC TOE',
                              subtitle: 'Beat AI\nINFINITE COINS',
                              imagePath: 'assets/TicTacToe.png',
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const TicTacToeGameScreen()));
                              },
                              startColor: Colors.grey.shade200, // Changed color to match image
                              endColor: Colors.grey.shade50, // Changed color to match image
                              imageSize: isSmallScreen ? 80 : 100, // Increased image size
                              titleFontSize: isSmallScreen ? 14 : 16,
                              subtitleFontSize: isSmallScreen ? 10 : 12,
                              textColor: Colors.black87, // Added text color
                              subtitleColor: Colors.black54, // Added subtitle color
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 10 : 15),
                          Expanded(
                            child: Column(
                              children: [
                                _buildOfferCard(
                                  context,
                                  title: 'WATCH ADS',
                                  subtitle: 'Watch & Earn',
                                  imagePath: 'assets/WatchAndEarn.png',
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const EarnCoinsScreen()));
                                  },
                                  startColor: Colors.grey.shade200, // Changed color to match image
                                  endColor: Colors.grey.shade50, // Changed color to match image
                                  imageSize: isSmallScreen ? 50 : 60,
                                  titleFontSize: isSmallScreen ? 14 : 16,
                                  subtitleFontSize: isSmallScreen ? 10 : 12,
                                  textColor: Colors.black87,
                                  subtitleColor: Colors.black54,
                                ),
                                SizedBox(height: isSmallScreen ? 10 : 15),
                                _buildOfferCard(
                                  context,
                                  title: 'SPIN WHEEL',
                                  subtitle: 'Spin & Win',
                                  imagePath: 'assets/SpinAndWin.png',
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SpinWheelGameScreen()));
                                  },
                                  startColor: Colors.grey.shade200, // Changed color to match image
                                  endColor: Colors.grey.shade50, // Changed color to match image
                                  imageSize: isSmallScreen ? 50 : 60,
                                  titleFontSize: isSmallScreen ? 14 : 16,
                                  subtitleFontSize: isSmallScreen ? 10 : 12,
                                  textColor: Colors.black87,
                                  subtitleColor: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 15 : 20),
                // Recent Earnings Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Text(
                    'Recent Earnings',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.black87, fontSize: sectionTitleFontSize),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 10 : 15),
                DefaultTabController(
                  length: 3, // Number of tabs: Games, Tasks, Ads
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Container(
                          height: isSmallScreen ? 40 : 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: TabBar(
                            indicator: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.black87,
                            tabs: const [
                              Tab(text: 'Games'),
                              Tab(text: 'Tasks'),
                              Tab(text: 'Ads'),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 10 : 15),
                      SizedBox(
                        height: 300, // Fixed height for the TabBarView
                        child: TabBarView(
                          children: [
                            _buildEarningsList('Games'), // Placeholder for Games earnings
                            _buildEarningsList('Tasks'), // Placeholder for Tasks earnings
                            _buildEarningsList('Ads'), // Placeholder for Ads earnings
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 15 : 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEarningsList(String category) {
    // This is a placeholder for the actual earnings list.
    // In a real application, this would fetch data based on the category.
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: 4, // Example items
      itemBuilder: (context, index) {
        return _buildEarningEntry(
          context,
          amount: '₹${(index + 1) * 30}',
          source: '$category Earning ${index + 1}',
          time: '${(index + 1) * 10} min ago',
          isSmallScreen: MediaQuery.of(context).size.width < 600,
        );
      },
    );
  }

  Widget _buildEarningEntry(
    BuildContext context, {
    required String amount,
    required String source,
    required String time,
    required bool isSmallScreen,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16.0 : 24.0, vertical: 5.0),
      elevation: 0.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      color: Colors.grey[100],
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12.0 : 15.0),
        child: Row(
          children: [
            Icon(Icons.add_circle_outline, color: Colors.green, size: isSmallScreen ? 20 : 24),
            SizedBox(width: isSmallScreen ? 10 : 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    amount,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.green, fontSize: isSmallScreen ? 16 : 18),
                  ),
                  Text(
                    source,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54, fontSize: isSmallScreen ? 12 : 14),
                  ),
                ],
              ),
            ),
            Text(
              time,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600], fontSize: isSmallScreen ? 10 : 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required String imagePath, // Changed from icon to imagePath
    required String label,
    required VoidCallback onTap,
    required Color startColor,
    required Color endColor,
    required double cardWidth,
    required double imageSize, // New parameter for image size
    required double labelFontSize,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0.0,
        color: Colors.transparent,
        child: Container(
          width: cardWidth,
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.grey[50], // Changed to solid light grey
            borderRadius: BorderRadius.circular(25.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((255 * 0.1).round()),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(imagePath, height: imageSize, width: imageSize, fit: BoxFit.contain), // Use Image.asset
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87, fontSize: labelFontSize), // Changed text color to dark
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
    required double imageSize,
    required double titleFontSize,
    required double subtitleFontSize,
    Color textColor = Colors.white, // New parameter for text color
    Color subtitleColor = Colors.white70, // New parameter for subtitle color
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0.0,
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[50], // Changed to solid light grey
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((255 * 0.1).round()),
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
                height: imageSize,
                width: imageSize,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: textColor, fontSize: titleFontSize),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: subtitleColor, fontSize: subtitleFontSize),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisitAndEarnCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String imagePath,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0.0,
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: Container(
          height: isSmallScreen ? 80 : 100,
          decoration: BoxDecoration(
            color: Colors.grey[50], // Changed to solid light grey
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((255 * 0.1).round()), // Consistent shadow
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Image.asset(
                  imagePath,
                  height: isSmallScreen ? 50 : 60,
                  width: isSmallScreen ? 50 : 60,
                  fit: BoxFit.contain,
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87, fontSize: isSmallScreen ? 16 : 18),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54, fontSize: isSmallScreen ? 12 : 14),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Icon(Icons.arrow_forward_ios, color: Colors.black54, size: isSmallScreen ? 20 : 24), // Changed to Material Icon
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
