import 'dart:convert';
import 'package:employee_management_assessment/framework/model/employee.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService extends ChangeNotifier {
  SharedPreferencesService(this._prefs);
  final SharedPreferences _prefs;
  static const _themeKey = 'dark_mode', _cacheKey = 'employee_cache';
  static Future<SharedPreferencesService> create() async =>
      SharedPreferencesService(await SharedPreferences.getInstance());
  bool get darkMode => _prefs.getBool(_themeKey) ?? false;
  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(_themeKey, value);
    notifyListeners();
  }

  List<Employee> get cachedEmployees {
    final raw = _prefs.getString(_cacheKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => Employee.fromJson(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> cacheEmployees(List<Employee> employees) async =>
      _prefs.setString(
        _cacheKey,
        jsonEncode(employees.map((e) => {...e.toJson(), 'id': e.id}).toList()),
      );
}
