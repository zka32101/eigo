import '../design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart' as sc;

const AppColors.primary = Color(0xFF1A73E8);
const kPrimaryDark = Color(0xFF1558B0);
const AppColors.primary.withAlpha(25) = Color(0xFF4A9EFF);
const AppColors.accentGreen = Color(0xFF34A853);
const kSecondaryColor = AppColors.accentGreen;
const AppColors.accentOrange = Color(0xFFFB8C00);
const AppColors.error = Color(0xFFE53935);
const kAccentPurple = Color(0xFF7B1FA2);
const kBgLight = Color(0xFFF0F4FF);
const AppColors.textPrimary = Color(0xFF1A1A2E);
const AppColors.textMuted = Color(0xFF6B7280);

// スキルカラー
const AppColors.listeningColor = Color(0xFF00BCD4);
const AppColors.speakingColor = Color(0xFFE91E63);
const AppColors.readingColor = Color(0xFF4CAF50);
const AppColors.writingColor = Color(0xFFFF9800);

ThemeData buildAppTheme() => sc.buildAppTheme(
  primaryColor: AppColors.primary,
  secondaryColor: AppColors.accentGreen,
  bgColor: kBgLight,
);

ThemeData buildDarkAppTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor:AppColors.textWhite,
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
