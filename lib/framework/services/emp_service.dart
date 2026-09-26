import 'package:dio/dio.dart';
import 'package:employee_management_assessment/framework/model/employee.dart';
import 'package:employee_management_assessment/framework/repository/emp_repo.dart';

class EmployeeService implements EmployeeRepository {
  EmployeeService({
    Dio? dio,
    String baseUrl = 'https://669b3f09276e45187d34eb4e.mockapi.io/api/v1',
  }) : _dio = dio ??
      Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        ),
      );

  final Dio _dio;

  @override
  Future<List<Employee>> getAll() async {
    final response = await _dio.get('/employee');
    return (response.data as List)
        .map((e) => Employee.fromJson(e))
        .toList();
  }

  @override
  Future<Employee> getById(String id) async {
    final response = await _dio.get('/employee/${Uri.encodeComponent(id)}');
    return Employee.fromJson(response.data);
  }

  @override
  Future<Employee> create(Employee employee) async {
    final response = await _dio.post(
      '/employee',
      data: employee.toJson(),
    );
    return Employee.fromJson(response.data);
  }

  @override
  Future<Employee> update(Employee employee) async {
    if (employee.id == null) {
      throw ArgumentError('An employee ID is required for updates.');
    }
    final response = await _dio.put(
      '/employee/${Uri.encodeComponent(employee.id!)}',
      data: employee.toJson(),
    );
    return Employee.fromJson(response.data);
  }

  @override
  Future<void> delete(String id) async {
    await _dio.delete('/employee/${Uri.encodeComponent(id)}');
  }

  @override
  Future<List<Map<String, dynamic>>> getCountries() async {
    final response = await _dio.get('/country');
    return (response.data as List).cast<Map<String, dynamic>>();
  }
}