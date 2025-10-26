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
        final largeOfferCardHeight = isSmallScreen ? 180.0 : 220.0;
        final superOfferCardHeight = isSmallScreen ? 100.0 : 120.0;
        final gridCrossAxisCount = isSmallScreen ? 2 : 3;
        final gridSpacing = isSmallScreen ? 15.0 : 20.0;

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
                        icon: HugeIcons.strokeRoundedVideoCameraAi,
                        label: 'Watch Ads',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const EarnCoinsScreen()));
                        },
                        startColor: Colors.orange.shade400,
                        endColor: Colors.orange.shade700,
                        cardWidth: quickActionCardWidth,
                        iconSize: isSmallScreen ? 25 : 30,
                        labelFontSize: isSmallScreen ? 12 : 14,
                      ),
                      SizedBox(width: isSmallScreen ? 10 : 15),
                      _buildQuickActionCard(
                        context,
                        icon: HugeIcons.strokeRoundedUserAdd01,
                        label: 'Invite Friends',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ReferralScreen()));
                        },
                        startColor: Colors.blue.shade400,
                        endColor: Colors.blue.shade700,
                        cardWidth: quickActionCardWidth,
                        iconSize: isSmallScreen ? 25 : 30,
                        labelFontSize: isSmallScreen ? 12 : 14,
                      ),
                      SizedBox(width: isSmallScreen ? 10 : 15),
                      _buildQuickActionCard(
                        context,
                        icon: HugeIcons.strokeRoundedGift,
                        label: 'Redeem Coins',
                        onTap: () {
                          setState(() {
                            _selectedIndex = 0;
                          });
                        },
                        startColor: Colors.green.shade400,
                        endColor: Colors.green.shade700,
                        cardWidth: quickActionCardWidth,
                        iconSize: isSmallScreen ? 25 : 30,
                        labelFontSize: isSmallScreen ? 12 : 14,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 20 : 30),
                // Main Offer Grid
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Text(
                    'Explore & Earn',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.black87, fontSize: sectionTitleFontSize),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 10 : 15),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildLargeOfferCard(
                              context,
                              title: 'Spin & Win',
                              subtitle: 'Try your luck!',
                              imagePath: 'assets/spin and win.png',
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const SpinWheelGameScreen()));
                              },
                              startColor: Colors.deepPurple.shade400,
                              endColor: Colors.deepPurple.shade700,
                              cardHeight: largeOfferCardHeight,
                              imageSize: isSmallScreen ? 60 : 80,
                              titleFontSize: isSmallScreen ? 16 : 18,
                              subtitleFontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 10 : 15),
                          Expanded(
                            child: _buildLargeOfferCard(
                              context,
                              title: 'Watch & Earn',
                              subtitle: 'Get coins by watching ads!',
                              imagePath: 'assets/watch and earn.png',
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const EarnCoinsScreen()));
                              },
                              startColor: Colors.purple.shade400,
                              endColor: Colors.purple.shade700,
                              cardHeight: largeOfferCardHeight,
                              imageSize: isSmallScreen ? 60 : 80,
                              titleFontSize: isSmallScreen ? 16 : 18,
                              subtitleFontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 10 : 15),
                      _buildSuperOfferCard(
                        context,
                        title: 'Read & Earn',
                        subtitle: 'Earn Upto 100k',
                        imagePath: 'assets/coin.png',
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ReadAndEarnScreen()));
                        },
                        startColor: Colors.orange.shade400,
                        endColor: Colors.orange.shade700,
                        buttonText: 'Start Reading',
                        cardHeight: superOfferCardHeight,
                        imageSize: isSmallScreen ? 40 : 50,
                        titleFontSize: isSmallScreen ? 16 : 18,
                        subtitleFontSize: isSmallScreen ? 12 : 14,
                        buttonPadding: isSmallScreen ? EdgeInsets.symmetric(horizontal: 12, vertical: 6) : EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        buttonTextStyle: isSmallScreen ? Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white) : Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                      SizedBox(height: isSmallScreen ? 10 : 15),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: gridCrossAxisCount,
                        crossAxisSpacing: gridSpacing,
                        mainAxisSpacing: gridSpacing,
                        children: [
                          _buildOfferCard(
                            context,
                            title: 'Tic Tac Toe',
                            subtitle: 'Play against NPC!',
                            imagePath: 'assets/tictactoe.png',
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const TicTacToeGameScreen()));
                            },
                            startColor: Colors.red.shade400,
                            endColor: Colors.red.shade700,
                            imageSize: isSmallScreen ? 50 : 60,
                            titleFontSize: isSmallScreen ? 14 : 16,
                            subtitleFontSize: isSmallScreen ? 10 : 12,
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
                            imageSize: isSmallScreen ? 50 : 60,
                            titleFontSize: isSmallScreen ? 14 : 16,
                            subtitleFontSize: isSmallScreen ? 10 : 12,
                          ),
                        ],
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

  Widget _buildQuickActionCard(
    BuildContext context, {
    required dynamic icon,
    required String label,
    required VoidCallback onTap,
    required Color startColor,
    required Color endColor,
    required double cardWidth,
    required double iconSize,
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
            gradient: LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
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
              HugeIcon(icon: icon, size: iconSize, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white, fontSize: labelFontSize),
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
    required double cardHeight,
    required double imageSize,
    required double titleFontSize,
    required double subtitleFontSize,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0.0,
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: Container(
          height: cardHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((255 * 0.1).round()),
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
                  height: imageSize,
                  width: imageSize,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontSize: titleFontSize),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70, fontSize: subtitleFontSize),
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
    required double cardHeight,
    required double imageSize,
    required double titleFontSize,
    required double subtitleFontSize,
    required EdgeInsetsGeometry buttonPadding,
    required TextStyle? buttonTextStyle,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0.0,
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: Container(
          height: cardHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((255 * 0.1).round()),
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
                  height: imageSize,
                  width: imageSize,
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontSize: titleFontSize),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70, fontSize: subtitleFontSize),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: CustomButton(
                  text: buttonText,
                  onPressed: onTap,
                  padding: buttonPadding,
                  startColor: Colors.white,
                  endColor: Colors.white,
                  textStyle: buttonTextStyle,
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
    required double imageSize,
    required double titleFontSize,
    required double subtitleFontSize,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0.0,
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontSize: titleFontSize),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70, fontSize: subtitleFontSize),
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
