import 'package:employee_management_assessment/framework/model/employee.dart';
import 'package:employee_management_assessment/framework/repository/emp_repo.dart';
import 'package:employee_management_assessment/framework/services/sharedpreferences_service.dart';
import 'package:flutter/foundation.dart';

class EmployeeController extends ChangeNotifier {
  EmployeeController(this._service, this._preferences) {
    employees = _preferences.cachedEmployees;
  }
  final EmployeeRepository _service;
  final SharedPreferencesService _preferences;
  List<Employee> employees = [];
  List<String> countries = [];
  bool loading = false;
  String? error;
  String query = '';
  String filter = 'Name';
  List<Employee> get filteredEmployees {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return employees;
    return employees
        .where(
          (e) => switch (filter) {
        'Email' => e.email,
        'Mobile' => e.mobile,
        'Country' => e.country,
        'ID' => e.id ?? '',
        _ => e.name,
      }.toLowerCase().contains(q),
    )
        .toList();
  }

  Future<void> load({bool refresh = false}) async {
    loading = employees.isEmpty || refresh;
    error = null;
    notifyListeners();
    try {
      employees = await _service.getAll();
      await _preferences.cacheEmployees(employees);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
    loadCountries();
  }

  Future<void> loadCountries() async {
    try {
      final list = await _service.getCountries();
      countries = list
          .map((e) => (e['name'] ?? e['country'] ?? e['title'] ?? '').toString())
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList();
      notifyListeners();
    } catch (_) {
      // Fallback
    }
  }

  void search(String value, {String? by}) {
    query = value;
    if (by != null) filter = by;
    notifyListeners();
  }

  Future<void> save(Employee employee) async {
    try {
      final saved = employee.id == null
          ? await _service.create(employee)
          : await _service.update(employee);
      employees = employee.id == null
          ? [saved, ...employees]
          : employees.map((e) => e.id == saved.id ? saved : e).toList();
      await _preferences.cacheEmployees(employees);
      notifyListeners();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> remove(String id) async {
    try {
      await _service.delete(id);
      employees = employees.where((e) => e.id != id).toList();
      await _preferences.cacheEmployees(employees);
      notifyListeners();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }
}
