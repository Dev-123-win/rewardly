# Rewardly UI/UX - Quick Reference Guide

## 🎨 Design System Quick Access

### Colors
```dart
// Primary
DesignSystem.primary              // #8A2BE2 (Purple)
DesignSystem.primaryLight         // #A855F7
DesignSystem.primaryDark          // #6B1FB8

// Semantic
DesignSystem.success              // #10B981 (Green)
DesignSystem.warning              // #F59E0B (Amber)
DesignSystem.error                // #EF4444 (Red)
DesignSystem.info                 // #3B82F6 (Blue)

// Text
DesignSystem.textPrimary          // #1F2937
DesignSystem.textSecondary        // #6B7280
DesignSystem.textTertiary         // #9CA3AF
```

### Typography
```dart
// Headers
DesignSystem.displayLarge         // 32px, Bold
DesignSystem.displayMedium        // 28px, Bold
DesignSystem.displaySmall         // 24px, Semi-Bold
DesignSystem.headlineLarge        // 20px, Semi-Bold
DesignSystem.headlineMedium       // 18px, Semi-Bold
DesignSystem.headlineSmall        // 16px, Semi-Bold

// Body
DesignSystem.bodyLarge            // 16px, Regular
DesignSystem.bodyMedium           // 14px, Regular
DesignSystem.bodySmall            // 12px, Regular

// Labels
DesignSystem.labelLarge           // 14px, Medium
DesignSystem.labelMedium          // 12px, Medium
DesignSystem.labelSmall           // 11px, Medium
DesignSystem.overline             // 10px, Semi-Bold
```

### Spacing
```dart
DesignSystem.spacing1             // 4px
DesignSystem.spacing2             // 8px
DesignSystem.spacing3             // 12px
DesignSystem.spacing4             // 16px
DesignSystem.spacing5             // 20px
DesignSystem.spacing6             // 24px
DesignSystem.spacing7             // 32px
DesignSystem.spacing8             // 40px
DesignSystem.spacing9             // 48px
DesignSystem.spacing10            // 56px
```

### Border Radius
```dart
DesignSystem.radiusSmall          // 8px
DesignSystem.radiusMedium         // 12px
DesignSystem.radiusLarge          // 16px
DesignSystem.radiusXL             // 20px
DesignSystem.radiusXXL            // 24px
DesignSystem.radiusCircle         // 999px
```

### Shadows
```dart
DesignSystem.shadowSmall          // Subtle shadow
DesignSystem.shadowMedium         // Medium shadow
DesignSystem.shadowLarge          // Large shadow
DesignSystem.shadowXL             // Extra large shadow
```

### Animation Durations
```dart
DesignSystem.durationFast         // 150ms
DesignSystem.durationNormal       // 300ms
DesignSystem.durationSlow         // 500ms
DesignSystem.durationVerySlow     // 800ms
```

---

## 🎯 Common Patterns

### Creating a Card
```dart
Container(
  padding: EdgeInsets.all(DesignSystem.spacing4),
  decoration: BoxDecoration(
    color: DesignSystem.surface,
    borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
    boxShadow: [DesignSystem.shadowMedium],
  ),
  child: Column(
    children: [
      Text('Title', style: DesignSystem.headlineMedium),
      SizedBox(height: DesignSystem.spacing3),
      Text('Content', style: DesignSystem.bodyMedium),
    ],
  ),
)
```

### Creating a Button
```dart
SizedBox(
  width: double.infinity,
  height: DesignSystem.minTouchSize,
  child: ElevatedButton(
    onPressed: () {},
    style: ElevatedButton.styleFrom(
      backgroundColor: DesignSystem.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
      ),
    ),
    child: Text(
      'Button',
      style: DesignSystem.titleLarge.copyWith(color: Colors.white),
    ),
  ),
)
```

### Creating a Gradient Container
```dart
Container(
  decoration: BoxDecoration(
    gradient: DesignSystem.gradientPrimary,
    borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
  ),
  child: Padding(
    padding: EdgeInsets.all(DesignSystem.spacing6),
    child: Text('Gradient', style: DesignSystem.headlineLarge),
  ),
)
```

