import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Add this import
import '../../design_system/design_system.dart';
import '../../local_storage_service.dart';
import '../../models/auth_result.dart'; // Add this import

/// Notification preferences screen for managing notification settings
///
/// Allows users to enable/disable notifications, choose notification types,
/// and configure sound and vibration settings.
class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  late LocalStorageService _storageService;
  String? _uid; // Add uid field

  bool _enableNotifications = true;
  bool _enableCoinNotifications = true;
  bool _enableWithdrawalNotifications = true;
  bool _enableReferralNotifications = true;
  bool _enableAchievementNotifications = true;
  bool _enableSound = true;
  bool _enableVibration = true;

  @override
  void initState() {
    super.initState();
    _storageService = LocalStorageService();
    // Defer _loadPreferences until after build to access context for Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authResult = Provider.of<AuthResult?>(context, listen: false);
      _uid = authResult?.uid;
      if (_uid != null) {
        _loadPreferences();
      }
    });
  }

  Future<void> _loadPreferences() async {
    if (_uid == null) return;
    final prefs = await _storageService.getNotificationPreferences(_uid!);
    setState(() {
      _enableNotifications = prefs['enableNotifications'] ?? true;
      _enableCoinNotifications = prefs['enableCoinNotifications'] ?? true;
      _enableWithdrawalNotifications =
          prefs['enableWithdrawalNotifications'] ?? true;
      _enableReferralNotifications = prefs['enableReferralNotifications'] ?? true;
      _enableAchievementNotifications =
          prefs['enableAchievementNotifications'] ?? true;
      _enableSound = prefs['enableSound'] ?? true;
      _enableVibration = prefs['enableVibration'] ?? true;
    });
  }

  Future<void> _savePreferences() async {
    if (_uid == null) return;
    await _storageService.saveNotificationPreferences(_uid!, {
      'enableNotifications': _enableNotifications,
      'enableCoinNotifications': _enableCoinNotifications,
      'enableWithdrawalNotifications': _enableWithdrawalNotifications,
      'enableReferralNotifications': _enableReferralNotifications,
      'enableAchievementNotifications': _enableAchievementNotifications,
      'enableSound': _enableSound,
      'enableVibration': _enableVibration,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.background,
      appBar: AppBar(
        title: const Text('Notification Preferences'),
        backgroundColor: DesignSystem.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // General Section
            _buildSectionHeader('General'),
            _buildSwitchTile(
              title: 'Enable Notifications',
              subtitle: 'Receive all notifications',
              value: _enableNotifications,
              onChanged: (value) {
                setState(() => _enableNotifications = value);
                _savePreferences();
              },
            ),
            const Divider(),

            // Notification Types Section
            _buildSectionHeader('Notification Types'),
            _buildSwitchTile(
              title: 'Coin Earned',
              subtitle: 'Get notified when you earn coins',
              value: _enableCoinNotifications,
              onChanged: _enableNotifications
                  ? (value) {
                      setState(() => _enableCoinNotifications = value);
                      _savePreferences();
                    }
                  : null,
            ),
            _buildSwitchTile(
              title: 'Withdrawals',
              subtitle: 'Get notified about withdrawal status',
              value: _enableWithdrawalNotifications,
              onChanged: _enableNotifications
                  ? (value) {
                      setState(() => _enableWithdrawalNotifications = value);
                      _savePreferences();
                    }
                  : null,
            ),
            _buildSwitchTile(
              title: 'Referrals',
              subtitle: 'Get notified about referral rewards',
              value: _enableReferralNotifications,
              onChanged: _enableNotifications
                  ? (value) {
                      setState(() => _enableReferralNotifications = value);
                      _savePreferences();
                    }
                  : null,
            ),
            _buildSwitchTile(
              title: 'Achievements',
              subtitle: 'Get notified when you unlock achievements',
              value: _enableAchievementNotifications,
              onChanged: _enableNotifications
                  ? (value) {
                      setState(() => _enableAchievementNotifications = value);
                      _savePreferences();
                    }
                  : null,
            ),
            const Divider(),

            // Feedback Section
            _buildSectionHeader('Feedback'),
            _buildSwitchTile(
              title: 'Sound',
              subtitle: 'Play sound for notifications',
              value: _enableSound,
              onChanged: _enableNotifications
                  ? (value) {
                      setState(() => _enableSound = value);
                      _savePreferences();
                    }
                  : null,
            ),
            _buildSwitchTile(
              title: 'Vibration',
              subtitle: 'Vibrate for notifications',
              value: _enableVibration,
              onChanged: _enableNotifications
                  ? (value) {
                      setState(() => _enableVibration = value);
                      _savePreferences();
                    }
                  : null,
            ),
            const Divider(),

            // Info Section
            Padding(
              padding: EdgeInsets.all(DesignSystem.spacing6),
              child: Container(
                padding: EdgeInsets.all(DesignSystem.spacing4),
                decoration: BoxDecoration(
                  color: DesignSystem.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
                  border: Border.all(
                    color: DesignSystem.info.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: DesignSystem.info,
                      size: 20,
                    ),
                    SizedBox(width: DesignSystem.spacing3),
                    Expanded(
                      child: Text(
                        'Disabling notifications will prevent you from receiving important updates about your account and rewards.',
                        style: DesignSystem.bodySmall.copyWith(
                          color: DesignSystem.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: DesignSystem.spacing6),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        DesignSystem.spacing6,
        DesignSystem.spacing6,
        DesignSystem.spacing6,
        DesignSystem.spacing3,
      ),
      child: Text(
        title,
        style: DesignSystem.titleMedium.copyWith(
          color: DesignSystem.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSystem.spacing4,
        vertical: DesignSystem.spacing2,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: DesignSystem.surface,
          borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
        ),
        child: SwitchListTile(
          title: Text(
            title,
            style: DesignSystem.bodyLarge.copyWith(
              color: DesignSystem.textPrimary,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: DesignSystem.bodySmall.copyWith(
              color: DesignSystem.textSecondary,
            ),
          ),
          value: value,
          onChanged: onChanged,
          activeThumbColor: DesignSystem.primary,
          contentPadding: EdgeInsets.symmetric(
            horizontal: DesignSystem.spacing4,
            vertical: DesignSystem.spacing2,
          ),
        ),
      ),
    );
  }
}
