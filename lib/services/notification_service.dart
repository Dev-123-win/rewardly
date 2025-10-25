import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import '../logger_service.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addNotification({
    required String uid,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .add({
        'title': title,
        'message': message,
        'type': type,
        'createdAt': Timestamp.now(),
        'isRead': false,
        'data': data,
      });
      LoggerService.info('Notification added: $title');
    } catch (e, s) {
      LoggerService.error('Error adding notification', e, s);
    }
  }

  Stream<List<AppNotification>> getNotificationsStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AppNotification.fromFirestore(doc))
          .toList();
    }).handleError((error) {
      LoggerService.error('Error fetching notifications', error, StackTrace.current);
      return <AppNotification>[];
    });
  }

  Future<void> markAsRead(String uid, String notificationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e, s) {
      LoggerService.error('Error marking notification as read', e, s);
    }
  }

  Future<void> deleteNotification(String uid, String notificationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .doc(notificationId)
          .delete();
    } catch (e, s) {
      LoggerService.error('Error deleting notification', e, s);
    }
  }

  Future<void> markAllAsRead(String uid) async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e, s) {
      LoggerService.error('Error marking all notifications as read', e, s);
    }
  }

  Future<int> getUnreadCount(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e, s) {
      LoggerService.error('Error getting unread count', e, s);
      return 0;
    }
  }
}