### Form Validation
```dart
ValidatedTextField(
  label: 'Email',
  hint: 'Enter your email',
  controller: _emailController,
  validator: (value) {
    if (value?.isEmpty ?? true) return 'Email is required';
    if (!value!.contains('@')) return 'Invalid email';
    return null;
  },
  keyboardType: TextInputType.emailAddress,
  helperText: 'We\'ll never share your email',
)
```

### Page Navigation
```dart
// Slide transition
Navigator.push(
  context,
  SlidePageRoute(child: const MyScreen()),
)

// Fade transition
Navigator.push(
  context,
  FadePageRoute(child: const MyScreen()),
)

// Scale transition
Navigator.push(
  context,
  ScalePageRoute(child: const MyScreen()),
)
```

### Responsive Layout
```dart
if (ResponsiveHelper.isSmallScreen(context)) {
  // Mobile layout
  return Column(children: [...]);
} else if (ResponsiveHelper.isMediumScreen(context)) {
  // Tablet layout
  return Row(children: [...]);
} else {
  // Desktop layout
  return GridView(gridDelegate: ...);
}
```

### Notification
```dart
final notificationService = NotificationService();

// Add notification
await notificationService.addNotification(
  uid: userId,
  title: 'Coins Earned!',
  message: 'You earned 100 coins',
  type: 'coin_earned',
)

// Listen to notifications
notificationService.getNotificationsStream(userId).listen((notifications) {
  // Update UI
})
```

---

## 🎬 Animation Examples

### Coin Earn Animation
```dart
Stack(
  children: [
    // Your content
    if (showAnimation)
      CoinEarnAnimation(
        coins: 100,
        position: Offset(100, 100),
        onComplete: () {
          setState(() => showAnimation = false);
        },
      ),
  ],
)
```

### Success Feedback
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: SuccessFeedback(
      message: 'Withdrawal submitted!',
      backgroundColor: DesignSystem.success,
      icon: Icons.check_circle,
    ),
  ),
)
```

---

## 📱 Responsive Breakpoints

```dart
// Small screens (phones)
< 600px

// Medium screens (tablets)
600px - 900px

// Large screens (desktops)
> 900px
```

### Adaptive Values
```dart
// Padding
ResponsiveHelper.getHorizontalPadding(context)
// Returns: 16 (small), 24 (medium), 10% width (large)

// Grid columns
ResponsiveHelper.getGridColumns(context)
// Returns: 2 (small), 3 (medium), 4 (large)

// Card height
ResponsiveHelper.getCardHeight(context)
// Returns: 180 (small), 200 (medium), 220 (large)

// Font scale
ResponsiveHelper.getFontScale(context)
// Returns: 1.0 (small), 1.1 (medium), 1.2 (large)
```

---

## 🔔 Notification Types

```dart
// Coin earned
'coin_earned'     // Green, success icon

// Withdrawal
'withdrawal'      // Purple, withdraw icon

// Referral
'referral'        // Blue, invite icon

// Warning
'warning'         // Amber, warning icon

// Info
'info'            // Blue, info icon
```

---

## 🎨 Icon Usage

```dart
import '../../design_system/app_icons.dart';

// Navigation
HugeIcon(icon: AppIcons.home, size: AppIcons.sizeMedium)
HugeIcon(icon: AppIcons.profile, size: AppIcons.sizeMedium)
HugeIcon(icon: AppIcons.redeem, size: AppIcons.sizeMedium)
HugeIcon(icon: AppIcons.invite, size: AppIcons.sizeMedium)

// Actions
HugeIcon(icon: AppIcons.earn, size: AppIcons.sizeMedium)
HugeIcon(icon: AppIcons.withdraw, size: AppIcons.sizeMedium)
HugeIcon(icon: AppIcons.share, size: AppIcons.sizeMedium)

