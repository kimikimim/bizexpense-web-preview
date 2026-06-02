import 'package:flutter/material.dart';

const _fontFamily = 'NanumGothic';

abstract class AppText {
  
  static const TextStyle display = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyBold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmallBold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.5,
  );

  static const TextStyle label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle labelBold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle amountLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle amountMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const TextStyle amountSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.0,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.0,
  );
}

TextTheme buildAppTextTheme({required bool isDark}) {
  final baseColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
  final secondaryColor = isDark ? Colors.white70 : const Color(0xFF555555);
  final hintColor = isDark ? Colors.white38 : const Color(0xFF999999);

  return TextTheme(
    
    displayLarge: AppText.display.copyWith(color: baseColor),
    displayMedium: AppText.h1.copyWith(color: baseColor),
    displaySmall: AppText.h2.copyWith(color: baseColor),

    headlineLarge: AppText.h1.copyWith(color: baseColor),
    headlineMedium: AppText.h2.copyWith(color: baseColor),
    headlineSmall: AppText.h3.copyWith(color: baseColor),

    titleLarge: AppText.h3.copyWith(color: baseColor),
    titleMedium: AppText.bodyBold.copyWith(color: baseColor),
    titleSmall: AppText.bodySmallBold.copyWith(color: baseColor),

    bodyLarge: AppText.body.copyWith(color: baseColor),
    bodyMedium: AppText.bodySmall.copyWith(color: secondaryColor),
    bodySmall: AppText.caption.copyWith(color: hintColor),

    labelLarge: AppText.button.copyWith(color: baseColor),
    labelMedium: AppText.label.copyWith(color: secondaryColor),
    labelSmall: AppText.caption.copyWith(color: hintColor),
  );
}
