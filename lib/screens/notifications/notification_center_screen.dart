import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../design_system/design_system.dart';
import '../../design_system/app_icons.dart';
import '../../models/notification_model.dart';
import '../../models/auth_result.dart';
import '../../services/notification_service.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    final authResult = Provider.of<AuthResult?>(context);
    final uid = authResult?.uid;

    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const Center(child: Text('Not authenticated')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: DesignSystem.background,
        elevation: 0,
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              _notificationService.markAllAsRead(uid);
            },
            child: Text(
              'Mark all read',
              style: DesignSystem.labelMedium.copyWith(
                color: DesignSystem.primary,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: DesignSystem.background,
      body: StreamBuilder<List<AppNotification>>(
        stream: _notificationService.getNotificationsStream(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final notifications = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(DesignSystem.spacing4),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationCard(
                context,
                notification,
                uid,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: DesignSystem.textTertiary,
          ),
          SizedBox(height: DesignSystem.spacing4),
          Text(
            'No Notifications',
            style: DesignSystem.headlineMedium.copyWith(
              color: DesignSystem.textPrimary,
            ),
          ),
          SizedBox(height: DesignSystem.spacing2),
          Text(
            'You\'re all caught up!',
            style: DesignSystem.bodyMedium.copyWith(
              color: DesignSystem.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    AppNotification notification,
    String uid,
  ) {
    final color = _getNotificationColor(notification.type);
    final icon = _getNotificationIcon(notification.type);

    return GestureDetector(
      onTap: () {
        if (!notification.isRead) {
          _notificationService.markAsRead(uid, notification.id);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: DesignSystem.spacing3),
        padding: EdgeInsets.all(DesignSystem.spacing4),
        decoration: BoxDecoration(
          color: notification.isRead
              ? DesignSystem.surface
              : color.withValues(alpha: 0.05),
          border: Border.all(
            color: notification.isRead
                ? DesignSystem.outline
                : color.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignSystem.radiusMedium),
              ),
              child: Center(
                child: HugeIcon(
                  icon: icon,
                  color: color,
                  size: AppIcons.sizeMedium,
                ),
              ),
            ),
            SizedBox(width: DesignSystem.spacing3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: DesignSystem.titleMedium.copyWith(
                      color: DesignSystem.textPrimary,
                      fontWeight: notification.isRead
                          ? FontWeight.w500
                          : FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: DesignSystem.spacing1),
                  Text(
                    notification.message,
                    style: DesignSystem.bodySmall.copyWith(
                      color: DesignSystem.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: DesignSystem.spacing2),
                  Text(
                    _formatTime(notification.createdAt),
                    style: DesignSystem.labelSmall.copyWith(
                      color: DesignSystem.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            SizedBox(width: DesignSystem.spacing2),
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Text('Delete'),
                  onTap: () {
                    _notificationService.deleteNotification(
                      uid,
                      notification.id,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'coin_earned':
        return DesignSystem.success;
      case 'withdrawal':
        return DesignSystem.primary;
      case 'referral':
        return DesignSystem.secondary;
      case 'warning':
        return DesignSystem.warning;
      default:
        return DesignSystem.info;
    }
  }

  List<List<dynamic>> _getNotificationIcon(String type) {
    switch (type) {
      case 'coin_earned':
        return AppIcons.success;
      case 'withdrawal':
        return AppIcons.withdraw;
      case 'referral':
        return AppIcons.invite;
      case 'warning':
        return AppIcons.warning;
      default:
        return AppIcons.info;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }
}
