import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qalam_mobile/core/error/api_exception.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/features/monetization/data/datasources/monetization_remote_data_source.dart';
import 'package:qalam_mobile/features/monetization/data/local/entitlement_cache_store.dart';
import 'package:qalam_mobile/features/monetization/data/repositories/monetization_repository_impl.dart';
import 'package:qalam_mobile/features/monetization/domain/entities/entitlement.dart';
import 'package:qalam_mobile/features/monetization/domain/entities/monetization_enums.dart';
import 'package:qalam_mobile/shared/domain/error_codes.dart';

class _MockRemote extends Mock implements MonetizationRemoteDataSource {}

class _MockCache extends Mock implements EntitlementCacheStore {}

void main() {
  late _MockRemote remote;
  late _MockCache cache;
  late MonetizationRepositoryImpl repo;

  const EntitlementSnapshot snapshot = EntitlementSnapshot(
    tier: PlanTier.pro,
    status: EntitlementStatus.allow,
    features: <EntitlementDecision>[],
  );

  setUpAll(() {
    registerFallbackValue(EntitlementSnapshot.free);
  });

  setUp(() {
    remote = _MockRemote();
    cache = _MockCache();
    repo = MonetizationRepositoryImpl(remote, cache);
  });

  test('entitlements() caches the snapshot on a successful read', () async {
    when(() => remote.entitlements()).thenAnswer((_) async => snapshot);
    when(() => cache.write(any())).thenAnswer((_) async {});

    final Result<EntitlementSnapshot> result = await repo.entitlements();

    expect(result, isA<Ok<EntitlementSnapshot>>());
    verify(() => cache.write(snapshot)).called(1);
  });

  test('entitlements() does NOT cache when the read fails', () async {
    when(() => remote.entitlements()).thenThrow(
      const ApiException(
        code: ErrorCodes.internalServerError,
        message: 'boom',
        status: 500,
      ),
    );

    final Result<EntitlementSnapshot> result = await repo.entitlements();

    expect(result, isA<Err<EntitlementSnapshot>>());
    verifyNever(() => cache.write(any()));
  });

  test('cachedEntitlements() delegates to the local cache', () {
    when(() => cache.read()).thenReturn(snapshot);
    expect(repo.cachedEntitlements(), snapshot);
  });
}
