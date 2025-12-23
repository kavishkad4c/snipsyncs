import 'package:flutter/material.dart';
import '../utils/colors.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;

  const GradientBackground({
    super.key,
    required this.child,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.gradient1,
      ),
      child: child,
    );
  }
}