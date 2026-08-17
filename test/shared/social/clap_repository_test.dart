/// The clap data layer (M7-3) — path, body, response adoption, and the two
/// failures the contract actually produces: an all-or-nothing 204 removal and
/// `CLAP_LIMIT_REACHED` on a maxed-out piece.
///
/// Tested at the repository boundary over a mocked `Dio` rather than against the
/// fake repo, because the point of these cases is the WIRE: that we POST the
/// batched `count` to `/pieces/:id/claps`, and that we adopt the server's two
/// numbers instead of trusting our own arithmetic.
library;

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/core/network/api_client.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/shared/domain/error_codes.dart';
import 'package:qalam_mobile/shared/social/data/engagement_remote_data_source.dart';
import 'package:qalam_mobile/shared/social/data/engagement_repository_impl.dart';
import 'package:qalam_mobile/shared/social/domain/engagement_repository.dart';

import '../../support/harness.dart';

class MockDio extends Mock implements Dio {}

Response<dynamic> _ok(Object? data) => Response<dynamic>(
  requestOptions: RequestOptions(path: '/x'),
  statusCode: 200,
  data: <String, dynamic>{'success': true, 'data': data},
);

/// The envelope the API returns for a domain-rule refusal (422).
DioException _domainRule(String code) => DioException(
  requestOptions: RequestOptions(path: '/x'),
  type: DioExceptionType.badResponse,
  response: Response<dynamic>(
    requestOptions: RequestOptions(path: '/x'),
    statusCode: 422,
    data: <String, dynamic>{
      'success': false,
      'error': <String, dynamic>{
        'code': code,
        'message': 'Clap limit reached.',
      },
    },
  ),
);

void main() {
  late MockDio dio;

  setUp(() {
    dio = MockDio();
  });

  Future<EngagementRepository> repo() async => EngagementRepositoryImpl(
    EngagementRemoteDataSource(
      ApiClient(
        dio: dio,
        connectivity: await buildFakeConnectivity(online: true),
      ),
    ),
  );

  test('clap POSTs the batched count and adopts BOTH server numbers', () async {
    when(
      () => dio.post<dynamic>(
        any(),
        data: any(named: 'data'),
        queryParameters: any(named: 'queryParameters'),
        cancelToken: any(named: 'cancelToken'),
        options: any(named: 'options'),
      ),
      // The server clamped 12 → 7 (it had 43) and the total moved past our +12
      // because other readers clapped while this page was open. Both are adopted.
    ).thenAnswer(
      (_) async =>
          _ok(<String, dynamic>{'viewerClaps': 50, 'totalClaps': 4211}),
    );

    final Result<ClapOutcome> res = await (await repo()).clap('p1', 12);

    expect(res.valueOrNull?.viewerClaps, 50);
    expect(res.valueOrNull?.totalClaps, 4211);

    final List<dynamic> captured = verify(
      () => dio.post<dynamic>(
        captureAny(),
        data: captureAny(named: 'data'),
        queryParameters: any(named: 'queryParameters'),
        cancelToken: any(named: 'cancelToken'),
        options: any(named: 'options'),
      ),
    ).captured;
    expect(captured[0], '/pieces/p1/claps');
    expect(captured[1], <String, Object?>{'count': 12});
  });

  test('unclap DELETEs and succeeds on a 204 with no body', () async {
    when(
      () => dio.delete<dynamic>(
        any(),
        data: any(named: 'data'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer(
      (_) async => Response<dynamic>(
        requestOptions: RequestOptions(path: '/pieces/p1/claps'),
        statusCode: 204,
      ),
    );

    final Result<void> res = await (await repo()).unclap('p1');

    expect(res.isOk, isTrue);
    verify(
      () => dio.delete<dynamic>(
        '/pieces/p1/claps',
        data: any(named: 'data'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).called(1);
  });

  test(
    'a maxed-out piece surfaces CLAP_LIMIT_REACHED as a domain rule',
    () async {
      when(
        () => dio.post<dynamic>(
          any(),
          data: any(named: 'data'),
          queryParameters: any(named: 'queryParameters'),
          cancelToken: any(named: 'cancelToken'),
          options: any(named: 'options'),
        ),
      ).thenAnswer(
        (_) => Future<Response<dynamic>>.error(
          _domainRule(ErrorCodes.clapLimitReached),
        ),
      );

      final Result<ClapOutcome> res = await (await repo()).clap('p1', 1);

      final Failure? f = res.failureOrNull;
      expect(f, isA<DomainRuleFailure>());
      expect(switch (f) {
        DomainRuleFailure(:final String code) => code,
        _ => null,
      }, ErrorCodes.clapLimitReached);
    },
  );
}
