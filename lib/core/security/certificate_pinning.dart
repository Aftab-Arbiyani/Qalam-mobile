/// Certificate pinning — architecture placeholder (docs/40 §39.2).
///
/// Pinning is a mobile-specific hardening scheduled for the security-hardening
/// epic, not M1 (it needs a pin set + a rotation plan to avoid bricking on cert
/// rotation). The seam is here so wiring it later is a one-line change: implement
/// [apply] to attach a validating `HttpClientAdapter`/badCertificateCallback to
/// the Dio instance. The M1 implementation is intentionally inert.
library;

import 'package:dio/dio.dart';

abstract interface class CertificatePinning {
  /// Attach pinning to [dio]. A no-op until a pin set is configured.
  void apply(Dio dio);
}

/// The M1 implementation: no pinning applied. Swapped for a pinning implementation
/// in the hardening epic without touching call sites.
class NoopCertificatePinning implements CertificatePinning {
  const NoopCertificatePinning();

  @override
  void apply(Dio dio) {
    // Inert by design. Pinning is enabled in the security-hardening epic.
  }
}
