/// Root / jailbreak detection — architecture placeholder (docs/40 §39.2).
///
/// A soft signal (warn/limit), never a hard block that punishes false positives.
/// The seam is defined so a future implementation drops in behind this interface.
/// The M1 implementation always reports a healthy device.
library;

/// The outcome of a device-integrity check.
class DeviceIntegrityReport {
  const DeviceIntegrityReport({
    required this.isCompromised,
    this.signals = const <String>[],
  });

  final bool isCompromised;
  final List<String> signals;

  static const DeviceIntegrityReport healthy = DeviceIntegrityReport(
    isCompromised: false,
  );
}

abstract interface class DeviceIntegrityService {
  Future<DeviceIntegrityReport> check();
}

class NoopDeviceIntegrityService implements DeviceIntegrityService {
  const NoopDeviceIntegrityService();

  @override
  Future<DeviceIntegrityReport> check() async => DeviceIntegrityReport.healthy;
}
