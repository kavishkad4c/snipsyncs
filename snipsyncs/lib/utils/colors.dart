import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF6C63FF);
  static const secondary = Color(0xFFFF6584);
  static const accent = Color(0xFF4ECDC4);
  static const darkPurple = Color(0xFF5B4FFF);
  static const lightPurple = Color(0xFF9C8FFF);
  static const info = Color(0xFF2196F3); // Added missing info color
  
  static const background = Color(0xFFF8F9FE);
  static const cardBackground = Colors.white;
  static const textPrimary = Color(0xFF2D3142);
  static const textSecondary = Color(0xFF9A9FAE);
  
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
  static const error = Color(0xFFF44336);
  
  static const gradient1 = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF5B4FFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const gradient2 = LinearGradient(
    colors: [Color(0xFFFF6584), Color(0xFFFF8FA3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const gradient3 = LinearGradient(
    colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}