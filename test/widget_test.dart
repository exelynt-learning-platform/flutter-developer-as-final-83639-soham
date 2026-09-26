import 'package:employee_management_assessment/framework/controller/auth_controller.dart';
import 'package:employee_management_assessment/framework/controller/emp_controller.dart';
import 'package:employee_management_assessment/framework/services/auth_service.dart';
import 'package:employee_management_assessment/framework/services/emp_service.dart';
import 'package:employee_management_assessment/framework/services/sharedpreferences_service.dart';
import 'package:employee_management_assessment/ui/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Renders LoginScreen for unauthenticated user', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferencesService.create();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: prefs),
          ChangeNotifierProvider(
            create: (_) => AuthController(AuthService(firebaseReady: false)),
          ),
          ChangeNotifierProvider(
            create: (_) => EmployeeController(EmployeeService(), prefs),
          ),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('Welcome to PeopleDesk'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
