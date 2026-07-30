import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/config/app_config.dart';
import 'package:qalam_mobile/core/config/app_flavor.dart';
import 'package:qalam_mobile/core/config/remote_config.dart';
import 'package:qalam_mobile/core/observability/operations_feature_flags.dart';

/// A remote config that returns fixed values for named keys (else the fallback).
class _StubRemoteConfig implements RemoteConfigService {
  const _StubRemoteConfig(this._bools, this._ints);
  final Map<String, bool> _bools;
  final Map<String, int> _ints;

  @override
  Future<void> initialize() async {}
  @override
  Future<void> refresh() async {}
  @override
  bool getBool(String key, {required bool fallback}) => _bools[key] ?? fallback;
  @override
  String getString(String key, {required String fallback}) => fallback;
  @override
  int getInt(String key, {required int fallback}) => _ints[key] ?? fallback;
  @override
  double getDouble(String key, {required double fallback}) => fallback;
}

AppConfig config({required bool enableAi}) => AppConfig(
  flavor: AppFlavor.development,
  apiUrl: 'http://localhost:4000',
  cdnUrl: '',
  webUrl: '',
  sentryDsn: '',
  enablePush: false,
  enableAi: enableAi,
  enableMonetization: false,
  enableCollaboration: false,
);

void main() {
  test('a compile-time kill switch that is OFF forces false', () {
    final OperationsFeatureFlags flags = OperationsFeatureFlags(
      config: config(enableAi: false),
      // Even if remote says true, the OFF compile-time gate wins.
      remoteConfig: const _StubRemoteConfig(<String, bool>{'feature.ai.enabled': true}, <String, int>{}),
    );
    expect(flags.isEnabled('feature.ai.enabled'), isFalse);
  });

  test('when the compile-time gate is ON, the remote value decides', () {
    final OperationsFeatureFlags flags = OperationsFeatureFlags(
      config: config(enableAi: true),
      remoteConfig: const _StubRemoteConfig(<String, bool>{'feature.ai.enabled': false}, <String, int>{}),
    );
    expect(flags.isEnabled('feature.ai.enabled'), isFalse);
  });

  test('an ungated key falls back to the supplied default via remote', () {
    final OperationsFeatureFlags flags = OperationsFeatureFlags(
      config: config(enableAi: true),
      remoteConfig: const _StubRemoteConfig(<String, bool>{}, <String, int>{}),
    );
    expect(flags.isEnabled('feature.experiment.x', fallback: true), isTrue);
    expect(flags.isEnabled('feature.experiment.x'), isFalse);
  });

  test('reads a remote rollout percentage', () {
    final OperationsFeatureFlags flags = OperationsFeatureFlags(
      config: config(enableAi: true),
      remoteConfig: const _StubRemoteConfig(<String, bool>{}, <String, int>{'feature.ai.enabled.rollout': 25}),
    );
    expect(flags.rolloutPercentage('feature.ai.enabled'), 25);
    expect(flags.rolloutPercentage('feature.other', fallback: 5), 5);
  });
}
