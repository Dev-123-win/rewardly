import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../providers/user_data_provider.dart';
import '../../auth_service.dart';
import '../../shared/shimmer_loading.dart';
import '../../models/auth_result.dart';
import '../info/privacy_policy_screen.dart';
import '../info/terms_of_service_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authResult = Provider.of<AuthResult?>(context);
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final userData = userDataProvider.userData;

    if (authResult?.uid == null || userData == null || !userData.exists) {
      return const ProfileScreenLoading();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;
    final horizontalPadding = isLargeScreen ? screenWidth * 0.2 : 20.0;
    final verticalSpacing = isLargeScreen ? 40.0 : 20.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: verticalSpacing),
            _ProfileHeader(
              isLargeScreen: isLargeScreen,
              authResult: authResult,
            ),
            SizedBox(height: verticalSpacing),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Account',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.grey.shade700,
                      fontSize: isLargeScreen ? 18 : 14,
                    ),
              ),
            ),
            const SizedBox(height: 10),
            _AccountCoinsCard(
              isLargeScreen: isLargeScreen,
              totalCoins: userDataProvider.totalCoins,
            ),
            SizedBox(height: verticalSpacing),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Settings',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.grey.shade700,
                      fontSize: isLargeScreen ? 18 : 14,
                    ),
              ),
            ),
            const SizedBox(height: 10),
            _SettingsOption(
              isLargeScreen: isLargeScreen,
              title: 'Notifications',
              icon: HugeIcons.strokeRoundedSchoolBell01, // Reverting to original icon
              onTap: () {
                // Navigate to notifications settings
              },
            ),
            const SizedBox(height: 5),
            _SettingsOption(
              isLargeScreen: isLargeScreen,
              title: 'Privacy',
              icon: HugeIcons.strokeRoundedCheckmarkBadge01, // Reverting to original icon
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                );
              },
            ),
            const SizedBox(height: 5),
            _SettingsOption(
              isLargeScreen: isLargeScreen,
              title: 'Terms and Conditions',
              icon: HugeIcons.strokeRoundedLegalDocument01, // Reverting to original icon
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TermsOfServiceScreen()),
                );
              },
            ),
            SizedBox(height: verticalSpacing),
            _LogoutButton(
              isLargeScreen: isLargeScreen,
              onTap: () async {
                await AuthService().signOut();
              },
            ),
            SizedBox(height: verticalSpacing),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final bool isLargeScreen;
  final AuthResult? authResult;

  const _ProfileHeader({
    required this.isLargeScreen,
    required this.authResult,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: isLargeScreen ? 80 : 60,
          backgroundColor: Colors.grey.shade200,
          child: HugeIcon(icon: HugeIcons.strokeRoundedUser, size: isLargeScreen ? 80 : 60, color: Colors.grey.shade600),
        ),
        SizedBox(height: isLargeScreen ? 20 : 15),
        Text(
          authResult?.email ?? 'Email not available',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: isLargeScreen ? 24 : 20,
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: isLargeScreen ? 5 : 3),
        Text(
          'App ID: ${authResult?.uid ?? 'UID not available'}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
                fontSize: isLargeScreen ? 16 : 14,
              ),
        ),
      ],
    );
  }
}

class _AccountCoinsCard extends StatelessWidget {
  final bool isLargeScreen;
  final int totalCoins;

  const _AccountCoinsCard({
    required this.isLargeScreen,
    required this.totalCoins,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isLargeScreen ? 20 : 15, horizontal: isLargeScreen ? 25 : 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                HugeIcon(icon: HugeIcons.strokeRoundedBitcoinBag, color: Colors.amber, size: isLargeScreen ? 28 : 24),
                SizedBox(width: isLargeScreen ? 15 : 10),
                Text(
                  'Coins',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: isLargeScreen ? 18 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            Text(
              '$totalCoins',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: isLargeScreen ? 22 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsOption extends StatelessWidget {
  final bool isLargeScreen;
  final String title;
  final List<List<dynamic>> icon;
  final VoidCallback onTap;

  const _SettingsOption({
    required this.isLargeScreen,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      child: ListTile(
        leading: HugeIcon(icon: icon, size: isLargeScreen ? 24 : 20, color: Theme.of(context).primaryColor),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: isLargeScreen ? 18 : 16,
              ),
        ),
        trailing: HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, size: isLargeScreen ? 20 : 18, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final bool isLargeScreen;
  final VoidCallback onTap;

  const _LogoutButton({
    required this.isLargeScreen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: isLargeScreen ? 60 : 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Text(
          'Logout',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.red.shade700,
                fontSize: isLargeScreen ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}

class ProfileScreenLoading extends StatelessWidget {
  const ProfileScreenLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 50),
            ShimmerLoading.circular(width: 120, height: 120),
            const SizedBox(height: 15),
            ShimmerLoading.rectangular(height: 20, width: 200),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ShimmerLoading.rectangular(height: 16, width: 80),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ShimmerLoading.rectangular(height: 60, width: double.infinity),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ShimmerLoading.rectangular(height: 16, width: 80),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ShimmerLoading.rectangular(height: 60, width: double.infinity),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ShimmerLoading.rectangular(height: 60, width: double.infinity),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ShimmerLoading.rectangular(height: 60, width: double.infinity),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ShimmerLoading.rectangular(height: 60, width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}
