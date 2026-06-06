import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get homeTitle => TextStyle(
    color: AppColors.black,
    fontSize: 42.sp,
    fontWeight: FontWeight.w900,
    height: 1.02,
  );

  static TextStyle get heading => TextStyle(
    color: AppColors.black,
    fontSize: 39.sp,
    fontWeight: FontWeight.w900,
    height: 1.05,
  );

  static TextStyle get topBarTitle => TextStyle(
    color: AppColors.black,
    fontSize: 33.sp,
    fontWeight: FontWeight.w900,
    height: 1.05,
  );

  static TextStyle get settingsTitle => TextStyle(
    color: AppColors.black,
    fontSize: 28.sp,
    fontWeight: FontWeight.w900,
  );

  static TextStyle get body => TextStyle(
    color: AppColors.text,
    fontSize: 22.sp,
    fontWeight: FontWeight.w400,
    height: 1.16,
  );

  static TextStyle get homeSubtitle => TextStyle(
    color: AppColors.text,
    fontSize: 23.sp,
    fontWeight: FontWeight.w400,
    height: 1.18,
  );

  static TextStyle get categoryTitle => TextStyle(
    color: AppColors.black,
    fontSize: 29.sp,
    fontWeight: FontWeight.w900,
    height: 1.02,
  );

  static TextStyle get subGameTitle => TextStyle(
    color: AppColors.black,
    fontSize: 20.sp,
    fontWeight: FontWeight.w900,
    height: 1.04,
  );

  static TextStyle get playButton => TextStyle(
    color: AppColors.black,
    fontSize: 18.sp,
    fontWeight: FontWeight.w900,
  );

  static TextStyle get metric => TextStyle(
    color: AppColors.black,
    fontSize: 27.sp,
    fontWeight: FontWeight.w900,
  );

  static TextStyle get levelLabel => TextStyle(
    color: AppColors.black,
    fontSize: 17.sp,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get levelNumber => TextStyle(
    color: AppColors.black,
    fontSize: 34.sp,
    fontFamily: 'Moranga',
    fontWeight: FontWeight.w900,
  );

  static TextStyle get gameLevel => TextStyle(
    color: AppColors.black,
    fontSize: 26.sp,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get puzzle => TextStyle(
    color: AppColors.black,
    fontSize: 39.sp,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static TextStyle get equationLarge => TextStyle(
    color: AppColors.black,
    fontSize: 42.sp,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get keypadNumber => TextStyle(
    color: AppColors.black,
    fontSize: 39.sp,
    fontWeight: FontWeight.w900,
  );

  static TextStyle get keypadAction => TextStyle(
    color: AppColors.black,
    fontSize: 25.sp,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get wideAnswer => TextStyle(
    color: AppColors.black,
    fontSize: 32.sp,
    fontWeight: FontWeight.w900,
  );

  static TextStyle get dialogTitle => TextStyle(
    color: AppColors.black,
    fontSize: 30.sp,
    fontWeight: FontWeight.w900,
  );

  static TextStyle get dialogBody =>
      TextStyle(color: AppColors.text, fontSize: 25.sp, height: 1.2);

  static TextStyle get dialogButton => TextStyle(
    color: AppColors.black,
    fontSize: 27.sp,
    fontWeight: FontWeight.w900,
  );

  static TextStyle get settingsSection => TextStyle(
    color: AppColors.black,
    fontSize: 23.sp,
    fontWeight: FontWeight.w900,
  );

  static TextStyle get settingsLabel => TextStyle(
    color: AppColors.black,
    fontSize: 24.sp,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get settingsRow => TextStyle(
    color: AppColors.black,
    fontSize: 22.sp,
    fontWeight: FontWeight.w900,
  );
}
