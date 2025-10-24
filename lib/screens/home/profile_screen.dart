import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart'; // Import HugeIcons
import 'package:provider/provider.dart';
import '../../providers/user_data_provider.dart';
import '../../auth_service.dart'; // Keep import for signOut
import '../../shared/shimmer_loading.dart';
import '../../models/auth_result.dart'; // Import AuthResult
import '../info/privacy_policy_screen.dart'; // Import PrivacyPolicyScreen
import '../info/terms_of_service_screen.dart'; // Import TermsOfServiceScreen

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authResult = Provider.of<AuthResult?>(context);
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final userData = userDataProvider.userData; // This is a DocumentSnapshot

    if (authResult?.uid == null || userData == null || !userData.exists) {
      return const ProfileScreenLoading();
    }


    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isLargeScreen = screenWidth > 800; // Define what constitutes a "large screen"
            final horizontalPadding = isLargeScreen ? constraints.maxWidth * 0.2 : 20.0;
            final verticalSpacing = isLargeScreen ? 40.0 : 20.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: isLargeScreen ? 80 : 50),
                  CircleAvatar(
                    radius: isLargeScreen ? 80 : 60,
                    backgroundColor: Colors.grey.shade200,
                    child: HugeIcon(icon: HugeIcons.strokeRoundedUser, size: isLargeScreen ? 80 : 60, color: Colors.grey.shade600),
                  ),
                  SizedBox(height: isLargeScreen ? 20 : 15),
                  Text(
                    authResult?.uid?.split('@')[0] ?? 'No Email',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black87,
                          fontSize: isLargeScreen ? 24 : 18,
                        ),
                  ),
                  SizedBox(height: isLargeScreen ? 10 : 8),
                  Card(
                    elevation: 0.0,
                    color: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      child: Row(
                        children: [
                          HugeIcon(icon: HugeIcons.strokeRoundedId, color: Theme.of(context).primaryColor, size: isLargeScreen ? 24 : 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              authResult?.uid ?? 'UID not available',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.black87,
                                fontSize: isLargeScreen ? 16 : 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: verticalSpacing),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0), // Padding handled by parent SingleChildScrollView
                      child: Text(
                        'Account',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.grey.shade700,
                              fontSize: isLargeScreen ? 18 : 14,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildAccountOption(
                    context,
                    title: 'Coins',
                    value: '${userDataProvider.totalCoins}', // Use the combined totalCoins from UserDataProvider
                    icon: HugeIcons.strokeRoundedBitcoinBag, // Changed to HugeIcons.strokeRoundedBitcoinBag
                  ),
                  SizedBox(height: verticalSpacing),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0), // Padding handled by parent SingleChildScrollView
                      child: Text(
                        'Settings',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.grey.shade700,
                              fontSize: isLargeScreen ? 18 : 14,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildSettingsOption(
                    context,
                    title: 'Notifications',
                    onTap: () {
                      // Navigate to notifications settings
                    },
                  ),
                  _buildSettingsOption(
                    context,
                    title: 'Privacy',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                      );
                    },
                  ),
                  _buildSettingsOption(
                    context,
                    title: 'Terms and Conditions',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TermsOfServiceScreen()),
                      );
                    },
                  ),
                  _buildSettingsOption(
                    context,
                    title: 'Logout',
                    onTap: () async {
                      await AuthService().signOut();
                    },
                    isLogout: true,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAccountOption(BuildContext context, {required String title, required String value, required List<List<dynamic>> icon}) { // Changed type to List<List<dynamic>>
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Row(
            children: [
              HugeIcon(icon: icon, color: Colors.amber, size: 20), // Replaced Icon with HugeIcon
              const SizedBox(width: 5),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsOption(BuildContext context, {required String title, required VoidCallback onTap, bool isLogout = false}) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: ListTile(
            title: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isLogout ? Colors.red : Colors.black87,
              ),
            ),
            trailing: isLogout ? null : HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, size: 18, color: Colors.grey), // Replaced Icon with HugeIcon
            onTap: onTap,
          ),
        ),
        if (!isLogout) const SizedBox(height: 5), // Add a small space between settings options
      ],
    );
  }
}

class ProfileScreenLoading extends StatelessWidget {
  const ProfileScreenLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
    ));
  }
}
