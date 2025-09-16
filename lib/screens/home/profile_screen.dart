import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rewardly_app/providers/user_data_provider.dart';
import 'package:rewardly_app/auth_service.dart'; // Assuming AuthService is used for sign out
import 'package:rewardly_app/shared/shimmer_loading.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final userDataProvider = Provider.of<UserDataProvider>(context);
    final userData = userDataProvider.userData;

    if (user == null || userData == null) {
      return const ProfileScreenLoading(); // Show loading indicator
    }

    return Scaffold(
      // AppBar removed as per request
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Profile Header (can be customized to include user info without an AppBar)
            Container(
              padding: const EdgeInsets.all(20.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.2 * 255).round()),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 40), // Space for status bar
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: userData['profile_picture'] != null
                        ? NetworkImage(userData['profile_picture'])
                        : null,
                    child: userData['profile_picture'] == null
                        ? Icon(Icons.person, size: 60, color: Colors.deepPurple.shade300)
                        : null,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    userData['name'] ?? 'Guest User',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    user.email ?? 'No Email',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withAlpha((0.8 * 255).round())),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Coins: ${userData['coins'] ?? 0}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.amberAccent),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Profile Options
            _buildProfileOption(
              context,
              icon: Icons.edit,
              title: 'Edit Profile',
              onTap: () {
                // Navigate to edit profile screen
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.history,
              title: 'Transaction History',
              onTap: () {
                // Navigate to transaction history screen
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.settings,
              title: 'Settings',
              onTap: () {
                // Navigate to settings screen
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.logout,
              title: 'Logout',
              onTap: () async {
                await AuthService().signOut();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

class ProfileScreenLoading extends StatelessWidget {
  const ProfileScreenLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.2 * 255).round()),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  ShimmerLoading.circular(width: 120, height: 120),
                  const SizedBox(height: 15),
                  ShimmerLoading.rectangular(height: 24, width: 150),
                  const SizedBox(height: 5),
                  ShimmerLoading.rectangular(height: 16, width: 200),
                  const SizedBox(height: 10),
                  ShimmerLoading.rectangular(height: 20, width: 100),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: ShimmerLoading.rectangular(height: 60, width: double.infinity),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: ShimmerLoading.rectangular(height: 60, width: double.infinity),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: ShimmerLoading.rectangular(height: 60, width: double.infinity),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: ShimmerLoading.rectangular(height: 60, width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}
