# 🔔 Phase 4: Notifications - Implementation Plan

## Status: READY TO IMPLEMENT

---

## 📋 Overview

**Phase 4** focuses on integrating the notification system throughout the app, adding notification badges, preferences, and real-time updates.

---

## 🎯 Phase 4 Objectives

### Primary Goals
1. ✅ Add notification badges to navigation tabs
2. ✅ Integrate notification service with app events
3. ✅ Create notification preferences UI
4. ✅ Implement real-time notification updates

### Secondary Goals
1. ✅ Add notification sounds
2. ✅ Add notification vibration
3. ✅ Implement notification grouping
4. ✅ Add notification history

---

## 📊 Notification Implementation Breakdown

### 1. Notification Badges

**Location**: Bottom navigation bar

**Implementation**:
```dart
// Add badge to notification tab
Stack(
  children: [
    Icon(Icons.notifications),
    if (unreadCount > 0)
      Positioned(
        right: 0,
        top: 0,
        child: Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
          constraints: BoxConstraints(minWidth: 16, minHeight: 16),
          child: Text(
            '$unreadCount',
            style: TextStyle(color: Colors.white, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ),
      ),
  ],
)
```

**Tasks**:
- [ ] Create BadgeWidget component
- [ ] Integrate into bottom navigation
- [ ] Update badge on new notification
- [ ] Clear badge on mark as read
- [ ] Test badge display

**Files to Modify**:
- `lib/screens/home/home.dart`

---

### 2. Notification Service Integration

**Location**: App-wide event system

**Implementation**:
```dart
// Trigger notification on coin earn
Future<void> _onCoinEarned(int coins) async {
  await notificationService.addNotification(
    uid: userId,
    title: 'Coins Earned!',
    message: 'You earned $coins coins',
    type: 'coin_earned',
  );
}

// Trigger notification on withdrawal
Future<void> _onWithdrawalSubmitted(int amount) async {
  await notificationService.addNotification(
    uid: userId,
    title: 'Withdrawal Submitted',
    message: 'Your withdrawal of $amount coins is being processed',
    type: 'withdrawal',
  );
}
```

**Tasks**:
- [ ] Add notification trigger on coin earn
- [ ] Add notification trigger on withdrawal
- [ ] Add notification trigger on referral
- [ ] Add notification trigger on achievement
- [ ] Add notification trigger on profile update
- [ ] Test all triggers

**Files to Modify**:
- `lib/screens/home/spin_wheel_game_screen.dart`
- `lib/screens/home/tic_tac_toe_game_screen.dart`
- `lib/screens/home/minesweeper_game_screen.dart`
- `lib/screens/home/withdraw_screen.dart`
- `lib/screens/home/referral_screen.dart`

---

### 3. Notification Preferences UI

**Location**: Settings/Profile screen

**Implementation**:
```dart
// Create NotificationPreferencesScreen
class NotificationPreferencesScreen extends StatefulWidget {
  @override
  State<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> {
  bool _enableNotifications = true;
  bool _enableCoinNotifications = true;
  bool _enableWithdrawalNotifications = true;
  bool _enableReferralNotifications = true;
  bool _enableSound = true;
  bool _enableVibration = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notification Preferences')),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Enable Notifications'),
            value: _enableNotifications,
            onChanged: (value) => setState(() => _enableNotifications = value),
          ),
          SwitchListTile(
            title: Text('Coin Notifications'),
            value: _enableCoinNotifications,
            onChanged: (value) => setState(() => _enableCoinNotifications = value),
          ),
          SwitchListTile(
            title: Text('Withdrawal Notifications'),
            value: _enableWithdrawalNotifications,
            onChanged: (value) => setState(() => _enableWithdrawalNotifications = value),
          ),
          SwitchListTile(
            title: Text('Referral Notifications'),
            value: _enableReferralNotifications,
            onChanged: (value) => setState(() => _enableReferralNotifications = value),
          ),
          SwitchListTile(
            title: Text('Sound'),
            value: _enableSound,
            onChanged: (value) => setState(() => _enableSound = value),
          ),
          SwitchListTile(
            title: Text('Vibration'),
            value: _enableVibration,
            onChanged: (value) => setState(() => _enableVibration = value),
          ),
        ],
      ),
    );
  }
}
```

**Tasks**:
- [ ] Create NotificationPreferencesScreen
- [ ] Add toggle for all notifications
- [ ] Add toggle for notification types
- [ ] Add toggle for sound
- [ ] Add toggle for vibration
- [ ] Save preferences to Firestore
- [ ] Load preferences on app start
- [ ] Test all preferences

**Files to Create**:
- `lib/screens/settings/notification_preferences_screen.dart`

**Files to Modify**:
- `lib/screens/home/profile_screen.dart`

---

### 4. Real-time Notification Updates

**Location**: Notification center and badges

**Implementation**:
```dart
// Listen to notification stream
StreamBuilder<List<DocumentSnapshot>>(
  stream: notificationService.getNotificationsStream(userId),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final notifications = snapshot.data!;
      return ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return NotificationTile(notification: notifications[index]);
        },
      );
    }
    return CircularProgressIndicator();
  },
)
```

**Tasks**:
- [ ] Implement real-time notification stream
- [ ] Update notification list in real-time
- [ ] Update badge count in real-time
- [ ] Handle notification deletion
- [ ] Handle notification marking as read
- [ ] Test real-time updates
- [ ] Test on slow network
- [ ] Test offline behavior

**Files to Modify**:
- `lib/screens/notifications/notification_center_screen.dart`
- `lib/screens/home/home.dart`

---

## 🔧 Implementation Steps

