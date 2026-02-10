import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BrandedLoader extends StatelessWidget {
  const BrandedLoader({super.key, this.label = 'Loading...'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0057D8), Color(0xFF6F2CFF)]),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 48),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .scale(duration: 1200.ms, begin: const Offset(0.9, 0.9), end: const Offset(1.05, 1.05))
              .then()
              .scale(duration: 1200.ms, begin: const Offset(1.05, 1.05), end: const Offset(0.9, 0.9)),
          const SizedBox(height: 14),
          Text(label).animate().fadeIn().slideY(begin: 0.2),
        ],
      ),
    );
  }
}
