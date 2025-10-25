import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
//import 'dart:convert';
//import 'dart:typed_data';
import 'package:share_plus/share_plus.dart'; // Added share_plus import
import '../../providers/user_data_provider.dart';
import '../../shared/shimmer_loading.dart';
import 'referral_rules_widget.dart'; // Import the new widget
import 'referral_history_screen.dart'; // Import the referral history screen
import 'package:hugeicons/hugeicons.dart';


class ReferralScreenLoading extends StatelessWidget {
  const ReferralScreenLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: ShimmerLoading.rectangular(height: 24, width: 120),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              ShimmerLoading.circular(width: 120, height: 120),
              const SizedBox(height: 30),
              ShimmerLoading.rectangular(height: 28, width: 250),
              const SizedBox(height: 15),
              ShimmerLoading.rectangular(height: 18, width: 300),
              const SizedBox(height: 40),
              ShimmerLoading.rectangular(height: 22, width: 180),
              const SizedBox(height: 10),
              ShimmerLoading.rectangular(height: 60, width: double.infinity),
              const SizedBox(height: 30),
              ShimmerLoading.rectangular(height: 50, width: double.infinity),
            ],
          ),
        ),
      ),
    );
  }
}

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context);

    if (userDataProvider.isLoading) {
      return const ReferralScreenLoading();
    }

    final userData = userDataProvider.userData;

    if (userData == null) {
      return const ReferralScreenLoading();
    }

    final data = userData.data() as Map<String, dynamic>?;
    final referralCode = data?['referralCode'] as String? ?? 'N/A';
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final isSmallScreen = screenWidth < 600;

                final horizontalPadding = isSmallScreen ? 20.0 : screenWidth * 0.1;
                final verticalSpacing = isSmallScreen ? 20.0 : 30.0;
                final titleFontSize = isSmallScreen ? 24.0 : 32.0;
                final subtitleFontSize = isSmallScreen ? 18.0 : 22.0;
                final bodyFontSize = isSmallScreen ? 14.0 : 16.0;
                final imageSize = isSmallScreen ? 150.0 : 200.0;
                final referralCodeFontSize = isSmallScreen ? 20.0 : 24.0;
                final copyIconSize = isSmallScreen ? 20.0 : 24.0;
                final buttonPadding = isSmallScreen ? EdgeInsets.symmetric(horizontal: 20, vertical: 12) : EdgeInsets.symmetric(horizontal: 30, vertical: 15);
                final buttonTextFontSize = isSmallScreen ? 16.0 : 18.0;
                final referralCardPadding = isSmallScreen ? 15.0 : 20.0;
                final referralCardIconSize = isSmallScreen ? 50.0 : 60.0;
                final referralCardTitleFontSize = isSmallScreen ? 18.0 : 22.0;
                final referralCardSubtitleFontSize = isSmallScreen ? 14.0 : 16.0;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalSpacing),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'We Share More.\nWe Earn More.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.black87, fontSize: titleFontSize),
                      ),
                      SizedBox(height: verticalSpacing * 0.75),
                      Text(
                        'Invite your Friends, Win Rewards!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.deepPurple,
                              fontSize: subtitleFontSize,
                            ),
                      ),
                      SizedBox(height: verticalSpacing * 0.5),
                      Text(
                        'Refer and Win. Share with Friends, Unlock Exciting Rewards!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black54, fontSize: bodyFontSize),
                      ),
                      SizedBox(height: verticalSpacing),
                      Image.asset(
                        'assets/referral.png',
                        height: imageSize,
                        width: imageSize,
                        fit: BoxFit.contain,
                      ),
                      Image.asset(
                        'assets/referral_banner.png',
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: verticalSpacing),
                      Text(
                        'Your Invite Code',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black87, fontSize: subtitleFontSize),
                      ),
                      SizedBox(height: verticalSpacing * 0.5),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: referralCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Referral code copied to clipboard!')),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 0 : horizontalPadding / 2),
                          padding: EdgeInsets.symmetric(horizontal: referralCardPadding, vertical: referralCardPadding),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(25.0),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                referralCode,
                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.deepPurple, letterSpacing: 2, fontSize: referralCodeFontSize),
                              ),
                              SizedBox(width: isSmallScreen ? 8 : 10),
                              HugeIcon(icon: HugeIcons.strokeRoundedCopy01, color: Colors.deepPurple.shade400, size: copyIconSize),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: verticalSpacing),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final box = context.findRenderObject() as RenderBox?;
                          await SharePlus.instance.share(
                            ShareParams(
                              text: 'Join Rewardly and earn rewards! Use my referral code: $referralCode',
                              subject: 'Join Rewardly!',
                              sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
                            ),
                          );
                        },
                        icon: HugeIcon(icon: HugeIcons.strokeRoundedShare01, color: Colors.white, size: copyIconSize),
                        label: Text(
                          'Refer Now',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontSize: buttonTextFontSize),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: buttonPadding,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                        ),
                      ),
                      const ReferralRulesWidget(),
                      SizedBox(height: verticalSpacing),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ReferralHistoryScreen()),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 0 : horizontalPadding / 2),
                          padding: EdgeInsets.all(referralCardPadding),
                          decoration: BoxDecoration(
                            color: Colors.lightBlue.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Here is your\nReferral earning',
                                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.black87, fontSize: referralCardTitleFontSize),
                                    ),
                                    SizedBox(height: isSmallScreen ? 8 : 10),
                                    Text(
                                      'Multiply Your Rewards\nWith Referrals! Refer, E...',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54, fontSize: referralCardSubtitleFontSize),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  HugeIcon(
                                    icon: HugeIcons.strokeRoundedTime04,
                                    size: referralCardIconSize,
                                    color: Colors.deepPurple.shade400,
                                  ),
                                  SizedBox(height: isSmallScreen ? 3 : 5),
                                  Text(
                                    'Click Here\nTo See You...',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blue.shade700, fontSize: isSmallScreen ? 12 : 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
