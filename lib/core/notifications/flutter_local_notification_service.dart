/// The concrete [LocalNotificationService] (docs/40 §33), backed by
/// `flutter_local_notifications`. Owns channel creation, contextual permission,
/// immediate presentation (used for foreground push, Phase-2 seam), the gated
/// `zonedSchedule` reminder seam, and tap→route surfacing. This is the ONLY file
/// that imports the plugin (docs/40 §31) — everything upstream depends on the
/// interface. Initialization failures are swallowed (a device without notification
/// support must not crash the app); the Noop behavior degrades gracefully.
library;

import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../logging/app_logger.dart';
import 'local_notification_service.dart';
import 'notification_channels.dart';

class FlutterLocalNotificationService implements LocalNotificationService {
  FlutterLocalNotificationService(
    this._logger, {
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final AppLogger _logger;

  final StreamController<String> _routes = StreamController<String>.broadcast();
  bool _initialized = false;
  bool _timezonesReady = false;

  @override
  Stream<String> get onSelectRoute => _routes.stream;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      const AndroidInitializationSettings android =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      // Permission is requested contextually (not on first launch), so defer the
      // Darwin permission prompts out of init.
      const DarwinInitializationSettings darwin = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      await _plugin.initialize(
        settings: const InitializationSettings(android: android, iOS: darwin),
        onDidReceiveNotificationResponse: _onTap,
      );
      await _createChannels();
      _initialized = true;
      // A cold-start tap (the app was launched by tapping a notification) is
      // delivered via launch details, not the tap callback — replay it once.
      unawaited(_replayLaunchRoute());
    } on Object catch (e, s) {
      _logger.recordError(e, s, reason: 'localNotifications.initialize');
    }
  }

  Future<void> _createChannels() async {
    final AndroidFlutterLocalNotificationsPlugin? android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return;
    for (final NotificationChannelKind kind in NotificationChannelKind.values) {
      await android.createNotificationChannel(kind.androidChannel);
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? false;
      }
      final IOSFlutterLocalNotificationsPlugin? ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (ios != null) {
        return await ios.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
      return false;
    } on Object catch (e, s) {
      _logger.recordError(e, s, reason: 'localNotifications.requestPermission');
      return false;
    }
  }

  @override
  Future<void> show(LocalNotification notification) async {
    if (!_initialized) await initialize();
    final NotificationDetails details = _detailsFor(notification);
    try {
      final DateTime? at = notification.scheduledAt;
      if (at == null || !at.isAfter(DateTime.now())) {
        await _plugin.show(
          id: notification.id,
          title: notification.title,
          body: notification.body,
          notificationDetails: details,
          payload: notification.route,
        );
        return;
      }
      // Scheduled delivery (the reminder seam, §33).
      await _ensureTimezones();
      await _plugin.zonedSchedule(
        id: notification.id,
        title: notification.title,
        body: notification.body,
        scheduledDate: tz.TZDateTime.from(at, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: notification.route,
      );
    } on Object catch (e, s) {
      _logger.recordError(e, s, reason: 'localNotifications.show');
    }
  }

  @override
  Future<void> cancel(int id) async {
    try {
      await _plugin.cancel(id: id);
    } on Object catch (e, s) {
      _logger.recordError(e, s, reason: 'localNotifications.cancel');
    }
  }

  @override
  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } on Object catch (e, s) {
      _logger.recordError(e, s, reason: 'localNotifications.cancelAll');
    }
  }

  NotificationDetails _detailsFor(LocalNotification n) {
    final NotificationChannelKind kind = n.channel;
    return NotificationDetails(
      android: AndroidNotificationDetails(
        kind.id,
        kind.name,
        channelDescription: kind.description,
        number: n.badgeCount,
      ),
      iOS: DarwinNotificationDetails(
        presentBadge: n.badgeCount != null,
        badgeNumber: n.badgeCount,
      ),
    );
  }

  Future<void> _ensureTimezones() async {
    if (_timezonesReady) return;
    tz_data.initializeTimeZones();
    try {
      final TimezoneInfo info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } on Object {
      // Fall back to UTC — a reminder still fires, just referenced to UTC. The
      // reminder path is a gated Phase-1 seam, so exactness is a Phase-2 concern.
    }
    _timezonesReady = true;
  }

  void _onTap(NotificationResponse response) => _emitRoute(response.payload);

  Future<void> _replayLaunchRoute() async {
    try {
      final NotificationAppLaunchDetails? details = await _plugin
          .getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp ?? false) {
        _emitRoute(details?.notificationResponse?.payload);
      }
    } on Object catch (e, s) {
      _logger.recordError(e, s, reason: 'localNotifications.launchDetails');
    }
  }

  void _emitRoute(String? route) {
    if (route != null && route.isNotEmpty && !_routes.isClosed) {
      _routes.add(route);
    }
  }

  void dispose() {
    unawaited(_routes.close());
  }
}
