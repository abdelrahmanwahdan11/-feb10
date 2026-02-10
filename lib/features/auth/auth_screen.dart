import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_localizations.dart';
import '../../core/session_store.dart';
import '../loading/branded_loader.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _store = SessionStore();

  bool isLogin = true;
  bool obscurePass = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  bool _isEmailValid(String value) {
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return regex.hasMatch(value);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final tr = AppLocalizations.of(context);
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    await _store.setAuthMode('user');
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isLogin ? tr.t('signinSuccess') : tr.t('signupSuccess'))),
    );
    context.go('/home');
  }

  Future<void> _continueGuest() async {
    final tr = AppLocalizations.of(context);
    await _store.setAuthMode('guest');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr.t('guestSuccess'))));
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? tr.t('login') : tr.t('signup'))),
      body: _loading
          ? BrandedLoader(label: tr.t('analyze'))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Icon(Icons.lock_person_rounded, size: 90, color: Theme.of(context).colorScheme.secondary)
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 1300.ms),
                      const SizedBox(height: 20),
                      if (!isLogin)
                        TextFormField(
                          controller: _nameCtrl,
                          validator: (value) => (value == null || value.trim().isEmpty) ? tr.t('requiredField') : null,
                          decoration: InputDecoration(labelText: tr.t('name'), prefixIcon: const Icon(Icons.person)),
                        ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _emailCtrl,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return tr.t('requiredField');
                          if (!_isEmailValid(value.trim())) return tr.t('invalidEmail');
                          return null;
                        },
                        decoration: InputDecoration(labelText: tr.t('email'), prefixIcon: const Icon(Icons.mail)),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: obscurePass,
                        validator: (value) {
                          if (value == null || value.isEmpty) return tr.t('requiredField');
                          if (value.length < 6) return tr.t('shortPassword');
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: tr.t('password'),
                          prefixIcon: const Icon(Icons.password_rounded),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => obscurePass = !obscurePass),
                            icon: Icon(obscurePass ? Icons.visibility : Icons.visibility_off),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(onPressed: _submit, child: Text(isLogin ? tr.t('login') : tr.t('signup'))),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => setState(() => isLogin = !isLogin),
                        child: Text(isLogin ? tr.t('signup') : tr.t('login')),
                      ),
                      const SizedBox(height: 8),
                      TextButton(onPressed: _continueGuest, child: Text(tr.t('guest'))),
                    ].animate(interval: 100.ms).fadeIn().slideX(begin: 0.1),
                  ),
                ),
              ),
            ),
    );
  }
}
