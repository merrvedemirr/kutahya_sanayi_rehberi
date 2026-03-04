import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get displayLarge => GoogleFonts.barlowCondensed(
    fontSize: 70,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
    height: 0.9,
  );

  static TextStyle get displayMedium => GoogleFonts.barlowCondensed(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
  );

  static TextStyle get headlineLarge => GoogleFonts.barlowCondensed(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
  );

  static TextStyle get headlineMedium => GoogleFonts.barlowCondensed(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.15,
  );

  static TextStyle get labelUppercase => GoogleFonts.barlowCondensed(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.textMuted,
    letterSpacing: 2.0,
  );

  static TextStyle get labelAccent => GoogleFonts.barlowCondensed(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.accent,
    letterSpacing: 2.0,
  );

  static TextStyle get bodyMedium => GoogleFonts.barlow(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  static TextStyle get bodySmall => GoogleFonts.barlow(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.5,
  );

  static TextStyle get cardTitle => GoogleFonts.barlowCondensed(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
  );

  static TextStyle get cardNum => GoogleFonts.barlowCondensed(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textMuted,
    letterSpacing: 2.0,
  );

  static TextStyle get chipLabel => GoogleFonts.barlowCondensed(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
  );

  static TextStyle get statusLabel => GoogleFonts.barlowCondensed(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
  );

  static TextStyle get phone => GoogleFonts.barlowCondensed(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );
}
