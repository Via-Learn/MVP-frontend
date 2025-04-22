import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.5,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}
