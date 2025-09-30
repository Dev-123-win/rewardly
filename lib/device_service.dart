import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class DeviceService {
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  Future<String?> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfoPlugin.androidInfo;
        return androidInfo.id; // Android ID (Note: androidInfo.id is Build.ID, which is not guaranteed to be unique across devices and can change after a factory reset. For a more persistent identifier, 'androidInfo.androidId' (Settings.Secure.ANDROID_ID) is often used, but it caused a getter error with the current package setup. Please verify 'device_info_plus' package version and its capabilities, or consider a server-side generated UUID for stronger uniqueness.)
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfoPlugin.iosInfo;
        return iosInfo.identifierForVendor; // IdentifierForVendor
      }
      // Add other platforms if needed (e.g., web, desktop)
      return null;
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'Error getting device ID');
      return null;
    }
  }
}
