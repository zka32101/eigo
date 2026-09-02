import '../design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart' as sc;

// Legacy theme constants - maintained for backward compatibility but prefer AppColors
const kPrimaryDark = Color(0xFF1558B0);
const kAccentPurple = Color(0xFF7B1FA2);

ThemeData buildAppTheme() => sc.buildAppTheme(
  primaryColor: AppColors.primary,
  secondaryColor: AppColors.accentGreen,
  bgColor: AppColors.bgLight,
);

ThemeData buildDarkAppTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor: AppColors.textWhite,
    elevation: 0,
  ),
  cardColor: const Color(0xFF1E1E1E),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: AppColors.textWhite.withOpacity(0.7)),
    titleMedium: TextStyle(color: AppColors.textWhite),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2A2A2A),
    labelStyle: const TextStyle(color: AppColors.textWhite.withOpacity(0.7)),
    hintStyle: const TextStyle(color: AppColors.textWhite.withOpacity(0.38)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
    ),
  ),
);
