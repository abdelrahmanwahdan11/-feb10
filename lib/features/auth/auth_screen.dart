import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_localizations.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool obscurePass = true;

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? tr.t('login') : tr.t('signup'))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Icon(Icons.lock_person_rounded, size: 90, color: Theme.of(context).colorScheme.secondary)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 1300.ms),
              const SizedBox(height: 20),
              if (!isLogin)
                TextField(decoration: InputDecoration(labelText: tr.t('name'), prefixIcon: const Icon(Icons.person))),
              const SizedBox(height: 14),
              TextField(decoration: InputDecoration(labelText: tr.t('email'), prefixIcon: const Icon(Icons.mail))),
              const SizedBox(height: 14),
              TextField(
                obscureText: obscurePass,
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
              FilledButton(
                onPressed: () => context.go('/home'),
                child: Text(isLogin ? tr.t('login') : tr.t('signup')),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: Text(isLogin ? tr.t('signup') : tr.t('login')),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go('/home'),
                child: Text(tr.t('guest')),
              ),
            ].animate(interval: 100.ms).fadeIn().slideX(begin: 0.1),
          ),
        ),
      ),
    );
  }
}
