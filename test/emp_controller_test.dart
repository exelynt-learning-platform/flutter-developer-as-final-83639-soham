import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:employee_management_assessment/framework/controller/emp_controller.dart';
import 'package:employee_management_assessment/framework/model/employee.dart';
import 'package:employee_management_assessment/framework/services/emp_service.dart';
import 'package:employee_management_assessment/framework/services/sharedpreferences_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  test('search filter and CRUD updates cached application state with Dio', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferencesService.create();

    final dio = Dio(BaseOptions(baseUrl: 'https://mock.api'));
    dio.httpClientAdapter = MockAdapter((options) async {
      if (options.method == 'GET') {
        return ResponseBody.fromString(
          jsonEncode([
            {
              'id': '11',
              'name': 'Nia Chen',
              'email': 'nia@example.com',
              'mobile': '5551112233',
              'country': 'India',
              'state': 'Goa',
              'district': 'Panaji',
            },
          ]),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      }
      if (options.method == 'POST') {
        return ResponseBody.fromString(
          jsonEncode({...options.data, 'id': '12'}),
          201,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      }
      if (options.method == 'DELETE') {
        return ResponseBody.fromString('{}', 200, headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        });
      }
      return ResponseBody.fromString(
        jsonEncode({...options.data, 'id': '11'}),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });

    final state = EmployeeController(
      EmployeeService(dio: dio, baseUrl: 'https://mock.api'),
      prefs,
    );

    await state.load();
    expect(state.employees.length, 1);

    state.search('nia', by: 'Name');
    expect(state.filteredEmployees.length, 1);

    state.search('12', by: 'ID');
    expect(state.filteredEmployees, isEmpty);

    const added = Employee(
      name: 'Omar',
      email: 'omar@example.com',
      mobile: '5551110000',
      country: 'India',
      state: 'Goa',
      district: 'Margao',
    );

    await state.save(added);
    expect(state.employees.first.id, '12');

    state.search('omar', by: 'Email');
    expect(state.filteredEmployees.single.name, 'Omar');

    await state.remove('12');
    expect(state.employees.length, 1);
    expect(prefs.cachedEmployees.single.name, 'Nia Chen');
  });
}