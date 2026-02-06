import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTextStyles.fontFamily,
      
      // Color Scheme
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.universityNavy,
        onPrimary: AppColors.pureWhite,
        secondary: AppColors.academicBlue,
        onSecondary: AppColors.pureWhite,
        tertiary: AppColors.professionalTeal,
        onTertiary: AppColors.pureWhite,
        error: AppColors.errorRed,
        onError: AppColors.pureWhite,
        background: AppColors.offWhite,
        onBackground: AppColors.charcoal,
        surface: AppColors.cardBackground,
        onSurface: AppColors.charcoal,
        outline: AppColors.inputBorder,
      ),

      scaffoldBackgroundColor: AppColors.offWhite,
      dividerColor: AppColors.divider,

      // Typography
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        headlineLarge: AppTextStyles.h1,
        headlineMedium: AppTextStyles.h2,
        headlineSmall: AppTextStyles.h3,
        titleLarge: AppTextStyles.h4,
        titleMedium: AppTextStyles.h5,
        titleSmall: AppTextStyles.h6,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyRegular,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.label,
        labelSmall: AppTextStyles.caption,
      ),

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.pureWhite,
        foregroundColor: AppColors.universityNavy,
        elevation: 2,
        shadowColor: Color(0x14000000), // ~8% opacity black
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTextStyles.h4,
        toolbarHeight: 64,
        iconTheme: IconThemeData(color: AppColors.universityNavy),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 2,
        shadowColor: const Color(0x14000000), // Subtle shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Input Decoration (Forms)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.pureWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.academicBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
        ),
        labelStyle: AppTextStyles.bodyRegular.copyWith(color: AppColors.mediumGray),
        hintStyle: AppTextStyles.bodyRegular.copyWith(color: AppColors.mediumGray.withOpacity(0.7)),
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.errorRed),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.academicBlue,
          foregroundColor: AppColors.pureWhite,
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(0, 40), // Height 40px
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: AppTextStyles.label.copyWith(fontSize: 14),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.academicBlue,
          side: const BorderSide(color: AppColors.academicBlue, width: 1.5), // Slightly thicker for visibility
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: AppTextStyles.label.copyWith(fontSize: 14),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.academicBlue,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: AppTextStyles.label.copyWith(fontSize: 14),
        ),
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.academicBlue,
        foregroundColor: AppColors.pureWhite,
        elevation: 4,
        shape: CircleBorder(), 
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.mediumGray,
        size: 24,
      ),
    );
  }
}
