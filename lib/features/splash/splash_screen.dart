import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_localizations.dart';
import '../../core/session_store.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _store = SessionStore();

  static const Set<String> _restorableRoutes = {
    '/home',
    '/reports',
    '/sheet',
    '/templates',
    '/progress',
    '/dashboard',
    '/automation',
    '/data-catalog',
    '/api-keys',
    '/expert-review',
    '/help-center',
  };

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () async {
      final seen = await _store.hasSeenOnboarding();
      final authMode = await _store.getAuthMode();
      final lastRoute = await _store.getLastVisitedRoute();
      if (!mounted) return;
      if (!seen) {
        context.go('/onboarding');
      } else if (authMode == null) {
        context.go('/auth');
      } else if (lastRoute != null && _restorableRoutes.contains(lastRoute)) {
        context.go(lastRoute);
      } else {
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF002766), Color(0xFF6F2CFF)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.grid_on_rounded, color: Colors.white, size: 80)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .rotate(duration: 2500.ms)
                  .shimmer(duration: 1800.ms),
              const SizedBox(height: 16),
              Text(
                tr.t('appTitle'),
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.4),
            ],
          ),
        ),
      ),
    );
  }
}