// Status
HugeIcon(icon: AppIcons.success, size: AppIcons.sizeMedium)
HugeIcon(icon: AppIcons.error, size: AppIcons.sizeMedium)
HugeIcon(icon: AppIcons.warning, size: AppIcons.sizeMedium)
```

---

## 📋 Common Tasks

### Add a new screen
1. Create file in `lib/screens/[category]/`
2. Use DesignSystem for styling
3. Use ResponsiveHelper for layout
4. Use SlidePageRoute for navigation

### Add form validation
1. Use ValidatedTextField widget
2. Provide validator function
3. Handle onValidationChanged callback
4. Show success animation on submit

### Add notification
1. Call NotificationService.addNotification()
2. Provide title, message, type
3. Listen to stream in UI
4. Display in NotificationCenterScreen

### Add animation
1. Choose animation type (Coin, Success, Transition)
2. Provide required parameters
3. Handle onComplete callback
4. Clean up in dispose()

---

## ⚡ Performance Tips

### Do's
✅ Use `const` constructors
✅ Use `RepaintBoundary` for complex widgets
✅ Dispose controllers in `dispose()`
✅ Use `shouldRebuild` in providers
✅ Lazy load images
✅ Use `ListView.builder` for long lists

### Don'ts
❌ Don't rebuild entire screen on state change
❌ Don't use `MediaQuery` in build multiple times
❌ Don't create new objects in build()
❌ Don't use heavy animations on main thread
❌ Don't load all images at once
❌ Don't use `ListView` for dynamic lists

---

## 🧪 Testing Checklist

### Before Commit
- [ ] Code compiles without errors
- [ ] No console warnings
- [ ] Responsive on small/medium/large screens
- [ ] Animations are smooth
- [ ] Forms validate correctly
- [ ] Notifications work
- [ ] Navigation works

### Before Release
- [ ] All screens tested on real device
- [ ] Performance profiled
- [ ] Accessibility checked
- [ ] Firebase rules verified
- [ ] Error handling tested
- [ ] Offline mode tested

---

## 🚨 Troubleshooting

### Animations are janky
```dart
// Check for excessive rebuilds
// Use const constructors
// Profile with DevTools
// Reduce animation complexity
```

### Form validation not working
```dart
// Ensure validator is provided
// Check TextEditingController is initialized
// Verify onValidationChanged callback
// Check validator logic
```

### Notifications not appearing
```dart
// Check Firestore rules
// Verify NotificationService initialized
// Check user UID is correct
// Check notification type is valid
```

### Responsive layout broken
```dart
// Use ResponsiveHelper for breakpoints
// Check LayoutBuilder constraints
// Verify MediaQuery usage
// Test on multiple screen sizes
```

---

## 📚 File Structure

```
lib/
├── design_system/
│   ├── design_system.dart          # Main design tokens
│   ├─��� app_icons.dart              # Icon constants
│   └── responsive_helper.dart      # Responsive utilities
├── widgets/
│   ├── validated_text_field.dart   # Form validation
│   ├── coin_earn_animation.dart    # Coin animation
│   ├── success_feedback.dart       # Success notification
│   ├── page_transitions.dart       # Page transitions
│   └── how_to_earn_guide.dart      # User guidance
├── models/
│   └── notification_model.dart     # Notification data
├── services/
│   └── notification_service.dart   # Notification service
├── screens/
│   ├── notifications/
│   │   └── notification_center_screen.dart
│   ├── info/
│   │   └── onboarding_enhanced.dart
│   └── home/
│       └── home_refactored.dart
└── ...
```

---

## 🔗 Related Documentation

- `IMPLEMENTATION_GUIDE.md` - Detailed integration guide
- `IMPLEMENTATION_SUMMARY.md` - Phase 1 summary
- Flutter Documentation: https://flutter.dev/docs
- Firebase Documentation: https://firebase.google.com/docs

---

## 💡 Tips & Tricks

### Tip 1: Use DesignSystem everywhere
```dart
// Good
Text('Hello', style: DesignSystem.headlineLarge)

// Avoid
Text('Hello', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
```

### Tip 2: Responsive first
```dart
// Good
if (ResponsiveHelper.isSmallScreen(context)) { ... }

// Avoid
if (MediaQuery.of(context).size.width < 600) { ... }
```

### Tip 3: Use page transitions
```dart
// Good
Navigator.push(context, SlidePageRoute(child: Screen()))

// Avoid
Navigator.push(context, MaterialPageRoute(builder: (_) => Screen()))
```

### Tip 4: Validate forms early
```dart
// Good
ValidatedTextField(validator: _validateEmail)

// Avoid
// Validate only on submit
```

---

**Last Updated**: 2024
**Version**: 1.0
**Status**: Ready for use