### Step 1: Notification Badges (Days 1-2)

**Create BadgeWidget**:
1. Design badge component
2. Implement badge display
3. Add animation on update
4. Test badge rendering

**Integrate into Navigation**:
1. Add badge to notification tab
2. Update badge on new notification
3. Clear badge on mark as read
4. Test badge updates

---

### Step 2: Service Integration (Days 2-3)

**Coin Earn Events**:
1. Add notification trigger to spin wheel
2. Add notification trigger to tic tac toe
3. Add notification trigger to minesweeper
4. Test all triggers

**Withdrawal Events**:
1. Add notification trigger to withdrawal
2. Test withdrawal notification
3. Verify notification content

**Other Events**:
1. Add notification trigger to referral
2. Add notification trigger to profile update
3. Test all event triggers

---

### Step 3: Preferences UI (Days 3-4)

**Create Preferences Screen**:
1. Design preferences UI
2. Implement toggle switches
3. Add save functionality
4. Test preferences

**Integrate into Profile**:
1. Add link to preferences
2. Load preferences on screen open
3. Save preferences on change
4. Test integration

---

### Step 4: Real-time Updates (Days 4-5)

**Notification Stream**:
1. Implement real-time stream
2. Update notification list
3. Update badge count
4. Test real-time updates

**Offline Handling**:
1. Cache notifications locally
2. Sync on reconnect
3. Test offline behavior
4. Test sync on reconnect

---

## 📊 Notification Types

```dart
enum NotificationType {
  coinEarned,      // Green, coin icon
  withdrawal,      // Purple, withdraw icon
  referral,        // Blue, invite icon
  achievement,     // Gold, star icon
  profileUpdate,   // Gray, profile icon
  info,            // Blue, info icon
  warning,         // Amber, warning icon
}
```

---

## 🎨 Notification Design

### Badge Design
- **Size**: 16x16dp minimum
- **Color**: Red (#EF4444)
- **Text**: White, 10px
- **Position**: Top-right corner
- **Animation**: Fade-in on update

### Notification Card Design
- **Height**: 80-100dp
- **Padding**: 16dp
- **Border Radius**: 12dp
- **Shadow**: Medium
- **Icon**: 24x24dp, color-coded
- **Title**: 14px, bold
- **Message**: 12px, regular
- **Timestamp**: 10px, gray

### Preferences Design
- **Layout**: List of toggles
- **Sections**: General, Types, Feedback
- **Toggle Size**: 48x48dp
- **Spacing**: 16dp between items

---

## 🧪 Testing Checklist

### Unit Tests
- [ ] Badge count calculation
- [ ] Notification filtering
- [ ] Preference saving/loading
- [ ] Stream handling

### Widget Tests
- [ ] Badge rendering
- [ ] Notification card rendering
- [ ] Preferences UI rendering
- [ ] Real-time updates

### Integration Tests
- [ ] Notification trigger on event
- [ ] Badge update on notification
- [ ] Preferences persistence
- [ ] Real-time stream updates

### Manual Testing
- [ ] Visual quality check
- [ ] Badge display accuracy
- [ ] Notification content accuracy
- [ ] Real-time update speed

---

## 📋 Deliverables

### New Files
- [ ] `lib/screens/settings/notification_preferences_screen.dart`
- [ ] `lib/widgets/notification_badge.dart` (optional)

### Modified Files
- [ ] `lib/screens/home/home.dart`
- [ ] `lib/screens/notifications/notification_center_screen.dart`
- [ ] `lib/screens/home/spin_wheel_game_screen.dart`
- [ ] `lib/screens/home/tic_tac_toe_game_screen.dart`
- [ ] `lib/screens/home/minesweeper_game_screen.dart`
- [ ] `lib/screens/home/withdraw_screen.dart`
- [ ] `lib/screens/home/referral_screen.dart`
- [ ] `lib/screens/home/profile_screen.dart`

---

## 📊 Success Criteria

### Functional
- ✅ Badges display correctly
- ✅ Notifications trigger on events
- ✅ Preferences save and load
- ✅ Real-time updates work
- ✅ Offline behavior works

### Performance
- ✅ Badge updates are instant
- ✅ Notification stream is responsive
- ✅ No memory leaks
- ✅ No excessive CPU usage

### User Experience
- ✅ Badges are visible
- ✅ Notifications are timely
- ✅ Preferences are intuitive
- ✅ Updates are smooth

---

## 🎯 Timeline

| Day | Task | Status |
|-----|------|--------|
| 1-2 | Notification Badges | ⏳ Ready |
| 2-3 | Service Integration | ⏳ Ready |
| 3-4 | Preferences UI | ⏳ Ready |
| 4-5 | Real-time Updates | ⏳ Ready |
| 5 | Testing & Optimization | ⏳ Ready |

---

## 📚 Resources

### Notification Documentation
- Firebase Cloud Messaging: https://firebase.google.com/docs/cloud-messaging
- Local Notifications: https://pub.dev/packages/flutter_local_notifications
- Firestore Real-time: https://firebase.google.com/docs/firestore/query-data/listen

### Design Resources
- Material Design Badges: https://material.io/components/badges
- Notification Design: https://material.io/components/snackbars

---

## 🎊 Next Steps

1. **Review this plan** with the team
2. **Identify any blockers** or dependencies
3. **Begin implementation** with notification badges
4. **Test thoroughly** on real devices
5. **Optimize performance** as needed
6. **Document any changes** to notification system

---

**Status**: ✅ Phase 4 Plan Complete | Ready for Implementation
**Estimated Duration**: 5 days
**Complexity**: Medium
**Risk Level**: Low
