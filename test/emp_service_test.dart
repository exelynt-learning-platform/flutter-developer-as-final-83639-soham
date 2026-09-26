import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:employee_management_assessment/framework/model/employee.dart';
import 'package:employee_management_assessment/framework/services/emp_service.dart';

class MockAdapter implements HttpClientAdapter {
  MockAdapter(this.handler);
  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
      RequestOptions options,
      Stream<List<int>>? requestStream,
      Future<void>? cancelFuture,
      ) =>
      handler(options);

  @override
  void close({bool force = false}) {}
}

void main() {
  test('service fetches records and sends create request using Dio', () async {
    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://mock.api'));

    dio.httpClientAdapter = MockAdapter((options) async {
      requests.add(options);
      if (options.path.contains('/employee') && options.method == 'GET') {
        return ResponseBody.fromString(
          '[{"id": "1", "name": "Ari"}]',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      }
      return ResponseBody.fromString(
        '{"id": "2", "name": "Bea"}',
        201,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });

    final service = EmployeeService(dio: dio, baseUrl: 'https://mock.api');

    expect((await service.getAll()).single.name, 'Ari');
    expect(
      (await service.create(
        const Employee(
          name: 'Bea',
          email: 'b@b.co',
          mobile: '5551234567',
          country: 'US',
          state: 'CA',
          district: 'LA',
        ),
      )).id,
      '2',
    );
    expect(requests.map((r) => r.method), ['GET', 'POST']);
  });
}