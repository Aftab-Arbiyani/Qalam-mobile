/// Runtime app + device facts (docs/40 §28) — resolved once at boot from
/// `package_info_plus` and `device_info_plus`, then injected. Used for the About
/// surface, analytics `deviceType`, and support diagnostics. Never contains PII.
library;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

@immutable
class AppEnvironmentInfo {
  const AppEnvironmentInfo({
    required this.appName,
    required this.version,
    required this.buildNumber,
    required this.platform,
    required this.deviceModel,
    required this.deviceType,
  });

  final String appName;
  final String version;
  final String buildNumber;

  /// `android` | `ios` | `web` | `unknown`.
  final String platform;
  final String deviceModel;

  /// `mobile` | `tablet` | `desktop` — the analytics device bucket.
  final String deviceType;

  String get fullVersion => '$version+$buildNumber';

  static const AppEnvironmentInfo unknown = AppEnvironmentInfo(
    appName: 'Qalam',
    version: '0.0.0',
    buildNumber: '0',
    platform: 'unknown',
    deviceModel: 'unknown',
    deviceType: 'mobile',
  );
}

/// Resolve environment info from platform plugins. Runs in `bootstrap` only.
Future<AppEnvironmentInfo> resolveAppEnvironmentInfo() async {
  final PackageInfo pkg = await PackageInfo.fromPlatform();
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  String platform = 'unknown';
  String model = 'unknown';
  String type = 'mobile';

  if (kIsWeb) {
    final WebBrowserInfo web = await deviceInfo.webBrowserInfo;
    platform = 'web';
    model = web.browserName.name;
    type = 'desktop';
  } else {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final AndroidDeviceInfo android = await deviceInfo.androidInfo;
        platform = 'android';
        model = android.model;
      case TargetPlatform.iOS:
        final IosDeviceInfo ios = await deviceInfo.iosInfo;
        platform = 'ios';
        model = ios.utsname.machine;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        platform = defaultTargetPlatform.name;
        type = 'desktop';
    }
  }

  return AppEnvironmentInfo(
    appName: pkg.appName.isEmpty ? 'Qalam' : pkg.appName,
    version: pkg.version,
    buildNumber: pkg.buildNumber,
    platform: platform,
    deviceModel: model,
    deviceType: type,
  );
}
