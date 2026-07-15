import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qalam_mobile/core/error/api_exception.dart';
import 'package:qalam_mobile/core/network/api_client.dart';
import 'package:qalam_mobile/shared/api/api_envelope.dart';
import 'package:qalam_mobile/shared/domain/error_codes.dart';

import '../../support/harness.dart';

class MockDio extends Mock implements Dio {}

Response<dynamic> _ok(Object? data, {Map<String, dynamic>? meta}) =>
    Response<dynamic>(
      requestOptions: RequestOptions(path: '/x'),
      statusCode: 200,
      data: <String, dynamic>{'success': true, 'data': data, 'meta': ?meta},
    );

void main() {
  late MockDio dio;

  setUp(() {
    dio = MockDio();
  });

  Future<ApiClient> onlineClient() async => ApiClient(
    dio: dio,
    connectivity: await buildFakeConnectivity(online: true),
  );

  test('get unwraps the envelope and decodes data', () async {
    when(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) async => _ok(<String, dynamic>{'id': 'p1'}));

    final ApiClient client = await onlineClient();
    final String id = await client.get<String>(
      '/pieces/p1',
      decode: (json) => json['id'] as String,
    );
    expect(id, 'p1');
  });

  test('getPage reads items + meta.pagination', () async {
    when(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer(
      (_) async => _ok(
        <Map<String, dynamic>>[
          <String, dynamic>{'id': 'a'},
          <String, dynamic>{'id': 'b'},
        ],
        meta: <String, dynamic>{
          'pagination': <String, dynamic>{
            'nextCursor': 'cur2',
            'hasMore': true,
            'limit': 20,
          },
        },
      ),
    );

    final ApiClient client = await onlineClient();
    final CursorPage<String> page = await client.getPage<String>(
      '/feed/latest',
      decodeItem: (json) => json['id'] as String,
    );
    expect(page.items, <String>['a', 'b']);
    expect(page.meta.nextCursor, 'cur2');
    expect(page.hasMore, isTrue);
  });

  test('offline is detected before the request fires', () async {
    final ApiClient client = ApiClient(
      dio: dio,
      connectivity: await buildFakeConnectivity(online: false),
    );
    await expectLater(
      client.get<String>('/pieces/p1', decode: (json) => 'x'),
      throwsA(
        isA<ApiException>().having(
          (ApiException e) => e.code,
          'code',
          ErrorCodes.apiOffline,
        ),
      ),
    );
    verifyNever(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
        cancelToken: any(named: 'cancelToken'),
      ),
    );
  });

  test('a DioException is converted to a typed ApiException', () async {
    when(
      () => dio.get<dynamic>(
        any(),
        queryParameters: any(named: 'queryParameters'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: '/pieces/x'),
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: RequestOptions(path: '/pieces/x'),
          statusCode: 404,
          data: <String, dynamic>{
            'success': false,
            'error': <String, dynamic>{
              'code': ErrorCodes.pieceNotFound,
              'message': 'nope',
            },
          },
        ),
      ),
    );

    final ApiClient client = await onlineClient();
    await expectLater(
      client.get<String>(
        '/pieces/x',
        decode: (json) => 'x',
        deduplicate: false,
      ),
      throwsA(
        isA<ApiException>()
            .having(
              (ApiException e) => e.code,
              'code',
              ErrorCodes.pieceNotFound,
            )
            .having((ApiException e) => e.status, 'status', 404),
      ),
    );
  });
}
