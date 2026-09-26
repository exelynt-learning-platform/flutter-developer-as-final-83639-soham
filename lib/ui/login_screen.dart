import 'package:employee_management_assessment/framework/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false, _obscure = true;
  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _emailRule(String? v) =>
      v == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)
          ? 'Enter a valid email address'
          : null;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Consumer<AuthController>(
                builder: (context, auth, _) => Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.people_alt_rounded,
                        size: 48,
                        color: Color(0xFF3658C8),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _register
                            ? 'Create your account'
                            : 'Welcome to PeopleDesk',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Manage your people, all in one place.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),
                      if (_register) ...[
                        TextFormField(
                          key: const Key('nameField'),
                          controller: _name,
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (v) => v == null || v.trim().length < 2
                              ? 'Enter your name'
                              : null,
                        ),
                        const SizedBox(height: 14),
                      ],
                      TextFormField(
                        key: const Key('emailField'),
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email address',
                          prefixIcon: Icon(Icons.mail_outline),
                        ),
                        validator: _emailRule,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        key: const Key('passwordField'),
                        controller: _password,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                        validator: (v) => v == null || v.length < 6
                            ? 'Use at least 6 characters'
                            : null,
                      ),
                      if (!_register)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: auth.loading
                                ? null
                                : () async {
                              if (_emailRule(_email.text) != null) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Enter your email first',
                                    ),
                                  ),
                                );
                                return;
                              }
                              await auth.resetPassword(_email.text);
                              if (context.mounted && auth.error == null)
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Password reset email sent',
                                    ),
                                  ),
                                );
                            },
                            child: const Text('Forgot password?'),
                          ),
                        ),
                      if (auth.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            auth.error!,
                            key: const Key('authError'),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      FilledButton(
                        onPressed: auth.loading
                            ? null
                            : () async {
                          if (!_form.currentState!.validate()) return;
                          if (_register) {
                            await auth.register(
                              _name.text,
                              _email.text,
                              _password.text,
                            );
                          } else {
                            await auth.login(_email.text, _password.text);
                          }
                        },
                        child: auth.loading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                            : Text(_register ? 'Create account' : 'Sign in'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: auth.loading
                            ? null
                            : () => auth.googleSignIn(),
                        icon: const Icon(Icons.g_mobiledata, size: 28),
                        label: const Text('Continue with Google'),
                      ),
                      TextButton(
                        onPressed: () => setState(() {
                          _register = !_register;
                        }),
                        child: Text(
                          _register
                              ? 'Already have an account? Sign in'
                              : 'New to PeopleDesk? Create account',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
