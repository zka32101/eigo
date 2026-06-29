import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart' as sc;

const kPrimaryColor = Color(0xFF1A73E8);
const kPrimaryDark = Color(0xFF1558B0);
const kPrimaryLight = Color(0xFF4A9EFF);
const kAccentGreen = Color(0xFF34A853);
const kAccentOrange = Color(0xFFFB8C00);
const kAccentRed = Color(0xFFE53935);
const kAccentPurple = Color(0xFF7B1FA2);
const kBgLight = Color(0xFFF0F4FF);
const kTextDark = Color(0xFF1A1A2E);
const kTextMuted = Color(0xFF6B7280);

// スキルカラー
const kListeningColor = Color(0xFF00BCD4);
const kSpeakingColor = Color(0xFFE91E63);
const kReadingColor = Color(0xFF4CAF50);
const kWritingColor = Color(0xFFFF9800);

ThemeData buildAppTheme() => sc.buildAppTheme(
  primaryColor: kPrimaryColor,
  secondaryColor: kAccentGreen,
  bgColor: kBgLight,
);

ThemeData buildDarkAppTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primaryColor: kPrimaryColor,
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  cardColor: const Color(0xFF1E1E1E),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.white70),
    titleMedium: TextStyle(color: Colors.white),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF2A2A2A),
    labelStyle: const TextStyle(color: Colors.white70),
    hintStyle: const TextStyle(color: Colors.white38),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
    ),
  ),
);
