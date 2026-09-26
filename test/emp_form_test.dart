import 'package:dio/dio.dart';
import 'package:employee_management_assessment/framework/controller/emp_controller.dart';
import 'package:employee_management_assessment/framework/services/emp_service.dart';
import 'package:employee_management_assessment/framework/services/sharedpreferences_service.dart';
import 'package:employee_management_assessment/ui/emp_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('employee form reports required fields and email errors', (
      tester,
      ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferencesService.create();

    final controller = EmployeeController(
      EmployeeService(dio: Dio()), prefs,);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(home: EmployeeFormScreen()),
      ),
    );

    await tester.tap(find.text('Save employee'));
    await tester.pump();

    expect(find.text('This field is required'), findsNWidgets(6));
  });
}