import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rewardly_app/providers/user_data_provider.dart';
import 'package:rewardly_app/auth_service.dart';
import 'package:rewardly_app/shared/shimmer_loading.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final userData = userDataProvider.userData;

    if (user == null || userData == null) {
      return const ProfileScreenLoading();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 50),
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: userData['profile_picture'] != null
                  ? NetworkImage(userData['profile_picture'])
                  : null,
              child: userData['profile_picture'] == null
                  ? Icon(Icons.person, size: 60, color: Colors.grey.shade600)
                  : null,
            ),
            const SizedBox(height: 15),
            Text(
              user.email ?? 'No Email',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black87),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Account',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey.shade700),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _buildAccountOption(
              context,
              title: 'Coins',
              value: '${userData['coins'] ?? 0}',
              icon: Icons.monetization_on,
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Settings',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey.shade700),
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
                // Navigate to privacy settings
              },
            ),
            _buildSettingsOption(
              context,
              title: 'Security',
              onTap: () {
                // Navigate to security settings
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
      ),
    );
  }

  Widget _buildAccountOption(BuildContext context, {required String title, required String value, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
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
              Icon(icon, color: Colors.amber, size: 20),
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
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            title: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isLogout ? Colors.red : Colors.black87,
              ),
            ),
            trailing: isLogout ? null : const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
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
    return Scaffold(
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
