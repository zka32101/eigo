import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_core/shared_core.dart' as sc;

import '../design_system/design_system.dart';

const kPrimaryDark = Color(0xFF1558B0);
const kAccentPurple = Color(0xFF7B1FA2);

ThemeData buildAppTheme() {
  final baseTheme = sc.buildAppTheme(
    primaryColor: AppColors.primary,
    secondaryColor: AppColors.accentGreen,
    bgColor: AppColors.bgLight,
  );

  return baseTheme.copyWith(
    textTheme: GoogleFonts.notoSansJpTextTheme(baseTheme.textTheme).copyWith(
      displayLarge: GoogleFonts.notoSansJp(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
      displayMedium: GoogleFonts.notoSansJp(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
      displaySmall: GoogleFonts.notoSansJp(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
      headlineMedium: GoogleFonts.notoSansJp(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      headlineSmall: GoogleFonts.notoSansJp(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      titleLarge: GoogleFonts.notoSansJp(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      titleMedium: GoogleFonts.notoSansJp(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      ),
      bodyLarge: GoogleFonts.notoSansJp(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
      ),
      bodyMedium: GoogleFonts.notoSansJp(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textDark,
      ),
      bodySmall: GoogleFonts.notoSansJp(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      labelLarge: GoogleFonts.notoSansJp(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      ),
    ),
  );
}

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
  textTheme: TextTheme(
    displayLarge: GoogleFonts.notoSansJp(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.textWhite,
    ),
    displayMedium: GoogleFonts.notoSansJp(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.textWhite,
    ),
    displaySmall: GoogleFonts.notoSansJp(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.textWhite,
    ),
    headlineMedium: GoogleFonts.notoSansJp(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textWhite,
    ),
    headlineSmall: GoogleFonts.notoSansJp(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textWhite,
    ),
    titleLarge: GoogleFonts.notoSansJp(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textWhite,
    ),
    titleMedium: GoogleFonts.notoSansJp(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textWhite,
    ),
    bodyLarge: GoogleFonts.notoSansJp(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textWhite,
    ),
    bodyMedium: GoogleFonts.notoSansJp(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textWhite.withOpacity(0.7),
    ),
    bodySmall: GoogleFonts.notoSansJp(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.textWhite.withOpacity(0.6),
    ),
    labelLarge: GoogleFonts.notoSansJp(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.textWhite,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2A2A2A),
    labelStyle: TextStyle(color: AppColors.textWhite.withOpacity(0.7)),
    hintStyle: TextStyle(color: AppColors.textWhite.withOpacity(0.38)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
    ),
  ),
);
