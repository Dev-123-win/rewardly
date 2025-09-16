import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rewardly_app/remote_config_service.dart';
import 'package:rewardly_app/shared/shimmer_loading.dart';
import 'package:provider/provider.dart';
import 'package:rewardly_app/providers/user_data_provider.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final RemoteConfigService _remoteConfigService = RemoteConfigService();

  int _dailyAdLimit = 0;
  int _coinsPerAd = 0;

  @override
  void initState() {
    super.initState();
    _loadRemoteConfig();
  }

  Future<void> _loadRemoteConfig() async {
    await _remoteConfigService.initialize();
    setState(() {
      _dailyAdLimit = _remoteConfigService.dailyAdLimit;
      _coinsPerAd = _remoteConfigService.coinsPerAd;
    });
  }

  Future<void> _updateRemoteConfig() async {
    await _remoteConfigService.initialize(); // Re-initialize to ensure latest values
    await _remoteConfigService.setConfigDefaults({
      'daily_ad_limit': _dailyAdLimit,
      'coins_per_ad': _coinsPerAd,
    });
    await _remoteConfigService.fetchAndActivate();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remote Config updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40), // Space for status bar
            Text(
              'Admin Panel',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.black87),
            ),
            const SizedBox(height: 20),
            Text(
              'Remote Config Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: _dailyAdLimit.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Daily Ad Limit',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  _dailyAdLimit = int.tryParse(val) ?? 0;
                });
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: _coinsPerAd.toString(),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Coins Per Ad',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  _coinsPerAd = int.tryParse(val) ?? 0;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateRemoteConfig,
              child: Text('Update Remote Config', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white)),
            ),
            const SizedBox(height: 40),
            Text(
              'User Management',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Consumer<UserDataProvider>(
                builder: (context, userDataProvider, child) {
                  if (userDataProvider.userData == null) {
                    return const _AdminPanelLoading();
                  }
                  // Assuming admin panel needs to list all users, not just the current user
                  // This part still needs a StreamBuilder or a separate provider for all users
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const _AdminPanelLoading();
                      }
                      return ListView(
                        children: snapshot.data!.docs.map((DocumentSnapshot document) {
                          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(data['email'] ?? 'N/A', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              subtitle: Text('Coins: ${data['coins']}, Ads Watched Today: ${data['adsWatchedToday']}', style: Theme.of(context).textTheme.bodySmall),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _confirmDeleteUser(context, document.id, data['email'] ?? 'N/A'),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteUser(BuildContext context, String uid, String email) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete user "$email"? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Dismiss dialog
                await FirebaseFirestore.instance.collection('users').doc(uid).delete();
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('User "$email" deleted!')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _AdminPanelLoading extends StatelessWidget {
  const _AdminPanelLoading();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            title: ShimmerLoading.rectangular(height: 16, width: 150),
            subtitle: ShimmerLoading.rectangular(height: 14, width: 200),
            trailing: ShimmerLoading.circular(width: 40, height: 40),
          ),
        );
      },
    );
  }
}
