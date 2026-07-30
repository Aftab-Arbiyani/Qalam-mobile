/// Read-only account/session facts for the account settings screen (docs/40 §14.6).
/// The frozen `v1` exposes no sessions or connected-accounts endpoints, so these are
/// the honest, device-local substitutes:
///
/// - [signInMethodProvider] — how THIS session was authenticated (password/Google),
///   recorded at `establish` time (the "connected accounts" stand-in).
/// - [deviceSessionInfoProvider] — a "this device" card: app version/build
///   (`package_info_plus`), device model + OS (`device_info_plus`), and the
///   remember-me flag. Plugin lookups are wrapped so a headless test never crashes.
library;

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/session/sign_in_method.dart';

part 'account_info_controller.g.dart';

@immutable
class DeviceSessionInfo {
  const DeviceSessionInfo({
    required this.appVersion,
    required this.deviceLabel,
    required this.rememberMe,
  });

  /// e.g. `1.0.0 (1)`.
  final String appVersion;

  /// e.g. `Pixel 7 · Android 14`, or `Unknown device` when unavailable.
  final String deviceLabel;

  /// Whether silent session restore is enabled for this device.
  final bool rememberMe;
}

@riverpod
SignInMethod signInMethod(Ref ref) =>
    SignInMethod.fromWire(ref.watch(preferencesStoreProvider).signInMethod);

@riverpod
Future<DeviceSessionInfo> deviceSessionInfo(Ref ref) async {
  final bool rememberMe = ref.watch(preferencesStoreProvider).rememberMe;
  return DeviceSessionInfo(
    appVersion: await _appVersion(),
    deviceLabel: await _deviceLabel(),
    rememberMe: rememberMe,
  );
}

Future<String> _appVersion() async {
  try {
    final PackageInfo info = await PackageInfo.fromPlatform();
    return '${info.version} (${info.buildNumber})';
  } on Object {
    return '—';
  }
}

Future<String> _deviceLabel() async {
  try {
    final DeviceInfoPlugin plugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final AndroidDeviceInfo a = await plugin.androidInfo;
      return '${a.manufacturer} ${a.model} · Android ${a.version.release}';
    }
    if (Platform.isIOS) {
      final IosDeviceInfo i = await plugin.iosInfo;
      return '${i.name} · iOS ${i.systemVersion}';
    }
    return 'This device';
  } on Object {
    return 'This device';
  }
}
