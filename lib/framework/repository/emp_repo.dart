import 'package:employee_management_assessment/framework/model/employee.dart';

abstract interface class EmployeeRepository {
  Future<List<Employee>> getAll();
  Future<Employee> getById(String id);
  Future<Employee> create(Employee employee);
  Future<Employee> update(Employee employee);
  Future<void> delete(String id);
  Future<List<Map<String, dynamic>>> getCountries();
}