import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: false,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.yellow),
      fontFamily: 'Montserrat',
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontFamily: 'Montserrat'),
      ),
    );
  }
}
