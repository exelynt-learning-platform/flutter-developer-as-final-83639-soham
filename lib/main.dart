import 'package:employee_management_assessment/framework/controller/auth_controller.dart';
import 'package:employee_management_assessment/framework/controller/emp_controller.dart';
import 'package:employee_management_assessment/framework/services/auth_service.dart';
import 'package:employee_management_assessment/framework/services/emp_service.dart';
import 'package:employee_management_assessment/framework/services/sharedpreferences_service.dart';
import 'package:employee_management_assessment/ui/dashboard_screen.dart';
import 'package:employee_management_assessment/ui/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseConnected = false;
  try {
    await Firebase.initializeApp();
    firebaseConnected = true;
  } catch (error) {
    debugPrint('Firebase is not configured yet: $error');
  }
  final preferences = await SharedPreferencesService.create();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: preferences),
        ChangeNotifierProvider(
          create: (_) =>
              AuthController(AuthService(firebaseReady: firebaseConnected)),
        ),
        ChangeNotifierProvider(
          create: (_) => EmployeeController(EmployeeService(), preferences),
        ),
      ],
      child: const EmployeeManagementApp(),
    ),
  );
}

class EmployeeManagementApp extends StatelessWidget {
  const EmployeeManagementApp({super.key});
  @override
  Widget build(BuildContext context) => Consumer<SharedPreferencesService>(
    builder: (context, prefs, _) => MaterialApp(
      title: 'PeopleDesk',
      debugShowCheckedModeBanner: false,
      themeMode: prefs.darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      home: Consumer<AuthController>(
        builder: (context, auth, _) => auth.isAuthenticated
            ? const DashboardScreen()
            : const LoginScreen(),
      ),
    ),
  );

  ThemeData _theme(Brightness brightness) {
    const seed = Color(0xFF3658C8);
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xFFF5F7FB)
          : const Color(0xFF111318),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF1B1E25),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF1B1E25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
