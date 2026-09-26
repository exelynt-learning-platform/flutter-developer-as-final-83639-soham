import 'package:employee_management_assessment/framework/controller/auth_controller.dart';
import 'package:employee_management_assessment/framework/services/auth_service.dart';
import 'package:employee_management_assessment/ui/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('login validates email and password before calling auth', (
      tester,
      ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthController(AuthService(firebaseReady: false)),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(find.text('Use at least 6 characters'), findsOneWidget);
  });
  testWidgets('Google sign-in action is present', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthController(AuthService(firebaseReady: false)),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
