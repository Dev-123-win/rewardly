import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../design_system/design_system.dart';
import '../../design_system/app_icons.dart';
import '../../shared/shimmer_loading.dart';
import '../../providers/user_data_provider.dart';
import '../../models/auth_result.dart';
import '../../widgets/how_to_earn_guide.dart';
import '../../widgets/page_transitions.dart';
import '../notifications/notification_center_screen.dart';
import 'earn_coins_screen.dart';
import 'referral_screen.dart';
import 'profile_screen.dart';
import 'withdraw_screen.dart';
import 'tic_tac_toe_game_screen.dart';
import 'minesweeper_game_screen.dart';
import 'spin_wheel_game_screen.dart';

class HomeRefactored extends StatefulWidget {
  const HomeRefactored({super.key});

  @override
  State<HomeRefactored> createState() => _HomeRefactoredState();
}

class _HomeRefactoredState extends State<HomeRefactored>
    with TickerProviderStateMixin {
  int _selectedIndex = 2; // Set Home as initial selected index
  late AnimationController _coinAnimationController;
  late Animation<double> _coinAnimation;
  int _previousCoins = 0;

  @override
  void initState() {
    super.initState();
    _coinAnimationController = AnimationController(
      vsync: this,
      duration: DesignSystem.durationNormal,
    );
    _coinAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _coinAnimationController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userDataProvider =
          Provider.of<UserDataProvider>(context, listen: false);
      _previousCoins =
          (userDataProvider.userData?.data() as Map<String, dynamic>?)?['coins']
              as int? ??
              0;
      _coinAnimation = Tween<double>(
              begin: _previousCoins.toDouble(), end: _previousCoins.toDouble())
          .animate(_coinAnimationController);

      userDataProvider.addListener(_onCoinsChanged);
    });
  }

  void _onCoinsChanged() {
    final userDataProvider =
        Provider.of<UserDataProvider>(context, listen: false);
    final newCoins =
        (userDataProvider.userData?.data() as Map<String, dynamic>?)?['coins']
            as int? ??
            0;

    if (newCoins != _previousCoins) {
      _coinAnimation = Tween<double>(
              begin: _previousCoins.toDouble(), end: newCoins.toDouble())
          .animate(
        CurvedAnimation(parent: _coinAnimationController, curve: Curves.easeOut),
      );
      _coinAnimationController.forward(from: 0.0);
      _previousCoins = newCoins;
    }
  }

  @override
  void dispose() {
    _coinAnimationController.dispose();
    Provider.of<UserDataProvider>(context, listen: false)
        .removeListener(_onCoinsChanged);
    super.dispose();
  }

  List<Widget> _buildScreens() {
    return [
      Consumer<UserDataProvider>(
        builder: (context, userDataProvider, _) => userDataProvider.userData ==
                null
            ? const _LoadingPlaceholder()
            : const WithdrawScreen(),
      ),
      Consumer<UserDataProvider>(
        builder: (context, userDataProvider, _) => userDataProvider.userData ==
                null
            ? const _LoadingPlaceholder()
            : const ReferralScreen(),
      ),
      _buildHomePageContent(),
      Consumer<UserDataProvider>(
        builder: (context, userDataProvider, _) => userDataProvider.userData ==
                null
            ? const _LoadingPlaceholder()
            : const ProfileScreen(),
      ),
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
        backgroundColor: DesignSystem.background,
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
          selectedItemColor: DesignSystem.primary,
          unselectedItemColor: DesignSystem.textTertiary,
          backgroundColor: DesignSystem.background,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildHomePageContent() {
    final authResult = Provider.of<AuthResult?>(context);
    final userDataProvider = Provider.of<UserDataProvider>(context);

    if (authResult?.uid == null || userDataProvider.userData == null) {
      return const HomeScreenLoading();
    }

    int coins =
        (userDataProvider.userData!.data() as Map<String, dynamic>?)?['coins'] ??
            0;
    double totalBalanceINR = coins / 1000.0;

    return RefreshIndicator(
      onRefresh: () async {
        await userDataProvider.updateUser(authResult?.uid);
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeaderSection(totalBalanceINR, coins),

            SizedBox(height: DesignSystem.spacing7),

            // How to Earn Guide
            const HowToEarnGuide(),

            SizedBox(height: DesignSystem.spacing7),

            // Primary Actions
            _buildPrimaryActionsSection(),

            SizedBox(height: DesignSystem.spacing7),

            // Featured Offers
            _buildFeaturedOffersSection(),

            SizedBox(height: DesignSystem.spacing7),

            // Games Section
            _buildGamesSection(),

            SizedBox(height: DesignSystem.spacing7),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(double totalBalanceINR, int coins) {
    return Container(
      padding: EdgeInsets.all(DesignSystem.spacing6),
      decoration: BoxDecoration(
        gradient: DesignSystem.gradientPrimary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(DesignSystem.radiusXL),
          bottomRight: Radius.circular(DesignSystem.radiusXL),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hello, User!',
                style: DesignSystem.headlineLarge.copyWith(
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    SlidePageRoute(
                      child: const NotificationCenterScreen(),
                    ),
                  );
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius:
                        BorderRadius.circular(DesignSystem.radiusMedium),
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: AppIcons.notification,
                      color: Colors.white,
                      size: AppIcons.sizeMedium,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSystem.spacing6),
          _buildBalanceCard(totalBalanceINR, coins),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(double totalBalanceINR, int coins) {
    return Container(
      padding: EdgeInsets.all(DesignSystem.spacing5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
        boxShadow: [DesignSystem.shadowLarge],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Balance',
                style: DesignSystem.bodyMedium.copyWith(
                  color: DesignSystem.textSecondary,
                ),
              ),
              SizedBox(height: DesignSystem.spacing2),
              Text(
                '₹${totalBalanceINR.toStringAsFixed(2)}',
                style: DesignSystem.displaySmall.copyWith(
                  color: DesignSystem.primary,
                ),
              ),
              SizedBox(height: DesignSystem.spacing1),
              AnimatedBuilder(
                animation: _coinAnimation,
                builder: (context, child) {
                  return Text(
                    '(${_coinAnimation.value.toInt()} coins)',
                    style: DesignSystem.bodySmall.copyWith(
                      color: DesignSystem.textSecondary,
                    ),
                  );
                },
              ),
            ],
          ),
          Image.asset(
            'assets/coin.png',
            width: 60,
            height: 60,
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryActionsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: DesignSystem.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: DesignSystem.headlineMedium.copyWith(
              color: DesignSystem.textPrimary,
            ),
          ),
          SizedBox(height: DesignSystem.spacing4),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: AppIcons.earn,
                  label: 'Watch Ads',
                  color: DesignSystem.warning,
                  onTap: () {
                    Navigator.push(
                      context,
                      SlidePageRoute(
                        child: const EarnCoinsScreen(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: DesignSystem.spacing3),
              Expanded(
                child: _buildActionButton(
                  icon: AppIcons.invite,
                  label: 'Refer',
                  color: DesignSystem.secondary,
                  onTap: () {
                    Navigator.push(
                      context,
                      SlidePageRoute(
                        child: const ReferralScreen(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: DesignSystem.spacing3),
              Expanded(
                child: _buildActionButton(
                  icon: AppIcons.redeem,
                  label: 'Redeem',
                  color: DesignSystem.success,
                  onTap: () {
                    setState(() => _selectedIndex = 0);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required List<List<dynamic>> icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(DesignSystem.spacing4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          children: [
            HugeIcon(
              icon: icon,
              color: color,
              size: AppIcons.sizeLarge,
            ),
            SizedBox(height: DesignSystem.spacing2),
            Text(
              label,
              style: DesignSystem.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedOffersSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: DesignSystem.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Featured',
            style: DesignSystem.headlineMedium.copyWith(
              color: DesignSystem.textPrimary,
            ),
          ),
          SizedBox(height: DesignSystem.spacing4),
          Row(
            children: [
              Expanded(
                child: _buildOfferCard(
                  title: 'Spin & Win',
                  subtitle: 'Try your luck!',
                  gradient: LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      SlidePageRoute(
                        child: const SpinWheelGameScreen(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: DesignSystem.spacing3),
              Expanded(
                child: _buildOfferCard(
                  title: 'Watch & Earn',
                  subtitle: 'Get coins now',
                  gradient: LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      SlidePageRoute(
                        child: const EarnCoinsScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard({
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
          boxShadow: [DesignSystem.shadowLarge],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(DesignSystem.spacing4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: DesignSystem.titleLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: DesignSystem.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGamesSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: DesignSystem.spacing4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Play & Earn',
            style: DesignSystem.headlineMedium.copyWith(
              color: DesignSystem.textPrimary,
            ),
          ),
          SizedBox(height: DesignSystem.spacing4),
          Row(
            children: [
              Expanded(
                child: _buildGameCard(
                  title: 'Tic Tac Toe',
                  icon: Icons.grid_3x3,
                  onTap: () {
                    Navigator.push(
                      context,
                      SlidePageRoute(
                        child: const TicTacToeGameScreen(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: DesignSystem.spacing3),
              Expanded(
                child: _buildGameCard(
                  title: 'Minesweeper',
                  icon: Icons.grid_on,
                  onTap: () {
                    Navigator.push(
                      context,
                      SlidePageRoute(
                        child: const MinesweeperGameScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(DesignSystem.spacing4),
        decoration: BoxDecoration(
          color: DesignSystem.surface,
          borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
          border: Border.all(color: DesignSystem.outline),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: DesignSystem.primary,
            ),
            SizedBox(height: DesignSystem.spacing2),
            Text(
              title,
              style: DesignSystem.titleMedium.copyWith(
                color: DesignSystem.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
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
          backgroundColor: DesignSystem.background,
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
            color: DesignSystem.background,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const ShimmerLoading.rectangular(
                      height: 200, width: double.infinity),
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
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: DesignSystem.primary,
          ),
        ),
      ),
    );
  }
}
